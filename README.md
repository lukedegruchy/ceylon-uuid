Ceylon UUID
====================

UUID implementation for Ceylon as well as utility functions.
---------------------

See: (http://tools.ietf.org/html/rfc4122) for the specification

The current implementation of the UUID class contains the following attributes:

* mostSignificantBits
* leastSignificantBits

Current version: 0.0.10

Version history:

- 0.0.1: The only functionality implemented is to obtain a UUID from a UUID string 
(ex E1303FB5-F085-4D11-A51C-D85DFFC7FE27) and the actual string attribute of the UUID will output this same
UUID string.
- 0.0.2: Add functionality to obtain a randomly generated UUID version 4.  
Also, validate for supported versions and variants.
- 0.0.3: Add functionality to support version 3 (MD5) and version 5 (SHA-1) UUIDs.  Also, support blank UUID
(00000000-0000-0000-0000-000000000000), even though the standard doesn't seem to mandate this, this concept
does seem to be used in practice.
- 0.0.4: Internal storage is based on most and least significant bits and all attributes such as version, variant,
string and bytes are computed on demand instead of inlined at initialization.
- 0.0.5:  Convert the class initializer to a constructor with the intention of making it unshared when the 
capability exists in ceylon-spec.  Ensure that the bytes attribute returns the correct bytes.  Import 
com.vasileff.ceylon.random.api and use it instead of Java's secureRandom for random number generation for
random UUIDs.
- 0.0.6: Add herd.chayote module and use its functions in place of any duplicate functions in this project.
- 0.0.7: Update to herd.chayote 0.0.7.  Change UUID constructor to sealed.  Move last unit test to test module.
Expose bytesToUuid() as shared.  Introduce type safe version as an enumerated type and use this for all
operations involving versions.
- 0.0.8: Add conversion functions from/to Java UUIDs.  Refactor into separate source files for the UUID class and 
functions/constants.  Add a TypedUUID based on Chayote TypedClass.
- 0.0.9: Replace all Integer uses that involve collections of Bytes or bits with Ceylon xmath Long (aliased as XLong).  Update to chayote 0.0.10.
- 0.0.10:  Prepare to publish to Herd. Increase version to 0.0.10. Update to Chayote 0.0.12. Improve documentation. Add support for ceylon-xmath from the Herd module. Remove functions duplicated with herd.chayote. Make bytesToUuid unshared and move its unit test to main module. Revert back to Java SecureRandom until ceylon-random is updated on Herd. Eliminate a bunch of TODOS.
