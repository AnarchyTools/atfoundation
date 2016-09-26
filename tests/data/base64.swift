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

class Base64Tests: XCTestCase {   
    func testBase64Encode() {
        var b64 = Base64.encode(string: "Hello World!")
        XCTAssert(b64 == "SGVsbG8gV29ybGQh")
        
        b64 = Base64.encode(string: "Hello World")
        XCTAssert(b64 == "SGVsbG8gV29ybGQ=")
        
        b64 = Base64.encode(string: "Hello You!")
        XCTAssert(b64 == "SGVsbG8gWW91IQ==")
        
        b64 = Base64.encode(string: "Nullam id dolor id nibh ultricies vehicula ut id elit. Donec id elit non mi porta gravida at eget metus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras justo odio, dapibus ac facilisis in, egestas eget quam.", linebreak: 76)
        XCTAssert(b64 == "TnVsbGFtIGlkIGRvbG9yIGlkIG5pYmggdWx0cmljaWVzIHZlaGljdWxhIHV0IGlkIGVsaXQuIERv\r\nbmVjIGlkIGVsaXQgbm9uIG1pIHBvcnRhIGdyYXZpZGEgYXQgZWdldCBtZXR1cy4gTG9yZW0gaXBz\r\ndW0gZG9sb3Igc2l0IGFtZXQsIGNvbnNlY3RldHVyIGFkaXBpc2NpbmcgZWxpdC4gQ3JhcyBqdXN0\r\nbyBvZGlvLCBkYXBpYnVzIGFjIGZhY2lsaXNpcyBpbiwgZWdlc3RhcyBlZ2V0IHF1YW0u")
    }
    
    func testBase64Decode() {
        var result = Base64.decode(string: "SGVsbG8gV29ybGQh")
        result.append(0)
        var string = result.withUnsafeBufferPointer {
            return String(cString: $0.baseAddress!)
        }
        XCTAssert(string == "Hello World!")
        
        result = Base64.decode(string: "SGVsbG8gV29ybGQ=")
        result.append(0)
        string = result.withUnsafeBufferPointer {
            return String(cString: $0.baseAddress!)
        }
        XCTAssert(string == "Hello World")

        result = Base64.decode(string: "SGVsbG8gWW91IQ==")
        result.append(0)
        string = result.withUnsafeBufferPointer {
            return String(cString: $0.baseAddress!)
        }
        XCTAssert(string == "Hello You!")

        result = Base64.decode(string: "TnVsbGFtIGlkIGRvbG9yIGlkIG5pYmggdWx0cmljaWVzIHZlaGljdWxhIHV0IGlkIGVsaXQuIERv\r\nbmVjIGlkIGVsaXQgbm9uIG1pIHBvcnRhIGdyYXZpZGEgYXQgZWdldCBtZXR1cy4gTG9yZW0gaXBz\r\ndW0gZG9sb3Igc2l0IGFtZXQsIGNvbnNlY3RldHVyIGFkaXBpc2NpbmcgZWxpdC4gQ3JhcyBqdXN0\r\nbyBvZGlvLCBkYXBpYnVzIGFjIGZhY2lsaXNpcyBpbiwgZWdlc3RhcyBlZ2V0IHF1YW0u")
        result.append(0)
        string = result.withUnsafeBufferPointer {
            return String(cString: $0.baseAddress!)
        }
        XCTAssert(string == "Nullam id dolor id nibh ultricies vehicula ut id elit. Donec id elit non mi porta gravida at eget metus. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Cras justo odio, dapibus ac facilisis in, egestas eget quam.")
    }
}

extension Base64Tests {
    static var allTests : [(String, (Base64Tests) -> () throws -> Void)] {
        return [
            ("testBase64Encode", testBase64Encode),
            ("testBase64Decode", testBase64Decode)
        ]
    }
}
