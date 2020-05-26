//
//  LoginController.swift
//  BillSplit
//
//  Created by Chijioke on 5/24/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import Eureka
import RxCocoa
import RxSwift

class LoginController: FormViewController {
  let viewModel: LoginViewModel
  let disposeBag = DisposeBag()

  required init(viewModel: LoginViewModel) {
    self.viewModel = viewModel
    super.init(style: .plain)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = false
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.separatorStyle = .none
    bindViewModel()
  }

  func bindViewModel() {
    form = viewModel.form()
  }
}

class LoginViewModel: ViewModel {
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

        let params = AuthParameter(email: self.email, password: self.password)
        return self.service.login(params: params).catchError { _ in
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
      <<< ButtonRow("Login", { row in
        row.title = "Login"
      }).onCellSelection({ [weak self, unowned form] _, _ in
        let errors = form.validate()
        guard errors.isEmpty else { return }
        self?.signupAction.onNext(())
      })

    return form
  }
}
