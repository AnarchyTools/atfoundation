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

public class Adler32 {

    private var s1: UInt32 = 1
    private var s2: UInt32 = 0
    private var counter: Int = 0

    /// Add data to checksum
    ///
    /// - parameter data: data to add to the checksum
    public func addData(_ data: [UInt8]) {
        for c in data {
            if self.counter == 5552 {
                self.counter = 0
                s1 = s1 % 65521
                s2 = s2 % 65521
            }
            s1 = (s1 + UInt32(c))
            s2 = (s2 + s1)
            self.counter += 1
        }
    }

    /// Get CRC of current state
    ///
    /// - returns: 32 Bits of CRC (current state)
    public var crc: UInt32 {
        return (self.s2 << 16) | self.s1
    }

    /// Calculate Adler32 CRC of String
    ///
    /// - parameter string: the string to calculate the CRC for
    /// - returns: 32 Bit CRC sum
    public class func crc(string: String) -> UInt32 {
        let data = [UInt8](string.utf8)
        return self.crc(data: data)
    }

    /// Calculate Adler32 CRC of Data
    ///
    /// - parameter data: data to calcuclate the CRC for
    /// - returns: 32 Bit CRC sum
    public class func crc(data: [UInt8]) -> UInt32 {
        let instance = Adler32()
        instance.addData(data)
        return instance.crc
    }

}

/// Adler32 CRC extension for String
public extension String {

    /// Calculate Adler32 CRC for string
    ///
    /// - returns: 32 Bit CRC sum
    public func adler32() -> UInt32 {
        return Adler32.crc(string: self)
    }
}