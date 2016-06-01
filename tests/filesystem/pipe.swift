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

class PipeTests: XCTestCase {

    func testUnidirectionalPipe() {
        do {
            let p = try UnidirectionalPipe()
            XCTAssertNotNil(p)
            let t = Thread() {
                do {
                    try p.write.writeLine(string: "Test")
                } catch {
                    XCTFail("Error thrown: \(error)")
                }
            }
            let result: String? = try p.read.readLine()
            let _ = t.wait()
            XCTAssertEqual(result, "Test")
        } catch {
            XCTFail("Error thrown: \(error)")
        }
    }

    func testUnidirectionalPipeReadEvent() {
        do {
            let e = expectation(withDescription: "wait for read to finish")

            let p = try UnidirectionalPipe()
            XCTAssertNotNil(p)
            p.read.onReadLine { line in
                XCTAssertEqual(line, "Test")
                e.fulfill()
            }
            try p.write.writeLine(string: "Test")
            waitForExpectations(withTimeout: 5, handler: nil)
        } catch {
            XCTFail("Error thrown: \(error)")
        }
    }

    func testBidirectionalPipeReadEvent() {
        do {
            let e0 = expectation(withDescription: "wait for read to finish first direction")
            let e1 = expectation(withDescription: "wait for read to finish second direction")

            let p = try BidirectionalPipe()
            XCTAssertNotNil(p)
            p.0.onReadLine { line in
                XCTAssertEqual(line, "Test to 0")
                e0.fulfill()
            }
            p.1.onReadLine { line in
                XCTAssertEqual(line, "Test to 1")
                e1.fulfill()
            }
            try p.0.writeLine(string: "Test to 1")
            try p.1.writeLine(string: "Test to 0")
            waitForExpectations(withTimeout: 5, handler: nil)
        } catch {
            XCTFail("Error thrown: \(error)")
        }
    }
}

extension PipeTests {
    static var allTests : [(String, (PipeTests) -> () throws -> Void)] {
        return [
            ("testUnidirectionalPipe", testUnidirectionalPipe),
            ("testUnidirectionalPipeReadEvent", testUnidirectionalPipeReadEvent),
            ("testBidirectionalPipeReadEvent", testBidirectionalPipeReadEvent),
        ]
    }
}
