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

/// Thread primitive
final public class Thread {
    private static let mainThreadID = pthread_self()

    private let threadMain: ((Void) -> Any?)
    private let detached: Bool
    private var threadID = pthread_t(bitPattern: 0)

    typealias ThreadMainFunction = @convention(c) (UnsafeMutableRawPointer!) -> UnsafeMutableRawPointer!

    /// Initialize and run a detached thread that does not return a value
    ///
    /// - parameter block: block to detach to new thread
    public init(_ block: @escaping (() -> ())) {
        self.threadMain = {
            block()
            return nil
        }
        self.detached = true

        var attr = pthread_attr_t()
        pthread_attr_init(&attr)
        defer { pthread_attr_destroy(&attr) }
#if os(Linux)
        pthread_attr_setdetachstate(&attr, Int32(detached ? PTHREAD_CREATE_DETACHED : PTHREAD_CREATE_JOINABLE))
#else
        pthread_attr_setdetachstate(&attr, detached ? PTHREAD_CREATE_DETACHED : PTHREAD_CREATE_JOINABLE)
#endif

        pthread_create(&self.threadID, &attr, { arg in
            let thread = unsafeBitCast(arg, to: Thread.self)
            let _ = thread.threadMain()
            return nil
        }, unsafeBitCast(self, to: UnsafeMutableRawPointer.self))
    }

    /// Wait for the result of a non-detached thread
    ///
    /// - returns: Value that the thread closure returned
    public func wait() -> Any? {
        if let threadID = self.threadID, self.detached {
            var returnValue = UnsafeMutableRawPointer(bitPattern: 0)
            pthread_join(threadID, &returnValue)
            if let returnValue = returnValue {
                let result = unsafeBitCast(returnValue, to: Any.self)
                return result
            }
        }
        return nil
    }

    /// Fetch current thread ID, returns zero for main thread
    public static var threadID: UInt64 {
        let thread = pthread_self()
        if thread == Thread.mainThreadID {
            return 0
        }
        return unsafeBitCast(thread, to: UInt64.self)
    }
}
