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
    let viewModel: GroupDetailViewModel = .init(service: service, group: group)
    let controller = GroupDetailController(viewModel: viewModel)
    let alertController = UIAlertController(title: "Add Expense", message: nil, preferredStyle: .alert)

    // Do not capture `group` in closure.
    let groupId = group.id
    let participants = group.users.map({ $0.id })
    let userID = UserDefaults.standard.integer(forKey: Constants.userID)

    alertController.addTextField { textField in
      textField.placeholder = "Name"
      textField.tag = 1
    }
    alertController.addTextField { textField in
      textField.placeholder = "$0.0"
      textField.tag = 2
      textField.keyboardType = .decimalPad
    }
    alertController.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
    alertController.addAction(.init(title: "Add", style: .default) { [unowned alertController, weak viewModel] _ in
      let nameField = alertController.textFields?.first(where: { $0.tag == 1 })
      let amountField = alertController.textFields?.first(where: { $0.tag == 2 })
      guard let number = NumberFormatter().number(from: amountField!.text!),
        !nameField!.text!.isEmpty else { return }
      let amount = number.doubleValue
      let request = ExpenseRequest(amount: amount, payerId: userID, groupId: groupId, participants: participants)
      viewModel?.add(expense: request)
    })

    delegate.subscribe(onNext: { [weak self] in
      switch $0 {
      case let .navigate(scene):
        guard case .expenseInput = scene else { self?.route(to: scene); return }

      default: break
      }
    }).disposed(by: controller.disposeBag)
    navigationController.pushViewController(controller, animated: true)
  }

  func route(to scene: Scene) {
    switch scene {
    case let .groupDetail(id): groupDetailScene(with: id)
    default: break
    }
  }
}
