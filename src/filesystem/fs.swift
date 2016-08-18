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
                throw SysError(errno: errno, path)
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
            throw SysError.NoSuchEntity(path)
        }
        if FS.isDirectory(path: path) {
            if recursive {
                try FS._rmdir_recursive(path: path)
            } else {
                if rmdir(path.description) != 0 {
                    throw SysError(errno: errno, path)
                }
            }
        } else {
            if unlink(path.description) != 0 {
                throw SysError(errno: errno, path)
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
                throw SysError(errno: errno, path)
            }
        } else {
            for idx in 0..<path.components.count {
                let subPath = Path(components: Array(path.components[0...idx]), absolute: path.isAbsolute)
                if !FS.fileExists(path: subPath) {
                    if mkdir(subPath.description, 511) != 0 {
                        throw SysError(errno: errno, subPath)
                    }
                } else {
                    if !FS.isDirectory(path: subPath) {
                        throw SysError.NotADirectory(subPath)
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
            throw SysError(errno: errno, path)
        }
        return FileInfo(path: path, statBuf: sbuf)
    }

    /// Get file/directory owner
    ///
    /// - Parameter path: path to query
    /// - Returns: User id of owner
    public class func getOwner(path: Path) throws -> uid_t {
        return try FS.getInfo(path: path).owner
    }

    /// Set file/directory owner
    ///
    /// - Parameter path: path to item
    /// - Parameter newOwner: User ID of new owner
    public class func setOwner(path: Path, newOwner: uid_t) throws {
        // TODO: Test
        let info = try self.getInfo(path: path)
        if chown(path.description, newOwner, info.group) < 0 {
            throw SysError(errno: errno, path)
        }
    }

    /// Get file/directory group
    ///
    /// - Parameter path: path to query
    /// - Returns: Group id of owner
    public class func getGroup(path: Path) throws -> gid_t {
        return try FS.getInfo(path: path).group
    }

    /// Set file/directory group
    ///
    /// - Parameter path: path to item
    /// - Parameter newGroup: Group ID of new owner
    public class func setGroup(path: Path, newGroup: gid_t) throws {
        let info = try self.getInfo(path: path)
        if chown(path.description, info.owner, newGroup) < 0 {
            throw SysError(errno: errno, path)
        }
    }

    /// Set file/directory owner
    ///
    /// - Parameter path: path to item
    /// - Parameter owner: User ID of new owner
    /// - Parameter group: Group ID of new owner
    public class func setOwnerAndGroup(path: Path, owner: uid_t, group: gid_t) throws {
        if chown(path.description, owner, group) < 0 {
            throw SysError(errno: errno, path)
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
        if chmod(path.description, mode.rawValue) < 0 {
            throw SysError(errno: errno, path)
        }
    }

    /// Fetch a group name for a group id
    ///
    /// - Parameter id: group id to resolve
    /// - Returns: string with group name or nil if it could not be resolved
    public class func resolveGroup(id: gid_t) throws -> String? {
        var grpBuf = group()
        var buffer = [Int8](repeating: 0, count: 1024)
        var result:UnsafeMutablePointer<group>? = nil
        let err = getgrgid_r(id, &grpBuf, &buffer, 1024, &result)

        if err != 0 {
            throw SysError(errno: err)
        }
        if result != nil {
            return String(validatingUTF8: grpBuf.gr_name)
        } else {
            return nil
        }
    }

    /// Fetch a group id for a group name
    ///
    /// - Parameter name: group name to resolve
    /// - Returns: group id or nil if it could not be resolved
    public class func resolveGroup(name: String) throws -> gid_t? {
        var grpBuf = group()
        var buffer = [Int8](repeating: 0, count: 1024)
        var result:UnsafeMutablePointer<group>? = nil
        let err = getgrnam_r(name, &grpBuf, &buffer, 1024, &result)

        if err != 0 {
            throw SysError(errno: err)
        }

        if result != nil {
            return grpBuf.gr_gid
        } else {
            return nil
        }
    }

    /// Fetch a user name for a user id
    ///
    /// - Parameter id: user id to resolve
    /// - Returns: string with user name or nil if it could not be resolved
    public class func resolveUser(id: uid_t) throws -> String? {
        var pwBuf = passwd()
        var buffer = [Int8](repeating: 0, count: 1024)
        var result:UnsafeMutablePointer<passwd>? = nil
        let err = getpwuid_r(id, &pwBuf, &buffer, 1024, &result)

        if err != 0 {
            throw SysError(errno: err)
        }
        if result != nil {
            return String(validatingUTF8: pwBuf.pw_name)
        } else {
            return nil
        }
    }

    /// Fetch a user id for a user name
    ///
    /// - Parameter name: user name to resolve
    /// - Returns: user id or nil if it could not be resolved
    public class func resolveUser(name: String) throws -> uid_t? {
        var pwBuf = passwd()
        var buffer = [Int8](repeating: 0, count: 1024)
        var result:UnsafeMutablePointer<passwd>? = nil
        let err = getpwnam_r(name, &pwBuf, &buffer, 1024, &result)

        if err != 0 {
            throw SysError(errno: err)
        }

        if result != nil {
            return pwBuf.pw_uid
        } else {
            return nil
        }
    }

    /// Get working directory
    ///
    /// - Returns: absolute path to current directory
    public class func getWorkingDirectory() throws -> Path {
        var buffer = [Int8](repeating: 0, count: 1025)
        if getcwd(&buffer, 1024) == nil {
            throw SysError(errno: errno)
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
            throw SysError(errno: errno, path)
        }
    }

    /// Create a symlink from one path to another
    ///
    /// - Parameter from: source path
    /// - Parameter to: destination path
    public class func symlinkItem(from: Path, to: Path) throws {
        if symlink(from.description, to.description) != 0 {
            throw SysError(errno: errno, to, from)
        }
    }

    #if os(Linux)
        public typealias Dir_t = OpaquePointer
    #else
        public typealias Dir_t = UnsafeMutablePointer<DIR>
    #endif

    /// Iterate over all entries in a directory
    ///
    /// - Parameter path: the path to iterate over
    /// - Parameter recursive: optional, recurse into sub directories, defaults to false
    /// - Parameter includeHidden: optional, include hidden files, defaults to false
    public class func iterateItems(path: Path, recursive: Bool = false, includeHidden: Bool = false) throws -> AnyIterator<FileInfo> {
        guard let d = opendir(path.description) else {
            throw SysError(errno: errno, path)
        }
        var deStack = [(Dir_t, dirent, Path)]()
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
                    #if os(Linux)
                        let typ = Int(de.d_type)
                    #else
                        let typ = Int32(de.d_type)
                    #endif
                    if typ == DT_DIR && recursive {
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
            let error = SysError(errno: errno, to, from)
            if case .CrossDeviceLink = error, !atomic {
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
            throw SysError.IsDirectory(from)
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
    public class func temporaryDirectory(prefix: String = "tempdir") throws -> Path {
        let p = Path.tempDirectory().appending(prefix + ".XXXXXXX")
        var buf = p.description.utf8CString
        let result = buf.withUnsafeMutableBufferPointer {
            mkdtemp($0.baseAddress)
        }
        if result == nil {
            throw SysError(errno: errno, p)
        }
        let dirname_ = buf.withUnsafeBufferPointer { (ptr) -> String? in
            if let o = ptr.baseAddress {
                    return String(cString: o) 
            } 
            return nil
        }
        if let dirname = dirname_ {
            return Path(dirname)
        } else {
            throw SysError.UnknownError
        }

    }

    /// Recursively copy a directory
    ///
    /// - Parameter from: source
    /// - Parameter to: destination
    @inline(__always) private class func _copy_recursive(from: Path, to: Path) throws {
        let iterator = try FS.iterateItems(path: from, recursive: true, includeHidden: true)
        for file in iterator {
            guard let relpath = file.path.relativeTo(path: from) else {
                throw SysError.InvalidArgument
            }
            let destinationPath = to + relpath
            switch file.type {
                case .FIFO:
                    if mkfifo(destinationPath.description, file.mode.rawValue) < 0 {
                        throw SysError(errno: errno, destinationPath)
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
    @inline(__always) private class func _copy_file(from: Path, to: Path) throws {
        let source = try File(path: from, mode: .ReadOnly, binary: true)
        try source.copyTo(path: to)
    }

    /// Recursive remove directory and all its content
    ///
    /// - Parameter path: path to remove
    private class func _rmdir_recursive(path: Path) throws {
        guard let d = opendir(path.description) else {
            throw SysError(errno: errno, path)
        }
        defer {
            closedir(d)
        }

        var de = dirent()
        var result:UnsafeMutablePointer<dirent>? = nil
        repeat {
            let status = readdir_r(d, &de, &result)
            guard status == 0 else {
                throw SysError(errno: status, path)
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
                #if os(Linux)
                    let typ = Int(de.d_type)
                #else
                    let typ = Int32(de.d_type)
                #endif
                if typ == DT_DIR {
                    try FS._rmdir_recursive(path: subPath)
                } else {
                    if unlink(subPath.description) != 0 {
                        throw SysError(errno: errno, subPath)
                    }
                }
            }
        } while true
        if rmdir(path.description) != 0 {
            throw SysError(errno: errno, path)
        }
    }
}
