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

class PathTests: XCTestCase {

    func testInitNoDelimiter() {
        let p = Path("test")
        XCTAssert(p.components.count == 1)
        if p.components.count >= 1 {
            XCTAssert(p.components[0] == "test")
        }
        XCTAssert(p.isAbsolute == false)
    }

    func testInitWithDelimiter() {
        let p = Path("test/dir")
        XCTAssert(p.components.count == 2)
        if p.components.count >= 2 {
            XCTAssert(p.components[0] == "test")
            XCTAssert(p.components[1] == "dir")
        }
        XCTAssert(p.isAbsolute == false)
    }

    func testInitAbsolutePath() {
        let p = Path("/test/dir")
        XCTAssert(p.components.count == 2)
        if p.components.count >= 2 {
            XCTAssert(p.components[0] == "test")
            XCTAssert(p.components[1] == "dir")
        }
        XCTAssert(p.isAbsolute == true)
    }

    func testInitComponentsRelative() {
        let p = Path(components: ["test", "dir"])
        XCTAssert(p.components.count == 2)
        if p.components.count >= 2 {
            XCTAssert(p.components[0] == "test")
            XCTAssert(p.components[1] == "dir")
        }
        XCTAssert(p.isAbsolute == false)
    }

    func testInitComponentsAbsolute() {
        let p = Path(components: ["test", "dir"], absolute: true)
        XCTAssert(p.components.count == 2)
        if p.components.count >= 2 {
            XCTAssert(p.components[0] == "test")
            XCTAssert(p.components[1] == "dir")
        }
        XCTAssert(p.isAbsolute == true)
    }

    func testAppending() {
        let p = Path("/test/dir")
        let q = p.appending("bar")
        XCTAssert(q.components.count == 3)
        if q.components.count >= 3 {
            XCTAssert(q.components[2] == "bar")
        }
        XCTAssert(q.isAbsolute == true)
    }

    func testRemovingLastComponent() {
        let p = Path("/test/dir/foo")
        let q = p.removingLastComponent()
        XCTAssert(q.components.count == 2)
        XCTAssert(q.isAbsolute == true)
    }

    func testRemovingFirstComponent() {
        let p = Path("/test/dir/foo")
        let q = p.removingFirstComponent()
        XCTAssert(q.components.count == 2)
        if q.components.count >= 2 {
            XCTAssert(q.components[0] == "dir")
            XCTAssert(q.components[1] == "foo")
        }
        XCTAssert(q.isAbsolute == false)
    }

    func testJoin() {
        let p = Path("/test/dir")
        let q = Path("bar")
        let r = p + q
        XCTAssert(r.components.count == 3)
        if r.components.count >= 3 {
            XCTAssert(r.components[0] == "test")
            XCTAssert(r.components[1] == "dir")
            XCTAssert(r.components[2] == "bar")
        }
        XCTAssert(r.isAbsolute == true)
    }

    func testJoinAbsolute() {
        let p = Path("/test/dir")
        let q = Path("/bar")
        let r = p + q
        XCTAssert(r.components.count == 1)
        if r.components.count > 0 {
            XCTAssert(r.components[0] == "bar")
        }
        XCTAssert(r.isAbsolute == true)
    }

    func testRelativeTo() {
        let p = Path("/this/is/a/long/path/it/goes/on/and/on")
        let q = Path("/this/is/a/long/path")
        if let r = p.relativeTo(path: q) {
            XCTAssert(r.components.count == 5)
            if r.components.count == 5 {
                XCTAssert(r.components[0] == "it")
                XCTAssert(r.components[1] == "goes")
                XCTAssert(r.components[2] == "on")
                XCTAssert(r.components[3] == "and")
                XCTAssert(r.components[4] == "on")
            }
            XCTAssert(r.isAbsolute == false)
        } else {
            XCTFail("Should not be nil")
        }
    }

    func testRelativeUpTo() {
        let p = Path("/this/is/another/long/path/it/goes/on/and/on")
        let q = Path("/this/is/a/long/path")
        if let r = p.relativeTo(path: q) {
            XCTAssert(r.components.count == 11)
            if r.components.count >= 11 {
                XCTAssert(r.components[0] == "..")
                XCTAssert(r.components[1] == "..")
                XCTAssert(r.components[2] == "..")
                XCTAssert(r.components[3] == "another")
                XCTAssert(r.components[4] == "long")
                XCTAssert(r.components[5] == "path")
                XCTAssert(r.components[6] == "it")
                XCTAssert(r.components[7] == "goes")
                XCTAssert(r.components[8] == "on")
                XCTAssert(r.components[9] == "and")
                XCTAssert(r.components[10] == "on")
            }
            XCTAssert(r.isAbsolute == false)
        } else {
            XCTFail("Should not be nil")
        }
    }

    func testRelativeToRelative() {
        let p = Path("this/is/a/long/path/it/goes/on/and/on")
        let q = Path("/this/is/a/long/path")
        let r = p.relativeTo(path: q)
        XCTAssert(r == nil)
    }

    func testHomeDir() {
        if let p = Path.homeDirectory() {
#if os(Linux)
            XCTAssert(p.components.count > 0, "Home dir has \(p.components.count) components")
            // disabled because CI has something other than /home/ci
            // if p.components.count >= 2 {
            //     XCTAssert(p.components[0] == "home")
            // }
            XCTAssert(p.isAbsolute == true)
#else
            XCTAssert(p.components.count == 2)
            if p.components.count >= 2 {
                XCTAssert(p.components[0] == "Users")
            }
            XCTAssert(p.isAbsolute == true)
#endif
        } else {
            XCTFail("Should not be nil")
        }
    }

    func testTempDir() {
        let p = Path.tempDirectory()
        XCTAssert(p.components.count == 1)
        if p.components.count >= 1 {
            XCTAssert(p.components[0] == "tmp")
        }
        XCTAssert(p.isAbsolute == true)
    }

    func testDescriptionRelative() {
        let p = Path("relative/path")
        XCTAssert(p.description == "relative/path")
    }

    func testDescriptionAbsolute() {
        let p = Path("/absolute/path")
        XCTAssert(p.description == "/absolute/path")
    }
}

extension PathTests {
    static var allTests : [(String, (PathTests) -> () throws -> Void)] {
        return [
            ("testInitNoDelimiter", testInitNoDelimiter),
            ("testInitWithDelimiter", testInitWithDelimiter),
            ("testInitAbsolutePath", testInitAbsolutePath),
            ("testInitComponentsRelative", testInitComponentsRelative),
            ("testInitComponentsAbsolute", testInitComponentsAbsolute),
            ("testAppending", testAppending),
            ("testRemovingLastComponent", testRemovingLastComponent),
            ("testRemovingFirstComponent", testRemovingFirstComponent),
            ("testJoin", testJoin),
            ("testJoinAbsolute", testJoinAbsolute),
            ("testRelativeTo", testRelativeTo),
            ("testRelativeUpTo", testRelativeUpTo),
            ("testRelativeToRelative", testRelativeToRelative),
            ("testHomeDir", testHomeDir),
            ("testTempDir", testTempDir),
            ("testDescriptionRelative", testDescriptionRelative),
            ("testDescriptionAbsolute", testDescriptionAbsolute)
        ]
    }
}
