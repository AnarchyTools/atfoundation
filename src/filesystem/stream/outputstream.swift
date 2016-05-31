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

public protocol OutputStream: class, Stream {
    func write(string: String) throws
    func writeLine(string: String) throws
    func write(data: [UInt8]) throws
    func flush()
}

public extension OutputStream {
    /// Write a string to the file
    ///
    /// - Parameter string: the string to write
    public func write(string: String) throws {
        let bytes = string.utf8.count
        while true {
            let written = fwrite(string, 1, bytes, self.fp)
            if bytes != written {
                let err = SysError(errno: errno)
                if case .TryAgain = err {
                    continue
                }
                if case .Interrupted = err{
                    continue
                }
            }
            break
        }
    }

    /// Write a line to the file, newline is appended automatically
    ///
    /// - Parameter string: the string to write
    public func writeLine(string: String) throws {
        while true {
            let bytes = fputs(string + "\n", self.fp)
            if bytes < 0 {
                let err = SysError(errno: errno)
                if case .TryAgain = err{
                    continue
                }
                if case .Interrupted = err{
                    continue
                }
            }
            break
        }
        self.flush()
    }

    /// Write data to the file
    ///
    /// - Parameter data: UInt8 array with bytes to write
    public func write(data: [UInt8]) throws {
        let bytes = data.count
        var written = 0
        while true {
            written += fwrite([UInt8](data[written..<bytes]), 1, bytes - written, self.fp)
            if bytes != written {
                let err = SysError(errno: errno)
                if case .TryAgain = err {
                    continue
                }
                if case .Interrupted = err {
                    continue
                }
                throw err
            }
            break
        }
    }

    /// Flush all buffers to disk
    public func flush() {
        fflush(self.fp)
    }
}