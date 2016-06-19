============
IP Addresses
============


.. swift:enum:: IPAddress

   .. swift:enum_case:: IPv4(_: UInt8, _: UInt8, _: UInt8, _: UInt8)
   
    IPv4 Address
   
   .. swift:enum_case:: IPv6(_: UInt16, _: UInt16, _: UInt16, _: UInt16, _: UInt16, _: UInt16, _: UInt16, _: UInt16)
   
    IPv6 Address
   
   .. swift:enum_case:: Wildcard
   
    Wildcard Address
   
   .. swift:init:: init?(fromString: String)
   
    Init from a string

    :parameter fromString: String with IP address
   
   .. swift:method:: sin_addr() -> in_addr?

    Create a ``in_addr`` from the address, may return ``nil`` if it was a IPv6 address
   
   .. swift:method:: sin6_addr() -> in6_addr?
   
    Create a ``in6_addr`` from the address, may return ``nil`` if it was a IPv4 address
   

.. swift:extension:: IPAddress : CustomStringConvertible

.. swift:extension:: in_addr : CustomStringConvertible

.. swift:extension:: in6_addr : CustomStringConvertible

.. swift:extension:: sockaddr_storage : CustomStringConvertible

