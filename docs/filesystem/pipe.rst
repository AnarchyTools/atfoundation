===================
Communication pipes
===================


.. swift:class:: WritePipe : OutputStream

   .. swift:var:: fp: UnsafeMutablePointer<FILE>?

    File pointer


.. swift:protocol:: ReadEvents : class, InputStream

   .. swift:var:: readThread: Thread?


   .. swift:method:: onReadData(cb: ([UInt8]) -> Void)


   .. swift:method:: onReadLine(cb: (String) -> Void)



.. swift:extension:: ReadEvents

   .. swift:method:: onReadData(cb: ([UInt8]) -> Void)


   .. swift:method:: onReadLine(cb: (String) -> Void)



.. swift:class:: ReadPipe : InputStream

   .. swift:var:: readThread: Thread? = nil


   .. swift:var:: fp: UnsafeMutablePointer<FILE>?

    File pointer


.. swift:extension:: ReadPipe : ReadEvents

   .. swift:class:: RWPipe : InputStream, OutputStream

       .. swift:var:: readThread: Thread? = nil


       .. swift:var:: fp: UnsafeMutablePointer<FILE>?

            File pointer



.. swift:extension:: RWPipe : ReadEvents


