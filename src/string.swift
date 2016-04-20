
public extension String {

    /// Create string from path
    ///
    /// - Parameter path: a path
    public init(path: Path) {
        self.init(path.description)
    }

    /// Load a string from a file
    ///
    /// - Parameter loadFromFile: the filename
    public init?(loadFromFile path: Path) throws {
        let f = try File(path: path, mode: .ReadOnly)
        if let s: String = try f.readAll() {
            self.init(s)
        } else {
            return nil
        }
    }

    /// Write a string to a file
    ///
    /// - Parameter to: file to write to
    public func write(to file: File) throws {
        try file.write(string: self)
    }

    /// Write a string to a new file
    ///
    /// - Parameter to: filename to write the string to
    public func write(to path: Path) throws {
        let f = try File(path: path, mode: .WriteOnly)
        try f.write(string: self)
        f.flush()
    }
}