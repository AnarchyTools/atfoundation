//
//  whitespace.swift
//  UnchainedString
//
//  Created by Johannes Schriewer on 22/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

import XCTest

@testable import atfoundation

class WhitespaceTests: XCTestCase {

    func testWhitespaceAtBeginning() {
        let s = "\n \t whitespace"
        XCTAssert(s.stringByTrimmingWhitespace() == "whitespace")
    }

    func testWhitespaceAtEnd() {
        let s = "whitespace\n \t "
        XCTAssert(s.stringByTrimmingWhitespace() == "whitespace")
    }

    func testWhitespaceAtBeginningAndEnd() {
        let s = "  \n \t \r\nwhitespace\n \t "
        XCTAssert(s.stringByTrimmingWhitespace() == "whitespace")
    }

    func testNoWhitespace() {
        let s = "whitespace"
        XCTAssert(s.stringByTrimmingWhitespace() == "whitespace")
    }
}

extension WhitespaceTests {
    static var allTests : [(String, WhitespaceTests -> () throws -> Void)] {
        return [
            ("testWhitespaceAtBeginning", testWhitespaceAtBeginning),
            ("testWhitespaceAtEnd", testWhitespaceAtEnd),
            ("testWhitespaceAtBeginningAndEnd", testWhitespaceAtBeginningAndEnd),
            ("testNoWhitespace", testNoWhitespace),
        ]
    }
}
