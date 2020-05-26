//
//  HomeCoordinator.swift
//  BillSplit
//
//  Created by Chijioke on 5/25/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import UIKit

class HomeCoordinator: BaseCoordinator {
  // swiftlint:disable:next weak_delegate
  var parentDelegate: ((ApplicationCoordinatorDelegate) -> Void)!
  let service: GroupRequest

  required init(service: GroupRequest, navigationController: UINavigationController) {
    self.service = service
    super.init(navigationController: navigationController)
  }

  override func start() {
    let viewModel: HomeViewModel = HomeViewModel(service: service)
    let controller = HomeController(viewModel: viewModel)
    navigationController.setViewControllers([controller], animated: true)
  }
}
