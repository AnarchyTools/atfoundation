#if os(Linux)
import Glibc
#else
import Darwin
#endif


public struct FileInfo {
// - path -> Path
// - owner -> Int
// - group -> Int
// - size -> UInt64
// - isDir -> Bool
// - isLink -> Bool
// - linkTarget -> Path

}

