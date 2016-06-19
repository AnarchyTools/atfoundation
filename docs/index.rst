============
atfoundation
============

.. image:: _static/logo.png
    :scale: 50%
    :alt: AnarchyTools logo
    :align: left

*atfoundation* is a relatively small replacement for Apple's *Foundation* extension to the Swift standard library.

The current problem with Apple's *Foundation* is that they want to follow the OS X APIs that *Foundation* delivers there. That is wirtten mostly in Objective C which is not available on Linux, so they are in fact re-implementing *Foundation* in Swift by copying the complete API interface over to Linux.

As this is an immense task it is not nearly finished yet. In my opinion they made the mistake to stub the complete API interface they want to recreate by defining all of the interfaces and then throwing a fatal "Not Implemented yet" error when you call that interface. As you can imagine that is totally unusable when you rely on an API that is working only to see that your program runs fine on OSX and crashes on Linux.

Furthermore by copying the interface from Objective C, the API may look familiar if you're coming from there, but sticks out like a sore thumb if you approach it from the direction of the Swift standard library (though they made some mistakes there too.)

*atfoundation* tries to fill in for *Foundation*. The philosopy behind *atfoundation* is to be small, readable, *swifty* and complete, which means every interface you can see actually works.

How to use
++++++++++

If you're already using `AnarchyTools <http://anarchytools.org>`_ simply add *atfoundation* to your dependencies:

.. code-block:: clojure

     (package

       ...

        :external-packages [
          {
             :url "https://github.com/AnarchyTools/atfoundation.git"
             :version [ "1.0.0" ]
          }
        ]

       ...

        :tasks {
          :default {
                :tool "atllbuild"

               ...

                :link-with ["atfoundation.a"]
                :dependencies ["atfoundation.atfoundation"]
          }
        }
     )

and import it in your source files:

.. code-block:: swift

     import atfoundation

Remove the c standard library dance, if you have something like:

.. code-block:: swift

     #if os(Linux)
          import Glibc
     #else
          import Darwin
     #endif

just remove that as *atfoundation* implicitly imports that for you.


.. toctree::
    :name: mastertoc
    :hidden:

    string
    filesystem
    date
    logger
    net
    process
    thread
    data
    uuid4
    random
    charset
    syserror
    tools
