#if os(Linux)
import Glibc
#else
import Darwin
#endif

public class FS {

    /// Check if a file exists and return true if it does
    ///
    /// - Parameter path: path to check
    /// - Returns: `true` if the file exists
    public class func fileExists(path: Path) -> Bool {
        var sbuf = stat()
        let result = stat(path.description, &sbuf)
        if result < 0 {
            if errno == ENOENT {
                return false
            }
        }
        return true
    }

    /// Check if a path is a directory and return true if it is
    ///
    /// - Parameter path: path to check
    /// - Returns: `true` if the path is a directory
    public class func isDirectory(path: Path) -> Bool {
        var sbuf = stat()
        let result = stat(path.description, &sbuf)
        if result == 0 {
            if sbuf.st_mode & S_IFDIR != 0 {
                return true
            }
        }
        return false
    }

// - moveItem(from:to:) throws
// - copyItem(from:to:recursive:) throws
// - removeItem(path:) throws
// - touchItem(path:) throws
// - symlinkItem(from:to:) throws
// - createDirectory(path:intermediate:) throws
// - createTempFile(prefix:suffix:) -> File
// - getOwner(path:) throws -> Int
// - getGroup(path:) throws -> Int
// - getSize(path:) throws -> UInt64
// - getInfo(path:) throws -> FileInfo
// - getCurrentDirectory() -> Path
// - changeCurrentDirectory(path:) throws
//
// - iterate(path:recursive:includeHidden:) throws -> AnyGenerator<FileInfo>


}