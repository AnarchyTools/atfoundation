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

/// If you want to write your own logger conform to `LoggerProtocol` and set `Log.logger = MyLogger()`
public protocol LoggerProcotol {
    /// Log file and line too?
    var logFileAndLine: Bool { get set }

    /// Log current date, useful for permanent logfiles
    var logDate: Bool { get set }

    /// Primary function to log something
    func log(_ level: Log.LogLevel, _ msg: [Any], date: Date?, file: String?, line: Int?, function: String?)
}

public extension LoggerProcotol {

    /// Convenience override if you don't want to log the file and line info
    ///
    /// - parameter level: log severity
    /// - parameter msg: data to log
    public func log(_ level: Log.LogLevel, _ msg: [Any]) {
        self.log(level, msg, file: nil, line: nil, function: nil)
    }

    /// Convenience override if you don't want to provide an explicit date
    ///
    /// - parameter level: log severity
    /// - parameter msg: data to log
    /// - parameter file: set to `#file`
    /// - parameter line: set to `#line`
    /// - parameter function: set to `#function`
    public func log(_ level: Log.LogLevel, _ msg: [Any], file: String?, line: Int?, function: String?) {
        self.log(level, msg, date: Date.now(), file: file, line: line, function: function)
    }

    /// Internal helper for fwrite from string
    ///
    /// - parameter stream: file stream to write to
    /// - parameter data: string to write
    internal func _fwrite(_ stream: UnsafeMutablePointer<FILE>, _ data: String) {
        let buf = [CChar].fromString(data)
        fwrite(buf, buf.count - 1, 1, stream)
    }


    /// Internal helper for colorizing log output on terminals
    ///
    /// - parameter stream: file stream to write to
    /// - parameter level: level to fetch to color for, set to `nil` to reset color
    internal func colorize(_ stream: UnsafeMutablePointer<FILE>, _ level: Log.LogLevel?) {
        let tty = isatty(fileno(stderr)) != 0
        if !tty {
            return
        }

        var color: String

        if let level = level {
            switch level {
                case .Debug:
                    color = "1;37"
                case .Info:
                    color = "0"
                case .Warn:
                    color = "1;33"
                case .Error:
                    color = "0;31"
                case .Fatal:
                    color = "0;35"
            }
        } else {
            color = "0"
        }

        self._fwrite(stream, "\u{1b}[\(color)m")
    }
}

/// Simple standard error logger, colorizes output if run on a terminal
public class StdErrLogger: LoggerProcotol {

    /// Log file and line too?
    public var logFileAndLine: Bool = false

    /// Log current date, useful for permanent logfiles
    public var logDate: Bool = false

    public func log(_ level: Log.LogLevel, _ msg: [Any], date: Date?, file: String?, line: Int?, function: String?) {
        self.colorize(stderr, level)
        if let date = date, self.logDate {
            self._fwrite(stderr, "\(date.isoDateString!) ")
        }
        if let file = file, let line = line, self.logFileAndLine || level == .Fatal {
            self._fwrite(stderr, "\(file):\(line): ")
        }

        for item in msg {
            self._fwrite(stderr, String(describing: item) + " ")
        }
        self.colorize(stderr, nil)
        self._fwrite(stderr, "\n")
        fflush(stderr)
    }
}

/// Simple standard output logger, colorizes output if run on a terminal
public class StdOutLogger: LoggerProcotol {

    /// Log file and line too?
    public var logFileAndLine: Bool = false

    /// Log current date, useful for permanent logfiles
    public var logDate: Bool = false

    public func log(_ level: Log.LogLevel, _ msg: [Any], date: Date?, file: String?, line: Int?, function: String?) {
        self.colorize(stdout, level)
        if let date = date, self.logDate {
            self._fwrite(stdout, "\(date.isoDateString!) ")
        }
        if let file = file, let line = line, self.logFileAndLine || level == .Fatal {
            self._fwrite(stdout, "\(file):\(line): ")
        }

        for item in msg {
            self._fwrite(stdout, String(describing: item) + " ")
        }
        self.colorize(stdout, nil)
        self._fwrite(stdout, "\n")
        fflush(stdout)
    }
}

