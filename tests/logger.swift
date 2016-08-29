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
        Log.logger = StdErrLogger()
        Log.logger.logFileAndLine = true

        Log.debug("debug log", "stderr")
        Log.info("info log", "stderr")
        Log.warn("warn log", "stderr")
        Log.error("error log", "stderr")
        Log.fatal("fatal log", "stderr")
    }

    func testLogStdOut() {
        Log.logLevel = .Debug
        Log.logger = StdOutLogger()
        Log.logger.logFileAndLine = false

        Log.debug("debug log", "stdout")
        Log.info("info log", "stdout")
        Log.warn("warn log", "stdout")
        Log.error("error log", "stdout")
        Log.fatal("fatal log", "stdout")
    }

    func testLogFile() {
        do {
            Log.logLevel = .Debug
            Log.logger = try FileLogger(filename: try FS.temporaryDirectory() + "logfile.log")
            Log.logger.logFileAndLine = true

            Log.debug("debug log", "file")
            Log.info("info log", "file")
            Log.warn("warn log", "file")
            Log.error("error log", "file")
            Log.fatal("fatal log", "file")

            let file = try File(path: (Log.logger as! FileLogger).logFileName!, mode: .ReadOnly)
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
    static var allTests : [(String, (LoggerTests) -> () throws -> Void)] {
        return [
            ("testLogStdErr", testLogStdErr),
            ("testLogStdOut", testLogStdOut),
            ("testLogFile", testLogFile),
        ]
    }
}