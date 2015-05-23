" An implementation of Universal Unique Identifier (UUID).  See http://tools.ietf.org/html/rfc4122.
  The current impelementation supports only a JDK backend due to dependencies upon [[java.security::MessageDigest]], 
  to produce random bytes, and to implement MD5/SHA-1 hashing, respectively.
  
  Currently, only versions 3,4, and 5 are supported, as well as version 0 for a blank UUID.
  
  In contrast to the strict interpretation of the standard, a blank UUID of 
  00000000-0000-0000-0000-000000000000 is supported.
  
  In addition support functions to convert from/to Java UUIDs.
  
  Also, there is a [[TypedUUID]] class that subclasses Chayote's TypedClass."
// TODO:  More Documentation
native("jvm")
module herd.uuid "0.0.8" {
    import ceylon.collection "1.1.1";
    import ceylon.interop.java "1.1.1";
    import ceylon.io "1.1.1";
    import com.vasileff.ceylon.random.api "0.0.4";
    shared import herd.chayote "0.0.9";
    shared import java.base "8";
}