/// Simple file logger, throws `fatalError` when the file cannot be opened
public class FileLogger: LoggerProcotol {
    /// Log file and line too?
    public var logFileAndLine: Bool = false

    /// Log current date, useful for permanent logfiles
    public var logDate: Bool = true

    /// File handle to log file
    private var logFile: File? = nil

    /// Current log file name
    public var logFileName: Path? = nil {
        didSet {
            self.logFile = nil
            if let filename = self.logFileName {
                do {
                    self.logFile = try File(path: filename, mode: .AppendOnly)
                } catch {
                    self.logFileName = nil
                }
            }
        }
    }

    /// Initialize with filename
    ///
    /// - parameter filename: the file to write to
    /// - throws: `SysError` when the file cannot be opened
    public init(filename: Path) throws {
        self.logFileName = filename
        self.logFile = try File(path: filename, mode: .AppendOnly)
    }


    /// Close and re-open log file (usually bound to a HUP UNIX Signal)
    public func reopenLog() {
        if let filename = self.logFileName {
            do {
                self.logFile = try File(path: filename, mode: .AppendOnly)
            } catch {
                self.logFileName = nil
            }
        }
    }

    public func log(_ level: Log.LogLevel, _ msg: [Any], date: Date?, file: String?, line: Int?, function: String?) {
        if let logFile = self.logFile {
            do {
                if let date = date, self.logDate {
                    try date.isoDateString!.write(to: logFile)
                }
                if let file = file, let line = line, self.logFileAndLine || level == .Fatal {
                    try " [\(level)] \(file):\(line): ".write(to: logFile)
                } else {
                    try " [\(level)]: ".write(to: logFile)
                }
                for item in msg {
                    try (String(describing: item) + " ").write(to: logFile)
                }
                try "\n".write(to: logFile)
                logFile.flush()
            } catch {
                fatalError("Could not open log file '\(logFileName)': \(error)")
            }
        } else {
            if let logFileName = self.logFileName {
                do {
                    self.logFile = try File(path: logFileName, mode: .AppendOnly)
                    self.log(level, msg, file: file, line: line, function: function)
                    return
                } catch {
                    fatalError("Could not open log file '\(logFileName)': \(error)")
                }
            }
        }
    }

}

/// Basic Logging class, the underlying logger may be reconfigured
public class Log {
    public static var logger: LoggerProcotol = StdErrLogger()

    /// Log level
    public enum LogLevel: Int {
        case Debug = 0
        case Info  = 1
        case Warn  = 2
        case Error = 3
        case Fatal = 4
    }

    /// Active log level
    public static var logLevel: LogLevel = .Debug

    /// Log a debug message
    ///
    /// - Parameter msg: message or object to log, works like in print
    public class func debug(_ msg: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        guard Log.logLevel.rawValue <= LogLevel.Debug.rawValue else {
            return
        }
        self.logger.log(.Debug, msg, file: file, line: line, function: function)
    }

    /// Log an informal message
    ///
    /// - Parameter msg: message or object to log, works like in print
    public class func info(_ msg: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        guard Log.logLevel.rawValue <= LogLevel.Info.rawValue else {
            return
        }
        self.logger.log(.Info, msg, file: file, line: line, function: function)
    }

    /// Log a warning message
    ///
    /// - Parameter msg: message or object to log, works like in print
    public class func warn(_ msg: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        guard Log.logLevel.rawValue <= LogLevel.Warn.rawValue else {
            return
        }
        self.logger.log(.Warn, msg, file: file, line: line, function: function)
    }

    /// Log an error message
    ///
    /// - Parameter msg: message or object to log, works like in print
    public class func error(_ msg: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        guard Log.logLevel.rawValue <= LogLevel.Error.rawValue else {
            return
        }
        self.logger.log(.Error, msg, file: file, line: line, function: function)
    }

    /// Log a fatal message, program usually quits after these
    ///
    /// - Parameter msg: message or object to log, works like in print
    public class func fatal(_ msg: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        guard Log.logLevel.rawValue <= LogLevel.Fatal.rawValue else {
            return
        }
        self.logger.log(.Fatal, msg, file: file, line: line, function: function)
    }

    /// Only use class functions please
    private init() {
    }
}
