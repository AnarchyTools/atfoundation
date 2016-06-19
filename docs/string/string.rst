======================
Misc string extensions
======================


.. swift:extension:: String

   .. swift:init:: init(path: Path)

    Create string from path

    :parameter path: a path

   .. swift:init:: init(loadFromFile path: Path) throws

    Load a string from a file

    :parameter loadFromFile: the filename

   .. swift:method:: write(to file: File) throws

    Write a string to a file

    :parameter to: file to write to


.. swift:extension:: UInt16

Extension to UInt16 to convert to hex String

   .. swift:method:: hexString(padded: Bool = true) -> String

    Create Hexadecimal representation of a UInt16

    :parameter padded: set to ``true`` if the result should be zero padded
    :returns: hex representation as String


.. swift:extension:: UInt8

Extension to UInt8 to convert to hex String

   .. swift:method:: hexString(padded: Bool = true) -> String

    Create Hexadecimal representation of a UInt8

    :parameter padded: set to ``true`` if the result should be zero padded
    :returns: hex representation as String

