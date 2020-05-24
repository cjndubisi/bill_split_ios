//
//  TextInputRow.swift
//  BillSplit
//
//  Created by Chijioke on 5/24/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import Eureka
import Stevia

class TextInputCell: Cell<String>, CellType {
  private(set) var inputTextField: UITextField!
  private(set) var inputNameLabel: UILabel!

  required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  fileprivate var inputRow: TextInputRow? { return row as? TextInputRow }

  override func setup() {
    super.setup()
    inputTextField = UITextField()
    inputNameLabel = UILabel()

    sv(inputNameLabel, inputTextField)
    equal(widths: inputNameLabel, inputTextField)

    inputTextField.height(20).fillHorizontally(m: 30)
    inputNameLabel.height(30).fillHorizontally(m: 30)
    layout(8, inputNameLabel!, 10, inputTextField!, 8)

    inputNameLabel.font = .systemFont(ofSize: 12)
    inputNameLabel.textColor = .gray

    height = { 70 }
    selectionStyle = .none

    inputTextField.delegate = self
  }

  override open func update() {
    // super.update() // don't call super to void detailTextView
    selectionStyle = .none
    inputNameLabel.text = row.tag
    inputTextField.text = row.displayValueFor?(row.value)
      ?? (row as? NoValueDisplayTextConformance)?.noValueDisplayText
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    inputTextField.addBorder(toSide: .bottom, withColor: .lightGray, andThickness: 1)
  }

  override open func cellCanBecomeFirstResponder() -> Bool {
    return canBecomeFirstResponder
  }

  override open var canBecomeFirstResponder: Bool {
    return !row.isDisabled
  }

  deinit {
    inputTextField.delegate = nil
  }
}

extension TextInputCell: UITextFieldDelegate {
  func textFieldDidEndEditing(_ textField: UITextField) {
    row.value = textField.text
    formViewController()?.endEditing(of: self)
    formViewController()?.textInputDidEndEditing(textField, cell: self)
  }
}

final class TextInputRow: Row<TextInputCell>, NoValueDisplayTextConformance, RowType {
  var noValueDisplayText: String?

  convenience init(name: String) {
    self.init(tag: name)
    setup()
  }

  required init(tag: String?) {
    super.init(tag: tag)

    setup()
  }

  private func setup() {
    cellProvider = .init()
  }
}

import UIKit
extension UIView {
  enum ViewSide {
    case left, right, top, bottom
  }

  func addBorder(toSide side: ViewSide,
                 withColor color: UIColor,
                 andThickness thickness: CGFloat,
                 padding: CGFloat = 0) {
    let name = "LineBorder\(side)"
    let border = layer.sublayers?.filter({ $0.name == name }).first ?? CALayer()
    border.name = name

    border.backgroundColor = color.cgColor
    let origin = bounds.origin
    let size = bounds.size

    switch side {
    case .left:
      border.frame = CGRect(x: origin.x, y: origin.y + padding / 2,
                            width: thickness, height: size.height - padding)
    case .right:
      border.frame = CGRect(x: size.width - thickness, y: origin.y + padding / 2,
                            width: thickness, height: size.height - padding)
    case .top:
      border.frame = CGRect(x: origin.x + padding / 2, y: origin.y,
                            width: size.width - padding, height: thickness)
    case .bottom:
      border.frame = CGRect(x: origin.x + padding / 2, y: size.height - thickness,
                            width: size.width + padding, height: thickness)
    }
    layer.addSublayer(border)
  }
}
