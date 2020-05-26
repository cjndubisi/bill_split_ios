//
//  File.swift
//  BillSplit
//
//  Created by Chijioke on 5/24/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import Foundation

typealias Result = [User: Payment]
struct BalanceResolver {
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
  public func resolve(from group: Group) -> [User: Payment] {
    let history = group.bills
    let users = group.users
    let itemStatement = history.map { (item) -> Result in
      let result: Result = [:]
      guard let participants = item.participants else { return Result() }
      let split = item.amount / Double(participants.count)
      let payer = participants.first(where: { item.payerId == $0.id })!
      return participants.reduce(result) { (prev, next) -> Result in
        var acc = prev
        guard next != payer else { return acc }

        acc[payer] = acc[payer] ?? Payment()
        acc[next] = acc[next] ?? Payment()

        let payersGet = (acc[payer]?.gets ?? [User: Double]()).merging([next: split]) { _, new in new }
        let payersDebts = acc[payer]?.debts ?? [User: Double]()
        acc[payer] = Payment(gets: payersGet, debts: payersDebts)

        let debtorsGet = acc[next]?.gets ?? [User: Double]()
        let debtorsDebts = (acc[next]?.debts ?? [User: Double]()).merging([payer: split * -1]) { _, new in new }
        acc[next] = Payment(gets: debtorsGet,
                            debts: debtorsDebts)

        return acc
      }
    }

    let details: Result = itemStatement.reduce(Result()) { (prev, next) -> Result in
      var acc = prev
      // combine each users gets and debts
      users.forEach { user in
        let accGets: [User: Double] = acc[user]?.gets ?? [:]
        let accDebts: [User: Double] = acc[user]?.debts ?? [:]
        let nextGets: [User: Double] = next[user]?.gets ?? [:]
        let nextDebts: [User: Double] = next[user]?.debts ?? [:]

        acc[user] = Payment(gets: accGets.merging(nextGets, uniquingKeysWith: +),
                            debts: accDebts.merging(nextDebts, uniquingKeysWith: +))
      }

      return acc
    }

    return details
  }
}

extension Group {
  func balances() -> [User: Payment] {
    let resolver = BalanceResolver()

    return resolver.resolve(from: self)
  }
}
