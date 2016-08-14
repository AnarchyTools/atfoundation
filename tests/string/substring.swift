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

class SubstringTests: XCTestCase {

    func testSubstring() {
        let s = "Extract (a rather unimportant) substring"
        let substring = s.subString(range: s.index(s.startIndex, offsetBy: 8)..<s.index(s.startIndex, offsetBy: 30))
        XCTAssert(substring == "(a rather unimportant)")
    }

    func testSubstringFullRange() {
        let s = "Extract (a rather unimportant) substring"
        let substring = s.subString(range: s.startIndex..<s.endIndex)
        XCTAssert(substring == s)
    }

    func testSubstringToIndex() {
        let s = "Extract (a rather unimportant) substring"
        let substring = s.subString(toIndex: s.index(s.startIndex, offsetBy: 8))
        XCTAssert(substring == "Extract ")
    }

    func testSubstringFromIndex() {
        let s = "Extract (a rather unimportant) substring"
        let substring = s.subString(fromIndex: s.index(s.startIndex, offsetBy: 8))
        XCTAssert(substring == "(a rather unimportant) substring")
    }
}

extension SubstringTests {
    static var allTests : [(String, (SubstringTests) -> () throws -> Void)] {
        return [
            ("testSubstring", testSubstring),
            ("testSubstringFullRange", testSubstringFullRange),
            ("testSubstringToIndex", testSubstringToIndex),
            ("testSubstringFromIndex", testSubstringFromIndex),
        ]
    }
}
