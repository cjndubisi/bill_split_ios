//
//  HomeController.swift
//  BillSplit
//
//  Created by Chijioke on 5/26/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift

class HomeController: UITableViewController {
  let viewModel: HomeViewModel
  let disposeBag = DisposeBag()

  required init(viewModel: HomeViewModel) {
    self.viewModel = viewModel
    super.init(style: .plain)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let barItem = UIBarButtonItem()
    barItem.title = "Logout"
    navigationItem.rightBarButtonItem = barItem
    bindViewModel()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    set(title: "Groups")
    navigationController?.setNavigationBarOpaque()
  }

  func bindViewModel() {
    let refreshControl = UIRefreshControl()
    tableView.delegate = nil
    tableView.dataSource = nil
    tableView.refreshControl = refreshControl
    if let item = navigationItem.rightBarButtonItem {
      item.rx.tap
        .map { CoordinatorDelegate.navigate(.splash) }
        .bind(to: viewModel.coordinatorDelegate).disposed(by: disposeBag)
    }
    // Bind Refreshing
    refreshControl.rx.controlEvent(.valueChanged)
      .bind(to: viewModel.dataSource.reload).disposed(by: disposeBag)
    viewModel.dataSource.fetching.observeOn(MainScheduler.instance)
      .bind(to: refreshControl.rx.isRefreshing).disposed(by: disposeBag)

    // On Subscribe will fetch data from network.
    viewModel.dataSource.value
      .map({ [AnimatableSectionModel(model: "basiclist", items: $0)] })
      .observeOn(MainScheduler.instance)
      .bind(to: tableView.rx.items(dataSource: tableViewDataSource())).disposed(by: disposeBag)

    tableView.rx.modelSelected(Group.self)
      .map { CoordinatorDelegate.navigate(.groupDetail($0)) }
      .bind(to: viewModel.coordinatorDelegate).disposed(by: disposeBag)

    viewModel.dataSource.disposable.disposed(by: disposeBag)
  }

  private func tableViewDataSource() -> RxTableViewSectionedAnimatedDataSource<
    AnimatableSectionModel<String, Group>
  > {
    return RxTableViewSectionedAnimatedDataSource<
      AnimatableSectionModel<String, Group>
    >(configureCell: { (_, tableView, _, item) -> UITableViewCell in
      var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.resuseIdentifier)
      if cell == nil {
        cell = UITableViewCell(style: .value1, reuseIdentifier: UITableViewCell.resuseIdentifier)
      }
      cell.textLabel?.text = item.name
      cell.detailTextLabel?.text = String(format: NSLocalizedString("member_count", comment: ""), item.users.count)
      cell.selectionStyle = .none
      cell.accessoryType = .disclosureIndicator

      return cell
    })
  }
}

class HomeViewModel: ViewModel {
  let dataSource: DataSource<ListableClosureService<Group>>
  let service: GroupRequest
  // swiftlint:disable:next weak_delegate
  var coordinatorDelegate: AnyObserver<CoordinatorDelegate>!

  init(service: GroupRequest) {
    self.service = service
    dataSource = DataSource(
      source: ListableClosureService<Group> { [weak service] in service?.all() ?? .never() }
    )
  }
}
