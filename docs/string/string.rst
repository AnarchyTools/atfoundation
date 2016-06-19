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

