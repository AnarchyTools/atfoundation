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

    func testTouchAndRemoveFile() {
        let p = Path.tempDirectory().appending("testfile.tmp")
        do {
            try FS.touchItem(path: p)
            XCTAssert(FS.fileExists(path: p) == true)
            try FS.touchItem(path: p)
            try FS.removeItem(path: p)
            XCTAssert(FS.fileExists(path: p) == false)
        } catch {
            XCTFail("Error thrown \(error)")
        }
    }

    func testCreateAndRemoveDirectory() {
        let p = Path.tempDirectory().appending("tempdir.tmp")
        do {
            try FS.createDirectory(path: p)
            XCTAssert(FS.isDirectory(path: p) == true)
            try FS.removeItem(path: p)
            XCTAssert(FS.isDirectory(path: p) == false)
            XCTAssert(FS.fileExists(path: p) == false)
        } catch {
            XCTFail("Error thrown \(error)")
        }
    }

    func testCreateAndRemoveDirectories() {
        let p = Path.tempDirectory().appending("tempdir.tmp")
        let s = p.appending("subdir")
        let q = s.appending("file.tmp")
        do {
            try FS.createDirectory(path: s, intermediate: true)
            XCTAssert(FS.isDirectory(path: p) == true)
            XCTAssert(FS.isDirectory(path: s) == true)
            try FS.touchItem(path: q)
            XCTAssert(FS.fileExists(path: q) == true)
            try FS.removeItem(path: p, recursive: true)
            XCTAssert(FS.isDirectory(path: p) == false)
            XCTAssert(FS.fileExists(path: p) == false)
        } catch {
            XCTFail("Error thrown \(error)")
        }
    }

    func testGetInfo() {
        let p = Path.tempDirectory().appending("testfile.tmp")
        do {
            try FS.touchItem(path: p)
            XCTAssert(FS.fileExists(path: p) == true)
            let info1 = try FS.getInfo(path: p)
            sleep(1)
            try FS.touchItem(path: p)
            let info2 = try FS.getInfo(path: p)
            XCTAssert(info1.mTime != info2.mTime)
            try FS.removeItem(path: p)
            XCTAssert(FS.fileExists(path: p) == false)
        } catch {
            XCTFail("Error thrown \(error)")
        }
    }

    func testIterate() {
        do {
            let iterator = try FS.iterateItems(path: try FS.getWorkingDirectory())
            var found = false
            for file in iterator {
                if file.path.basename() == "build.atpkg" {
                    found = true
                }
            }
            XCTAssert(found == true)
        } catch {
            XCTFail("Error thrown \(error)")
        }
    }

    func testIterateRecursive() {
        do {
            let iterator = try FS.iterateItems(path: try FS.getWorkingDirectory(), recursive: true)
            var count = 0
            for file in iterator {
                if file.path.basename() == "fs.swift" {
                    count += 1
                }
            }
            XCTAssert(count == 2)
        } catch {
            XCTFail("Error thrown \(error)")
        }
    }
}

extension FSTests {
    static var allTests : [(String, FSTests -> () throws -> Void)] {
        return [
            ("testFileExists", testFileExists),
            ("testFileDoesNotExist", testFileDoesNotExist),
            ("testIsDirExisting", testIsDirExisting),
            ("testIsDirNonExisting", testIsDirNonExisting),
            ("testIsDirFile", testIsDirFile),
            ("testTouchAndRemoveFile", testTouchAndRemoveFile),
            ("testCreateAndRemoveDirectory", testCreateAndRemoveDirectory),
            ("testCreateAndRemoveDirectories", testCreateAndRemoveDirectories),
            ("testGetInfo", testGetInfo),
        ]
    }
}