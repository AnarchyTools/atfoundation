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

/// Simple Date struct, stores only UTC
public struct Date {

    public enum WeekDay: Int32 {
        case Sunday = 0
        case Monday = 1
        case Tuesday = 2
        case Wednesday = 3
        case Thursday = 4
        case Friday = 5
        case Saturday = 6
    }

    /// Epoch timestamp (seconds since 1970-01-01)
    public let timestamp: Int

    /// Return a RFC-822 date string
    public var rfc822DateString: String? {
        return self.format("%a, %d %b %Y %H:%M:%S +0000")
    }

    /// Return a ISO-8601 date string
    public var isoDateString: String? {
        return self.format("%FT%TZ")
    }

    /// Second
    public var second: Int32 {
        return self._timeStruct().tm_sec
    }

    /// Minute
    public var minute: Int32 {
        return self._timeStruct().tm_min
    }

    /// Hour
    public var hour: Int32 {
        return self._timeStruct().tm_hour
    }

    /// Time tuple
    public var timeTuple: (hour: Int32, minute: Int32, second: Int32) {
        let v = self._timeStruct()
        return (hour: v.tm_hour, minute: v.tm_min, second: v.tm_sec)
    }

    /// Day (1-31)
    public var day: Int32 {
        return self._timeStruct().tm_mday
    }

    /// Month (1-12)
    public var month: Int32 {
        return self._timeStruct().tm_mon + 1
    }

    /// Year
    public var year: Int32 {
        return self._timeStruct().tm_year + 1900
    }

    /// Weekday
    public var weekDay: WeekDay {
        return WeekDay(rawValue: self._timeStruct().tm_wday)!
    }

    /// Day of the year
    public var dayOfYear: Int32 {
        return self._timeStruct().tm_yday
    }

    /// Date tuple
    public var dateTuple: (year: Int32, month: Int32, day: Int32) {
        let v = self._timeStruct()
        return (year: v.tm_year + 1900, month: v.tm_mon + 1, day: v.tm_mday)
    }

    /// Simple initializer
    ///
    /// - Parameter timestamp: Epoch timestamp (seconds since 1970-01-01)
    public init(timestamp: Int) {
        self.timestamp = timestamp
    }

    /// Initialize with exact date
    ///
    /// - Parameter year: The year
    /// - Parameter month: optional, the month (1-12!)
    /// - Parameter day: optional, the day (1-31!)
    /// - Parameter hour: optional, the hour (0-23)
    /// - Parameter minute: optional, the minute (0-59)
    /// - Parameter second: optional, the second (0-59)
    public init(year: Int32, month: Int32 = 1, day: Int32 = 1, hour: Int32 = 0, minute: Int32 = 0, second: Int32 = 0) {
        var time = tm()
        time.tm_year = year - 1900
        time.tm_mon = month - 1
        time.tm_mday = day
        time.tm_hour = hour
        time.tm_min = minute
        time.tm_sec = second
        self.timestamp = timegm(&time)
    }

    /// Initialize with ISO-8601 date string
    ///
    /// multiple variants for defining time zone are recognized
    ///
    /// - Parameter isoDateString: date string to parse
    /// - Returns: nil if string was not parseable
    public init?(isoDateString: String) {
        var time = tm()
        if strptime(isoDateString, "%FT%T%z", &time) == nil {
            if strptime(isoDateString, "%FT%T%Z", &time) == nil {
                if strptime(isoDateString, "%FT%TZ", &time) == nil {
                    if strptime(isoDateString, "%FT%T", &time) == nil {
                        return nil
                    }
                }
            }
        }
        self.timestamp = timegm(&time)
    }

    /// Initialize with RFC-822 date string
    ///
    /// multiple variants for defining the time zone are recognized
    ///
    /// - Parameter rfc822DateString: date string to parse
    /// - Returns: nil if string was not parseable
    public init?(rfc822DateString: String) {
        var time = tm()
        if strptime(rfc822DateString, "%a, %d %b %Y %H:%M:%S GMT", &time) == nil {
            if strptime(rfc822DateString, "%a, %d %b %Y %H:%M:%S %z", &time) == nil {
                if strptime(rfc822DateString, "%a, %d %b %Y %H:%M:%S", &time) == nil {
                    return nil
                }
            }
        }
        time.tm_gmtoff = 0
        self.timestamp = mktime(&time)
    }

    /// Initialize from string with a custom format.
    /// see C-Library documentation for strptime/strftime for examples
    ///
    /// - Parameter string: string with date to parse
    /// - Parameter format: format string that defines how to parse the string
    /// - Returns: nil if string was not parseable
    public init?(string: String, format: String) {
        var time = tm()
        if strptime(string, format, &time) == nil {
            return nil
        }
        self.timestamp = timegm(&time)
    }

    /// Return current time/date
    ///
    /// - Returns: Date() instance with current timestamp
    public static func now() -> Date {
        return Date(timestamp: time(nil))
    }

    /// Format a date by defined format
    /// see C-Library documentation for strptime/strftime for examples
    ///
    /// - Parameter format: format string
    /// - Returns: formatted date or nil if format string was invalid
    public func format(_ format: String) -> String? {
        var output = [Int8](repeating: 0, count: 200)
        var t = self._timeStruct()
        let len = strftime(&output, 199, format, &t)
        if len > 0 {
            return String(validatingUTF8: output)
        }
        return nil
    }

    /// Convert from timestamp to tm struct
    ///
    /// - Returns: tm struct of self
    private func _timeStruct() -> tm {
        var tt = time_t(self.timestamp)
        var t = tm()
        gmtime_r(&tt, &t)
        return t
    }
}

public func +(lhs: Date, rhs: Date) -> Date {
    return Date(timestamp: lhs.timestamp + rhs.timestamp)
}


public func -(lhs: Date, rhs: Date) -> Date {
    return Date(timestamp: lhs.timestamp - rhs.timestamp)
}

public func +=(lhs: inout Date, rhs: Date) {
    lhs = Date(timestamp: lhs.timestamp + rhs.timestamp)
}

public func -=(lhs: inout Date, rhs: Date) {
    lhs = Date(timestamp: lhs.timestamp - rhs.timestamp)
}

public func >(lhs: Date, rhs: Date) -> Bool {
    return lhs.timestamp > rhs.timestamp
}

public func >=(lhs: Date, rhs: Date) -> Bool {
    return lhs.timestamp >= rhs.timestamp
}

public func <(lhs: Date, rhs: Date) -> Bool {
    return lhs.timestamp < rhs.timestamp
}

public func <=(lhs: Date, rhs: Date) -> Bool {
    return lhs.timestamp <= rhs.timestamp
}

public func ==(lhs: Date, rhs: Date) -> Bool {
    return lhs.timestamp == rhs.timestamp
}
