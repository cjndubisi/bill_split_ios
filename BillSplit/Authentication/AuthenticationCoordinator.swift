//
//  AuthenticationCoordinator.swift
//  BillSplit
//
//  Created by Chijioke on 5/24/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import NVActivityIndicatorView
import RxSwift
import UIKit

class AuthenticationCoordinator: BaseCoordinator {
  private var controller: AuthenticationController!
  private lazy var loginController: UIViewController = UIViewController(nibName: nil, bundle: nil)
  private weak var signUpController: SignUpController!

  override func start() {
    let viewModel = AuthViewModel()
    let controller = AuthenticationController(viewModel: viewModel)

    viewModel.actionObservable
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: {
        switch $0 {
        case .login: self.loginFlow()
        case .signup: self.signupFlow()
        }
    }).disposed(by: controller.disposeBag)

    self.controller = controller
    navigationController.isNavigationBarHidden = true
    navigationController.setViewControllers([controller], animated: false)
  }

  // MARK: Router

  private func loginFlow() {
    navigationController.pushViewController(loginController, animated: true)
  }

  private func homeFlow() {
    // finish this coordintator
    // start home coordinator with nav.setViewController
  }

  func signupFlow() {
    let service = BillAPIService()
    let viewModel = SignUpViewModel(service: service)
    let controller = SignUpController(viewModel: viewModel)
    let delegate = PublishSubject<CoordinatorDelegate>()

    delegate.subscribe(onNext: { [weak self] in
      switch $0 {
      case .startAnimating:
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(.init())
      case .endAnimating:
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
      case let .navigate(scene):
        self?.route(to: scene)
      }
    }).disposed(by: controller.disposeBag)

    navigationController.pushViewController(controller, animated: true)
    viewModel.coordinatorDelegate = delegate.asObserver()

    signUpController = controller
  }

  func route(to scene: Scene) {
    switch scene {
    case .home:
      homeFlow()
    default: break
    }
  }
}
