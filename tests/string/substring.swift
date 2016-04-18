//
//  substring.swift
//  UnchainedString
//
//  Created by Johannes Schriewer on 22/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import XCTest

@testable import atfoundation

class SubstringTests: XCTestCase {

    func testSubstring() {
        let s = "Extract (a rather unimportant) substring"
        let substring = s.subString(range: s.startIndex.advanced(by: 8)...s.startIndex.advanced(by: 29))
        XCTAssert(substring == "(a rather unimportant)")
    }

    func testSubstringFullRange() {
        let s = "Extract (a rather unimportant) substring"
        let substring = s.subString(range: s.startIndex..<s.endIndex)
        XCTAssert(substring == s)
    }

    func testSubstringToIndex() {
        let s = "Extract (a rather unimportant) substring"
        let substring = s.subString(toIndex: s.startIndex.advanced(by: 8))
        XCTAssert(substring == "Extract ")
    }

    func testSubstringFromIndex() {
        let s = "Extract (a rather unimportant) substring"
        let substring = s.subString(fromIndex: s.startIndex.advanced(by: 8))
        XCTAssert(substring == "(a rather unimportant) substring")
    }
}

extension SubstringTests {
    static var allTests : [(String, SubstringTests -> () throws -> Void)] {
        return [
            ("testSubstring", testSubstring),
            ("testSubstringFullRange", testSubstringFullRange),
            ("testSubstringToIndex", testSubstringToIndex),
            ("testSubstringFromIndex", testSubstringFromIndex),
        ]
    }
}
