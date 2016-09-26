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

class SubProcessTests: XCTestCase {
    func testDefaultEnvironment() {
        setenv("XXX", "bla", 1)
        XCTAssertNil(SubProcess.defaultEnvironment["XXX"])
        XCTAssertEqual(SubProcess.defaultEnvironment["PATH"], String(validatingUTF8: getenv("PATH")))
    }

    func testBlockingExitCode() {
        do {
            let exitCode1: Int32 = try SubProcess(executable: Path("true")).run()
            XCTAssertEqual(exitCode1, 0)
            let exitCode2: Int32 = try SubProcess(executable: Path("false")).run()
            XCTAssertEqual(exitCode2, 1)
        } catch {
            XCTFail("Error thrown \(error)")
        }
    }

    func testAsyncStdoutStream() {
        let e = expectation(description: "wait for process to finish")
        let process = SubProcess(executable: Path("cat"))
        do {
            let input = try UnidirectionalPipe()
            let stdout: atfoundation.InputStream = try process.run(stdin: input.read)
            if let p = stdout as? ReadPipe {
                p.onReadLine { line in
                    XCTAssertEqual(line, "Hello")
                    e.fulfill()
                }
            } else {
                XCTFail("stdout is not a readable pipe")
                e.fulfill()
            }
            try input.write.writeLine(string: "Hello")
            input.write.closeStream()
            XCTAssertEqual(process.waitForExit(), 0)
        } catch {
            XCTFail("Error thrown: \(error)")
            e.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testAsyncBidirectionalStream() {
        let e = expectation(description: "wait for process to finish")
        let process = SubProcess(executable: Path("cat"))
        do {
            let stream: atfoundation.InputStream & atfoundation.OutputStream = try process.run()
            if let p = stream as? RWPipe {
                p.onReadLine { line in
                    XCTAssertEqual(line, "Hello")
                    stream.closeStream()
                    e.fulfill()
                }
            } else {
                XCTFail("stream is not a bi-directional pipe")
                e.fulfill()
            }
            try stream.writeLine(string: "Hello")
            XCTAssertEqual(process.waitForExit(), 0)
        } catch {
            XCTFail("Error thrown: \(error)")
            e.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testBlockingStringList() {
        do {
            let result: (exitCode: Int32, output: [String]) = try SubProcess(executable: Path("ls")).run()
            XCTAssertEqual(result.exitCode, 0)
            XCTAssert(result.output.count > 0)
            Log.debug(result.output)
        } catch {
            XCTFail("Error thrown \(error)")
        }
    }

    func testAsyncTwoStreams() {
        let e = expectation(description: "wait for process to finish")
        let process = SubProcess(executable: Path("ls"), arguments: "--invalid-parameter")
        do {
            let streams: (stdout: atfoundation.InputStream, stderr: atfoundation.InputStream) = try process.run()
            if let p = streams.stdout as? ReadPipe {
                p.onReadLine { line in
                    Log.debug(line)
                    XCTFail("Should not output to stderr")
                }
            } else {
                XCTFail("stdout is not a readable pipe")
            }
            if let p = streams.stderr as? ReadPipe {
                var fulfilled = false
                p.onReadLine { line in
                    Log.debug(line)
                    if !fulfilled {
                        e.fulfill()
                        fulfilled = true
                    }
                }
            } else {
                XCTFail("stderr is not a readable pipe")
                e.fulfill()
            }
#if os(Linux)
            XCTAssertEqual(process.waitForExit(), 2)
#else
            XCTAssertEqual(process.waitForExit(), 1)
#endif
        } catch {
            XCTFail("Error thrown: \(error)")
            e.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}

extension SubProcessTests {
    static var allTests : [(String, (SubProcessTests) -> () throws -> Void)] {
        return [
            ("testDefaultEnvironment", testDefaultEnvironment),
            ("testBlockingExitCode", testBlockingExitCode),
            ("testBlockingStringList", testBlockingStringList),
            ("testAsyncStdoutStream", testAsyncStdoutStream),
            ("testAsyncBidirectionalStream", testAsyncBidirectionalStream),
            ("testAsyncTwoStreams", testAsyncTwoStreams)
        ]
    }
}
