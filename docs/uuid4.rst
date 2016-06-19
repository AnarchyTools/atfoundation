===========
UUID values
===========


.. swift:struct:: UUID4 : Equatable

   UUID4 (Random class)

   .. swift:init:: init()
   
    Initialize random UUID
   
   .. swift:init:: init(bytes: [UInt8])
   
    Initialize UUID from bytes
    
    :parameter bytes: 16 bytes of UUID data
    :returns: nil if the bytes are no valid UUID
   
   .. swift:init:: init(string: String)
   
    Initialize UUID from string
    
    :parameter string: string in default UUID representation
   

.. swift:extension:: UUID4 : CustomStringConvertible 

.. swift:extension:: UUID4 : Hashable  

