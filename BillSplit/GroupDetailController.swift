//
//  GroupDetailController.swift
//  BillSplit
//
//  Created by Chijioke on 5/26/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift
import Stevia

extension UIViewController: NoBackTextController {}

class GroupDetailController: UITableViewController {
  let viewModel: GroupDetailViewModel
  let disposeBag = DisposeBag()

  private var tableHeader: GroupHeaderView!

  required init(viewModel: GroupDetailViewModel) {
    self.viewModel = viewModel
    super.init(style: .plain)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    removeBackText()
    setupHeader()
    bindViewModel()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.layoutIfNeeded()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarTransparent()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarOpaque()
  }

  private func setupHeader() {
    tableHeader = .init()
    let size = tableHeader.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    tableHeader.frame.size.height = size.height
    tableView.tableHeaderView = tableHeader
  }

  private func tableViewDataSource() -> RxTableViewSectionedAnimatedDataSource<
    AnimatableSectionModel<String, GroupDetailItem>
  > {
    return RxTableViewSectionedAnimatedDataSource<
      AnimatableSectionModel<String, GroupDetailItem>
    >(configureCell: { (_, tableView, _, item) -> UITableViewCell in
      let cell = tableView.dequeueReusableCell(
        withIdentifier: UITableViewCell.resuseIdentifier
      ) ?? UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.resuseIdentifier)
      let rightTextlabel = cell.accessoryView as? UILabel ?? UILabel()

      rightTextlabel.text = item.detailTitle
      rightTextlabel.font = .systemFont(ofSize: 12)
      rightTextlabel.numberOfLines = 2
      rightTextlabel.textAlignment = .right
      rightTextlabel.textColor = .lightGray
      rightTextlabel.sizeToFit()

      cell.textLabel?.text = item.title
      cell.detailTextLabel?.text = item.subtitle
      cell.detailTextLabel?.textColor = .lightGray
      cell.accessoryView = rightTextlabel
      cell.selectionStyle = .none

      return cell
    })
  }

  func bindViewModel() {
    tableView.delegate = nil
    tableView.dataSource = nil
    tableHeader.titleLabel.text = viewModel.title
    tableHeader.subtitleLabel.text = viewModel.subtitle
    tableHeader.addExpenseButton.rx.tap.observeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak viewModel] _ in
        viewModel?.coordinatorDelegate.onNext(.navigate(.expenseInput))
    }).disposed(by: disposeBag)
    tableHeader.balanceButton.rx.tap.observeOn(MainScheduler.instance)
      .subscribe(onNext: { _ in

    }).disposed(by: disposeBag)

    viewModel.dataSource.value
      .map({ [AnimatableSectionModel(model: "bills", items: $0)] })
      .bind(to: tableView.rx.items(dataSource: tableViewDataSource())).disposed(by: disposeBag)
  }
}

struct GroupDetailItem: Equatable, IdentifiableType {
  let title: String
  let subtitle: String
  let detailTitle: String
  var identity: String {
    return title + subtitle + detailTitle
  }
}

class GroupDetailViewModel: ViewModel {
  let title: String
  let subtitle: String
  // swiftlint:disable:next weak_delegate
  var coordinatorDelegate: AnyObserver<CoordinatorDelegate>!

  let service: GroupRequest
  private(set) var dataSource: DataSource<ListableClosureService<GroupDetailItem>>!

  init(service: GroupRequest, group: Group) {
    let id = group.id
    self.service = service
    title = group.name
    subtitle = """
    \(group.bills.count) Bills
    \(group.bills.count) members
    $\(group.bills.reduce(0.0, { $0 + $1.amount })) Total Expenses
    """
    dataSource = DataSource(
      source: ListableClosureService<GroupDetailItem> { [weak service] in
        service?.get(group: id).map({ [weak self] in self?.buildItems(group: $0) ?? [] }) ?? .never()
      }
    )
  }

  func buildItems(group: Group) -> [GroupDetailItem] {
    let users = group.users
    let userID = UserDefaults.standard.integer(forKey: Constants.userID)
    let currentUser = users.first(where: { $0.id == userID })!
    return group.bills.map { item in
      let amount = item.amount
      let payer = users.first(where: { $0.id == item.payerId })!
      let action = payer.id == currentUser.id ? "lent" : "borrowed"
      let perPerson = item.amount / Double(users.count)

      return GroupDetailItem(
        title: item.name,
        subtitle: "\(payer.name) paid $\(Double(round(100 * amount) / 100))",
        detailTitle: "you \(action)\n$\(perPerson * Double(users.count - 1))"
      )
    }
  }

  func add(expense: ExpenseRequest) -> Disposable {
    return service.add(expense: expense).map { _ in () }
      .observeOn(MainScheduler.instance)
      .asObservable().subscribe(dataSource.reload)
  }
}

private class GroupHeaderView: UIView {
  private(set) var titleLabel: UILabel!
  private(set) var subtitleLabel: UILabel!
  private(set) var addExpenseButton: UIButton!
  private(set) var balanceButton: UIButton!
  var horizontalButtonStack: UIStackView! {
    return balanceButton?.superview as? UIStackView
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    addExpenseButton = UIButton()
    balanceButton = UIButton()
    titleLabel = UILabel()
    subtitleLabel = UILabel()
    let buttonStack = UIStackView(arrangedSubviews: [addExpenseButton, balanceButton])

    sv(titleLabel, subtitleLabel, buttonStack)
    [titleLabel, subtitleLabel, horizontalButtonStack].forEach {
      // layout horizontally.
      $0.fillHorizontally(m: 40)
    }
    // height, layout vertically.
    layout(
      8,
      titleLabel!.height(40),
      8,
      subtitleLabel!.height(>=50),
      8,
      horizontalButtonStack!.height(>=50),
      8
    )

    titleLabel.numberOfLines = 1
    titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
    subtitleLabel.numberOfLines = 5
    subtitleLabel.font = .systemFont(ofSize: 12)
    addExpenseButton.setTitle("Add Expense", for: .normal)
    addExpenseButton.setTitleColor(.white, for: .normal)
    addExpenseButton.backgroundColor = .systemBlue
    balanceButton.setTitle("Balances", for: .normal)
    balanceButton.backgroundColor = .systemBlue
    balanceButton.setTitleColor(.white, for: .normal)
    buttonStack.spacing = 20
    buttonStack.distribution = .fillEqually

    buttonStack.subviews.forEach {
      $0.makeRound(radius: 4)
    }
  }
}
