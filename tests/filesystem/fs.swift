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

class FSTests: XCTestCase {

    func testFileExists() {
        let p = Path("./build.atpkg")
        XCTAssert(FS.fileExists(path: p) == true)
    }

    func testFileDoesNotExist() {
        let p = Path("./does_not_exist")
        XCTAssert(FS.fileExists(path: p) == false)
    }

    func testIsDirExisting() {
        let p = Path("./src")
        XCTAssert(FS.isDirectory(path: p) == true)
    }

    func testIsDirNonExisting() {
        let p = Path("./does_not_exist")
        XCTAssert(FS.isDirectory(path: p) == false)
    }

    func testIsDirFile() {
        let p = Path("./build.atpkg")
        XCTAssert(FS.isDirectory(path: p) == false)
    }

    func testTouchAndRemoveFile() {
        do {
            let p = try FS.temporaryDirectory() + "tempfile.tmp"
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
        do {
            let p = try FS.temporaryDirectory() + "tempdir.tmp"
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
        do {
            let p = try FS.temporaryDirectory() + "tempdir.tmp"
            let s = p.appending("subdir")
            let q = s.appending("file.tmp")
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
        do {
            let p = try FS.temporaryDirectory() + "testfile.tmp"
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

    func testChmodFile() {
        do {
            let p = try FS.temporaryDirectory() + "testfile.tmp"
            try FS.touchItem(path: p)
            XCTAssert(FS.fileExists(path: p) == true)
            var attrib = try FS.getAttributes(path: p)
            XCTAssert(attrib.description != "rw-rw-rw-")
            try FS.setAttributes(path: p, mode: FileMode.ReadAll + FileMode.WriteAll)
            attrib = try FS.getAttributes(path: p)
            XCTAssert(attrib.description == "rw-rw-rw-", attrib.description)
            try FS.removeItem(path: p)
            XCTAssert(FS.fileExists(path: p) == false)
        } catch {
            XCTFail("Error thrown \(error)")
        }
    }

    func testResolveGroup() {
        do {
            let gid = getgid()
            let name = try FS.resolveGroup(id: gid)
            XCTAssertNotNil(name)
            let resolved_gid = try FS.resolveGroup(name: name!)
            XCTAssertNotNil(resolved_gid)
            XCTAssert(gid == resolved_gid!)
        } catch {
            XCTFail("Error thrown \(error)")
        }
    }

    func testResolveUser() {
        do {
            let uid = getuid()
            let name = try FS.resolveUser(id: uid)
            XCTAssertNotNil(name)
            let resolved_uid = try FS.resolveUser(name: name!)
            XCTAssertNotNil(resolved_uid)
            XCTAssert(uid == resolved_uid!)
        } catch {
            XCTFail("Error thrown \(error)")
        }
    }

    func testSetGroup() {
        do {
            let p = try FS.temporaryDirectory() + "testfile.tmp"
            try FS.touchItem(path: p)
            XCTAssert(FS.fileExists(path: p) == true)
            let gid = try FS.getGroup(path: p)
            let everyone = try FS.resolveGroup(name: "everyone")
            XCTAssertNotNil(everyone)
            try FS.setGroup(path: p, newGroup: everyone!)
            let newGroup = try FS.getGroup(path: p)
            XCTAssert(gid != newGroup)
            XCTAssert(newGroup == everyone!)

            try FS.removeItem(path: p)
            XCTAssert(FS.fileExists(path: p) == false)
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
            ("testChmodFile", testChmodFile),
            ("testResolveGroup", testResolveGroup),
            ("testResolveUser", testResolveUser),
            ("testSetGroup", testSetGroup)
        ]
    }
}