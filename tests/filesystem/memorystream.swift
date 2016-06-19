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

class MemoryStreamTests: XCTestCase {

	func testFromData() {
		let stream = MemoryStream(data: [0, 1, 2, 3, 4, 5])
		XCTAssertEqual(stream.size, 6)
		if stream.size == 6 {
			XCTAssertEqual(stream.buffer[0], 0)
			XCTAssertEqual(stream.buffer[1], 1)
			XCTAssertEqual(stream.buffer[2], 2)
			XCTAssertEqual(stream.buffer[3], 3)
			XCTAssertEqual(stream.buffer[4], 4)
			XCTAssertEqual(stream.buffer[5], 5)
		}
	}

	func testFromString() {
		let stream = MemoryStream(string: "Hello")
		XCTAssertEqual(stream.size, 5)
		if stream.size == 5 {
			XCTAssertEqual(stream.buffer[0], 0x48)
			XCTAssertEqual(stream.buffer[1], 0x65)
			XCTAssertEqual(stream.buffer[2], 0x6c)
			XCTAssertEqual(stream.buffer[3], 0x6c)
			XCTAssertEqual(stream.buffer[4], 0x6f)
		}
	}

	func testReadData() {
		let stream = MemoryStream(string: "Hello World")
		stream.position = 0
		do {
			let result: [UInt8] = try stream.read(size: 5)
			XCTAssertEqual(result.count, 5)
			if result.count == 5 {
				XCTAssertEqual(result[0], 0x48)
				XCTAssertEqual(result[1], 0x65)
				XCTAssertEqual(result[2], 0x6c)
				XCTAssertEqual(result[3], 0x6c)
				XCTAssertEqual(result[4], 0x6f)
			}
			XCTAssertEqual(stream.position, 5)
		} catch {
			XCTFail("Error thrown: \(error)")
		}
	}

	func testReadString() {
		let stream = MemoryStream(string: "Hello World")
		stream.position = 0
		do {
			let result: String? = try stream.read(size: 5)
			XCTAssertNotNil(result)
			XCTAssertEqual(result!.characters.count, 5)
			XCTAssertEqual(result!, "Hello")
			XCTAssertEqual(stream.position, 5)
		} catch {
			XCTFail("Error thrown: \(error)")
		}
	}

	func testReadLine() {
		let stream = MemoryStream(string: "Hello World\nAnother line")
		stream.position = 0
		do {
			let result = try stream.readLine()
			XCTAssertNotNil(result)
			XCTAssertEqual(result!.characters.count, 12)
			XCTAssertEqual(result!, "Hello World\n")
			XCTAssertEqual(stream.position, 12)
			let result2 = try stream.readLine()
			XCTAssertNotNil(result2)
			XCTAssertEqual(result2!.characters.count, 12)
			XCTAssertEqual(result2!, "Another line")
			XCTAssertEqual(stream.position, 24)
		} catch {
			XCTFail("Error thrown: \(error)")
		}
	}

	func testReadAllString() {
		let stream = MemoryStream(string: "Hello World\nAnother line")
		stream.position = 0
		do {
			let result: String? = try stream.readAll()
			XCTAssertNotNil(result)
			XCTAssertEqual(result!.characters.count, 24)
			XCTAssertEqual(result!, "Hello World\nAnother line")
			XCTAssertEqual(stream.position, 24)
		} catch {
			XCTFail("Error thrown: \(error)")
		}
	}

	func testReadAllData() {
		let string = "Hello World\nAnother line"
		let stream = MemoryStream(string: string)
		stream.position = 0
		do {
			let result: [UInt8] = try stream.readAll()
			XCTAssertNotNil(result)
			XCTAssertEqual(result.count, 24)
			var index = string.utf8.startIndex
			for i in 0..<result.count {
				XCTAssertEqual(result[i], string.utf8[index])
				index = string.utf8.index(index, offsetBy: 1)
			}
			XCTAssertEqual(stream.position, 24)
		} catch {
			XCTFail("Error thrown: \(error)")
		}
	}

	func testWriteDataAppending() {
		let stream = MemoryStream(string: "Hello World\nAnother line\n")
		do {
			try stream.write(data: [0x48, 0x65, 0x6c, 0x6c, 0x6f])
			stream.position = 0
			let result: String? = try stream.readAll()
			XCTAssertNotNil(result)
			XCTAssertEqual(result!, "Hello World\nAnother line\nHello")
			XCTAssertEqual(stream.position, 30)
		} catch {
			XCTFail("Error thrown: \(error)")
		}
	}

