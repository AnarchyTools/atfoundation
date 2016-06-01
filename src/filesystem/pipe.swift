
/// Create an unidirectional pipe (one read end and one write end)
///
/// - returns: a read pipe and a write pipe
public func UnidirectionalPipe() throws -> (write: WritePipe, read: ReadPipe) {
    var fds = [Int32](repeating: 0, count: 2)
    let result = pipe(&fds)
    if result != 0 {
        throw SysError(errno: errno)
    }
    return (write: try WritePipe(fd: fds[1]), read: try ReadPipe(fd: fds[0]))
}

/// Create a bidirectional pipe (two r/w ends)
///
/// - returns: two bidirectional streams connected to each other
public func BidirectionalPipe() throws -> (RWPipe, RWPipe) {
    var fds = [Int32](repeating: 0, count: 2)
    let result = socketpair(PF_LOCAL, SOCK_STREAM, 0, &fds)
    if result != 0 {
        throw SysError(errno: errno)
    }
    return (try RWPipe(fd: fds[0]), try RWPipe(fd: fds[1]))
}

/// A writable pipe
public class WritePipe: OutputStream {

    /// File pointer
    public var fp: UnsafeMutablePointer<FILE>?

    /// Initialize with a file descriptor
    ///
    /// - parameter fd: a file descriptor
    private init(fd: Int32) throws {
        self.fp = fdopen(fd, "wb")

        if self.fp == nil {
            throw SysError(errno: errno, fd)
        }
    }

    deinit {
        if let fp = self.fp {
            fclose(fp)
        }
    }
}

public protocol ReadEvents: class, InputStream {
    var readThread: Thread? { get set }

    func onReadData(cb: ([UInt8]) -> Void)
    func onReadLine(cb: (String) -> Void)
}

public extension ReadEvents {
    public func onReadData(cb: ([UInt8]) -> Void) {
        self.readThread = Thread() {
            while true {
                var fds = pollfd()
                fds.fd = fileno(self.fp)
                fds.events = Int16(POLLIN) | Int16(POLLERR) | Int16(POLLHUP)
                if poll(&fds, 1, -1) < 0 {
                    let err = SysError(errno: errno)
                    if case .TryAgain = err {
                        continue
                    }
                    return
                }
                if fds.revents & Int16(POLLIN) == 0 {
                    return
                }
                do {
                    let data: [UInt8] = try self.read()
                    cb(data)
                } catch {
                    return
                }
            }
        }
    }

    public func onReadLine(cb: (String) -> Void) {
        self.readThread = Thread() {
            while true {
                guard let fp = self.fp else {
                    return
                }
                var fds = pollfd()
                fds.fd = fileno(fp)
                fds.events = Int16(POLLIN) | Int16(POLLERR) | Int16(POLLHUP)
                if poll(&fds, 1, -1) < 0 {
                    let err = SysError(errno: errno)
                    if case .TryAgain = err {
                        continue
                    }
                    return
                }
                if fds.revents & Int16(POLLIN) == 0 {
                    return
                }
                do {
                    if let line = try self.readLine() {
                        cb(line)
                    }
                } catch {
                    return
                }
            }
        }
    }
}

/// A readable pipe
public class ReadPipe: InputStream {
    public var readThread: Thread? = nil

    /// File pointer
    public var fp: UnsafeMutablePointer<FILE>?

    /// Initialize with a file descriptor
    ///
    /// - parameter fd: a file descriptor
    private init(fd: Int32) throws {
        self.fp = fdopen(fd, "rb")

        if self.fp == nil {
            throw SysError(errno: errno, fd)
        }
    }

    deinit {
        if let fp = self.fp {
            fclose(fp)
        }
    }
}

extension ReadPipe: ReadEvents { }

/// A bidirectional pipe
public class RWPipe: InputStream, OutputStream {
    public var readThread: Thread? = nil

    /// File pointer
    public var fp: UnsafeMutablePointer<FILE>?

    /// Initialize with a file descriptor
    ///
    /// - parameter fd: a file descriptor
    private init(fd: Int32) throws {
        self.fp = fdopen(fd, "r+b")

        if self.fp == nil {
            throw SysError(errno: errno, fd)
        }
    }

    deinit {
        if let fp = self.fp {
            fclose(fp)
        }
    }
}

extension RWPipe: ReadEvents { }
