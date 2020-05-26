//
//  HomeCoordinator.swift
//  BillSplit
//
//  Created by Chijioke on 5/25/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import RxSwift
import Stevia

class HomeCoordinator: BaseCoordinator {
  // swiftlint:disable weak_delegate
  var parentDelegate: ((ApplicationCoordinatorDelegate) -> Void)!
  let delegate = PublishSubject<CoordinatorDelegate>()
  // swiftlint:enable weak_delegate

  let service: GroupRequest

  required init(service: GroupRequest, navigationController: UINavigationController) {
    self.service = service
    super.init(navigationController: navigationController)
  }

  override func start() {
    let viewModel: HomeViewModel = HomeViewModel(service: service)
    let controller = HomeController(viewModel: viewModel)

    viewModel.coordinatorDelegate = delegate.asObserver()
    delegate.subscribe(onNext: { [weak self] in
      switch $0 {
      case let .navigate(scene):
        self?.route(to: scene)
      default: break
      }
    }).disposed(by: controller.disposeBag)
    navigationController.setViewControllers([controller], animated: true)
  }

  // MARK: - Router

  private func groupDetailScene(with group: Group) {
    let viewModel: GroupDetailViewModel = .init(group: group)
    let controller = GroupDetailController(viewModel: viewModel)
    navigationController.pushViewController(controller, animated: true)
  }

  func route(to scene: Scene) {
    switch scene {
    case let .groupDetail(id): groupDetailScene(with: id)
    default: break
    }
  }
}
