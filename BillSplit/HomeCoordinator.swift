//
//  HomeCoordinator.swift
//  BillSplit
//
//  Created by Chijioke on 5/25/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import Eureka
import RxSwift
import Stevia

class HomeCoordinator: BaseCoordinator {
  // swiftlint:disable weak_delegate
  var parentDelegate: ((ApplicationCoordinatorDelegate) -> Void)!
  // swiftlint:enable weak_delegate

  let service: GroupRequest

  required init(service: GroupRequest, navigationController: UINavigationController) {
    self.service = service
    super.init(navigationController: navigationController)
  }

  override func start() {
    let viewModel: HomeViewModel = HomeViewModel(service: service)
    let controller = HomeController(viewModel: viewModel)
    let delegate = PublishSubject<CoordinatorDelegate>()

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
    let delegate = PublishSubject<CoordinatorDelegate>()

    viewModel.coordinatorDelegate = delegate.asObserver()
    delegate.subscribe(onNext: { [weak self] in
      guard case let .navigate(scene) = $0 else { return }
      if case .expenseInput = scene {
        self?.navigationController.present(alertController, animated: true, completion: nil)
        return
      }
      self?.route(to: scene)
    }).disposed(by: controller.disposeBag)

    navigationController.pushViewController(controller, animated: true)
  }

  func balanceScene(for group: Group) {
    let viewModel = BalanceViewModel(group: group)
    let controller = BalanceController(viewModel: viewModel)

    navigationController.pushViewController(controller, animated: true)
  }

  func membersScene(for group: Group) {
    let viewModel = MembersViewModel(service: service, group: group)
    let controller = MembersController(viewModel: viewModel)
    let alertController = addMember(to: group, viewModel: viewModel, controller: controller)
    let delegate = PublishSubject<CoordinatorDelegate>()

    viewModel.coordinatorDelegate = delegate.asObserver()
    delegate.subscribe(onNext: { [weak self] in
      guard case let .navigate(scene) = $0 else { return }
      if case .addMember = scene {
        self?.navigationController.present(alertController, animated: true, completion: nil)
        return
      }
      self?.route(to: scene)
    }).disposed(by: controller.disposeBag)

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

  // TODO: Clean up duplicate.
  private func addMember(to group: Group,
                         viewModel: MembersViewModel,
                         controller: MembersController) -> UIViewController {
    let groupId = group.id
    let alertController = UIAlertController(title: "Add Member", message: nil, preferredStyle: .alert)

    alertController.addTextField { textField in
      textField.placeholder = "Name"
      textField.tag = 1
    }
    alertController.addTextField { textField in
      textField.placeholder = "Email"
      textField.tag = 2
      textField.keyboardType = .decimalPad
    }
    alertController.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
    alertController.addAction(.init(title: "Add", style: .default) {
      [unowned alertController,
       unowned controller,
       weak viewModel] _ in

      let nameField = alertController.textFields?.first(where: { $0.tag == 1 })
      let emailField = alertController.textFields?.first(where: { $0.tag == 2 })

      guard let email = emailField?.text!, RuleEmail().isValid(value: email) == nil,
        let name = nameField?.text, !name.isEmpty
      else { return }

      let request = MemberRequest(
        name: name,
        email: email,
        groupId: groupId
      )

      viewModel?.add(member: request).disposed(by: controller.disposeBag)
    })

    return alertController
  }

  func route(to scene: Scene) {
    switch scene {
    case let .groupDetail(id): groupDetailScene(with: id)
    case .splash:
      parentDelegate?(.authFlow)
    case let .groupBalance(group):
      balanceScene(for: group)
    case let .members(group):
      membersScene(for: group)
    default: break
    }
  }
}
