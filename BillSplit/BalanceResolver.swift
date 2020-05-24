//
//  File.swift
//  BillSplit
//
//  Created by Chijioke on 5/24/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import Foundation

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

extension Group {
  func balances() -> [String: Payment] {
    let resolver = BalanceResolver()

    return resolver.resolve(from: self)
  }
}

// let groupA = Group(users: ["a", "b", "c"], history: [
//    Bill(amount: 90,payer: "a", participants: ["a", "b", "c"]),
//    Bill(amount: 12,payer: "b", participants: ["a", "b", "c"]),
// ])

/**
 ```
 let groupA = Group(
 users: ["a", "b", "c"],
 history: [
 Bill(amount: 90,payer: "a", participants: ["a", "b", "c"]),
 Bill(amount: 12,payer: "b", participants: ["a", "b", "c"]),
 ])

 resovler(group: groupA)
 //expected
 {
 "a": Payment.{ gets: [ "a": 0, "b": 30, "c": 30 ], debts: [ "a": 0, "b": -4, "c": 0 ] },
 "b": Payment.{ gets: [ "a": 4, "b": 0, "c": 4 ], debts: [ "a": -30, "b": 0, "c": 0 ] },
 "c": Payment.{ gets: [ "a": 0, "b": 0, "c": 0 ], debts: [ "a": -30, "b": -4, "c": 0 ] },
 };
 ```
 */

typealias Result = [String: Payment]
struct BalanceResolver {
  public func resolve(from group: Group) -> [String: Payment] {
    let history = group.history
    let users = group.users
    let itemStatement = history.map { (item) -> Result in
      let result: Result = [:]
      let split = item.amount / Double(item.participants.count)

      return item.participants.reduce(result) { (prev, next) -> [String: Payment] in
        var acc = prev
        guard next != item.payer else { return acc }

        acc[item.payer] = acc[item.payer] ?? Payment()
        acc[next] = acc[next] ?? Payment()

        let payersGet = (acc[item.payer]?.gets ?? [String: Double]()).merging([next: split]) { _, new in new }
        let payersDebts = acc[item.payer]?.debts ?? [String: Double]()
        acc[item.payer] = Payment(gets: payersGet, debts: payersDebts)

        let debtorsGet = acc[next]?.gets ?? [String: Double]()
        let debtorsDebts = (acc[next]?.debts ?? [String: Double]()).merging([item.payer: split * -1]) { _, new in new }
        acc[next] = Payment(gets: debtorsGet,
                            debts: debtorsDebts)

        return acc
      }
    }

    let details: Result = itemStatement.reduce(Result()) { (prev, next) -> Result in
      var acc = prev
      // combine each users gets and debts
      users.forEach { user in
        let accGets: [String: Double] = acc[user]?.gets ?? [:]
        let accDebts: [String: Double] = acc[user]?.debts ?? [:]
        let nextGets: [String: Double] = next[user]?.gets ?? [:]
        let nextDebts: [String: Double] = next[user]?.debts ?? [:]

        acc[user] = Payment(gets: accGets.merging(nextGets, uniquingKeysWith: +),
                            debts: accDebts.merging(nextDebts, uniquingKeysWith: +))
      }

      return acc
    }

    return details
  }
}
