//
//  Extensions.swift
//  BillSplit
//
//  Created by Chijioke on 5/26/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

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

  func makeRound(radius: CGFloat? = nil) {
    layoutIfNeeded()
    layer.cornerRadius = radius ?? bounds.height / 2.0
    layer.masksToBounds = true
  }
}

extension UITableViewCell {
  static var resuseIdentifier: String {
    return String(describing: Self.self)
  }
}

extension UINavigationController {
  func setNavigationBarTransparent() {
    isNavigationBarHidden = false
    navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationBar.shadowImage = UIImage()
  }

  func setNavigationBarOpaque() {
    isNavigationBarHidden = false
    navigationBar.setBackgroundImage(nil, for: .default)
    navigationBar.shadowImage = nil
  }
}

extension UIViewController {
  func showAlert(title: String, message: String,
                 handler: ((UIAlertAction) -> Void)? = nil) {
    let alert = UIAlertController(title: title,
                                  message: message,
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
    present(alert, animated: true, completion: nil)
  }
}

protocol NoBackTextController: UIViewController {}

extension NoBackTextController {
  func removeBackText() {
    title = ""
    navigationController?.navigationBar.topItem?.title = " "
  }

  func set(title: String) {
    self.title = title
    navigationController?.navigationBar.topItem?.title = title
  }
}
