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

class DateTests: XCTestCase {

    func testISODateParsing() {
        if let date = Date(isoDateString: "1984-01-24T12:34:00Z") {
            XCTAssert(date.timestamp == 443795640)
            XCTAssert(date.year == 1984, "\(date.year) != 1984")
            XCTAssert(date.month == 1, "\(date.month) != 1")
            XCTAssert(date.day == 24, "\(date.day) != 24")
            XCTAssert(date.hour == 12, "\(date.hour) != 12")
            XCTAssert(date.minute == 34, "\(date.minute) != 34")
            XCTAssert(date.second == 0, "\(date.second) != 0")
            XCTAssert(date.weekDay == .Tuesday, "\(date.weekDay) != Tuesday")
            XCTAssert(date.dayOfYear == 23, "\(date.dayOfYear) != 23")
        } else {
            XCTFail("Failure to parse date")
        }
    }

    func testTimeStampToISODate() {
        let date = Date(timestamp: 443795640)
        XCTAssertNotNil(date.isoDateString)
        XCTAssert(date.isoDateString == "1984-01-24T12:34:00Z")
    }

    func testRFC822DateParsing() {
        if let date = Date(rfc822DateString: "Tue, 24 Jan 1984 12:34:00 +0000") {
            XCTAssert(date.timestamp == 443795640, "\(date.timestamp) != 443795640")
        } else {
            XCTFail("Failure to parse date")
        }
    }

    func testTimeStampToRFC822Date() {
        let date = Date(timestamp: 443795640)
        XCTAssertNotNil(date.isoDateString)
        XCTAssert(date.rfc822DateString == "Tue, 24 Jan 1984 12:34:00 +0000")
    }

    func testEqualDates() {
        let date1 = Date(timestamp: 443795640)
        let date2 = Date(isoDateString: "1984-01-24T12:34:00Z")!
        XCTAssert(date1 == date2)
    }

    func testBiggerDate() {
        let date1 = Date(timestamp: 443795640)
        let date2 = Date(isoDateString: "1984-01-25T12:34:00Z")!
        XCTAssert(date1 < date2)
        XCTAssert(date2 > date1)
        XCTAssertFalse(date1 == date2)
    }

    func testAddingDates() {
        let date1 = atfoundation.Date(timestamp: 86400)
        let date2 = atfoundation.Date(timestamp: 86400)
        XCTAssert(date1 + date2 == atfoundation.Date(timestamp: 86400 * 2))
        XCTAssert(date1 - date2 == Date(timestamp: 0))
    }

    func testAddingInterval() {
        let date1 = Date(timestamp: 86400)
        XCTAssert(date1 + TimeInterval(seconds: 100) == Date(timestamp: 86500))
        XCTAssert(date1 + TimeInterval(seconds: -100) == Date(timestamp: 86300))
    }

}

extension DateTests {
    static var allTests : [(String, (DateTests) -> () throws -> Void)] {
        return [
            ("testISODateParsing", testISODateParsing),
            ("testTimeStampToISODate", testTimeStampToISODate),
            ("testRFC822DateParsing", testRFC822DateParsing),
            ("testTimeStampToRFC822Date", testTimeStampToRFC822Date),
            ("testEqualDates", testEqualDates),
            ("testBiggerDate", testBiggerDate),
            ("testAddingDates", testAddingDates),
            ("testAddingInterval", testAddingInterval),
        ]
    }
}