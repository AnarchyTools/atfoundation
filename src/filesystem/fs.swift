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

    /// Update modification time for existing item or create empty file
    ///
    /// - Parameter path: path to update/create
    public class func touchItem(path: Path) throws {
        if !FS.fileExists(path: path) {
            let _ = try File(path: path, mode: .WriteOnly)
        } else {
            if utimes(path.description, nil) < 0 {
                throw errnoToError(errno: errno)
            }
        }
    }

    /// Remove item from file system
    ///
    /// If `path` is a non-empty directory and `recursive` is false
    /// an error will be thrown!
    ///
    /// - Parameter path: path to remove
    /// - Parameter recursive: optional, set to true to recursively remove directories
    public class func removeItem(path: Path, recursive: Bool = false) throws {
        if !FS.fileExists(path: path) {
            throw SysError.NoSuchEntity
        }
        if FS.isDirectory(path: path) {
            if recursive {
                try FS._rmdir_recursive(path: path)
            } else {
                if rmdir(path.description) != 0 {
                    throw errnoToError(errno: errno)
                }
            }
        } else {
            if unlink(path.description) != 0 {
                throw errnoToError(errno: errno)
            }
        }
    }

    /// Create a directory
    ///
    /// - Parameter path: directory to create
    /// - Parameter intermediate: optional set to true if you want the complete path to
    ///                           be created with intermediate directories included
    public class func createDirectory(path: Path, intermediate: Bool = false) throws {
        if !intermediate {
            if mkdir(path.description, 511) != 0 {
                throw errnoToError(errno: errno)
            }
        } else {
            for idx in 0..<path.components.count {
                let subPath = Path(components: Array(path.components[0...idx]), absolute: path.isAbsolute)
                if !FS.fileExists(path: subPath) {
                    if mkdir(subPath.description, 511) != 0 {
                        throw errnoToError(errno: errno)
                    }
                } else {
                    if !FS.isDirectory(path: subPath) {
                        throw SysError.NotADirectory
                    }
                }
            }
        }
    }

    /// Get file information for a path
    ///
    /// - Parameter path: path to query
    /// - Returns: FileInfo struct
    public class func getInfo(path: Path) throws -> FileInfo {
        var sbuf = stat()
        let result = stat(path.description, &sbuf)
        if result < 0 {
            throw errnoToError(errno: errno)
        }
        return FileInfo(path: path, statBuf: sbuf)
    }

    /// Get file/directory owner
    ///
    /// - Parameter path: path to query
    /// - Returns: User id of owner
    public class func getOwner(path: Path) throws -> UInt32 {
        return try FS.getInfo(path: path).owner
    }

    /// Set file/directory owner
    ///
    /// - Parameter path: path to item
    /// - Parameter newOwner: User ID of new owner
    public class func setOwner(path: Path, newOwner: UInt32) throws {
        // TODO: Test
        let info = try self.getInfo(path: path)
        if chown(path.description, newOwner, info.group) < 0 {
            throw errnoToError(errno: errno)
        }
    }

    /// Get file/directory group
    ///
    /// - Parameter path: path to query
    /// - Returns: Group id of owner
    public class func getGroup(path: Path) throws -> UInt32 {
        return try FS.getInfo(path: path).group
    }

    /// Set file/directory group
    ///
    /// - Parameter path: path to item
    /// - Parameter newGroup: Group ID of new owner
    public class func setGroup(path: Path, newGroup: UInt32) throws {
        // TODO: Test
        let info = try self.getInfo(path: path)
        if chown(path.description, info.owner, newGroup) < 0 {
            throw errnoToError(errno: errno)
        }
    }

    /// Set file/directory owner
    ///
    /// - Parameter path: path to item
    /// - Parameter owner: User ID of new owner
    /// - Parameter group: Group ID of new owner
    public class func setOwnerAndGroup(path: Path, owner: UInt32, group: UInt32) throws {
        // TODO: Test
        if chown(path.description, owner, group) < 0 {
            throw errnoToError(errno: errno)
        }
    }

    /// Get file/directory size
    ///
    /// - Parameter path: path to query
    /// - Returns: File size
    public class func getSize(path: Path) throws -> UInt64 {
        return try FS.getInfo(path: path).size
    }

    /// Get file/directory mode
    ///
    /// - Parameter path: path to query
    /// - Returns: File mode
    public class func getAttributes(path: Path) throws -> FileMode {
        return try FS.getInfo(path: path).mode
    }

    /// Change attributes of a filesystem object
    ///
    /// - Parameter path: path to item to change
    /// - Parameter mode: attributes to set
    public class func setAttributes(path: Path, mode: FileMode) throws {
        // TODO: Test
        if chmod(path.description, mode.rawValue) < 0 {
            throw errnoToError(errno: errno)
        }
    }

    /// Get working directory
    ///
    /// - Returns: absolute path to current directory
    public class func getWorkingDirectory() throws -> Path {
        var buffer = [Int8](repeating: 0, count: 1025)
        if getcwd(&buffer, 1024) == nil {
            throw errnoToError(errno: errno)
        }
        if let dir = String(validatingUTF8: buffer) {
            return Path(dir)
        } else {
            throw SysError.InvalidArgument
        }
    }

    /// Change working directory
    ///
    /// - Parameter path: path to change current directory to
    public class func changeWorkingDirectory(path: Path) throws {
        if chdir(path.description) != 0 {
            throw errnoToError(errno: errno)
        }
    }

    /// Create a symlink from one path to another
    ///
    /// - Parameter from: source path
    /// - Parameter to: destination path
    public class func symlinkItem(from: Path, to: Path) throws {
        if symlink(from.description, to.description) != 0 {
            throw errnoToError(errno: errno)
        }
    }

    /// Iterate over all entries in a directory
    ///
    /// - Parameter path: the path to iterate over
    /// - Parameter recursive: optional, recurse into sub directories, defaults to false
    /// - Parameter includeHidden: optional, include hidden files, defaults to false
    public class func iterateItems(path: Path, recursive: Bool = false, includeHidden: Bool = false) throws -> AnyIterator<FileInfo> {
        guard let d = opendir(path.description) else {
            throw errnoToError(errno: errno)
        }
        var deStack = [(UnsafeMutablePointer<DIR>, dirent, Path)]()
        deStack.append((d, dirent(), path))

        return AnyIterator {
            repeat {
                guard let stackFrame = deStack.last else {
                    return nil
                }

                let d = stackFrame.0
                var de = stackFrame.1
                let path = stackFrame.2

                var result:UnsafeMutablePointer<dirent>? = nil
                guard readdir_r(d, &de, &result) == 0 else {
                    closedir(d)
                    deStack.removeLast()
                    continue
                }
                if result == nil {
                    closedir(d)
                    deStack.removeLast()
                    continue
                }

                deStack.removeLast()
                deStack.append((d, de, path))

                var buffer:[Int8] = fixedCArrayToArray(data: &de.d_name)
                buffer.append(0)

                if let filename = String(validatingUTF8: buffer) {
                    if filename == "." || filename == ".." {
                        continue
                    }

                    if filename.hasPrefix(".") && !includeHidden {
                        continue
                    }

                    let subPath = path.appending(filename)
                    if Int32(de.d_type) == DT_DIR && recursive {
                        if let subD = opendir(subPath.description) {
                            deStack.append((subD, dirent(), subPath))
                        }
                    }

                    var sbuf = stat()
                    if stat(subPath.description, &sbuf) == 0 {
                        return FileInfo(path: subPath, statBuf: sbuf)
                    }
                }
            } while true
        }
    }

    /// Move a filesystem item from one place to another
    ///
    /// - Parameter from: item to move
    /// - Parameter to: destination
    /// - Parameter atomic: optional, if true bail out if the destination
    ///                     is on another file system than the source.
    ///                     If set to false we copy then remove the source
    ///                     in that case. Defaults to true.
    public class func moveItem(from: Path, to: Path, atomic: Bool = true) throws {
        // TODO: Test
        let result = rename(from.description, to.description)
        if result < 0 {
            let error = errnoToError(errno: errno)
            if error == .CrossDeviceLink && !atomic {
                try FS.copyItem(from: from, to: to, recursive: true)
                try FS.removeItem(path: from, recursive: true)
            } else {
                throw error
            }
        }
    }

    /// Copy a filesystem item from one place to another
    ///
    /// - Parameter from: item to move
    /// - Parameter to: destination
    /// - Parameter recursive: optional, if `from` is a directory copy recursively,
    ///                        defaults to false
    public class func copyItem(from: Path, to: Path, recursive: Bool = false) throws {
        // TODO: Test
        let isDir = FS.isDirectory(path: from)
        if !recursive && isDir {
            throw SysError.IsDirectory
        }
        if isDir {
            try FS._copy_recursive(from: from, to: to)
        } else {
            try FS._copy_file(from: from, to: to)
        }
        let mode = try FS.getAttributes(path: from)
        try FS.setAttributes(path: to, mode: mode)
    }

    /// Create and return a unique temporary directory
    ///
    /// - Parameter prefix: prefix name of the directory
    /// - Returns: path to the already created directory
    public class func temporaryDirectory(prefix: String) throws -> Path {
        // TODO: Test
        let p = Path.tempDirectory().appending(prefix + ".XXXXXXX")
        let buf = Array(p.description.utf8)
        let _ = mkdtemp(UnsafeMutablePointer(buf))
        if let dirname = String(validatingUTF8: UnsafeMutablePointer(buf)) {
            let path = Path(dirname)
            return path
        } else {
            throw SysError.UnknownError
        }

    }

    /// Recursively copy a directory
    ///
    /// - Parameter from: source
    /// - Parameter to: destination
    private class func _copy_recursive(from: Path, to: Path) throws {
        let iterator = try FS.iterateItems(path: from, recursive: true, includeHidden: true)
        for file in iterator {
            guard let relpath = file.path.relativeTo(path: from) else {
                throw SysError.InvalidArgument
            }
            let destinationPath = to + relpath
            switch file.type {
                case .FIFO:
                    if mkfifo(destinationPath.description, file.mode.rawValue) < 0 {
                        throw errnoToError(errno: errno)
                    }
                    try FS.setAttributes(path: destinationPath, mode: file.mode)
                case .Directory:
                    try FS.createDirectory(path: destinationPath)
                    try FS.setAttributes(path: destinationPath, mode: file.mode)
                case .File:
                    try FS._copy_file(from: file.path, to: destinationPath)
                    try FS.setAttributes(path: destinationPath, mode: file.mode)
                case .Symlink:
                    if let target = file.linkTarget {
                        try FS.symlinkItem(from: target, to: destinationPath)
                    }
                default:
                    // skip?
                    continue
            }
        }
    }

    /// Copy a file
    ///
    /// - Parameter from: source
    /// - Parameter to: destination, will be truncated before copying
    private class func _copy_file(from: Path, to: Path) throws {
        let source = try File(path: from, mode: .ReadOnly, binary: true)
        try source.copyTo(path: to)
    }

    /// Recursive remove directory and all its content
    ///
    /// - Parameter path: path to remove
    private class func _rmdir_recursive(path: Path) throws {
        guard let d = opendir(path.description) else {
            throw errnoToError(errno: errno)
        }
        defer {
            closedir(d)
        }

        var de = dirent()
        var result:UnsafeMutablePointer<dirent>? = nil
        repeat {
            guard readdir_r(d, &de, &result) == 0 else {
                throw errnoToError(errno: errno)
            }
            if result == nil {
                break
            }

            var buffer:[Int8] = fixedCArrayToArray(data: &de.d_name)
            buffer.append(0)

            if let filename = String(validatingUTF8: buffer) {
                if filename == "." || filename == ".." {
                    continue
                }

                let subPath = path.appending(filename)
                if Int32(de.d_type) == DT_DIR {
                    try FS._rmdir_recursive(path: subPath)
                } else {
                    if unlink(subPath.description) != 0 {
                        throw errnoToError(errno: errno)
                    }
                }
            }
        } while true
        if rmdir(path.description) != 0 {
            throw errnoToError(errno: errno)
        }
    }
}
