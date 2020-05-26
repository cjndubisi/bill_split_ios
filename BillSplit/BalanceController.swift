//
//  BalanceController.swift
//  BillSplit
//
//  Created by Chijioke on 5/26/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import UIKit

class BalanceController: UITableViewController {
  let viewModel: BalanceViewModel

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
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarTransparent()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarOpaque()
  }
}

struct BalanceItem {
  let title: String
  let subtitle: String
}

class BalanceViewModel {

  let balances: [User:Payment]
  init(group: Group) {
    self.balances = BalanceResolver().resolve(from: group)
  }

  func title(for user: User) -> NSAttributedString {
    let balances = self.balances
    let gets = balances[user]?.gets.reduce(0.0) {acc, next in acc + next.value } ?? 0.0
    let debts = balances[user]?.debts.reduce(0.0) {acc, next in acc + next.value } ?? 0.0

    let isGreater = gets >= debts
    let verb = isGreater ? "gets back" : "owes"
    let amount = isGreater ? "$\(Double(round(100 * gets) / 100))" : "$\(Double(round(100 * debts) / 100))"
    let color = isGreater ? UIColor.green : UIColor.orange
    let title = "\(user) \(verb) \(amount)"

    let attributedTitle = NSMutableAttributedString(
      string: title,
      attributes: [
        .font : UIFont.systemFont(ofSize: 14)
      ]
    )

    attributedTitle.addAttributes([.foregroundColor: color.withAlphaComponent(0.7)],
      range: (title as NSString).range(of: amount))

    return NSAttributedString(attributedString: attributedTitle)
  }

  func subtitle(for user: User) -> String {
    let balances = self.balances
    let gets = balances[user]?.gets ?? [:]
    let debts = balances[user]?.debts ?? [:]

    let inflow = gets.compactMap({(next, index) -> String? in
      guard let amount = gets[next], amount != 0 else {
        return nil
      }
      return "\(next) owes $\(Double(round(100 * abs(amount)) / 100)) to \(user)"
    }).joined(separator: "\n")

    let outflow = debts.compactMap({(next, index) -> String? in
      guard let amount = debts[next], amount != 0 else {
        return nil
      }
      return "\(next) owes $\(Double(round(100 * abs(amount)) / 100)) to \(user)"
    }).joined(separator: "\n")

    return inflow + "\n" + outflow
  }
}
