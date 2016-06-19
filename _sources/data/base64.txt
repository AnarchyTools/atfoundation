===============
Base64 encoding
===============


.. swift:enum:: Base64Alphabet : String

   Base64 alphabet

   .. swift:enum_case:: Default = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
   
    default alphabet
   
   .. swift:enum_case:: URL = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
   
    URL type alphabet
   
   .. swift:enum_case:: XMLName = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.-"
   
    XML name alphabet
   
   .. swift:enum_case:: XMLIdentifier = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_:"
   
    XML identifier alphabet
   
   .. swift:enum_case:: Filename = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+-"
   
    alphabet for file names
   
   .. swift:enum_case:: RegEx = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!-"
   
    alphabet for regular expressions
   

.. swift:class:: Base64

   Base64 decoding and encoding

   .. swift:class_method:: encode(data: [UInt8], linebreak: Int? = nil, alphabet: Base64Alphabet = .Default) -> String
   
    Encode data with Base64 encoding
    
    :parameter data: data to encode
    :parameter linebreak: (optional) number of characters after which to insert a linebreak. (Value rounded to multiple of 4)
    :parameter alphabet: (optional) Base64 alphabet to use
    :returns: Base64 string with padding
   
   .. swift:class_method:: decode(data: [UInt8], alphabet: Base64Alphabet = .Default) -> [UInt8]
   
    Decode Base64 encoded data
    
    :parameter data: data to decode
    :parameter alphabet: (optional) Base64 alphabet to use
    :returns: decoded data
   
   .. swift:class_method:: encode(string: String, linebreak: Int? = nil, alphabet: Base64Alphabet = .Default) -> String
   
    Encode string with Base64 encoding
    
    :parameter string: string to encode
    :parameter linebreak: (optional) number of characters after which to insert a linebreak. (Value rounded to multiple of 4)
    :parameter alphabet: (optional) Base64 alphabet to use
    :returns: Base64 string with padding
   
   .. swift:class_method:: decode(string: String, alphabet: Base64Alphabet = .Default) -> [UInt8]
   
    Decode Base64 encoded string
    
    :parameter string: string to decode
    :parameter alphabet: (optional) Base64 alphabet to use
    :returns: decoded data
   

