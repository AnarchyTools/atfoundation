=====================
Sub-string extraction
=====================


.. swift:extension:: String

   .. swift:method:: subString(range: Range<String.Index>) -> String

    Create substring from string

    :parameter range: range of the substring, will be clamped to ``self.endIndex``
    :returns: substring or ``nil`` if start index out of range

   .. swift:method:: subString(toIndex index: String.Index) -> String

    Create substring from start to index

    :parameter index: end index, excluded
    :returns: substring

   .. swift:method:: subString(fromIndex index: String.Index) -> String

    Create substring from index to end

    :parameter index: start index, included
    :returns: substring or ``nil`` if start index out of range


