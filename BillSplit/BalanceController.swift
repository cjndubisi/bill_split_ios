//
//  BalanceController.swift
//  BillSplit
//
//  Created by Chijioke on 5/26/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import RxCocoa
import RxDataSources
import RxSwift

class BalanceController: UITableViewController {
  let viewModel: BalanceViewModel
  let disposeBag = DisposeBag()

  required init(viewModel: BalanceViewModel) {
    self.viewModel = viewModel
    super.init(style: .plain)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    removeBackText()
    bindViewModel()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarTransparent()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarOpaque()
  }

  func bindViewModel() {
    tableView.delegate = nil
    tableView.dataSource = nil
    viewModel.dataSource.value
      .map({ [AnimatableSectionModel(model: "Balance", items: $0)] })
      .bind(to: tableView.rx.items(dataSource: tableViewDataSource())).disposed(by: disposeBag)
  }

  private func tableViewDataSource() -> RxTableViewSectionedAnimatedDataSource<
    AnimatableSectionModel<String, BalanceItem>
  > {
    return RxTableViewSectionedAnimatedDataSource<
      AnimatableSectionModel<String, BalanceItem>
    >(configureCell: { (_, tableView, _, item) -> UITableViewCell in

      let cell = tableView.dequeueReusableCell(
        withIdentifier: UITableViewCell.resuseIdentifier
      ) ?? UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.resuseIdentifier)

      cell.textLabel?.attributedText = item.title
      cell.detailTextLabel?.text = item.subtitle
      cell.detailTextLabel?.numberOfLines = 0
      cell.detailTextLabel?.textColor = .lightGray
      cell.selectionStyle = .none

      return cell
    })
  }
}

struct BalanceItem: Equatable, IdentifiableType {
  let title: NSAttributedString
  let subtitle: String

  var identity: String {
    return title.string + subtitle
  }
}

class BalanceViewModel {
  private(set) var dataSource: DataSource<ListableClosureService<BalanceItem>>!

  init(group: Group) {
    let balances = BalanceResolver().resolve(from: group)
    let inital = balances.map({ item in
      BalanceItem(title: title(for: item.key, payment: item.value),
                  subtitle: subtitle(for: item.key, payment: item.value))
    })
    dataSource = DataSource(source: ListableClosureService<BalanceItem> { .never() },
                            initial: inital)
  }

  func title(for user: User, payment: Payment) -> NSAttributedString {
    let gets = payment.gets.reduce(0.0) { acc, next in acc + next.value }
    let debts = payment.debts.reduce(0.0) { acc, next in acc + next.value }

    let isGreater = gets >= debts
    let verb = isGreater ? "gets back" : "owes"
    let amount = isGreater ? "$\(Double(round(100 * gets) / 100))" : "$\(Double(round(100 * debts) / 100))"
    let color = isGreater ? UIColor.green : UIColor.orange
    let title = "\(user.name) \(verb) \(amount)"

    let attributedTitle = NSMutableAttributedString(
      string: title,
      attributes: [
        .font: UIFont.systemFont(ofSize: 14),
      ]
    )

    attributedTitle.addAttributes([.foregroundColor: color.withAlphaComponent(0.7)],
                                  range: (title as NSString).range(of: amount))

    return NSAttributedString(attributedString: attributedTitle)
  }

  func subtitle(for user: User, payment: Payment) -> String {
    let gets = payment.gets
    let debts = payment.debts
    let inflow = gets.compactMap({ (next, _) -> String? in
      guard let amount = gets[next], amount != 0 else {
        return nil
      }
      return "\(next.name) owes $\(Double(round(100 * abs(amount)) / 100)) to \(user.name)"
    }).joined(separator: "\n")

    let outflow = debts.compactMap({ (next, _) -> String? in
      guard let amount = debts[next], amount != 0 else {
        return nil
      }
      return "\(next.name) owes $\(Double(round(100 * abs(amount)) / 100)) to \(user.name)"
    }).joined(separator: "\n")

    return inflow + "\n" + outflow
  }
}
