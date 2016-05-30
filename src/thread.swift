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

    typealias ThreadMainFunction = @convention(c) (UnsafeMutablePointer<Void>!) -> UnsafeMutablePointer<Void>!

    /// Initialize and run a thread
    ///
    /// - parameter block: block to run in a new thread, the return value of the block can be aquired with `wait()`
    public init(_ block: ((Void) -> Any?)) {
        self.threadMain = block
        self.detached = false

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
            let result = thread.threadMain()
            return unsafeBitCast(result, to: UnsafeMutablePointer<Void>.self)
        }, unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self))
    }

    /// Initialize and run a detached thread that does not return a value
    ///
    /// - parameter block: block to detach to new thread
    public init(_ block: ((Void) -> Void)) {
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
            thread.threadMain()
            return nil
        }, unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self))
    }

    /// Wait for the result of a non-detached thread
    ///
    /// - returns: Value that the thread closure returned
    public func wait() -> Any? {
        if self.detached {
            var returnValue = UnsafeMutablePointer<Void>(nil)
            pthread_join(self.threadID, &returnValue)
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

/// Barrier primitive
final public class Barrier {
    private let mutex = Mutex()
    internal var conditionID = pthread_cond_t()

    /// Initialize a new barrier
    public init() {
        pthread_cond_init(&self.conditionID, nil)
    }

    deinit {
        pthread_cond_destroy(&self.conditionID)
    }

    /// Wait for a signal (stop at the barrier)
    ///
    /// - parameter timeout: optional, time in nano seconds to wait, set to nil or skip to wait forever
    public func wait(timeout: Int? = nil) {
        if let timeout = timeout {
            var ts = timespec()
            var tv = timeval()
            gettimeofday(&tv, nil)
            ts.tv_sec = tv.tv_sec + timeout / 1000000000
            ts.tv_nsec += timeout % 1000000000
            pthread_cond_timedwait(&self.conditionID, &self.mutex.mutexID, &ts)
        } else {
            pthread_cond_wait(&self.conditionID, &self.mutex.mutexID)
        }
    }

    /// Signal the barrier, all threads blocked on that barrier will resume execution
    public func signal() {
        pthread_cond_signal(&self.conditionID)
    }
}

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

/// Semaphore primitive
final public class Semaphore {
    private var semaphoreID: UnsafeMutablePointer<sem_t>?

    /// Name of the semaphore
    public let name: String

    /// Initialize a semaphore
    ///
    /// - parameter name: The name
    /// - parameter count: Resource allocation limit
    public init(name: String, count: UInt32) throws {
        self.name = name
        self.semaphoreID = sem_open(name, O_CREAT)
        guard let _ = self.semaphoreID else {
            throw SysError(errno: errno)
        }
    }

    deinit {
        sem_unlink(name)
    }

    /// Wait for a semaphore. This decrements the resource limit,
    /// if the limit reaches zero the thread will wait for a `post()`
    /// from another thread.
    /// Usually you could use `try!` to execute this as every error
    /// this throws is either system resource exhaustion or a programming
    /// error.
    public func wait() throws {
        let result = sem_wait(self.semaphoreID)
        if result != 0 {
            throw SysError(errno: result)
        }
    }

    /// Test if resources are available
    ///
    /// Usually you could use `try!` to execute this as every error
    /// this throws is either system resource exhaustion or a programming
    /// error.
    ///
    /// - returns: false if the semaphore resources are at zero already,
    ///            true if the semaphore could be aquired
    public func tryWait() throws -> Bool {
        let result = sem_trywait(self.semaphoreID)
        if result != 0 {
            let err = SysError(errno: result)
            if case .TryAgain = err {
                return false
            }
            throw err
        }
        return true
    }

    /// Release a resource to the semaphore
    public func post() {
        sem_post(self.semaphoreID)
    }

    /// Execute a block aquiring resources from the semaphore and return the
    /// resources afterwards, this is the prefered function to call.
    ///
    /// - parameter cb: block to execute
    public func whileLocking(cb: (Void) -> Void) throws {
        try self.wait()
        cb()
        self.post()
    }
}
