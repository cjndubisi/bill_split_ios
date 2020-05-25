//
//  AuthenticationController.swift
//  BillSplit
//
//  Created by Chijioke on 5/24/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import RxCocoa
import RxSwift
import Stevia
class AuthViewModel: ViewModel {
  let actionObserver: AnyObserver<Action>
  let coordinatorDelegate: Observable<CoordinatorDelegate>

  enum Action {
    case signup
    case login
  }

  init() {
    let actionSubject = PublishSubject<Action>()

    coordinatorDelegate = actionSubject.map {
      switch $0 {
      case .signup: return .navigate(.signup)
      case .login: return .navigate(.login)
      }
    }
    actionObserver = actionSubject.asObserver()
  }
}

class AuthenticationController: UIViewController {
  var viewModel: AuthViewModel!
  let disposeBag = DisposeBag()

  @IBOutlet var signupBtn: UIButton!
  @IBOutlet var loginBtn: UIButton!

  init(viewModel: AuthViewModel) {
    super.init(nibName: "AuthenticationController", bundle: .main)
    self.viewModel = viewModel
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.isNavigationBarHidden = true
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    bindViewModel()
  }

  // MARK: ViewModel Binding

  func bindViewModel() {
    signupBtn.rx.tap.map({ .signup })
      .bind(to: viewModel.actionObserver).disposed(by: disposeBag)

    loginBtn.rx.tap.map({ .login })
      .bind(to: viewModel.actionObserver).disposed(by: disposeBag)
  }
}
