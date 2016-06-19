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

class QuotedPrintableTests: XCTestCase {   
    
    func testQuotedPrintableEncode() {
        var encoded = QuotedPrintable.encode(string: "Hello World")
        XCTAssert(encoded == "Hello World")
        
        encoded = QuotedPrintable.encode(string: "e = m * c^2")
        XCTAssert(encoded == "e =3D m * c^2")
        
        encoded = QuotedPrintable.encode(string: "Nullam id dolor id nibh ultricies vehicula ut id elit. Donec id elit non mi porta gravida at eget metus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras justo odio, dapibus ac facilisis in, egestas eget quam.")
        XCTAssert(encoded == "Nullam id dolor id nibh ultricies vehicula ut id elit. Donec id elit non mi=\r\n porta gravida at eget metus. Lorem ipsum dolor sit amet, consectetur adipi=\r\nscing elit. Cras justo odio, dapibus ac facilisis in, egestas eget quam.")
    }

    func testQuotedPrintableDecode() {
        var decoded = QuotedPrintable.decode(string: "Hello World")
        XCTAssert(decoded == "Hello World")
     
        decoded = QuotedPrintable.decode(string: "e =3D m * c^2")
        XCTAssert(decoded == "e = m * c^2")
        
        decoded = QuotedPrintable.decode(string: "Nullam id dolor id nibh ultricies vehicula ut id elit. Donec id elit non mi=\r\n porta gravida at eget metus. Lorem ipsum dolor sit amet, consectetur adipi=\r\nscing elit. Cras justo odio, dapibus ac facilisis in, egestas eget quam.")
        XCTAssert(decoded == "Nullam id dolor id nibh ultricies vehicula ut id elit. Donec id elit non mi porta gravida at eget metus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras justo odio, dapibus ac facilisis in, egestas eget quam.")
    }
}

extension QuotedPrintableTests {
    static var allTests : [(String, (QuotedPrintableTests) -> () throws -> Void)] {
        return [
            ("testQuotedPrintableEncode", testQuotedPrintableEncode),
            ("testQuotedPrintableDecode", testQuotedPrintableDecode)
        ]
    }
}
