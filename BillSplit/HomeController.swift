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
    tableView.register(DetailTableCell.self, forCellReuseIdentifier: DetailTableCell.resuseIdentifier)
    bindViewModel()
  }

  func bindViewModel() {
    let refreshControl = UIRefreshControl()
    tableView.delegate = nil
    tableView.dataSource = nil
    tableView.refreshControl = refreshControl

    // Bind Refreshing
    refreshControl.rx.controlEvent(.valueChanged)
      .bind(to: viewModel.dataSource.reload).disposed(by: disposeBag)
    viewModel.dataSource.fetching
      .bind(to: refreshControl.rx.isRefreshing).disposed(by: disposeBag)

    // On Subscribe will fetch data from network.
    viewModel.dataSource.value
      .map({ [AnimatableSectionModel(model: "basiclist", items: $0)] })
      .bind(to: tableView.rx.items(dataSource: tableViewDataSource())).disposed(by: disposeBag)
  }

  private func tableViewDataSource() -> RxTableViewSectionedAnimatedDataSource<
    AnimatableSectionModel<String, Group>
  > {
    return RxTableViewSectionedAnimatedDataSource<
      AnimatableSectionModel<String, Group>
    >(configureCell: { (_, tableView, index, item) -> UITableViewCell in
      let cell = tableView.dequeueReusableCell(withIdentifier: DetailTableCell.resuseIdentifier, for: index)
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

  init(service: GroupRequest) {
    self.service = service
    dataSource = DataSource(
      source: ListableClosureService<Group> { [weak service] in service?.all() ?? .never() }
    )
  }
}

private final class DetailTableCell: UITableViewCell {
  override init(style _: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: .value1, reuseIdentifier: reuseIdentifier)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
}
