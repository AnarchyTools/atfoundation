=====================
Replacing sub-strings
=====================


.. swift:extension:: String

   .. swift:method:: replacing(range: Range<String.Index>, replacement: String) -> String

    Return new string with ``range`` replaced by ``replacement``

    :parameter range: range to replace
    :parameter replacement: replacement
    :returns: new string with substituted range

   .. swift:method:: replacing(searchTerm: String, replacement: String) -> String

    Search for a substring and replace with other string

    :parameter searchTerm: substring to search
    :parameter replacement: replacement to substitute
    :returns: new string with applied substitutions

   .. swift:method:: replace(range: Range<String.Index>, replacement: String)

    Replace ``range`` in string with substitute, modifies self

    :parameter range: range to replace
    :parameter replacement: substitute

   .. swift:method:: replace(searchTerm: String, replacement: String)

    Replace substring in string, modifies self

    :parameter searchTerm: string to replace
    :parameter replacement: substitute


