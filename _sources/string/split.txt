============================
Splitting strings into parts
============================


.. swift:extension:: String

   .. swift:method:: join(parts: [String], delimiter: String) -> String

    Join array of strings by using a delimiter string

    :parameter parts: parts to join
    :parameter delimiter: delimiter to insert
    :returns: combined string

   .. swift:method:: join(parts: [String], delimiter: Character) -> String

    Join array of strings by using a delimiter character

    :parameter parts: parts to join
    :parameter delimiter: delimiter to insert
    :returns: combined string

   .. swift:method:: join(parts: [String]) -> String

    Join array of strings

    :parameter parts: parts to join
    :returns: combined string

   .. swift:method:: split(character: Character, maxSplits: Int = 0) -> [String]

    Split string into array by using delimiter character

    :parameter character: delimiter to use
    :parameter maxSplits: (optional) maximum number of splits, set to 0 to allow unlimited splits
    :returns: array with string components

   .. swift:method:: split(string: String, maxSplits: Int = 0) -> [String]

    Split string into array by using delimiter string

    :parameter string: delimiter to use
    :parameter maxSplits: (optional) maximum number of splits, set to 0 to allow unlimited splits
    :returns: array with string components


