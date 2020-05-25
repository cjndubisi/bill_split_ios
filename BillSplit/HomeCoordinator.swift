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

  override func start() {
    let controller = UITableViewController(style: .plain)
    navigationController.setViewControllers([controller], animated: true)
  }
}

class HomeViewModel: ViewModel {}
