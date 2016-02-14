import ceylon.interop.java {
    createJavaByteArray,
    javaByteArray
}
import ceylon.io.charset {
    utf8
}
import ceylon.random {
    DefaultRandom
}

import com.vasileff.ceylon.integer64 {
    Integer64,
    integer64
}

import java.security {
    MessageDigest {
        messageDigestInstance=getInstance
    }
}

shared {Byte*} stringToBytes(String text)
    => createJavaByteArray(utf8.encode(text)).byteArray.sequence();

// TODO: Use a native Ceylon md5 function when it's ready
shared Byte[] md5({Byte+} namedBytes)
    => encodeBytes(namedBytes,messageDigestInstance("MD5"));

// TODO: Use a native Ceylon sha1 function when it's ready
shared Byte[] sha1({Byte+} namedBytes)
    => encodeBytes(namedBytes,messageDigestInstance("SHA-1"));

shared Byte[] encodeBytes({Byte+} namedBytes,MessageDigest messageDigest)
    => messageDigest.digest(javaByteArray(Array(namedBytes))).byteArray.sequence();

shared {Byte+} randomData(Integer size) {
    Byte[] randomData = let (random=DefaultRandom())
    (0:size).collect((thing) => random.nextByte());

    assert(nonempty randomData);

    return randomData;
}

shared Integer64 byteToInteger64(Byte byte) {
    "Impossible for a Byte not to fit into a platform's Integer64"
     assert(exists byteAs64 = integer64(byte.unsigned) );

    return byteAs64;
}