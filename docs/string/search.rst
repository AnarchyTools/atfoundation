========================================
Searching for sub-strings and characters
========================================


.. swift:extension:: String

   .. swift:method:: position(character: Character, index: String.Index? = nil, reverse: Bool = false) -> String.Index?

    Search for a character in a string

    :parameter character: character to search
    :parameter index: (optional) start index, defaults to start or end of string depending on ``reverse``
    :parameter reverse: (optional) search backwards from the ``index`` or the end of the string
    :returns: ``String.Index`` if character was found or ``nil``

   .. swift:method:: positions(character: Character) -> [String.Index]

    Return array with string indices of found character positions

    :parameter character: character to search
    :returns: array of ``String.Index`` or empty array if character not found

   .. swift:method:: position(string: String, index: String.Index? = nil, reverse: Bool = false) -> String.Index?

    Search for a substring

    :parameter string: substring to search
    :parameter index: (optional) start index, defaults to start or end of string depending on ``reverse``
    :parameter reverse: (optional) search backwards from the ``index`` or the end of the string
    :returns: ``String.Index`` if character was found or ``nil``

   .. swift:method:: positions(string: String) -> [String.Index]

    Return array with string indices of found substring positions

    :parameter string: substring to search
    :returns: array of ``String.Index`` or empty array if substring not found

   .. swift:method:: contains(string: String) -> Bool

    Search for a substring

    :parameter string: string to search
    :returns: ``true`` if the string contains the substring

   .. swift:method:: contains(character: Character) -> Bool

    Search for a character

    :parameter char: character to search
    :returns: ``true`` if the string contains the character

   .. swift:method:: hasPrefix(_ prefix: String) -> Bool

    Check if a string has a prefix

    :parameter prefix: the prefix to check for
    :returns: true if the prefix was an empty string or the string has the prefix

   .. swift:method:: hasSuffix(_ suffix: String) -> Bool

    Check if a string has a suffix

    :parameter suffix: the suffix to check for
    :returns: true if the suffix was an empty string or the string has the suffix


