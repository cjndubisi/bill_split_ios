//
//  BalanceResolver.swift
//  BillSplitTests
//
//  Created by Chijioke on 5/24/20.
//  Copyright © 2020 Chijioke. All rights reserved.
//

import XCTest
@testable import BillSplit

class BalanceResolverTests: XCTestCase {

    func testResolver() {
        let groupA = Group(users: ["a", "b", "c"], history: [
            Bill(amount: 90,payer: "a", participants: ["a", "b", "c"]),
            Bill(amount: 12,payer: "b", participants: ["a", "b", "c"]),
        ])

        let resolver = BalanceResolver()
        let result = resolver.resolve(from: groupA)

        XCTAssertEqual(result["a"]?.gets, ["b": 30, "c": 30])
        XCTAssertEqual(result["a"]?.debts, ["b": -4])

        XCTAssertEqual(result["b"]?.gets, ["a": 4, "c": 4])
        XCTAssertEqual(result["b"]?.debts, ["a": -30])

        XCTAssertEqual(result["c"]?.gets, [:])
        XCTAssertEqual(result["c"]?.debts, ["a": -30, "b": -4])
    }
}
