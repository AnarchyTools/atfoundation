//
//  replace.swift
//  UnchainedString
//
//  Created by Johannes Schriewer on 22/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import XCTest

@testable import atfoundation

class ReplaceTests: XCTestCase {

    // MARK: New strings

    func testNewStringSubstring() {
        let s = "Hello World!"
        XCTAssert(s.replacing(searchTerm: "World", replacement: "You") == "Hello You!")
    }

    func testNewStringSubstringWithEmpty() {
        let s = "Hello World!"
        XCTAssert(s.replacing(searchTerm: " World", replacement: "") == "Hello!")
    }

    func testNewStringEmptySubstring() {
        let s = "Hello World!"
        XCTAssert(s.replacing(searchTerm: "", replacement: "You") == "Hello World!")
    }

    func testNewStringRange() {
        let s = "Hello World!"
        XCTAssert(s.replacing(range: s.startIndex.advanced(by: 6)..<s.startIndex.advanced(by: 6+5), replacement: "You") == "Hello You!")
    }

    func testNewStringRangeWithEmpty() {
        let s = "Hello World!"
        XCTAssert(s.replacing(range: s.startIndex.advanced(by: 5)..<s.startIndex.advanced(by: 6+5), replacement: "") == "Hello!")
    }

    func testNewStringReplacingEnd() {
        let s = "Hello World!"
        XCTAssert(s.replacing(searchTerm: "World!", replacement: "You!") == "Hello You!")
    }

    // MARK: String modification

    func testModifySubstring() {
        var s = "Hello World!"
        s.replace(searchTerm: "World", replacement: "You")
        XCTAssert(s == "Hello You!")
    }

    func testModifySubstringWithEmpty() {
        var s = "Hello World!"
        s.replace(searchTerm: " World", replacement: "")
        XCTAssert(s == "Hello!")
    }

    func testModifyEmptySubstring() {
        var s = "Hello World!"
        s.replace(searchTerm: "", replacement: "You")
        XCTAssert(s == "Hello World!")
    }

    func testModifyRange() {
        var s = "Hello World!"
        s.replace(range: s.startIndex.advanced(by: 6)..<s.startIndex.advanced(by: 6+5), replacement: "You")
        XCTAssert(s == "Hello You!")
    }

    func testModifyRangeWithEmpty() {
        var s = "Hello World!"
        s.replace(range: s.startIndex.advanced(by: 5)..<s.startIndex.advanced(by: 6+5), replacement: "")
        XCTAssert(s == "Hello!")
    }

    func testModifyStringReplacingEnd() {
        var s = "Hello World!"
        s.replace(searchTerm: "World!", replacement: "You!")
        XCTAssert(s == "Hello You!")
    }

}

extension ReplaceTests {
    static var allTests : [(String, ReplaceTests -> () throws -> Void)] {
        return [
            ("testNewStringSubstring", testNewStringSubstring),
            ("testNewStringSubstringWithEmpty", testNewStringSubstringWithEmpty),
            ("testNewStringEmptySubstring", testNewStringEmptySubstring),
            ("testNewStringRange", testNewStringRange),
            ("testNewStringRangeWithEmpty", testNewStringRangeWithEmpty),
            ("testNewStringReplacingEnd", testNewStringReplacingEnd),
            ("testModifySubstring", testModifySubstring),
            ("testModifySubstringWithEmpty", testModifySubstringWithEmpty),
            ("testModifyEmptySubstring", testModifyEmptySubstring),
            ("testModifyRange", testModifyRange),
            ("testModifyRangeWithEmpty", testModifyRangeWithEmpty),
            ("testModifyStringReplacingEnd", testModifyStringReplacingEnd),
        ]
    }
}
