========================
Seekable stream protocol
========================


.. swift:protocol:: SeekableStream : class, Stream

   .. swift:var:: position: Int


   .. swift:var:: size: Int


   .. swift:method:: truncate(size: Int) throws



.. swift:extension:: SeekableStream

   .. swift:var:: position: Int

    seek to a position or return position

   .. swift:var:: size: Int

    query file size

   .. swift:method:: truncate(size: Int) throws

    Truncate or preallocate a file

    :parameter size: size of the file after this operation. If it is bigger than the current size remaining size is prefilled with zeroes.


.. swift:extension:: InputStream where Self: SeekableStream

   .. swift:method:: copyTo(stream: protocol<OutputStream, SeekableStream>) throws

    Copy this file to another file

    :parameter file: the file to copy the file content to


