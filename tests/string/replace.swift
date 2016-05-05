// Copyright (c) 2016 Anarchy Tools Contributors.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
        XCTAssert(s.replacing(range: s.index(s.startIndex, offsetBy: 6)..<s.index(s.startIndex, offsetBy: 6+5), replacement: "You") == "Hello You!")
    }

    func testNewStringRangeWithEmpty() {
        let s = "Hello World!"
        XCTAssert(s.replacing(range: s.index(s.startIndex, offsetBy: 5)..<s.index(s.startIndex, offsetBy: 6+5), replacement: "") == "Hello!")
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
        s.replace(range: s.index(s.startIndex, offsetBy: 6)..<s.index(s.startIndex, offsetBy: 6+5), replacement: "You")
        XCTAssert(s == "Hello You!")
    }

    func testModifyRangeWithEmpty() {
        var s = "Hello World!"
        s.replace(range: s.index(s.startIndex, offsetBy: 5)..<s.index(s.startIndex, offsetBy: 6+5), replacement: "")
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
