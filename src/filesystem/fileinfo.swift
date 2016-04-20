#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// UNIX File mode
public struct FileMode: OptionSet {
    public let rawValue: Int

    public static let Inaccessible = FileMode(rawValue: 0)

    public static let ExecOthers   = FileMode(rawValue: 1 << 0)
    public static let WriteOthers  = FileMode(rawValue: 1 << 1)
    public static let ReadOthers   = FileMode(rawValue: 1 << 2)
    public static let RWOthers     = [ReadOthers, WriteOthers]

    public static let ExecGroup    = FileMode(rawValue: 1 << 3)
    public static let WriteGroup   = FileMode(rawValue: 1 << 4)
    public static let ReadGroup    = FileMode(rawValue: 1 << 5)
    public static let RWGroup      = [ReadGroup, WriteGroup]

    public static let ExecOwner    = FileMode(rawValue: 1 << 6)
    public static let WriteOwner   = FileMode(rawValue: 1 << 7)
    public static let ReadOwner    = FileMode(rawValue: 1 << 8)
    public static let RWOwner      = [ReadOwner, WriteOwner]

    public static let ExecAll      = [ExecOthers, ExecGroup, ExecOwner]
    public static let WriteAll     = [WriteOthers, WriteGroup, WriteOwner]
    public static let ReadAll      = [ReadOthers, ReadGroup, ReadOwner]

    public static let StickyBit    = FileMode(rawValue: 1 << 9)
    public static let SetGID       = FileMode(rawValue: 1 << 10)
    public static let SetUID       = FileMode(rawValue: 1 << 11)

    public init(rawValue: Int) {
        self.rawValue = rawValue & ((1 << 12) - 1)
    }

    private init(_ mode: FileMode) {
        self.rawValue = mode.rawValue
    }
}

extension FileMode: CustomStringConvertible {
    public var description : String {
        var result = ""
        result += (self.contains(.ReadOwner))  ? "r" : "-"
        result += (self.contains(.WriteOwner)) ? "w" : "-"
        result += (self.contains(.ExecOwner))  ? "x" : "-"

        result += (self.contains(.ReadGroup))  ? "r" : "-"
        result += (self.contains(.WriteGroup)) ? "w" : "-"
        result += (self.contains(.ExecGroup))  ? "x" : "-"

        result += (self.contains(.ReadOthers))  ? "r" : "-"
        result += (self.contains(.WriteOthers)) ? "w" : "-"
        result += (self.contains(.ExecOthers))  ? "x" : "-"

        return result
    }
}

/// File information
public struct FileInfo {

    /// path to the file
    let path: Path

    /// owner
    let owner: UInt32

    /// group
    let group: UInt32

    /// mode
    let mode: FileMode

    /// file size
    let size: UInt64

    /// is this a directory
    let isDir: Bool

    /// is this a symlink
    let isLink: Bool

    /// path to original if this is a symlink
    let linkTarget: Path?

    /// modification timestamp
    let mTime: Int

    /// creation timestamp
    let cTime: Int

    /// last access timestamp
    let aTime: Int

    internal init(path: Path, statBuf: stat) {
        self.path = path
        self.owner = statBuf.st_uid
        self.group = statBuf.st_gid
        self.mode = FileMode(rawValue: Int(statBuf.st_mode))
        self.size = UInt64(statBuf.st_size)
        self.isDir = (statBuf.st_mode & S_IFDIR != 0)
        self.isLink = (statBuf.st_mode & S_IFLNK != 0)
        if self.isLink {
            var link = [Int8](repeating: 0, count: 1024)
            readlink(path.description, &link, 1024)
            if let target = String(validatingUTF8: link) {
                self.linkTarget = Path(string: target)
            } else {
                self.linkTarget = nil
            }
        } else {
            self.linkTarget = nil
        }

        self.mTime = statBuf.st_mtimespec.tv_sec
        self.cTime = statBuf.st_ctimespec.tv_sec
        self.aTime = statBuf.st_atimespec.tv_sec
    }
}

