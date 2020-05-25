//
//  HomeCoordinator.swift
//  BillSplit
//
//  Created by Chijioke on 5/25/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import RxCocoa
import RxSwift

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

class HomeController: UITableViewController {
  let viewModel: HomeViewModel

  required init(viewModel: HomeViewModel) {
    self.viewModel = viewModel
    super.init(style: .plain)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

protocol GroupRequest: AnyObject {
  func all() -> Single<[Group]>
}

class HomeViewModel: ViewModel {
  let dataSource: DataSource<ListableClosureService<Group>>
  let service: GroupRequest

  init(service: GroupRequest) {
    self.service = service
    dataSource = DataSource(
      source: ListableClosureService<Group> { [weak service] in service?.all() ?? .never() }
    )
  }
}
