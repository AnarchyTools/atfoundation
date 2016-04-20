#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// UNIX File mode
public struct FileMode: OptionSet {
    public let rawValue: UInt16

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

    public init(rawValue: UInt16) {
        self.rawValue = rawValue & ((1 << 12) - 1)
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

public enum FileType: UInt16 {
    case Invalid = 0
    case FIFO = 1
    case CharacterDevice = 2
    case Directory = 4
    case BlockDevice = 6
    case File = 8
    case Symlink = 10
    case Socket = 12
    case Whiteout = 14

    private init?(statMode: UInt16) {
        self.init(rawValue: (statMode & 0xf000) >> 12)
    }
}

/// File information
public struct FileInfo {

    /// path to the file
    public let path: Path

    /// owner
    public let owner: UInt32

    /// group
    public let group: UInt32

    /// mode
    public let mode: FileMode

    /// file size
    public let size: UInt64

    /// file type
    public let type: FileType

    /// path to original if this is a symlink
    public let linkTarget: Path?

    /// modification timestamp
    public let mTime: Int

    /// creation timestamp
    public let cTime: Int

    /// last access timestamp
    public let aTime: Int

    internal init(path: Path, statBuf: stat) {
        self.path = path
        self.owner = statBuf.st_uid
        self.group = statBuf.st_gid
        self.mode = FileMode(rawValue: statBuf.st_mode)
        self.size = UInt64(statBuf.st_size)
        self.type = FileType(statMode: statBuf.st_mode)!
        if self.type == .Symlink {
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

