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

final public class Thread {
    private static let mainThreadID = pthread_self()

    private let threadMain: (Any? -> Any?)
    private let detached: Bool
    private var threadID: pthread_t? = nil

    private var argument: Any?
    private var result: Any?

    typealias ThreadMainFunction = @convention(c) (UnsafeMutablePointer<Void>!) -> UnsafeMutablePointer<Void>!

    public init(argument: Any? = nil, detached: Bool = false, _ block: (Any? -> Any?)) {
        self.threadMain = block
        self.argument = argument
        self.detached = detached

        var attr = pthread_attr_t()
        pthread_attr_init(&attr)
        defer { pthread_attr_destroy(&attr) }
        pthread_attr_setdetachstate(&attr, detached ? PTHREAD_CREATE_DETACHED : PTHREAD_CREATE_JOINABLE)

        pthread_create(&self.threadID, &attr, { arg in
            let thread = unsafeBitCast(arg, to: Thread.self)
            let result = thread.threadMain(thread.argument)
            return unsafeBitCast(result, to: UnsafeMutablePointer<Void>!.self)
        }, nil)
    }

    public init(argument: Any? = nil, detached: Bool = false, _ block: (Void -> Void)) {
        self.threadMain = { arg in
            block()
            return nil
        }
        self.argument = argument
        self.detached = detached

        var attr = pthread_attr_t()
        pthread_attr_init(&attr)
        defer { pthread_attr_destroy(&attr) }
        pthread_attr_setdetachstate(&attr, detached ? PTHREAD_CREATE_DETACHED : PTHREAD_CREATE_JOINABLE)

        pthread_create(&self.threadID, &attr, { arg in
            let thread = unsafeBitCast(arg, to: Thread.self)
            thread.threadMain(nil)
            return nil
        }, unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self))
    }

    public func wait() -> Any? {
        if self.detached {
            var returnValue = UnsafeMutablePointer<Void>(nil)
            pthread_join(self.threadID!, &returnValue)
            let result = unsafeBitCast(returnValue, to: Any.self)
            return result
        }
        return nil
    }

    public static var threadID: UInt64 {
        let thread = pthread_self()
        if thread == Thread.mainThreadID {
            return 0
        }
        return unsafeBitCast(thread, to: UInt64.self)
    }
}

final public class Barrier {
    private let mutex = Mutex()
    internal var conditionID = pthread_cond_t()

    public init() {
        pthread_cond_init(&self.conditionID, nil)
    }

    deinit {
        pthread_cond_destroy(&self.conditionID)
    }

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

    public func signal() {
        pthread_cond_signal(&self.conditionID)
    }
}

final public class Mutex {
    internal var mutexID = pthread_mutex_t()

    public init(recursive: Bool = false) {
        var attr = pthread_mutexattr_t()
        pthread_mutexattr_init(&attr)
        defer { pthread_mutexattr_destroy(&attr) }

        pthread_mutexattr_settype(&attr, recursive ? PTHREAD_MUTEX_RECURSIVE : PTHREAD_MUTEX_ERRORCHECK)
        pthread_mutex_init(&self.mutexID, &attr)
    }

    deinit {
        pthread_mutex_destroy(&self.mutexID)
    }

    public func lock() throws {
        let result = pthread_mutex_lock(&self.mutexID)
        if result != 0 {
            throw SysError(errno: result)
        }
    }

    public func unlock() throws {
        let result = pthread_mutex_unlock(&self.mutexID)
        if result != 0 {
            throw SysError(errno: result)
        }
    }

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

    public func whileLocking(_ cb: Void -> Void) throws {
        try self.lock()
        cb()
        try self.unlock()
    }
}

final public class Semaphore {
    public let name: String
    private var semaphoreID: UnsafeMutablePointer<sem_t>?

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

    public func wait() throws {
        let result = sem_wait(self.semaphoreID)
        if result != 0 {
            throw SysError(errno: result)
        }
    }

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

    public func post() {
        sem_post(self.semaphoreID)
    }

    public func whileLocking(cb: Void -> Void) throws {
        try self.wait()
        cb()
        self.post()
    }
}
