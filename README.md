Ceylon UUID
====================

UUID implementation for Ceylon as well as utility functions.
---------------------

An implementation of Universal Unique Identifier (UUID).  See [http://tools.ietf.org/html/rfc4122](http://tools.ietf.org/html/rfc4122)

 The current implementation supports only a JVM backend due to dependencies upon [[java.security::MessageDigest]],
 to produce random bytes, and to implement MD5/SHA-1 hashing, respectively.

According to the standard, the following components make up a [[UUID]] :

- timeLow (8 digits)
- timeMid (4 digits)
- timeHiVersion (4 digits)
- clockSeqHiVariant (2 digits)
- clockSeqLow (2 digits)
- node (12 digits)

For example, for the following UUID:  5561de0e-64ad-4d9b-94f2-46926fc44121:

- timeLow = 5561de0e
- timeMid = 64ad
- timeHiVersion = 4d9b
- clockSeqHiVariant = 94
- clockSeqLow = f2
- node = 46926fc44121

Since the above UUID was generated randomly, its version is 4, and is the first digit of the timeHiVersion.

The variant is 2.  Despite any variant with a leading bit of 1 being supported, with all variants
supported for either backward or future compatibility, only variant 2 is in actual use.

Currently, only versions 3 (MD5 sum), 4 (randomly generated), and 5 (SHA1) are supported.

Usage:

To make use of UUID, import the module from herd (in a JVM-only project currently):

        import herd.uuid "0.0.10";

To obtain a [[UUID]] from a UUID [[String]]:

        UUID? uuidFromString = fromString(\"01c17b28-380d-48e2-9d6d-5c9f92b3546d\");

To generate a UUID version 3 as an MD5 hash of a String with

        UUID uuidVersion3 = uuid3Md5(\"some string\");

To generate a UUID version 5 as an SHA1 hash of a String and namespace with

        UUID uuidVersion5 = uuid5Sha1(\"some string\", fromString(\"08110431-c913-4e72-b3e6-d3baad15f4db\"));

To generate a random UUID version 4:

        UUID uuidVersion4 = uuid4Random();

In addition support functions to convert from/to Java [[java.util::UUID]]s.

To obtain a Java [[java.util::UUID]] from a [[UUID]]:

        import java.util {
           JUUID=UUID
        }

        JUUID javaUuid = toJavaUuid(ceylonUuid);

To obtain a [[UUID]] from a Java [[java.util::UUID]]:

        UUID javaUuid = toUuid(javaUuid);

Also, there is a [[TypedUUID]] class that subclasses the herd.chayote [[herd.chayote.type_classes::TypedClass]].

        class AccountId(UUID baseValue) extends TypedUUID(baseValue) {}
        class ReferenceId(UUID baseValue) extends TypedUUID(baseValue) {}

        value accountId1 = AccountId(fromString());
        value accountId2 = AccountId(fromString());

        value refId1 = ReferenceId(fromString());
        value refId2 = ReferenceId(fromString());

        assertFalse(accountId1.equals(accountId2);
        assertFalse(accountId1.equals(referenceId1);
        assertFalse(referenceId2.equals(accountId2);

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
- 0.0.10:  Prepare to publish to Herd. Increase version to 0.0.10. Update to Chayote 0.0.12. Improve documentation. Add support for ceylon-xmath from the Herd module. Remove functions duplicated with herd.chayote. Make bytesToUuid unshared and move its unit test to main module. Eliminate a bunch of TODOS.
