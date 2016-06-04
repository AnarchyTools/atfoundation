Sub-Strings
+++++++++++

The sub-string functions work like you will expect from other languages but use the ``String.Index`` construct as known by other string functionality.

.. swift:extension:: String

    .. swift:method:: subString(range: Range<String.Index>) -> String

       :parameter range: Sub-string range
       :returns: new string that contains only the sub-string

    .. swift:method:: subString(toIndex: String.Index) -> String

    .. swift:method:: subString(fromIndex: String.Index) -> String


