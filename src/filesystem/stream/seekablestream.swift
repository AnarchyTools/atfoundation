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

public protocol SeekableStream: class, Stream {
    var position: Int { get set }
    var size: Int { get }

    func truncate(size: Int) throws
    // func copyTo(stream: protocol<OutputStream, SeekableStream>) throws
}

public extension SeekableStream {

    /// seek to a position or return position
    public var position: Int {
        set(newValue) {
            fseek(self.fp, newValue, SEEK_SET)
        }

        get {
            return ftell(self.fp)
        }
    }

    /// query file size
    public var size: Int {
        get {
            let offset = self.position
            fseek(self.fp, 0, SEEK_END)
            let size = self.position
            self.position = offset
            return size
        }
    }

    /// Truncate or preallocate a file
    ///
    /// - Parameter size: size of the file after this operation. If it
    ///                   is bigger than the current size remaining
    ///                   size is prefilled with zeroes.
    public func truncate(size: Int) throws {
        var e: SysError
        while true {
            fflush(self.fp)
            if ftruncate(fileno(self.fp), off_t(size)) != 0 {
                e = SysError(errno: errno)
                if case .Interrupted = e {
                    continue
                }
                throw e
            }
            break
        }
        fflush(self.fp)
    }
}

public extension InputStream where Self: SeekableStream {

    /// Copy this file to another file
    ///
    /// - Parameter file: the file to copy the file content to
    public func copyTo(stream: OutputStream & SeekableStream) throws {
        try stream.truncate(size: 0)
        stream.position = 0

        var oldPosition = self.position
        self.position = 0
        defer {
            self.position = oldPosition
        }
        while true {
            do {
                let buffer:[UInt8] = try self.read(size: 4096)
                try stream.write(data: buffer)
            } catch SysError.EndOfFile {
                return
            }
        }
    }
}