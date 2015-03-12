# ceylon-uuid
Ceylon UUID
====================

UUID implementation for Ceylon as well as utility functions.
---------------------

See: (http://tools.ietf.org/html/rfc4122) for the specification

The current implementation of the UUID class contains the following attributes:

* timeLow;
* timeMid;
* timeHiVersion;
* clockSeqHiVariant;
* clockSeqLow;
* node;

Currently (version 0.0.1), the only functionality implemented is to obtain a UUID from a UUID string 
(ex E1303FB5-F085-4D11-A51C-D85DFFC7FE27) and the actual string attribute of the UUID will output this same
UUID string.