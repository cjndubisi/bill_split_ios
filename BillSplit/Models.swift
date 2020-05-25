//
//  Models.swift
//  BillSplit
//
//  Created by Chijioke on 5/25/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import Foundation

struct User: Codable {
  let name: String
  let email: String
}

struct Bill {
  let amount: Double
  let payer: String
  let participants: [String]
}

struct Group {
  let users: [String]
  let history: [Bill]
}

struct Payment {
  var gets: [String: Double] = [:]
  var debts: [String: Double] = [:]
}
