===============
File management
===============


.. swift:class:: FS

   .. swift:class_method:: fileExists(path: Path) -> Bool

    Check if a file exists and return true if it does

    :parameter path: path to check
    :returns: ``true`` if the file exists

   .. swift:class_method:: isDirectory(path: Path) -> Bool

    Check if a path is a directory and return true if it is

    :parameter path: path to check
    :returns: ``true`` if the path is a directory

   .. swift:class_method:: touchItem(path: Path) throws

    Update modification time for existing item or create empty file

    :parameter path: path to update/create

   .. swift:class_method:: removeItem(path: Path, recursive: Bool = false) throws

    Remove item from file system

    If ``path`` is a non-empty directory and ``recursive`` is false
    an error will be thrown!

    :parameter path: path to remove
    :parameter recursive: optional, set to true to recursively remove directories

   .. swift:class_method:: createDirectory(path: Path, intermediate: Bool = false) throws

    Create a directory

    :parameter path: directory to create
    :parameter intermediate: optional set to true if you want the complete path to be created with intermediate directories included

   .. swift:class_method:: getInfo(path: Path) throws -> FileInfo

    Get file information for a path

    :parameter path: path to query
    :returns: FileInfo struct

   .. swift:class_method:: getOwner(path: Path) throws -> uid_t

    Get file/directory owner

    :parameter path: path to query
    :returns: User id of owner

   .. swift:class_method:: setOwner(path: Path, newOwner: uid_t) throws

    Set file/directory owner

    :parameter path: path to item
    :parameter newOwner: User ID of new owner

   .. swift:class_method:: getGroup(path: Path) throws -> gid_t

    Get file/directory group

    :parameter path: path to query
    :returns: Group id of owner

   .. swift:class_method:: setGroup(path: Path, newGroup: gid_t) throws

    Set file/directory group

    :parameter path: path to item
    :parameter newGroup: Group ID of new owner

   .. swift:class_method:: setOwnerAndGroup(path: Path, owner: uid_t, group: gid_t) throws

    Set file/directory owner

    :parameter path: path to item
    :parameter owner: User ID of new owner
    :parameter group: Group ID of new owner

   .. swift:class_method:: getSize(path: Path) throws -> UInt64

    Get file/directory size

    :parameter path: path to query
    :returns: File size

   .. swift:class_method:: getAttributes(path: Path) throws -> FileMode

    Get file/directory mode

    :parameter path: path to query
    :returns: File mode

   .. swift:class_method:: setAttributes(path: Path, mode: FileMode) throws

    Change attributes of a filesystem object

    :parameter path: path to item to change
    :parameter mode: attributes to set

   .. swift:class_method:: resolveGroup(id: gid_t) throws -> String?

    Fetch a group name for a group id

    :parameter id: group id to resolve
    :returns: string with group name or nil if it could not be resolved

   .. swift:class_method:: resolveGroup(name: String) throws -> gid_t?

    Fetch a group id for a group name

    :parameter name: group name to resolve
    :returns: group id or nil if it could not be resolved

   .. swift:class_method:: resolveUser(id: uid_t) throws -> String?

    Fetch a user name for a user id

    :parameter id: user id to resolve
    :returns: string with user name or nil if it could not be resolved

   .. swift:class_method:: resolveUser(name: String) throws -> uid_t?

    Fetch a user id for a user name

    :parameter name: user name to resolve
    :returns: user id or nil if it could not be resolved

   .. swift:class_method:: getWorkingDirectory() throws -> Path

    Get working directory

    :returns: absolute path to current directory

   .. swift:class_method:: changeWorkingDirectory(path: Path) throws

    Change working directory

    :parameter path: path to change current directory to

   .. swift:class_method:: symlinkItem(from: Path, to: Path) throws

    Create a symlink from one path to another

    :parameter from: source path
    :parameter to: destination path

   .. swift:class_method:: iterateItems(path: Path, recursive: Bool = false, includeHidden: Bool = false) throws -> AnyIterator<FileInfo>

    Iterate over all entries in a directory

    :parameter path: the path to iterate over
    :parameter recursive: optional, recurse into sub directories, defaults to false
    :parameter includeHidden: optional, include hidden files, defaults to false

   .. swift:class_method:: moveItem(from: Path, to: Path, atomic: Bool = true) throws

    Move a filesystem item from one place to another

    :parameter from: item to move
    :parameter to: destination
    :parameter atomic: optional, if true bail out if the destination is on another file system than the source. If set to false we copy then remove the source in that case. Defaults to true.

   .. swift:class_method:: copyItem(from: Path, to: Path, recursive: Bool = false) throws

    Copy a filesystem item from one place to another

    :parameter from: item to move
    :parameter to: destination
    :parameter recursive: optional, if ``from`` is a directory copy recursively, defaults to false

   .. swift:class_method:: temporaryDirectory(prefix: String = "tempdir") throws -> Path

    Create and return a unique temporary directory

    :parameter prefix: prefix name of the directory
    :returns: path to the already created directory


