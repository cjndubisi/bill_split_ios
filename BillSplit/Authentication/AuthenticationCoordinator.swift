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
  private var service: BillAPIService = BillAPIService()
  // swiftlint:disable:next weak_delegate
  var parentDelegate: ((ApplicationCoordinatorDelegate) -> Void)!

  override func start() {
    let viewModel = AuthViewModel()
    let controller = AuthenticationController(viewModel: viewModel)

    viewModel.coordinatorDelegate
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] in
        guard case let .navigate(scene) = $0 else { return }
        self?.route(to: scene)
    }).disposed(by: controller.disposeBag)

    navigationController.isNavigationBarHidden = true
    navigationController.setViewControllers([controller], animated: false)
  }

  // MARK: Router

  private func loginScene() {
    let viewModel = LoginViewModel(service: service)
    let controller = LoginController(viewModel: viewModel)
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

    // retains controller
    navigationController.pushViewController(controller, animated: true)
    viewModel.coordinatorDelegate = delegate.asObserver()
  }

  func signupScene() {
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

    // retains controller
    navigationController.pushViewController(controller, animated: true)
    viewModel.coordinatorDelegate = delegate.asObserver()
  }

  func route(to scene: Scene) {
    // ensure not animating
    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    switch scene {
    case .login: loginScene()
    case .signup: signupScene()
    case .home:
      parentDelegate?(.homeFlow)
    default:
      break
    }
  }
}
