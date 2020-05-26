//
//  SignUpController.swift
//  BillSplit
//
//  Created by Chijioke on 5/24/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import Eureka
import RxCocoa
import RxSwift

class SignUpController: FormViewController {
  let viewModel: SignUpViewModel
  let disposeBag = DisposeBag()

  required init(viewModel: SignUpViewModel) {
    self.viewModel = viewModel
    super.init(style: .plain)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = false
    tableView.layoutIfNeeded()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.largeTitleDisplayMode = .never
    removeBackText()
    tableView.separatorStyle = .none
    bindViewModel()
  }

  func bindViewModel() {
    form = viewModel.form()
  }
}

class SignUpViewModel: ViewModel {
  private(set) var name: String = ""
  private(set) var email: String = ""
  private(set) var password: String = ""

  private let service: AuthService

  // swiftlint:disable:next weak_delegate
  var coordinatorDelegate: AnyObserver<CoordinatorDelegate>!

  // View Actions
  let signupAction: AnyObserver<Void>

  private(set) var disposables: CompositeDisposable!

  init(service: AuthService) {
    let actionSubject = PublishSubject<Void>()

    self.service = service
    signupAction = actionSubject.asObserver()

    weak var weakSelf = self

    let actionToken = actionSubject
      .do(onNext: {
        weakSelf?.coordinatorDelegate.onNext(.startAnimating)
    })
      .flatMap { _ -> Single<AuthResponse> in
        guard let self = weakSelf else { return .never() }

        let params = AuthParameter(name: self.name, email: self.email, password: self.password)
        return self.service.signUp(params: params).catchError { _ in
          // TODO: Show Error
          weakSelf?.coordinatorDelegate.onNext(.endAnimating)
          return .never()
        }
      }
      .subscribe(onNext: { response in
        UserDefaults.standard.setValue(response.token, forKey: Constants.tokenKey)
        UserDefaults.standard.setValue(response.user.id, forKey: Constants.userID)
        weakSelf?.coordinatorDelegate.onNext(.navigate(.home))
    })

    disposables = CompositeDisposable(disposables: [actionToken])
  }

  func form() -> Form {
    let form = Form()
    weak var weakSelf = self

    TextInputRow.defaultOnRowValidationChanged = { cell, row in
      let color = !row.isValid ? UIColor.red.withAlphaComponent(0.1) : .white
      cell.backgroundColor = color
    }

    form +++ Section()
      <<< TextInputRow(name: "Name").cellSetup({ _, row in
        row.add(rule: RuleRequired(msg: "Name is required"))
        row.add(rule: RuleMinLength(minLength: 3))
      }).onChange({ row in
        weakSelf?.name = row.value ?? ""
      })
      <<< TextInputRow(name: "Email").cellSetup({ _, row in
        row.add(rule: RuleEmail())
        row.add(rule: RuleRequired(msg: "Email is Required"))
      }).onChange({ row in
        weakSelf?.email = row.value ?? ""
      })
      <<< TextInputRow(name: "Password")
      .cellSetup({ _, row in
        row.add(rule: RuleRequired(msg: "Password is required"))
        })
      .cellUpdate({ cell, _ in
        cell.inputTextField.isSecureTextEntry = true
        })
      .onChange({ row in
        weakSelf?.password = row.value ?? ""
        })
      +++ Section()
      <<< ButtonRow("signup", { row in
        row.title = "Sign Up"
      }).onCellSelection({ [weak self, unowned form] _, _ in
        let errors = form.validate()
        guard errors.isEmpty else { return }
        self?.signupAction.onNext(())
      })

    return form
  }
}
