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

/// Time interval
public struct TimeInterval {
    fileprivate let interval: Int

    /// Initialize on second scale
    ///
    /// - Parameter seconds: Seconds
    /// - Parameter minutes: optional, Minutes
    /// - Parameter hours: optional, Hours
    /// - Parameter days: optional, Days
    public init(seconds: Int, minutes: Int = 0, hours: Int = 0, days: Int = 0) {
        self.interval = seconds + minutes * 60 + hours * 3600 + days * 86400
    }

    /// Initialize on minute scale
    ///
    /// - Parameter minutes: Minutes
    /// - Parameter hours: optional, Hours
    /// - Parameter days: optional, Days
    public init(minutes: Int, hours: Int = 0, days: Int = 0) {
        self.interval = minutes * 60 + hours * 3600 + days * 86400
    }

    /// Initialize on hour scale
    ///
    /// - Parameter hours: Hours
    /// - Parameter days: optional, Days
    public init(hours: Int, days: Int = 0) {
        self.interval = hours * 3600 + days * 86400
    }

    /// Initialize on day scale
    ///
    /// - Parameter days: Days
    public init(days: Int) {
        self.interval = days * 86400
    }

    /// Initialize on week scale
    ///
    /// - Parameter weeks: Weeks
    public init(weeks: Int) {
        self.interval = weeks * 86400 * 7
    }
}

public func +(lhs: Date, rhs: TimeInterval) -> Date {
    return Date(timestamp: lhs.timestamp + rhs.interval)
}

public func -(lhs: Date, rhs: TimeInterval) -> Date {
    return Date(timestamp: lhs.timestamp - rhs.interval)
}

public func +=(lhs: inout Date, rhs: TimeInterval) {
    lhs = Date(timestamp: lhs.timestamp + rhs.interval)
}

public func -=(lhs: inout Date, rhs: TimeInterval) {
    lhs = Date(timestamp: lhs.timestamp - rhs.interval)
}
