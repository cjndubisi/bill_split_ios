//
//  Models.swift
//  BillSplit
//
//  Created by Chijioke on 5/25/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import Foundation

struct User: Codable {
  var id: Int!
  let name: String
  let email: String
}

extension User: Hashable {}

struct Bill: Codable {
  let amount: Double
  let payerId: Int
  let participants: [User]
}

struct Group: Codable {
  let users: [User]
  let history: [Bill]
}

struct Payment {
  var gets: [User: Double] = [:]
  var debts: [User: Double] = [:]
}
