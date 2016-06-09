============================
URL parsing and construction
============================


.. swift:struct:: URL

   .. swift:var:: schema: String?


   .. swift:var:: domain: String


   .. swift:var:: path: Path


   .. swift:var:: port: Int


   .. swift:var:: parameters= [(name: String, value: String?)]()


   .. swift:var:: fragment: String?


   .. swift:var:: user: String?


   .. swift:var:: password: String?


   .. swift:init:: init(string: String)


.. swift:extension:: String

   .. swift:var:: urlEncoded: String


   .. swift:var:: urlDecoded: String?


.. swift:extension:: URL : CustomStringConvertible

.. swift:extension:: URL : Hashable

