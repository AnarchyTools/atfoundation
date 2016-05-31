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

public protocol InputStream: class, Stream {
    func read(size: Int) throws -> String?
    func read(size: Int) throws -> [UInt8]
    func readAll() throws -> String?
    func readAll() throws -> [UInt8]
    func readLine() throws -> String?

    func iterate(chunkSize: Int) -> AnyIterator<[UInt8]>
    func iterateLines() -> AnyIterator<String>

    func pipe(to: OutputStream) throws
}


public extension InputStream {

    /// Read bytes into a string
    ///
    /// - Parameter size: maximum size to read, may return less bytes on EOF
    /// - Returns: String read from file if valid UTF-8 or nil
    public func read(size: Int = 4096) throws -> String? {
        var buffer:[UInt8] = try self.read(size: size)
        buffer.append(0)
        return String(validatingUTF8: UnsafePointer<CChar>(buffer))
    }

    /// Read bytes from file
    ///
    /// - Parameter size: maximum size to read, may return less bytes on EOF
    /// - Returns: UInt8 array with bytes
    public func read(size: Int = 4096) throws -> [UInt8] {
        var buffer = [UInt8](repeating: 0, count: size)
        while true {
            let read = fread(UnsafeMutablePointer(buffer), 1, size, self.fp)
            if read == 0 {
                if feof(self.fp) == 0 {
                    let err = SysError(errno: errno)
                    if case .TryAgain = err {
                        continue
                    }
                    if case .Interrupted = err {
                        continue
                    }
                } else {
                    throw SysError.EndOfFile
                }
            }
            if read < size {
                buffer = Array(buffer[0..<read])
            }
            break;
        }
        return buffer
    }

    /// Read complete file into a string
    ///
    /// - Returns: String read from file if valid UTF-8 or nil
    public func readAll() throws -> String? {
        var buffer:[UInt8] = try self.readAll()
        buffer.append(0)
        return String(validatingUTF8: UnsafePointer<CChar>(buffer))
    }

    /// Read complete file
    ///
    /// - Returns: Uint8 array of bytes read from file
    public func readAll() throws -> [UInt8] {
        var buffer = [UInt8]()
        while true {
            do {
                let tmp: [UInt8] = try self.read(size: 4096)
                buffer.append(contentsOf: tmp)
            } catch SysError.EndOfFile {
                return buffer
            }
        }
    }

    /// Read a single line from a file, max 64 KiB
    ///
    /// - Returns: String read from file (newline included) if valid UTF-8 or nil
    public func readLine() throws -> String? {
        let buffer = [UInt8](repeating: 0, count: 64 * 1024 + 1)
        while true {
            let read = fgets(UnsafeMutablePointer(buffer), 64 * 1024, self.fp)
            if read == nil {
                if feof(self.fp) == 0 {
                    let err = SysError(errno: errno)
                    if case .TryAgain = err {
                        continue
                    }
                    if case .Interrupted = err {
                        continue
                    }
                } else {
                    throw SysError.EndOfFile
                }
            }
            break;
        }
        return String(validatingUTF8: UnsafePointer<CChar>(buffer))
    }

    /// Iterate over chunks of data
    ///
    /// - Parameter chunkSize: size to read for each iteration. Last
    ///                        iteration may return less than that.
    public func iterate(chunkSize: Int) -> AnyIterator<[UInt8]> {
        return AnyIterator {
            do {
                let buffer:[UInt8] = try self.read(size: chunkSize)
                return buffer
            } catch {
                return nil
            }
        }
    }

    /// Iterate over lines of the file
    public func iterateLines() -> AnyIterator<String> {
        return AnyIterator {
            do {
                let result = try self.readLine()
                return result
            } catch {
                return nil
            }
        }
    }

    /// Pipe data from current position to output stream until end of current stream
    ///
    /// - Parameter to: the stream to copy data to
    public func pipe(to destination: OutputStream) throws {
        while true {
            do {
                let buffer:[UInt8] = try self.read(size: 4096)
                try destination.write(data: buffer)
            } catch SysError.EndOfFile {
                return
            }
        }
    }
}