//
//  UnchainedStringTests.swift
//  UnchainedStringTests
//
//  Created by Johannes Schriewer on 22/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import XCTest

@testable import atfoundation

class SearchTests: XCTestCase {
    // MARK: Position of char

    func testPositionOfChar() {
        let c: Character = "."
        let s = "Just a string with a . in it"
        if let result = s.position(character: c) {
            XCTAssert(s.startIndex.advanced(by: 21) == result)
        } else {
            XCTFail(". not found")
        }
    }

    func testPositionOfCharNotFound() {
        let c: Character = "!"
        let s = "Just a string with a . in it"
        if let _ = s.position(character: c) {
            XCTFail("Should not find a position")
        }
    }

    func testPositionOfCharReverse() {
        let c: Character = "i"
        let s = "Just a string with a . in it"
        if let result = s.position(character: c, reverse: true) {
            XCTAssert(s.startIndex.advanced(by: 26) == result)
        } else {
            XCTFail("i not found")
        }
    }

    func testPositionOfCharStartIndex() {
        let c: Character = "i"
        let s = "Just a string with a . in it"
        if let result = s.position(character: c, index: s.startIndex.advanced(by: 22)) {
            XCTAssert(s.startIndex.advanced(by: 23) == result)
        } else {
            XCTFail("i not found")
        }
    }

    func testPositionOfCharStartIndexReverse() {
        let c: Character = "i"
        let s = "Just a string with a . in it"
        if let result = s.position(character: c, index: s.startIndex.advanced(by: 25), reverse: true) {
            XCTAssert(s.startIndex.advanced(by: 23) == result)
        } else {
            XCTFail("i not found")
        }
    }

    func testPositionsOfChar() {
        let c: Character = "i"
        let s = "Just a string with a . in it"
        let result = s.positions(character: c)
        XCTAssert(result.count == 4)
        if result.count == 4 {
            XCTAssert(result[0] == s.startIndex.advanced(by: 10))
            XCTAssert(result[1] == s.startIndex.advanced(by: 15))
            XCTAssert(result[2] == s.startIndex.advanced(by: 23))
            XCTAssert(result[3] == s.startIndex.advanced(by: 26))
        }
    }

    func testPositionsOfCharNotFound() {
        let c: Character = "!"
        let s = "Just a string with a . in it"
        let result = s.positions(character: c)
        XCTAssert(result.count == 0)
    }

    // MARK: Position of string

    func testPositionOfString() {
        let n = "a "
        let s = "Just a string with a . in it"
        if let result = s.position(string: n) {
            XCTAssert(s.startIndex.advanced(by: 5) == result)
        } else {
            XCTFail("'a ' not found")
        }
    }

    func testPositionOfStringNotFound() {
        let n = "! "
        let s = "Just a string with a . in it"
        if let _ = s.position(string: n) {
            XCTFail("Should not find a position")
        }
    }

    func testPositionOfStringReverse() {
        let n = "a "
        let s = "Just a string with a . in it"
        if let result = s.position(string: n, reverse: true) {
            XCTAssert(s.startIndex.advanced(by: 19) == result)
        } else {
            XCTFail("'a ' not found")
        }
    }

    func testPositionOfStringStartIndex() {
        let n = "a "
        let s = "Just a string with a . in it"
        if let result = s.position(string: n, index: s.startIndex.advanced(by: 10)) {
            XCTAssert(s.startIndex.advanced(by: 19) == result)
        } else {
            XCTFail("'a ' not found")
        }
    }

    func testPositionOfStringStartIndexReverse() {
        let n = "a "
        let s = "Just a string with a . in it"
        if let result = s.position(string: n, index: s.startIndex.advanced(by: 10), reverse: true) {
            XCTAssert(s.startIndex.advanced(by: 5) == result)
        } else {
            XCTFail("'a ' not found")
        }
    }

    func testPositionsOfString() {
        let n = "a "
        let s = "Just a string with a . in it"
        let result = s.positions(string: n)
        XCTAssert(result.count == 2)
        if result.count == 2 {
            XCTAssert(result[0] == s.startIndex.advanced(by: 5))
            XCTAssert(result[1] == s.startIndex.advanced(by: 19))
        }
    }

    func testPositionsOfStringNotFound() {
        let n = "! "
        let s = "Just a string with a . in it"
        let result = s.positions(string: n)
        XCTAssert(result.count == 0)
    }

