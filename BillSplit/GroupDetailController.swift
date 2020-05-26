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
    AnimatableSectionModel<String, Bill>
  > {
    return RxTableViewSectionedAnimatedDataSource<
      AnimatableSectionModel<String, Bill>
    >(configureCell: { [unowned viewModel] (_, tableView, _, item) -> UITableViewCell in

      let amount = item.amount
      let payer = viewModel.users.first(where: { $0.id == item.payerId })!
      let action = payer.id == viewModel.currentUser.id ? "lent" : "borrowed"
      let perPerson = item.amount / Double(viewModel.users.count)
      let cell = tableView.dequeueReusableCell(
        withIdentifier: UITableViewCell.resuseIdentifier
      ) ?? UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.resuseIdentifier)
      let rightTextlabel = cell.accessoryView as? UILabel ?? UILabel()

      rightTextlabel.text = "you \(action)\n$\(perPerson * Double(viewModel.users.count - 1))"
      rightTextlabel.font = .systemFont(ofSize: 12)
      rightTextlabel.numberOfLines = 2
      rightTextlabel.textAlignment = .right
      rightTextlabel.textColor = .lightGray
      rightTextlabel.sizeToFit()

      cell.textLabel?.text = item.name
      cell.detailTextLabel?.text = "\(payer.name) paid $\(Double(round(100 * amount) / 100))"
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
    tableHeader.addExpenseButton.rx.tap.subscribe(onNext: { _ in

    }).disposed(by: disposeBag)
    tableHeader.balanceButton.rx.tap.subscribe(onNext: { _ in

    }).disposed(by: disposeBag)

    viewModel.dataSource.value
      .map({ [AnimatableSectionModel(model: "bills", items: $0)] })
      .bind(to: tableView.rx.items(dataSource: tableViewDataSource())).disposed(by: disposeBag)
  }
}

class GroupDetailViewModel: ViewModel {
  let title: String
  let subtitle: String
  let users: [User]
  private(set) lazy var currentUser: User = {
    let userID = UserDefaults.standard.integer(forKey: Constants.userID)
    return self.users.first(where: { $0.id == userID })!
  }()

  // swiftlint:disable:next weak_delegate
  var coordinatorDelegate: AnyObserver<CoordinatorDelegate>!

  let dataSource: DataSource<ListableClosureService<Bill>>
  let service: GroupRequest

  init(service: GroupRequest, group: Group) {
    let id = group.id
    self.service = service
    dataSource = DataSource(
      source: ListableClosureService<Bill> { [weak service] in service?.get(group: id).map({ $0.bills }) ?? .never() }
    )
    users = group.users
    title = group.name
    subtitle = """
    \(group.bills.count) Bills
    \(group.bills.count) memenbers
    $\(group.bills.reduce(0.0, { $0 + $1.amount })) Total Expenses
    """
  }

  func add(expense _: ExpenseRequest) {
    // add
    dataSource.reload.onNext(())
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
