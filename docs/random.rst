========================
Random number generators
========================


.. swift:protocol:: RandomNumberGenerator

   Random number generators

   .. swift:method:: bytes(count: Int) -> [UInt8]
   
    Returns byte buffer of random bytes
    
    :parameter count: number of bytes to return
    :returns: buffer of random bytes
   
   .. swift:method:: unsignedNumber(range: CountableRange<UInt32>) -> UInt32
   
    Return a UInt32 random number
    
    :parameter range: Range of generated random number
    :returns: random number in ``range``
   
   .. swift:method:: signedNumber(range: CountableRange<Int32>) -> Int32
   
    Return a Int32 random number
    
    This may be a bit slower than the unsigned version as we have
    to upcast through a 64 bit type to avoid overflows.
    
    :parameter range: Range of generated random number
    :returns: random number in ``range``
   

.. swift:class:: Random : RandomNumberGenerator

   CSPRNG for linux uses /dev/urandom, so it needs a file descriptor,
   CSPRNG for OSX uses arc4random

   .. swift:class_method:: bytes(count: Int) -> [UInt8]
   
    Returns byte buffer of random bytes
    
    :parameter count: number of bytes to return
    :returns: buffer of random bytes
   
   .. swift:class_method:: unsignedNumber(range: CountableRange<UInt32>) -> UInt32
   
    Return a UInt32 random number
    
    :parameter range: Range of generated random number
    :returns: random number in ``range``
   
   .. swift:class_method:: signedNumber(range: CountableRange<Int32>) -> Int32
   
    Return a Int32 random number
    
    This may be a bit slower than the unsigned version as we have
    to upcast through a 64 bit type to avoid overflows.
    
    :parameter range: Range of generated random number
    :returns: random number in ``range``

