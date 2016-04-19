#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

/// Posix file abstraction class
public class File {
    /// FILE pointer
    public let fp: UnsafeMutablePointer<FILE>?

    /// file path (may be nil if created from file descriptor or file pointer)
    private(set) public var path: Path?

    /// take ownership of the file descriptor/pointer
    private let closeWhenDeallocated: Bool

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

    /// fetch a file descriptor for this file
    public var fd: Int32 {
        return fileno(self.fp)
    }

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
        self.closeWhenDeallocated = true

        self.fp = fopen(path.description, openMode)
        if self.fp == nil {
            throw errnoToError(errno: errno)
        }
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
            throw errnoToError(errno: errno)
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
        let buf = Array(p.description.utf8)
        let fd = mkstemp(UnsafeMutablePointer(buf))
        if let filename = String(validatingUTF8: UnsafeMutablePointer(buf)) {
            try self.init(fd: fd, mode: .ReadAndWrite, binary: binary, takeOwnership: true)
            self.path = Path(string: filename)
        } else {
            throw SysError.UnknownError
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

    /// Read bytes into a string
    ///
    /// - Parameter size: maximum size to read, may return less bytes on EOF
    /// - Returns: String read from file if valid UTF-8 or nil
    public func read(size: Int) throws -> String? {
        var buffer:[UInt8] = try self.read(size: size)
        buffer.append(0)
        return String(validatingUTF8: UnsafePointer<CChar>(buffer))
    }

    /// Read bytes from file
    ///
    /// - Parameter size: maximum size to read, may return less bytes on EOF
    /// - Returns: UInt8 array with bytes
    public func read(size: Int) throws -> [UInt8] {
        var buffer = [UInt8](repeating: 0, count: size)
        let read = fread(UnsafeMutablePointer(buffer), 1, size, self.fp)
        if read == 0 {
            if feof(self.fp) == 0 {
                throw errnoToError(errno: errno)
            } else {
                throw SysError.EndOfFile
            }
        }
        if read < size {
            buffer = Array(buffer[0..<read])
        }
        return buffer
    }

    /// Read complete file into a string
    ///
    /// - Returns: String read from file if valid UTF-8 or nil
    public func readAll() throws -> String? {
        let buffer:[UInt8] = try self.readAll()
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
        let buffer = [UInt8](repeating: 0, count: 64 * 1024)
        let read = fgets(UnsafeMutablePointer(buffer), 64 * 1024, self.fp)
        if read == nil {
            if feof(self.fp) == 0 {
                throw errnoToError(errno: errno)
            } else {
                throw SysError.EndOfFile
            }
        }
        return String(validatingUTF8: UnsafePointer<CChar>(buffer))
    }

    /// Write a string to the file
    ///
    /// - Parameter string: the string to write
    public func write(string: String) throws {
        let bytes = string.utf8.count
        let written = fwrite(string, 1, bytes, self.fp)
        if bytes != written {
            throw errnoToError(errno: errno)
        }
    }

    /// Write a line to the file, newline is appended automatically
    ///
    /// - Parameter string: the string to write
    public func writeLine(string: String) throws {
        let bytes = fputs(string + "\n", self.fp)
        if bytes < 0 {
            throw errnoToError(errno: errno)
        }
    }

    /// Write data to the file
    ///
    /// - Parameter data: UInt8 array with bytes to write
    public func write(data: [UInt8]) throws {
        let bytes = data.count
        let written = fwrite(data, 1, bytes, self.fp)
        if bytes != written {
            throw errnoToError(errno: errno)
        }
    }

    /// Flush all buffers to disk
    public func flush() {
        fflush(self.fp)
    }

    /// Truncate or preallocate a file
    ///
    /// - Parameter size: size of the file after this operation. If it
    ///                   is bigger than the current size remaining
    ///                   size is prefilled with zeroes.
    public func truncate(size: Int) throws {
        var e: SysError? = nil
        repeat {
            fflush(self.fp)
            if ftruncate(fileno(self.fp), off_t(size)) != 0 {
                e = errnoToError(errno: errno)
                if e! != .Interrupted {
                    throw e!
                }
            }
        } while e == .Interrupted
        fflush(self.fp)
    }

    /// Iterate over chunks of data
    ///
    /// The file position is saved internally, so you may use multiple
    /// iterators at once. Warning: this does not mean it is thread safe
    /// to do that!
    ///
    /// - Parameter chunkSize: size to read for each iteration. Last
    ///                        iteration may return less than that.
    public func iterate(chunkSize: Int) -> AnyIterator<[UInt8]> {
        var position = self.position

        return AnyIterator {
            self.position = position
            do {
                let buffer:[UInt8] = try self.read(size: chunkSize)
                position += buffer.count
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

    /// Copy this file to another path
    ///
    /// - Parameter path: the path to copy the file to
    public func copyTo(path: Path) throws {
        let output = try File(path: path, mode: .WriteOnly, binary: true)
        var oldPosition = self.position
        self.position = 0
        defer {
            self.position = oldPosition
        }
        while true {
            do {
                let buffer:[UInt8] = try self.read(size: 4096)
                try output.write(data: buffer)
            } catch SysError.EndOfFile {
                return
            }
        }
    }
}