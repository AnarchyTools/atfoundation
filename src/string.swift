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

public extension String {

    /// Create string from path
    ///
    /// - Parameter path: a path
    public init(path: Path) {
        self.init(path.description)!
    }

    /// Load a string from a file
    ///
    /// - Parameter loadFromFile: the filename
    public init?(loadFromFile path: Path) throws {
        let f = try File(path: path, mode: .ReadOnly)
        if let s: String = try f.readAll() {
            self.init(s)
        } else {
            return nil
        }
    }

    /// Write a string to a file
    ///
    /// - Parameter to: file to write to
    public func write(to file: File) throws {
        try file.write(string: self)
    }

    /// Write a string to a new file
    ///
    /// - Parameter to: filename to write the string to
    public func write(to path: Path) throws {
        let f = try File(path: path, mode: .WriteOnly)
        try f.write(string: self)
        f.flush()
    }
}