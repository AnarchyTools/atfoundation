=========================
Output streams (writable)
=========================


.. swift:protocol:: OutputStream : class, Stream

   .. swift:method:: write(string: String) throws


   .. swift:method:: writeLine(string: String) throws


   .. swift:method:: write(data: [UInt8]) throws


   .. swift:method:: flush()



.. swift:extension:: OutputStream

   .. swift:method:: write(string: String) throws

    Write a string to the file

    :parameter string: the string to write

   .. swift:method:: writeLine(string: String) throws

    Write a line to the file, newline is appended automatically

    :parameter string: the string to write

   .. swift:method:: write(data: [UInt8]) throws

    Write data to the file

    :parameter data: UInt8 array with bytes to write

   .. swift:method:: flush()

    Flush all buffers to disk


