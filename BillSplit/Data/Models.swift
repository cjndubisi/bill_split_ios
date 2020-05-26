//
//  Models.swift
//  BillSplit
//
//  Created by Chijioke on 5/25/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import Foundation

struct User: Codable {
  var id: Int
  let name: String
  let email: String
}

extension User: Equatable {
  static func == (lhs: User, rhs: User) -> Bool {
    lhs.id == rhs.id && lhs.name == rhs.name && lhs.email == rhs.email
  }
}

extension User: Hashable {}

struct Bill: Codable {
  let id: Int
  let name: String
  let amount: Double
  let payerId: Int
  let participants: [User]!
}

extension Bill: Equatable {
  static func == (lhs: Bill, rhs: Bill) -> Bool {
    lhs.id == rhs.id && lhs.name == rhs.name && lhs.amount == rhs.amount && lhs.payerId == rhs.payerId
  }
}

struct Group: Codable {
  var id: Int
  let name: String
  let users: [User]
  let bills: [Bill]
}

extension Group: Equatable {
  static func == (lhs: Group, rhs: Group) -> Bool {
    lhs.id == rhs.id && lhs.users.count == rhs.users.count && lhs.bills.count == rhs.bills.count
  }
}

struct Payment {
  var gets: [User: Double] = [:]
  var debts: [User: Double] = [:]
}
