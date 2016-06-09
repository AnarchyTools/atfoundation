===========
File access
===========


.. swift:class:: ROFile : SeekableStream, InputStream

   .. swift:var:: fp: UnsafeMutablePointer<FILE>?

    FILE pointer

   .. swift:var:: path: Path?

    file path (may be nil if created from file descriptor or file pointer)

   .. swift:init:: init(path: Path, binary: Bool = false) throws

    Initialize with a path

    :parameter path: the path to open
    :parameter mode: file mode to use
    :parameter binary: optional, open in binary mode, defaults to text mode

   .. swift:init:: init(fd: Int32, binary: Bool = false, takeOwnership: Bool = false) throws

    Initialize with a file descriptor

    :parameter fd: the file descriptor to open
    :parameter mode: file mode to use
    :parameter binary: optional, open in binary mode, defaults to text mode
    :parameter takeOwnership: optional, close file if this gets deallocated, defaults to false

   .. swift:init:: init(file: UnsafeMutablePointer<FILE>, takeOwnership: Bool = false)

    Initialize with a file pointer

    :parameter file: the file pointer to use
    :parameter takeOwnership: optional, close file if this gets deallocated, defaults to false


.. swift:class:: WOFile : SeekableStream, OutputStream

   .. swift:var:: fp: UnsafeMutablePointer<FILE>?

    FILE pointer

   .. swift:var:: path: Path?

    file path (may be nil if created from file descriptor or file pointer)

   .. swift:init:: init(path: Path, binary: Bool = false) throws

    Initialize with a path

    :parameter path: the path to open
    :parameter mode: file mode to use
    :parameter binary: optional, open in binary mode, defaults to text mode

   .. swift:init:: init(fd: Int32, binary: Bool = false, takeOwnership: Bool = false) throws

    Initialize with a file descriptor

    :parameter fd: the file descriptor to open
    :parameter mode: file mode to use
    :parameter binary: optional, open in binary mode, defaults to text mode
    :parameter takeOwnership: optional, close file if this gets deallocated, defaults to false

   .. swift:init:: init(file: UnsafeMutablePointer<FILE>, takeOwnership: Bool = false)

    Initialize with a file pointer

    :parameter file: the file pointer to use
    :parameter takeOwnership: optional, close file if this gets deallocated, defaults to false


.. swift:class:: RWFile : SeekableStream, InputStream, OutputStream

   .. swift:var:: fp: UnsafeMutablePointer<FILE>?

    FILE pointer

   .. swift:var:: path: Path?

    file path (may be nil if created from file descriptor or file pointer)

   .. swift:init:: init(path: Path, binary: Bool = false) throws

    Initialize with a path

    :parameter path: the path to open
    :parameter mode: file mode to use
    :parameter binary: optional, open in binary mode, defaults to text mode

   .. swift:init:: init(fd: Int32, binary: Bool = false, takeOwnership: Bool = false) throws

    Initialize with a file descriptor

    :parameter fd: the file descriptor to open
    :parameter mode: file mode to use
    :parameter binary: optional, open in binary mode, defaults to text mode
    :parameter takeOwnership: optional, close file if this gets deallocated, defaults to false

   .. swift:init:: init(file: UnsafeMutablePointer<FILE>, takeOwnership: Bool = false)

    Initialize with a file pointer

    :parameter file: the file pointer to use
    :parameter takeOwnership: optional, close file if this gets deallocated, defaults to false


.. swift:class:: File : SeekableStream, InputStream, OutputStream

   .. swift:var:: fp: UnsafeMutablePointer<FILE>?

    FILE pointer

   .. swift:var:: path: Path?

    file path (may be ``nil`` if created from file descriptor or file pointer)

   .. swift:init:: init(path: Path, mode: Mode, binary: Bool = false) throws

    Initialize with a path

    :parameter path: the path to open
    :parameter mode: file mode to use
    :parameter binary: optional, open in binary mode, defaults to text mode

   .. swift:init:: init(fd: Int32, mode: Mode, binary: Bool = false, takeOwnership: Bool = false) throws

    Initialize with a file descriptor

    :parameter fd: the file descriptor to open
    :parameter mode: file mode to use
    :parameter binary: optional, open in binary mode, defaults to text mode
    :parameter takeOwnership: optional, close file if this gets deallocated, defaults to false

   .. swift:init:: init(file: UnsafeMutablePointer<FILE>, takeOwnership: Bool = false)

    Initialize with a file pointer

    :parameter file: the file pointer to use
    :parameter takeOwnership: optional, close file if this gets deallocated, defaults to false

   .. swift:init:: init(tempFileAtPath path: Path, prefix: String, binary: Bool = false) throws

    Initialize with a temporary file name

    :parameter tempFileAtPath: path to create the temp file in
    :parameter prefix: file name prefix to use
    :parameter binary: optional, open in binary mode, defaults to text mode

   .. swift:class_method:: tempFile(binary: Bool = false) throws -> File

    Create a completely temporary file in the temp dir

    :parameter binary: optional, open in binary mode, defaults to text mode
    :returns: File instance for a unique temporary file

   .. swift:method:: copyTo(path: Path) throws

    Copy this file to another path

    :parameter path: the path to copy the file to

   .. swift:enum:: Mode : String

       .. swift:enum_case:: ReadOnly = "r"

            Read only

       .. swift:enum_case:: WriteOnly = "w"

            Write only

       .. swift:enum_case:: ReadAndWrite = "r+"

            Read an write

       .. swift:enum_case:: AppendOnly = "a"

            Write only, set position to end

       .. swift:enum_case:: AppendAndRead = "a+"

            Read and write, set position to end



