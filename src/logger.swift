//
//  logger.swift
//  unchained
//
//  Created by Johannes Schriewer on 17/12/15.
//  Copyright © 2015 Johannes Schriewer. All rights reserved.
//

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif

/// Basic Logging class, can write to file or stdout/stderr
public class Log {

    /// Log level
    public enum LogLevel: Int {
        case Debug = 0
        case Info  = 1
        case Warn  = 2
        case Error = 3
        case Fatal = 4
    }

    /// Log target
    public enum LogTarget {
        case StdErr
        case StdOut
        case File
    }

    /// Active log level
    public static var logLevel: LogLevel = .Debug

    /// Log file and line too?
    public static var logFileAndLine: Bool = false

    /// Active log target
    public static var logTarget: LogTarget = .StdErr

    /// Current log file name, remember to set logTarget to `.File` for this to work
    public static var logFileName: Path? = nil {
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

    /// File handle to log file
    private static var logFile: File? = nil

    /// Log a debug message
    ///
    /// - Parameter msg: message or object to log, works like in print
    public class func debug(_ msg: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        guard Log.logLevel.rawValue <= LogLevel.Debug.rawValue else {
            return
        }
        self.log("DEBUG", msg, file: file, line: line, function: function)
    }

    /// Log an informal message
    ///
    /// - Parameter msg: message or object to log, works like in print
    public class func info(_ msg: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        guard Log.logLevel.rawValue <= LogLevel.Info.rawValue else {
            return
        }
        self.log("INFO ", msg, file: file, line: line, function: function)
    }

    /// Log a warning message
    ///
    /// - Parameter msg: message or object to log, works like in print
    public class func warn(_ msg: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        guard Log.logLevel.rawValue <= LogLevel.Warn.rawValue else {
            return
        }
        self.log("WARN ", msg, file: file, line: line, function: function)
    }

    /// Log an error message
    ///
    /// - Parameter msg: message or object to log, works like in print
    public class func error(_ msg: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        guard Log.logLevel.rawValue <= LogLevel.Error.rawValue else {
            return
        }
        self.log("ERROR", msg, file: file, line: line, function: function)
    }

    /// Log a fatal message, program usually quits after these
    ///
    /// - Parameter msg: message or object to log, works like in print
    public class func fatal(_ msg: Any..., file: String = #file, line: Int = #line, function: String = #function) {
        guard Log.logLevel.rawValue <= LogLevel.Fatal.rawValue else {
            return
        }
        self.log("FATAL", msg, file: file, line: line, function: function)
    }

    /// Close and re-open log file (usually bound to a HUP UNIX Signal)
    public class func reopenLog() {
        if let filename = self.logFileName {
            do {
                self.logFile = try File(path: filename, mode: .AppendOnly)
            } catch {
                self.logFileName = nil
            }
        }
    }

    // MARK: - Private
    private class func log(_ level: String, _ msg: [Any], file: String, line: Int, function: String) {
        let date = Date.now()

        if let logFile = self.logFile where self.logTarget == .File {
            do {
                try date.isoDateString!.write(to: logFile)
                if self.logFileAndLine {
                    try " [\(level)] \(file):\(line): ".write(to: logFile)
                } else {
                    try " [\(level)]: ".write(to: logFile)
                }
                for item in msg {
                    try (String(item) + " ").write(to: logFile)
                }
                try "\n".write(to: logFile)
                logFile.flush()
            } catch {
                self.logTarget = .StdErr
                self._fwrite(stderr, "\(date.isoDateString!) [FATAL]: Could not write to logfile \(logFileName), reverting to STDERR!")
                self.log(level, msg, file: file, line: line, function: function)
            }
        } else {
            if let logFileName = self.logFileName where self.logTarget == .File {
                do {
                    self.logFile = try File(path: logFileName, mode: .AppendOnly)
                    self.log(level, msg, file: file, line: line, function: function)
                    return
                } catch {
                    self._fwrite(stderr, "\(date.isoDateString!) [FATAL]: Could not open logfile \(logFileName)!")
                    fflush(stderr)
                }
            }

            #if os(Linux)
            let os_stdout = stdout!
            let os_stderr = stderr!
            #else
            let os_stdout = stdout
            let os_stderr = stderr
            #endif
            let out = (self.logTarget == .StdOut) ? os_stdout : os_stderr
            if self.logFileAndLine {
            self._fwrite(out, "\(date.isoDateString!) [\(level)] \(file):\(line): ")
            } else {
            self._fwrite(out, "\(date.isoDateString!) [\(level)]: ")
            }

            for item in msg {
                self._fwrite(out, String(item) + " ")
            }
            self._fwrite(out, "\n")
            fflush(out)
        }
    }

    private class func _fwrite(_ stream: UnsafeMutablePointer<FILE>, _ data: String) {
        let buf = [CChar].fromString(data)
        fwrite(buf, buf.count - 1, 1, stream)
    }

    /// Only use class functions please
    private init() {
    }
}
