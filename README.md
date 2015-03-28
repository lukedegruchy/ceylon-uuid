Ceylon UUID
====================

UUID implementation for Ceylon as well as utility functions.
---------------------

See: (http://tools.ietf.org/html/rfc4122) for the specification

The current implementation of the UUID class contains the following attributes:

* mostSignificantBits
* leastSignificantBits

Current version: 0.0.3

Version history:

* 0.0.1: The only functionality implemented is to obtain a UUID from a UUID string 
(ex E1303FB5-F085-4D11-A51C-D85DFFC7FE27) and the actual string attribute of the UUID will output this same
UUID string.
* 0.0.2: Add functionality to obtain a randomly generated UUID version 4.  
Also, validate for supported versions and variants.
* 0.0.3: Add functionality to support version 3 (MD5) and version 5 (SHA-1) UUIDs.  Also, support blank UUID
(00000000-0000-0000-0000-000000000000), even though the standard doesn't seem to mandate this, this concept
does seem to be used in practice.
* 0.0.4: Internal storage is based on most and least significant bits and all attributes such as version, variant,
string and bytes are computed on demand instead of inlined at initialization.
