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
