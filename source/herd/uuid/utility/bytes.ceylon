import ceylon.interop.java {
    createJavaByteArray,
    javaByteArray
}
import ceylon.io.charset {
    utf8
}

import com.vasileff.ceylon.xmath.long {
    longNumber,
    XLong=Long
}

import java.lang {
    ByteArray
}
import java.security {
    MessageDigest {
        messageDigestInstance=getInstance
    },
    SecureRandom
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

shared {Byte+} randomData(Integer size)
    => javaRandomData(size);

{Byte+} javaRandomData(Integer size) {
    ByteArray data = ByteArray(size);
    SecureRandom().nextBytes(data);

    assert( nonempty dataSequence=data.byteArray.sequence());

    return dataSequence;
}

shared XLong byteToLong(Byte byte) => longNumber(byte.unsigned);