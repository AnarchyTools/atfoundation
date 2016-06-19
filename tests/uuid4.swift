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

class UUID4Tests: XCTestCase {  
    
    func testUUIDFromString() throws {
        let uuid = UUID4(string: "de305d54-75b4-431b-adb2-eb6b9e546014")
        XCTAssertNotNil(uuid)
        XCTAssert(uuid!.description == "DE305D54-75B4-431B-ADB2-EB6B9E546014")
    }

    func testUUIDFromStringFail1() throws {
        let uuid = UUID4(string: "de305d54-75b4-431badb2-eb6b9e546014")
        XCTAssertNil(uuid)
    }

    func testUUIDFromStringFail2() throws {
        let uuid = UUID4(string: "de305d54-75b4-431b-adb2-b6b9e546014")
        XCTAssertNil(uuid)
    }

    func testUUIDFromStringFail3() throws {
        let uuid = UUID4(string: "de305d54-75b4-431b-adb2-b6b9e54601")
        XCTAssertNil(uuid)
    }

}

extension UUID4Tests {
    static var allTests : [(String, (UUID4Tests) -> () throws -> Void)] {
        return [
            ("testUUIDFromString", testUUIDFromString),
            ("testUUIDFromStringFail1", testUUIDFromStringFail1),
            ("testUUIDFromStringFail2", testUUIDFromStringFail2),
            ("testUUIDFromStringFail3", testUUIDFromStringFail3)
        ]
    }
}
