//
//  BalanceResolver.swift
//  BillSplitTests
//
//  Created by Chijioke on 5/24/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

@testable import BillSplit
import XCTest

class BalanceResolverTests: XCTestCase {
  func testResolver() {
    let UserA = User(id: 1, name: "a", email: "a@a.com")
    let UserB = User(id: 2, name: "b", email: "b@b.com")
    let UserC = User(id: 3, name: "c", email: "c@c.com")

    let groupA = Group(users: [UserA, UserB, UserC], history: [
      Bill(amount: 90, payerId: UserA.id, participants: [UserA, UserB, UserC]),
      Bill(amount: 12, payerId: UserB.id, participants: [UserA, UserB, UserC]),
    ])

    let resolver = BalanceResolver()
    let result = resolver.resolve(from: groupA)

    XCTAssertEqual(result[UserA]?.gets, [UserB: 30, UserC: 30])
    XCTAssertEqual(result[UserA]?.debts, [UserB: -4])

    XCTAssertEqual(result[UserB]?.gets, [UserA: 4, UserC: 4])
    XCTAssertEqual(result[UserB]?.debts, [UserA: -30])

    XCTAssertEqual(result[UserC]?.gets, [:])
    XCTAssertEqual(result[UserC]?.debts, [UserA: -30, UserB: -4])
  }
}
