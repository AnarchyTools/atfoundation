========================
Input (readable) streams
========================


.. swift:protocol:: InputStream : class, Stream

   .. swift:method:: read(size: Int) throws -> String?


   .. swift:method:: read(size: Int) throws -> [UInt8]


   .. swift:method:: readAll() throws -> String?


   .. swift:method:: readAll() throws -> [UInt8]


   .. swift:method:: readLine() throws -> String?


   .. swift:method:: iterate(chunkSize: Int) -> AnyIterator<[UInt8]>


   .. swift:method:: iterateLines() -> AnyIterator<String>


   .. swift:method:: pipe(to: OutputStream) throws



.. swift:extension:: InputStream

   .. swift:method:: read(size: Int = 4096) throws -> String?

    Read bytes into a string

    :parameter size: maximum size to read, may return less bytes on EOF
    :returns: String read from file if valid UTF-8 or nil

   .. swift:method:: read(size: Int = 4096) throws -> [UInt8]

    Read bytes from file

    :parameter size: maximum size to read, may return less bytes on EOF
    :returns: UInt8 array with bytes

   .. swift:method:: readAll() throws -> String?

    Read complete file into a string

    :returns: String read from file if valid UTF-8 or nil

   .. swift:method:: readAll() throws -> [UInt8]

    Read complete file

    :returns: Uint8 array of bytes read from file

   .. swift:method:: readLine() throws -> String?

    Read a single line from a file, max 64 KiB

    :returns: String read from file (newline excluded) if valid UTF-8 or nil

   .. swift:method:: iterate(chunkSize: Int) -> AnyIterator<[UInt8]>

    Iterate over chunks of data

    :parameter chunkSize: size to read for each iteration. Last iteration may return less than that.

   .. swift:method:: iterateLines() -> AnyIterator<String>

    Iterate over lines of the file

   .. swift:method:: pipe(to destination: OutputStream) throws

    Pipe data from current position to output stream until end of current stream

    :parameter to: the stream to copy data to


