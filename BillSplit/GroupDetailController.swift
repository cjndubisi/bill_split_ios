//
//  GroupDetailController.swift
//  BillSplit
//
//  Created by Chijioke on 5/26/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import Stevia
import RxSwift
import RxCocoa

protocol NoBackTextController: UIViewController {}

extension NoBackTextController {
  func removeBackText() {
    title = ""
    navigationController?.navigationBar.topItem?.title = " "
  }
}

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
    tableView.tableHeaderView?.isUserInteractionEnabled = true
    tableHeader.isUserInteractionEnabled = true
    tableView.contentInset.top = -50
  }

  func bindViewModel() {
    tableHeader.titleLabel.text = viewModel.title
    tableHeader.subtitleLabel.text = viewModel.subtitle
    tableHeader.addExpenseButton.rx.tap.subscribe(onNext: { _ in

    }).disposed(by: disposeBag)
    tableHeader.balanceButton.rx.tap.subscribe(onNext: { _ in

    }).disposed(by: disposeBag)
  }
}

class GroupDetailViewModel: ViewModel {
  let title: String
  let subtitle: String

  // swiftlint:disable:next weak_delegate
  var coordinatorDelegate: AnyObserver<CoordinatorDelegate>!
  
  init(group: Group) {
    title = group.name
    subtitle = """
    \(group.bills.count) Bills
    \(group.bills.count) memenbers
    $\(group.bills.reduce(0.0, { $0 + $1.amount })) Total Expenses
    """
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
