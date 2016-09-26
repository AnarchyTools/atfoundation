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

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public final class MemoryStream: InputStream, OutputStream, SeekableStream {
    internal var buffer = [UInt8]()

    public var fp: UnsafeMutablePointer<FILE>? = nil
    public let fd: Int32 = -1

    public var position: Int = 0
    public var size: Int {
        return buffer.count
    }

    public convenience init(string: String) {
        self.init(capacity: string.utf8.count)
        try! self.write(string: string)
    }

    public convenience init(data: [UInt8]) {
        self.init(capacity: data.count)
        try! self.write(data: data)
    }

    public convenience init() {
        self.init(capacity: 255)
    }

    public init(capacity: Int) {
        self.buffer.reserveCapacity(capacity)
    }

    public func truncate(size: Int) throws {
        if size == self.buffer.count {
            return
        }

        if size > self.buffer.count {
            let start = self.buffer.count
            self.buffer.reserveCapacity(size)
            for _ in start..<size {
                self.buffer.append(0)
            }
        } else {
            self.buffer.removeLast(self.buffer.count - size)
        }

        self.position = self.buffer.count
    }

    public func read(size: Int) throws -> String? {
        var slice: [UInt8] = try self.read(size: size)
        slice.append(0)
        return slice.withUnsafeBufferPointer {
            return String(cString: $0.baseAddress!)
        }
    }

    public func read(size: Int) throws -> [UInt8] {
        if self.position >= buffer.count {
            throw SysError.EndOfFile
        }

        let end = min(self.position + size, self.buffer.count)
        let slice = [UInt8](self.buffer[self.position..<end])
        self.position = end
        return slice        
    }

    public func readAll() throws -> String? {
        var slice: [UInt8] = try self.readAll()
        slice.append(0)
        return slice.withUnsafeBufferPointer {
            return String(cString: $0.baseAddress!)
        }
    }

    public func readAll() throws -> [UInt8] {
        if self.position >= buffer.count {
            throw SysError.EndOfFile
        }

        let slice = [UInt8](self.buffer[self.position..<self.buffer.count])
        self.position = self.buffer.count
        return [UInt8](slice)
    }

    public func readLine() throws -> String? {
        if self.position >= buffer.count {
            throw SysError.EndOfFile
        }

        var slice = [UInt8]()
        for char in self.buffer[self.position..<self.buffer.count] {
            slice.append(char)
            if char == 0x0a {
                self.position += slice.count
                slice.append(0)
                return slice.withUnsafeBufferPointer {
                    return String(cString: $0.baseAddress!)
                }
            }
        }
        if slice.count > 0 {
            self.position += slice.count
            slice.append(0)
            return slice.withUnsafeBufferPointer {
                return String(cString: $0.baseAddress!)
            }
        } else {
            return nil
        }
    }

    public func pipe(to: OutputStream) throws {
        try to.write(data: self.readAll())
    }

    public func write(string: String) throws {
        let data = [UInt8](string.utf8)
        try self.write(data: data)
    }

    public func writeLine(string: String) throws {
        try self.write(string: string + "\n")
    }

    public func write(data: [UInt8]) throws {
        if self.position == self.buffer.count {
            self.buffer.append(contentsOf: data)
            self.position = self.buffer.count
        } else if self.position > self.buffer.count {
            try self.truncate(size: self.position)
            self.buffer.append(contentsOf: data)
            self.position = self.buffer.count
        } else {
            for i in self.position..<self.buffer.count {
                self.buffer[i] = data[i - self.position]
            }
            if (self.position + data.count > self.buffer.count) {
                self.buffer.append(contentsOf: data[(self.buffer.count - self.position)..<data.count])
            }
            self.position += data.count
        }
    }

    public func flush() {
        // this has no effect
    }
}

extension MemoryStream: Hashable {
    public var hashValue: Int {
        return Int(Adler32.crc(data: self.buffer)) + self.position
    }
}

public func ==(lhs: MemoryStream, rhs: MemoryStream) -> Bool {
    if lhs.buffer.count != rhs.buffer.count {
        return false
    }
    if lhs.position != rhs.position {
        return false
    }
    for i in 0..<lhs.buffer.count {
        if lhs.buffer[i] != rhs.buffer[i] {
            return false
        }
    }
    return true
}
