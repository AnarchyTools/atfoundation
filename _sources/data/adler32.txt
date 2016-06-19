================
Adler32 Checksum
================


.. swift:class:: Adler32

   .. swift:method:: addData(_ data: [UInt8])

    Add data to checksum

    :parameter data: data to add to the checksum

   .. swift:var:: crc: UInt32

    Get CRC of current state

    :returns: 32 Bits of CRC (current state)

   .. swift:class_method:: crc(string: String) -> UInt32

    Calculate Adler32 CRC of String

    :parameter string: the string to calculate the CRC for
    :returns: 32 Bit CRC sum

   .. swift:class_method:: crc(data: [UInt8]) -> UInt32

    Calculate Adler32 CRC of Data

    :parameter data: data to calcuclate the CRC for
    :returns: 32 Bit CRC sum


.. swift:extension:: String

   .. swift:method:: adler32() -> UInt32

    Calculate Adler32 CRC for string

    :returns: 32 Bit CRC sum


