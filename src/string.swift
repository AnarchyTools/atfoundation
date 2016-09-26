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
    public init?(path: Path) {
        self.init(path.description)
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

// TODO: Make Tests

/// Extension to UInt16 to convert to hex String
public extension UInt16 {

    /// Convert to hex string
    ///
    /// - Parameter padded: set to `true` to pad with zeroes, defaults to `true`
    /// - Returns: String of maximum length of 4 characters, hex encoded value
    func hexString(padded: Bool = true) -> String {
        let dict:[Character] = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
        var result = ""
        var somethingWritten = false
        for i in 0...3 {
            let value = Int(self >> UInt16(((3 - i) * 4)) & 0xf)
            if !padded && !somethingWritten && value == 0 {
                continue
            }
            somethingWritten = true
            result.append(dict[value])
        }
        if (result.characters.count == 0) {
            return "0"
        }
        return result
    }
}

// TODO: Make Tests

/// Extension to UInt8 to convert to hex String
public extension UInt8 {

    /// Convert to hex string
    ///
    /// - Parameter padded: set to `true` to pad with zeroes, defaults to `true`
    /// - Returns: String of maximum length of 2 characters, hex encoded value
    func hexString(padded: Bool = true) -> String {
        let dict:[Character] = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"]
        var result = ""

        let c1 = Int(self >> 4)
        let c2 = Int(self & 0xf)

        if c1 == 0 && padded {
            result.append(dict[c1])
        } else if c1 > 0 {
            result.append(dict[c1])
        }
        result.append(dict[c2])

        if (result.characters.count == 0) {
            return "0"
        }
        return result
    }
}