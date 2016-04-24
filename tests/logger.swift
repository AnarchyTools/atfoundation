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

class LoggerTests: XCTestCase {

    func testLogStdErr() {
        Log.logLevel = .Debug
        Log.logTarget = .StdErr

        Log.debug("debug log", Log.logTarget)
        Log.info("info log", Log.logTarget)
        Log.warn("warn log", Log.logTarget)
        Log.error("error log", Log.logTarget)
        Log.fatal("fatal log", Log.logTarget)
    }

    func testLogStdOut() {
        Log.logLevel = .Debug
        Log.logTarget = .StdOut

        Log.debug("debug log", Log.logTarget)
        Log.info("info log", Log.logTarget)
        Log.warn("warn log", Log.logTarget)
        Log.error("error log", Log.logTarget)
        Log.fatal("fatal log", Log.logTarget)
    }

    func testLogFile() {
        do {
            Log.logLevel = .Debug
            Log.logFileName = try FS.temporaryDirectory() + "logfile.log"
            Log.logTarget = .File

            Log.debug("debug log", Log.logTarget)
            Log.info("info log", Log.logTarget)
            Log.warn("warn log", Log.logTarget)
            Log.error("error log", Log.logTarget)
            Log.fatal("fatal log", Log.logTarget)

            let file = try File(path: Log.logFileName!, mode: .ReadOnly)
            let content = ["debug", "info", "warn", "error", "fatal"]
            for idx in 0..<5 {
                let line = try file.readLine()!
                let currentContent = content[idx]
                XCTAssertNotNil(line.position(string: currentContent))
            }
        } catch {
            XCTFail("Error thrown \(error)")
        }
    }

}

extension LoggerTests {
    static var allTests : [(String, LoggerTests -> () throws -> Void)] {
        return [
            ("testLogStdErr", testLogStdErr),
            ("testLogStdOut", testLogStdOut),
            ("testLogFile", testLogFile),
        ]
    }
}