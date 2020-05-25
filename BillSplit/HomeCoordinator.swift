//
//  HomeCoordinator.swift
//  BillSplit
//
//  Created by Chijioke on 5/25/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import Foundation

class HomeCoordinator: BaseCoordinator {
  override func start() {
    let controller = UITableViewController(style: .plain)
    navigationController.setViewControllers([controller], animated: true)
  }
}