	func testWriteStringAppending() {
		let stream = MemoryStream(string: "Hello World\nAnother line\n")
		do {
			try stream.write(string: "Hello")
			stream.position = 0
			let result: String? = try stream.readAll()
			XCTAssertNotNil(result)
			XCTAssertEqual(result!, "Hello World\nAnother line\nHello")
			XCTAssertEqual(stream.position, 30)
		} catch {
			XCTFail("Error thrown: \(error)")
		}
	}

	func testWriteLineAppending() {
		let stream = MemoryStream(string: "Hello World\nAnother line\n")
		do {
			try stream.writeLine(string: "Hello")
			stream.position = 0
			let result: String? = try stream.readAll()
			XCTAssertNotNil(result)
			XCTAssertEqual(result!, "Hello World\nAnother line\nHello\n")
			XCTAssertEqual(stream.position, 31)
		} catch {
			XCTFail("Error thrown: \(error)")
		}
	}

	func testTruncate() {
		let stream = MemoryStream(string: "Hello World\nAnother line\n")
		do {
			try stream.truncate(size: 5)
			XCTAssertEqual(stream.size, 5)

			stream.position = 0
			let result: String? = try stream.readAll()
			XCTAssertNotNil(result)
			XCTAssertEqual(result!, "Hello")
		} catch {
			XCTFail("Error thrown: \(error)")
		}
	}

	func testExtend() {
		let stream = MemoryStream(string: "Hello World\nAnother line\n")
		do {
			try stream.truncate(size: 50)
			XCTAssertEqual(stream.size, 50)

			stream.position = 0
			let result: [UInt8] = try stream.readAll()
			XCTAssertNotNil(result)
			XCTAssertEqual(result.count, 50)
		} catch {
			XCTFail("Error thrown: \(error)")
		}
	}

	func testPipe() {
		let stream = MemoryStream(string: "Hello World\nAnother line")
		stream.position = 0
		let secondStream = MemoryStream()
		do {
			try stream.pipe(to: secondStream)
			XCTAssertEqual(stream, secondStream)
		} catch {
			XCTFail("Error thrown: \(error)")
		}
	}

	func testSeek() {
		let stream = MemoryStream(string: "Hello World")
		stream.position = 6
		do {
			let result: String? = try stream.read(size: 5)
			XCTAssertNotNil(result)
			XCTAssertEqual(result!.characters.count, 5)
			XCTAssertEqual(result!, "World")
			XCTAssertEqual(stream.position, 11)
		} catch {
			XCTFail("Error thrown: \(error)")
		}
	}

	func testOverwrite() {
		let stream = MemoryStream(string: "Hello World")
		stream.position = 6
		do {
			try stream.write(string: "Hello")
			stream.position = 0
			let result: String? = try stream.readAll()
			XCTAssertNotNil(result)
			XCTAssertEqual(result!.characters.count, 11)
			XCTAssertEqual(result!, "Hello Hello")
			XCTAssertEqual(stream.position, 11)
		} catch {
			XCTFail("Error thrown: \(error)")
		}
	}

	func testOverwriteAppend() {
		let stream = MemoryStream(string: "Hello World")
		stream.position = 6
		do {
			try stream.write(string: "Hello World")
			stream.position = 0
			let result: String? = try stream.readAll()
			XCTAssertNotNil(result)
			XCTAssertEqual(result!.characters.count, 17)
			XCTAssertEqual(result!, "Hello Hello World")
			XCTAssertEqual(stream.position, 17)
		} catch {
			XCTFail("Error thrown: \(error)")
		}
	}
}

extension MemoryStreamTests {
    static var allTests : [(String, (MemoryStreamTests) -> () throws -> Void)] {
        return [
            ("testFromData", testFromData),
            ("testFromString", testFromString),
            ("testReadData", testReadData),
            ("testReadString", testReadString),
            ("testReadLine", testReadLine),
            ("testReadAllString", testReadAllString),
            ("testReadAllData", testReadAllData),
            ("testWriteDataAppending", testWriteDataAppending),
            ("testWriteStringAppending", testWriteStringAppending),
            ("testWriteLineAppending", testWriteLineAppending),
            ("testTruncate", testTruncate),
            ("testExtend", testExtend),
            ("testPipe", testPipe),
            ("testSeek", testSeek),
            ("testOverwrite", testOverwrite),
            ("testOverwriteAppend", testOverwriteAppend)
        ]
    }
}