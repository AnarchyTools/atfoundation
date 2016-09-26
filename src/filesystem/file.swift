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

public class ROFile: SeekableStream, InputStream {
    /// FILE pointer
    public var fp: UnsafeMutablePointer<FILE>?

    /// file path (may be nil if created from file descriptor or file pointer)
    private(set) public var path: Path?

    /// take ownership of the file descriptor/pointer
    private var closeWhenDeallocated: Bool

    /// Initialize with a path
    ///
    /// - Parameter path: the path to open
    /// - Parameter mode: file mode to use
    /// - Parameter binary: optional, open in binary mode, defaults to text mode
    public init(path: Path, binary: Bool = false) throws {
        var openMode = "r"
        if binary {
            openMode += "b"
        }
        self.path = path

        self.closeWhenDeallocated = false
        self.fp = fopen(path.description, openMode)
        if self.fp == nil {
            throw SysError(errno: errno, path)
        }
        self.closeWhenDeallocated = true
    }

    /// Initialize with a file descriptor
    ///
    /// - Parameter fd: the file descriptor to open
    /// - Parameter mode: file mode to use
    /// - Parameter binary: optional, open in binary mode, defaults to text mode
    /// - Parameter takeOwnership: optional, close file if this gets deallocated, defaults to false
    public init(fd: Int32, binary: Bool = false, takeOwnership: Bool = false) throws {
        var openMode = "r"
        if binary {
            openMode += "b"
        }

        self.closeWhenDeallocated = takeOwnership
        self.path = nil

        self.fp = fdopen(fd, openMode)
        if self.fp == nil {
            throw SysError(errno: errno, fd)
        }
    }

    /// Initialize with a file pointer
    ///
    /// - Parameter file: the file pointer to use
    /// - Parameter takeOwnership: optional, close file if this gets deallocated, defaults to false
    public init(file: UnsafeMutablePointer<FILE>, takeOwnership: Bool = false) {
        self.fp = file
        self.path = nil
        self.closeWhenDeallocated = takeOwnership
    }

    /// Close file if we have taken ownership
    deinit {
        if self.closeWhenDeallocated {
            fclose(self.fp)
        }
    }
}

public class WOFile: SeekableStream, OutputStream {
    /// FILE pointer
    public var fp: UnsafeMutablePointer<FILE>?

    /// file path (may be nil if created from file descriptor or file pointer)
    private(set) public var path: Path?

    /// take ownership of the file descriptor/pointer
    private var closeWhenDeallocated: Bool

    /// Initialize with a path
    ///
    /// - Parameter path: the path to open
    /// - Parameter mode: file mode to use
    /// - Parameter binary: optional, open in binary mode, defaults to text mode
    public init(path: Path, binary: Bool = false) throws {
        var openMode = "w"
        if binary {
            openMode += "b"
        }
        self.path = path

        self.closeWhenDeallocated = false
        self.fp = fopen(path.description, openMode)
        if self.fp == nil {
            throw SysError(errno: errno, path)
        }
        self.closeWhenDeallocated = true
    }

    /// Initialize with a file descriptor
    ///
    /// - Parameter fd: the file descriptor to open
    /// - Parameter mode: file mode to use
    /// - Parameter binary: optional, open in binary mode, defaults to text mode
    /// - Parameter takeOwnership: optional, close file if this gets deallocated, defaults to false
    public init(fd: Int32, binary: Bool = false, takeOwnership: Bool = false) throws {
        var openMode = "w"
        if binary {
            openMode += "b"
        }

        self.closeWhenDeallocated = takeOwnership
        self.path = nil

        self.fp = fdopen(fd, openMode)
        if self.fp == nil {
            throw SysError(errno: errno, fd)
        }
    }

    /// Initialize with a file pointer
    ///
    /// - Parameter file: the file pointer to use
    /// - Parameter takeOwnership: optional, close file if this gets deallocated, defaults to false
    public init(file: UnsafeMutablePointer<FILE>, takeOwnership: Bool = false) {
        self.fp = file
        self.path = nil
        self.closeWhenDeallocated = takeOwnership
    }

    /// Close file if we have taken ownership
    deinit {
        if self.closeWhenDeallocated {
            fclose(self.fp)
        }
    }
}

public class RWFile: SeekableStream, InputStream, OutputStream {
    /// FILE pointer
    public var fp: UnsafeMutablePointer<FILE>?

    /// file path (may be nil if created from file descriptor or file pointer)
    private(set) public var path: Path?

    /// take ownership of the file descriptor/pointer
    private var closeWhenDeallocated: Bool

    /// Initialize with a path
    ///
    /// - Parameter path: the path to open
    /// - Parameter mode: file mode to use
    /// - Parameter binary: optional, open in binary mode, defaults to text mode
    public init(path: Path, binary: Bool = false) throws {
        var openMode = "r+"
        if binary {
            openMode += "b"
        }
        self.path = path

        self.closeWhenDeallocated = false
        self.fp = fopen(path.description, openMode)
        if self.fp == nil {
            throw SysError(errno: errno, path)
        }
        self.closeWhenDeallocated = true
    }