    // MARK: Contains

    func testContainsChar() {
        let c: Character = "."
        let s = "Just a string with a . in it"
        XCTAssertTrue(s.contains(character: c))
    }

    func testContainsCharNotFound() {
        let c: Character = "!"
        let s = "Just a string with a . in it"
        XCTAssertFalse(s.contains(character: c))
    }

    func testContainsString() {
        let n = "in"
        let s = "Just a string with a . in it"
        XCTAssertTrue(s.contains(string: n))
    }

    func testContainsStringNotFound() {
        let n = "out"
        let s = "Just a string with a . in it"
        XCTAssertFalse(s.contains(string: n))
    }

#if false // cannot be tested because it is in foundation which is included implicitly by xctest

    // MARK: Prefix

    func testHasPrefix() {
        let s = "Just a string with a . in it"
        XCTAssertTrue(s.hasPrefix("Just"))
    }

    func testHasPrefixNotFound() {
        let s = "Just a string with a . in it"
        XCTAssertFalse(s.hasPrefix("Foobar"))
    }

    func testHasEmptyPrefix() {
        let s = "Just a string with a . in it"
        XCTAssertTrue(s.hasPrefix(""))
    }

    func testHasTooLongPrefix() {
        let s = "Just"
        XCTAssertFalse(s.hasPrefix("Just a long prefix"))
    }

    func testHasPrefixAlike() {
        let s = "Just a string with a . in it"
        XCTAssertFalse(s.hasPrefix("Just a  thing"))
    }

    // MARK: Suffix

    func testHasSuffix() {
        let s = "Just a string with a . in it"
        XCTAssertTrue(s.hasSuffix("in it"))
    }

    func testHasSuffixNotFound() {
        let s = "Just a string with a . in it"
        XCTAssertFalse(s.hasSuffix("foobar"))
    }

    func testHasEmptySuffix() {
        let s = "Just a string with a . in it"
        XCTAssertTrue(s.hasSuffix(""))
    }

    func testHasTooLongSuffix() {
        let s = "Just"
        XCTAssertFalse(s.hasSuffix("Just a long prefix"))
    }

    func testHasSuffixAlike() {
        let s = "Just a string with a . in it"
        XCTAssertFalse(s.hasSuffix(". of it"))
    }
#endif
}

extension SearchTests {
    static var allTests : [(String, SearchTests -> () throws -> Void)] {
        return [
            ("testPositionOfChar", testPositionOfChar),
            ("testPositionOfCharNotFound", testPositionOfCharNotFound),
            ("testPositionOfCharReverse", testPositionOfCharReverse),
            ("testPositionOfCharStartIndex", testPositionOfCharStartIndex),
            ("testPositionOfCharStartIndexReverse", testPositionOfCharStartIndexReverse),
            ("testPositionsOfChar", testPositionsOfChar),
            ("testPositionsOfCharNotFound", testPositionsOfCharNotFound),
            ("testPositionOfString", testPositionOfString),
            ("testPositionOfStringNotFound", testPositionOfStringNotFound),
            ("testPositionOfStringReverse", testPositionOfStringReverse),
            ("testPositionOfStringStartIndex", testPositionOfStringStartIndex),
            ("testPositionOfStringStartIndexReverse", testPositionOfStringStartIndexReverse),
            ("testPositionsOfString", testPositionsOfString),
            ("testPositionsOfStringNotFound", testPositionsOfStringNotFound),
            ("testContainsChar", testContainsChar),
            ("testContainsCharNotFound", testContainsCharNotFound),
            ("testContainsString", testContainsString),
            ("testContainsStringNotFound", testContainsStringNotFound)

            // ("testHasPrefix", testHasPrefix),
            // ("testHasPrefixNotFound", testHasPrefixNotFound),
            // ("testHasEmptyPrefix", testHasEmptyPrefix),
            // ("testHasTooLongPrefix", testHasTooLongPrefix),
            // ("testHasPrefixAlike", testHasPrefixAlike),
            // ("testHasSuffix", testHasSuffix),
            // ("testHasSuffixNotFound", testHasSuffixNotFound),
            // ("testHasEmptySuffix", testHasEmptySuffix),
            // ("testHasTooLongSuffix", testHasTooLongSuffix),
            // ("testHasSuffixAlike", testHasSuffixAlike)
        ]
    }
}
