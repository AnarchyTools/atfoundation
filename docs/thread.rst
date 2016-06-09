====================
Threading primitives
====================


.. swift:class:: Thread

   .. swift:init:: init(_ block: ((Void) -> Any?))

    Initialize and run a thread

    :parameter block: block to run in a new thread, the return value of the block can be aquired with ``wait()``

   .. swift:init:: init(_ block: ((Void) -> Void))

    Initialize and run a detached thread that does not return a value

    :parameter block: block to detach to new thread

   .. swift:method:: wait() -> Any?

    Wait for the result of a non-detached thread

    :returns: Value that the thread closure returned

   .. swift:static_var:: threadID: UInt64

    Fetch current thread ID, returns zero for main thread


.. swift:class:: Barrier

   .. swift:init:: init()

    Initialize a new barrier

   .. swift:method:: wait(timeout: Int? = nil)

    Wait for a signal (stop at the barrier)

    :parameter timeout: optional, time in nano seconds to wait, set to nil or skip to wait forever

   .. swift:method:: signal()

    Signal the barrier, all threads blocked on that barrier will resume execution


.. swift:class:: Mutex

   .. swift:init:: init(recursive: Bool = false)

    Initialize new lock

    :parameter recursive: Set to true if you want a recursive lock (same thread may recursively lock multiple times)

   .. swift:method:: lock() throws

    Lock the mutex, may throw an error on resource exhaustion or
    multiple locking from the same thread when not recursive
    Usually you could use ``try!`` to execute this as every error
    this throws is either system resource exhaustion or a programming
    error.

   .. swift:method:: unlock() throws

    Unlock a locked mutex, may throw errors if the mutex was not locked
    Usually you could use ``try!`` to execute this as every error
    this throws is either system resource exhaustion or a programming
    error.

   .. swift:method:: tryLock() throws -> Bool

    Try locking the mutex, returns false if the lock is already held
    somewhere. If it returns true the locking succeeded.
    Usually you could use ``try!`` to execute this as every error
    this throws is either system resource exhaustion or a programming
    error.

   .. swift:method:: whileLocking(_ cb: (Void) -> Void) throws

    Run a block with the lock held, this is the prefered method to use

    :parameter cb: block to execute


.. swift:class:: Semaphore

   .. swift:let:: name: String

    Name of the semaphore

   .. swift:init:: init(name: String, count: UInt32) throws

    Initialize a semaphore

    :parameter name: The name
    :parameter count: Resource allocation limit

   .. swift:method:: wait() throws

    Wait for a semaphore. This decrements the resource limit,
    if the limit reaches zero the thread will wait for a ``post()``
    from another thread.
    Usually you could use ``try!`` to execute this as every error
    this throws is either system resource exhaustion or a programming
    error.

   .. swift:method:: tryWait() throws -> Bool

    Test if resources are available

    Usually you could use ``try!`` to execute this as every error
    this throws is either system resource exhaustion or a programming
    error.

    :returns: false if the semaphore resources are at zero already, true if the semaphore could be aquired

   .. swift:method:: post()

    Release a resource to the semaphore

   .. swift:method:: whileLocking(cb: (Void) -> Void) throws

    Execute a block aquiring resources from the semaphore and return the
    resources afterwards, this is the prefered function to call.

    :parameter cb: block to execute