    /// Initialize with a file descriptor
    ///
    /// - Parameter fd: the file descriptor to open
    /// - Parameter mode: file mode to use
    /// - Parameter binary: optional, open in binary mode, defaults to text mode
    /// - Parameter takeOwnership: optional, close file if this gets deallocated, defaults to false
    public init(fd: Int32, binary: Bool = false, takeOwnership: Bool = false) throws {
        var openMode = "r+"
        if binary {
            openMode += "b"
        }

        self.closeWhenDeallocated = takeOwnership
        self.path = nil

        self.fp = fdopen(fd, openMode)
        if self.fp == nil {
            throw SysError(errno: errno, fd)
        }
    }

    /// Initialize with a file pointer
    ///
    /// - Parameter file: the file pointer to use
    /// - Parameter takeOwnership: optional, close file if this gets deallocated, defaults to false
    public init(file: UnsafeMutablePointer<FILE>, takeOwnership: Bool = false) {
        self.fp = file
        self.path = nil
        self.closeWhenDeallocated = takeOwnership
    }

    /// Close file if we have taken ownership
    deinit {
        if self.closeWhenDeallocated {
            fclose(self.fp)
        }
    }
}

/// Posix file abstraction class
public class File: SeekableStream, InputStream, OutputStream {
    /// FILE pointer
    public var fp: UnsafeMutablePointer<FILE>?

    /// file path (may be `nil` if created from file descriptor or file pointer)
    private(set) public var path: Path?

    /// take ownership of the file descriptor/pointer
    private var closeWhenDeallocated: Bool

    /// File mode
    public enum Mode:String {
        /// Read only
        case ReadOnly      = "r"

        /// Write only
        case WriteOnly     = "w"

        /// Read an write
        case ReadAndWrite  = "r+"

        /// Write only, set position to end
        case AppendOnly    = "a"

        /// Read and write, set position to end
        case AppendAndRead = "a+"
    }

    /// Initialize with a path
    ///
    /// - Parameter path: the path to open
    /// - Parameter mode: file mode to use
    /// - Parameter binary: optional, open in binary mode, defaults to text mode
    public init(path: Path, mode: Mode, binary: Bool = false) throws {
        var openMode = mode.rawValue
        if binary {
            openMode += "b"
        }
        self.path = path

        self.closeWhenDeallocated = false
        self.fp = fopen(path.description, openMode)
        if self.fp == nil {
            throw SysError(errno: errno, path)
        }
        self.closeWhenDeallocated = true
    }

    /// Initialize with a file descriptor
    ///
    /// - Parameter fd: the file descriptor to open
    /// - Parameter mode: file mode to use
    /// - Parameter binary: optional, open in binary mode, defaults to text mode
    /// - Parameter takeOwnership: optional, close file if this gets deallocated, defaults to false
    public init(fd: Int32, mode: Mode, binary: Bool = false, takeOwnership: Bool = false) throws {
        var openMode = mode.rawValue
        if binary {
            openMode += "b"
        }

        self.closeWhenDeallocated = takeOwnership
        self.path = nil

        self.fp = fdopen(fd, openMode)
        if self.fp == nil {
            throw SysError(errno: errno, fd)
        }
    }

    /// Initialize with a file pointer
    ///
    /// - Parameter file: the file pointer to use
    /// - Parameter takeOwnership: optional, close file if this gets deallocated, defaults to false
    public init(file: UnsafeMutablePointer<FILE>, takeOwnership: Bool = false) {
        self.fp = file
        self.path = nil
        self.closeWhenDeallocated = takeOwnership
    }

    /// Initialize with a temporary file name
    ///
    /// - Parameter tempFileAtPath: path to create the temp file in
    /// - Parameter prefix: file name prefix to use
    /// - Parameter binary: optional, open in binary mode, defaults to text mode
    public convenience init(tempFileAtPath path: Path, prefix: String, binary: Bool = false) throws {
        let p = path.appending(prefix + ".XXXXXXX")
        var buf = p.description.utf8CString
        let fd = buf.withUnsafeMutableBufferPointer {
            mkstemp($0.baseAddress)
        }
        let filename_ = buf.withUnsafeBufferPointer { (ptr) -> String? in
            if let o = ptr.baseAddress {
                    return String(cString: o) 
            } 
            return nil
        }
        if let filename = filename_ {
            try self.init(fd: fd, mode: .ReadAndWrite, binary: binary, takeOwnership: true)
            self.path = Path(filename)
        } else {
            close(fd)
            throw SysError.UnknownError(file: #file, line: #line, function: #function)
        }
    }

    /// Create a completely temporary file in the temp dir
    ///
    /// - Parameter binary: optional, open in binary mode, defaults to text mode
    /// - Returns: File instance for a unique temporary file
    public class func tempFile(binary: Bool = false) throws -> File {
        return try File(tempFileAtPath: Path.tempDirectory(), prefix: "tmp", binary: binary)
    }

    /// Close file if we have taken ownership
    deinit {
        if self.closeWhenDeallocated {
            fclose(self.fp)
        }
    }

    /// Copy this file to another path
    ///
    /// - Parameter path: the path to copy the file to
    public func copyTo(path: Path) throws {
        let output = try File(path: path, mode: .WriteOnly, binary: true)
        try self.copyTo(stream: output)
        if let srcPath = self.path {
            let fileMode = try FS.getAttributes(path: srcPath)
            try FS.setAttributes(path: path, mode: fileMode)
        }
    }
}
