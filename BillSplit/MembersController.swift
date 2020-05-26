//
//  MembersController.swift
//  BillSplit
//
//  Created by Chijioke on 5/26/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift

class MembersController: UITableViewController {
  let viewModel: MembersViewModel
  let disposeBag = DisposeBag()

  required init(viewModel: MembersViewModel) {
    self.viewModel = viewModel
    super.init(style: .plain)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let barItem = UIBarButtonItem()

    barItem.title = "Add Member"
    navigationItem.rightBarButtonItem = barItem
    navigationItem.largeTitleDisplayMode = .always

    bindViewModel()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    set(title: "Members")
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
      .map({ [AnimatableSectionModel(model: "memberList", items: $0)] })
      .observeOn(MainScheduler.instance)
      .bind(to: tableView.rx.items(dataSource: tableViewDataSource())).disposed(by: disposeBag)

    tableView.rx.modelSelected(Group.self)
      .map { CoordinatorDelegate.navigate(.groupDetail($0)) }
      .bind(to: viewModel.coordinatorDelegate).disposed(by: disposeBag)

    viewModel.dataSource.disposable.disposed(by: disposeBag)
  }

  private func tableViewDataSource() -> RxTableViewSectionedAnimatedDataSource<
    AnimatableSectionModel<String, User>
  > {
    return RxTableViewSectionedAnimatedDataSource<
      AnimatableSectionModel<String, User>
    >(configureCell: { (_, tableView, _, item) -> UITableViewCell in
      var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.resuseIdentifier)
      if cell == nil {
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.resuseIdentifier)
      }
      cell.textLabel?.text = item.name
      cell.detailTextLabel?.text = item.email
      cell.selectionStyle = .none

      return cell
    })
  }
}

class MembersViewModel: ViewModel {
  let dataSource: DataSource<ListableClosureService<User>>
  let service: GroupRequest
  // swiftlint:disable:next weak_delegate
  var coordinatorDelegate: AnyObserver<CoordinatorDelegate>!

  init(service: GroupRequest, group: Group) {
    let id = group.id
    self.service = service
    dataSource = DataSource(
      source: ListableClosureService<User> { [weak service] in service?.get(group: id).map({ $0.users }) ?? .never() }
    )
  }

  func add(member request: MemberRequest) -> Disposable {
    return service.add(member: request).map { _ in () }
      .observeOn(MainScheduler.instance)
      .catchError({ [weak self] error in
        self?.coordinatorDelegate.onNext(.error(error))
        return .never()
      })
      .asObservable().subscribe(dataSource.reload)
  }
}
