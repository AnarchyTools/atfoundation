#if os(Linux)
import Glibc
#else
import Darwin
#endif

/// Abstraction for filesystem paths
public struct Path {

    /// split path components
    public let components: [String]

    /// is this an absolute or relative path
    public let isAbsolute: Bool

    /// delimiter between path components
    public var delimiter: Character

    /// Initialize with a string, the string is split
    /// into components by the rules of the current platform
    ///
    /// - Parameter string: The string to parse
    public init(_ string: String, delimiter: Character = "/") {
        self.delimiter = "/"
        var components = string.split(character: self.delimiter)
        if components[0] == "" {
            self.isAbsolute = true
            components.remove(at: 0)
        } else {
            self.isAbsolute = false
        }
        self.components = components
    }

    /// Initialize with path components
    ///
    /// - Parameter components: Array of path component strings
    /// - Parameter absolute: Boolean, defines if the path is absolute
    public init(components: [String], absolute: Bool = false) {
        self.components = components
        self.isAbsolute = absolute
        self.delimiter = "/"
    }

    /// Create a new path instance by appending a component
    ///
    /// - Parameter component: path component to append
    /// - Returns: new Path instance
    public func appending(_ component: String) -> Path {
        var components = self.components
        components.append(component)
        return Path(components: components, absolute: self.isAbsolute)
    }

    /// Create a new path instance by removing the last path component
    ///
    /// - Returns: New path instance cropped by the last path component
    public func removingLastComponent() -> Path {
        var components = self.components
        components.removeLast()
        return Path(components: components, absolute: self.isAbsolute)
    }

    /// Create a new path instance by removing the first path component
    ///
    /// - Returns: New path instance cropped by the first path component,
    ///            implies conversion to relative path
    public func removingFirstComponent() -> Path {
        var components = self.components
        components.remove(at: 0)
        return Path(components: components, absolute: false)
    }

    /// Create a new path instance by joining two paths
    ///
    /// - Parameter path: other path to append to this instance.
    ///                   If the other path is absolute the result
    ///                   is the other path without this instance.
    public func join(_ path: Path) -> Path {
        if path.isAbsolute {
            return Path(components: path.components, absolute: true)
        } else {
            var myComponents = self.components
            myComponents += path.components
            return Path(components: myComponents, absolute: self.isAbsolute)
        }
    }

    /// Create a path instance that defines a relative path to another path
    ///
    /// - Parameter path: the path to calculate a relative path to
    /// - Returns: new path instance that is a relative path to `path`.
    ///            If this instance is not absolute the result will be `nil`
    public func relativeTo(path: Path) -> Path? {
        if !self.isAbsolute || !path.isAbsolute {
            return nil
        }
        let maxCount = min(self.components.count, path.components.count)
        var up = 0
        var same = 0
        for idx in 0..<maxCount {
            let c1 = self.components[idx]
            let c2 = path.components[idx]
            if c1 != c2 {
                up = maxCount - idx
                break
            } else {
                same = idx
            }
        }
        var newComponents = [String]()
        if same < up {
            for _ in 0..<(up - same + 1) {
                newComponents.append("..")
            }
        }
        for idx in (same + 1)..<self.components.count {
            newComponents.append(self.components[idx])
        }
        return Path(components:newComponents, absolute: false)
    }

    /// Return the dirname of a path
    ///
    /// - Returns: new path instance with only the dir name
    public func dirname() -> Path {
        return self.removingLastComponent()
    }

    /// Return the file name of a path
    ///
    /// - Returns: file name string
    public func basename() -> String {
        return self.components.last!
    }

    /// Return absolute path to the user's home directory
    ///
    /// - Returns: absolute path to user's homee directory or `nil` if
    ///            that's not available
    public static func homeDirectory() -> Path? {
        let home = getenv("HOME")
        if let s = String(validatingUTF8: home) {
            return Path(s)
        }
        return nil
    }

    /// Return path to the temp directory
    ///
    /// - Returns: path instance with temp directory
    public static func tempDirectory() -> Path {
        // TODO: temp dirs for other platforms
        return Path("/tmp")
    }
}

public func +(lhs: Path, rhs: String) -> Path {
    return lhs.join(Path(rhs))
}

public func +(lhs: Path, rhs: Path) -> Path {
    return lhs.join(rhs)
}

public func +=(lhs: inout Path, rhs: String) {
    lhs = lhs.join(Path(rhs))
}

public func +=(lhs: inout Path, rhs: Path) {
    lhs = lhs.join(rhs)
}

extension Path: CustomStringConvertible {

    /// Convert path back to a String
    public var description: String {
        var result = String.join(parts: components, delimiter: self.delimiter)
        if self.isAbsolute {
            result = "\(self.delimiter)" + result
        }
        return result
    }
}