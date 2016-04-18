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
        XCTAssert(s.stringByReplacing(searchTerm: "World", replacement: "You") == "Hello You!")
    }

    func testNewStringSubstringWithEmpty() {
        let s = "Hello World!"
        XCTAssert(s.stringByReplacing(searchTerm: " World", replacement: "") == "Hello!")
    }

    func testNewStringEmptySubstring() {
        let s = "Hello World!"
        XCTAssert(s.stringByReplacing(searchTerm: "", replacement: "You") == "Hello World!")
    }

    func testNewStringRange() {
        let s = "Hello World!"
        XCTAssert(s.stringByReplacing(range: s.startIndex.advanced(by: 6)..<s.startIndex.advanced(by: 6+5), replacement: "You") == "Hello You!")
    }

    func testNewStringRangeWithEmpty() {
        let s = "Hello World!"
        XCTAssert(s.stringByReplacing(range: s.startIndex.advanced(by: 5)..<s.startIndex.advanced(by: 6+5), replacement: "") == "Hello!")
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
}

extension ReplaceTests {
    static var allTests : [(String, ReplaceTests -> () throws -> Void)] {
        return [
            ("testNewStringSubstring", testNewStringSubstring),
            ("testNewStringSubstringWithEmpty", testNewStringSubstringWithEmpty),
            ("testNewStringEmptySubstring", testNewStringEmptySubstring)
        ]
    }
}
