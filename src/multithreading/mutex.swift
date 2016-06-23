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

/// Mutex lock primitive
final public class Mutex {
    internal var mutexID = pthread_mutex_t()

    /// Initialize new lock
    ///
    /// - parameter recursive: Set to true if you want a recursive lock
    ///                        (same thread may recursively lock multiple times)
    public init(recursive: Bool = false) {
        var attr = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        defer { pthread_mutexattr_destroy(&attr) }

#if os(Linux)
        pthread_mutexattr_settype(&attr, Int32(recursive ? PTHREAD_MUTEX_RECURSIVE : PTHREAD_MUTEX_ERRORCHECK))
#else
        pthread_mutexattr_settype(&attr, recursive ? PTHREAD_MUTEX_RECURSIVE : PTHREAD_MUTEX_ERRORCHECK)
#endif
        pthread_mutex_init(&self.mutexID, &attr)
    }

    deinit {
        pthread_mutex_destroy(&self.mutexID)
    }

    /// Lock the mutex, may throw an error on resource exhaustion or
    /// multiple locking from the same thread when not recursive
    /// Usually you could use `try!` to execute this as every error
    /// this throws is either system resource exhaustion or a programming
    /// error.
    public func lock() throws {
        let result = pthread_mutex_lock(&self.mutexID)
        if result != 0 {
            throw SysError(errno: result)
        }
    }

    /// Unlock a locked mutex, may throw errors if the mutex was not locked
    /// Usually you could use `try!` to execute this as every error
    /// this throws is either system resource exhaustion or a programming
    /// error.
    public func unlock() throws {
        let result = pthread_mutex_unlock(&self.mutexID)
        if result != 0 {
            throw SysError(errno: result)
        }
    }

    /// Try locking the mutex, returns false if the lock is already held
    /// somewhere. If it returns true the locking succeeded.
    /// Usually you could use `try!` to execute this as every error
    /// this throws is either system resource exhaustion or a programming
    /// error.
    public func tryLock() throws -> Bool {
        let result = pthread_mutex_trylock(&self.mutexID)
        if result != 0 {
            let err = SysError(errno: result)
            if case .DeviceOrResourceBusy = err {
                return false
            }
            throw err
        }
        return true
    }

    /// Run a block with the lock held, this is the prefered method to use
    ///
    /// - parameter cb: block to execute
    public func whileLocking(_ cb: (Void) -> Void) throws {
        try self.lock()
        cb()
        try self.unlock()
    }
}
