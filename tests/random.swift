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

class RandomTests: XCTestCase {  
    
    func testRandomBytes() {
        let result = Random.bytes(count: 16)
        var sum = 0
        for byte in result {
            sum += Int(byte)
        }
        XCTAssertNotEqual(sum, 0) // this may happen but is extremely unlikely
    }

    func testRandomUnsigned() {
        let v1 = Random.unsignedNumber(range: 1..<100000)
        let v2 = Random.unsignedNumber(range: 1..<100000)
        Log.debug(v1)
        Log.debug(v2)
        XCTAssertNotEqual(v1, v2) // this could happen but is unlikely
    }

    func testRandomSigned() {
        let v1 = Random.signedNumber(range: -100000..<1)
        let v2 = Random.signedNumber(range: -100000..<1)
        Log.debug(v1)
        Log.debug(v2)
        XCTAssertNotEqual(v1, v2) // this could happen but is unlikely
    }
}

extension RandomTests {
    static var allTests : [(String, (RandomTests) -> () throws -> Void)] {
        return [
            ("testRandomBytes", testRandomBytes),
            ("testRandomUnsigned", testRandomUnsigned),
            ("testRandomSigned", testRandomSigned),
        ]
    }
}
