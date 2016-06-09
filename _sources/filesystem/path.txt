====================================
Path construction and deconstruction
====================================


.. swift:struct:: Path

   .. swift:let:: components: [String]

    split path components

   .. swift:let:: isAbsolute: Bool

    is this an absolute or relative path

   .. swift:var:: delimiter: Character

    delimiter between path components

   .. swift:init:: init(_ string: String, delimiter: Character = "/")

    Initialize with a string, the string is split
    into components by the rules of the current platform

    :parameter string: The string to parse

   .. swift:init:: init(components: [String], absolute: Bool = false)

    Initialize with path components

    :parameter components: Array of path component strings
    :parameter absolute: Boolean, defines if the path is absolute

   .. swift:init:: init(absolute: Bool = false)

    Initialize empty path

    :parameter absolute: If set to true the empty path is equal to the root path, else it equals the current path

   .. swift:method:: appending(_ component: String) -> Path

    Create a new path instance by appending a component

    :parameter component: path component to append
    :returns: new Path instance

   .. swift:method:: removingLastComponent() -> Path

    Create a new path instance by removing the last path component

    :returns: New path instance cropped by the last path component

   .. swift:method:: removingFirstComponent() -> Path

    Create a new path instance by removing the first path component

    :returns: New path instance cropped by the first path component, implies conversion to relative path

   .. swift:method:: join(_ path: Path) -> Path

    Create a new path instance by joining two paths

    :parameter path: other path to append to this instance. If the other path is absolute the result is the other path without this instance.

   .. swift:method:: relativeTo(path: Path) -> Path?

    Create a path instance that defines a relative path to another path

    :parameter path: the path to calculate a relative path to
    :returns: new path instance that is a relative path to ``path``. If this instance is not absolute the result will be ``nil``

   .. swift:method:: dirname() -> Path

    Return the dirname of a path

    :returns: new path instance with only the dir name

   .. swift:method:: basename() -> String

    Return the file name of a path

    :returns: file name string

   .. swift:method:: homeDirectory() -> Path?

    Return absolute path to the user's home directory

    :returns: absolute path to user's homee directory or ``nil`` if that's not available

   .. swift:method:: tempDirectory() -> Path

    Return path to the temp directory

    :returns: path instance with temp directory


.. swift:extension:: Path : CustomStringConvertible


