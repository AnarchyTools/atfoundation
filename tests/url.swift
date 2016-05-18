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

class URLTests: XCTestCase {

    func testURLEncode() {
        XCTAssert("Hello_ & string123".urlEncoded == "Hello_%20%26%20string123")
    }

    func testURLDecode() {
        XCTAssert("Hello_%20%26%20string123".urlDecoded == "Hello_ & string123")
    }

    func testURLParse1() {
        let url = atfoundation.URL(string: "http://google.com/")
        XCTAssert(url.schema == "http")
        XCTAssert(url.domain == "google.com", url.domain)
        XCTAssert(url.path.description == "/")
        XCTAssert(url.port == 80)
        XCTAssert(url.description == "http://google.com/", url.description)
    }

    func testURLParse2() {
        let url = atfoundation.URL(string: "https://user:password@example.com/path/here?parameter=value%20here#fragment")
        XCTAssert(url.schema == "https")
        XCTAssert(url.domain == "example.com", url.domain)
        XCTAssert(url.fragment == "fragment", "\(url.fragment)")
        XCTAssert(url.user == "user", "\(url.user)")
        XCTAssert(url.password == "password", "\(url.password)")
        XCTAssert(url.path.description == "/path/here", url.path.description)
        XCTAssert(url.parameters.count == 1)
        if url.parameters.count == 1 {
            XCTAssert(url.parameters[0].name == "parameter")
            XCTAssert(url.parameters[0].value == "value here")
        }
        XCTAssert(url.port == 443)
        XCTAssert(url.description == "https://user:password@example.com/path/here?parameter=value%20here#fragment", url.description)
    }
}

extension URLTests {
    static var allTests : [(String, URLTests -> () throws -> Void)] {
        return [
            ("testURLEncode", testURLEncode),
            ("testURLDecode", testURLDecode),
            ("testURLParse1", testURLParse1),
            ("testURLParse2", testURLParse2),
        ]
    }
}