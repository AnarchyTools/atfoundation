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

class SocketTests: XCTestCase {
    
    func testSocketListen() {
        let expectation = self.expectation(withDescription: "testSocketListen")

        var fullfilled = false
        var data: String = ""
        var sock: ListeningSocket? = nil
        sock = Socket.listen(address: .Wildcard, port: 4567) { (socket: ConnectedSocket, char: UInt8) -> Bool in
            data.append(UnicodeScalar(char))
            if data.hasSuffix("\r\n\r\n") {
                Log.debug("\(socket.fd): \(data)")
                
                socket.send(string: "HTTP/1.1 404 Not found\r\nConnection: close\r\n\r\n") { (socket: ConnectedSocket, stream: protocol<InputStream, SeekableStream>) in
                    print("\(socket.fd): Sent 404")
                    
                    if !fullfilled {
                        fullfilled = true
                        expectation.fulfill()
                    }
                }
                return true
            }
            return true
        }
        
        if sock == nil {
            XCTFail("Could not initialize listening socket")
        }
        
        let curl = SubProcess(executable: Path("curl"), arguments: "http://127.0.0.1:4567")
        do {
            let out: InputStream = try curl.run()
            sleep(2)
            sock = nil // force close
            Log.debug("curl", curl.waitForExit())            
        } catch {
            XCTFail("Could not run curl")
        }
        self.waitForExpectations(withTimeout: 100, handler: nil)
    }

    func testSocketConnect() {
        let sock = Socket.connect(domain: "google.com", port: 80) { (socket: ConnectedSocket, char: UInt8) -> Bool in
            return true
        }
        
        if sock == nil {
            XCTFail("Could not connect socket")
        }
    }
}

extension SocketTests {
    static var allTests : [(String, (SocketTests) -> () throws -> Void)] {
        return [
            ("testSocketListen", testSocketListen),
            ("testSocketConnect", testSocketConnect),
        ]
    }
}
