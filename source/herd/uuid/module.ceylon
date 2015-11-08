"An implementation of Universal Unique Identifier (UUID).  See http://tools.ietf.org/html/rfc4122.
 The current impelementation supports only a JDK backend due to dependencies upon [[java.security::MessageDigest]],
 to produce random bytes, and to implement MD5/SHA-1 hashing, respectively.

 According to the standard, the following components make up a [[UUID]]:

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
 supported for either backward of future compatbility, only variant 2 is in actual use.

 Currently, only versions 3 (MD5 sum), 4 (randomly generated), and 5 (SHA1) are supported.

 In addition support functions to convert from/to Java UUIDs.

 Also, there is a [[TypedUUID]] class that subclasses Chayote's TypedClass."
// TODO:  Support JavaScript runtime once native SHA1 and MD5 support is available
native("jvm")
module herd.uuid "0.0.10" {
    import ceylon.collection "1.2.0";
    import ceylon.interop.java "1.2.0";
    import ceylon.io "1.2.0";
    import ceylon.test "1.2.0";
    import com.vasileff.ceylon.random.api "0.0.5";
    shared import com.vasileff.ceylon.xmath "0.0.1";
    shared import herd.chayote "0.0.12";
    shared import java.base "8";
}
