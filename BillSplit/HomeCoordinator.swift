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

  // MARK: - Routes

  private func groupDetailScene(with group: Group) {
    let viewModel: GroupDetailViewModel = .init(service: service, group: group)
    let controller = GroupDetailController(viewModel: viewModel)
    let alertController = expenseInput(for: group, viewModel: viewModel, controller: controller)

    viewModel.coordinatorDelegate = delegate.asObserver()
    delegate.subscribe(onNext: { [weak self] in
      switch $0 {
      case let .navigate(scene):
        switch scene {
        case .expenseInput:
          self?.navigationController.present(alertController, animated: true, completion: nil)
        case let .groupBalance(group):
          self?.balanceScene(for: group)
        default:
          break
        }
      default: break
      }
    }).disposed(by: controller.disposeBag)

    navigationController.pushViewController(controller, animated: true)
  }

  func balanceScene(for group: Group) {
    let viewModel = BalanceViewModel(group: group)
    let controller = BalanceController(viewModel: viewModel)

    navigationController.pushViewController(controller, animated: true)
  }

  private func expenseInput(for group: Group,
                            viewModel: GroupDetailViewModel,
                            controller: GroupDetailController) -> UIViewController {
    let groupId = group.id
    let participants = group.users.map({ $0.id })
    let userID = UserDefaults.standard.integer(forKey: Constants.userID)
    let alertController = UIAlertController(title: "Add Expense", message: nil, preferredStyle: .alert)

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
    alertController.addAction(.init(title: "Add", style: .default) {
      [unowned alertController,
       unowned controller,
       weak viewModel] _ in

      let nameField = alertController.textFields?.first(where: { $0.tag == 1 })
      let amountField = alertController.textFields?.first(where: { $0.tag == 2 })

      guard let number = NumberFormatter().number(from: amountField!.text!),
        let name = nameField?.text, !name.isEmpty
      else { return }

      let amount = number.doubleValue
      let request = ExpenseRequest(
        name: name,
        amount: amount,
        payerId: userID,
        groupId: groupId,
        participants: participants
      )

      viewModel?.add(expense: request).disposed(by: controller.disposeBag)
    })

    return alertController
  }

  func route(to scene: Scene) {
    switch scene {
    case let .groupDetail(id): groupDetailScene(with: id)
    case .splash:
      parentDelegate?(.authFlow)
    default: break
    }
  }
}
