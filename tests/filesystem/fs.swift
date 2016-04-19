import XCTest

@testable import atfoundation

class FSTests: XCTestCase {

    func testFileExists() {
        let p = Path(string:"./build.atpkg")
        XCTAssert(FS.fileExists(path: p) == true)
    }

    func testFileDoesNotExist() {
        let p = Path(string:"./does_not_exist")
        XCTAssert(FS.fileExists(path: p) == false)
    }

    func testIsDirExisting() {
        let p = Path(string:"./src")
        XCTAssert(FS.isDirectory(path: p) == true)
    }

    func testIsDirNonExisting() {
        let p = Path(string:"./does_not_exist")
        XCTAssert(FS.isDirectory(path: p) == false)
    }

    func testIsDirFile() {
        let p = Path(string:"./build.atpkg")
        XCTAssert(FS.isDirectory(path: p) == false)
    }
}

extension FSTests {
    static var allTests : [(String, FSTests -> () throws -> Void)] {
        return [
            ("testFileExists", testFileExists),
            ("testFileDoesNotExist", testFileDoesNotExist),
            ("testIsDirExisting", testIsDirExisting),
            ("testIsDirNonExisting", testIsDirNonExisting),
            ("testIsDirFile", testIsDirFile)
        ]
    }
}