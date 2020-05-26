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

    inputNameLabel.height(20).fillHorizontally(m: 30)
    inputTextField.height(30).fillHorizontally(m: 30)
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
    inputTextField.autocapitalizationType = .none
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
  func textFieldDidBeginEditing(_: UITextField) {
    backgroundColor = .white
    row.cleanValidationErrors()
  }

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

  override func updateCell() {
    super.updateCell()
    validationOptions = .validatesOnDemand
  }
}
