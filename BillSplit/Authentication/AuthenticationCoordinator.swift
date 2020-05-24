//
//  AuthenticationCoordinator.swift
//  BillSplit
//
//  Created by Chijioke on 5/24/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import UIKit

class AuthenticationCoordinator: BaseCoordinator {
  private var controller: AuthenticaitonController!
  private var loginController: UIViewController = UIViewController(nibName: nil, bundle: nil)
  private var signUpController: UIViewController = UIViewController(nibName: nil, bundle: nil)

  override func start() {
    let viewModel = AuthViewModel()
    let controller = AuthenticaitonController(viewModel: viewModel)

    viewModel.actionObservable.subscribe(onNext: { [weak self] in
      switch $0 {
      case .login: self?.loginFlow()
      case .signup: self?.signupFlow()
      }
        }).disposed(by: controller.disposeBag)

    self.controller = controller

    navigationController.setViewControllers([controller], animated: false)
  }

  // MARK: Router

  private func loginFlow() {
    navigationController.pushViewController(loginController, animated: true)
  }

  func signupFlow() {
    navigationController.pushViewController(signUpController, animated: true)
  }
}
