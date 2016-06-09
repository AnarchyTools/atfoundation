======================
In-memory stream (R/W)
======================


.. swift:class:: MemoryStream : InputStream, OutputStream, SeekableStream

   .. swift:var:: fp: UnsafeMutablePointer<FILE>? = nil


   .. swift:let:: fd: Int32 = -1


   .. swift:var:: position: Int = 0


   .. swift:var:: size: Int


   .. swift:init:: init(string: String)


   .. swift:init:: init(data: [UInt8])


   .. swift:init:: init()


   .. swift:init:: init(capacity: Int)


   .. swift:method:: truncate(size: Int) throws


   .. swift:method:: read(size: Int) throws -> String?


   .. swift:method:: read(size: Int) throws -> [UInt8]


   .. swift:method:: readAll() throws -> String?


   .. swift:method:: readAll() throws -> [UInt8]


   .. swift:method:: readLine() throws -> String?


   .. swift:method:: pipe(to: OutputStream) throws


   .. swift:method:: write(string: String) throws


   .. swift:method:: writeLine(string: String) throws


   .. swift:method:: write(data: [UInt8]) throws


   .. swift:method:: flush()



.. swift:extension:: MemoryStream : Hashable


