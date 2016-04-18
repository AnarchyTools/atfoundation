// # TODO List:
//
// ## File class:
//
// - init?(path:) throws
// - init?(fd:) throws
// - init?(file:) throws
// - init?(tempFilePrefix:suffix:)
// - open(mode:binary:) throws
// - seek(fromStart:) throws
// - seek(relative:) throws
// - read(count:) throws -> Data
// - readAll() throws -> Data
// - readAll() throws -> String
// - write(data:) throws -> Int (bytes written)
// - readLine() throws -> String
// - writeLine() throws -> Int (bytes written)
// - write(string:) throws -> Int (bytes written)
// - write(float:) throws -> Int (bytes written)
// - write(int:) throws -> Int (bytes written)
// - close()
// - flush()
// - fd -> Int
// - file -> FILE
// - iterate(chunkSize:) -> AnyGenerator<Data>
// - iterateLines() -> AnyGenerator<String>
// - copyTo(otherFile:) throws -> Int (bytes written)
// - size -> UInt64
// - truncate(size:) throws
// - prealloc(size:) throws
//
// ## FileMode enum
//
// - read
// - write
// - rw
// - append
//
// ## File error enum
//
// - AccessDenied
// - QuotaExceeded
// - IOError
// - IsDirectory
// - SymlinkLoop
// - FileDescriptorsExhausted
// - NameTooLong
// - NoSpaceLeftOnDevice
// - ReadOnlyFilesystem
// - BadFileDescriptor
// - OutOfMemory
// - EndOfFile
