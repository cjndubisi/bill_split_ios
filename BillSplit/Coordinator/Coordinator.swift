//
//  Coordinator.swift
//  BillSplit
//
//  Created by Chijioke on 5/24/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import UIKit

protocol Coordinator {
  func start()
  var finish: (() -> Void)! { get }
}

class BaseCoordinator: Coordinator {
  var finish: (() -> Void)!

  var navigationController: UINavigationController!

  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }

  func start() {}
}

enum Scene {
  case splash
  case login
  case signup
  case home
  case group
  case groupDetail(Group)
  case expenseInput
  case groupBalance(Group)
}

extension Scene: Equatable {}

enum CoordinatorDelegate {
  case navigate(Scene)
  case startAnimating
  case endAnimating
}

protocol ViewModel {}
