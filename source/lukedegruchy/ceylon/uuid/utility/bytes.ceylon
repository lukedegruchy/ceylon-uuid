import ceylon.interop.java {
    createJavaByteArray,
    javaByteArray
}
import ceylon.io.charset {
    utf8
}

import java.lang {
    ByteArray
}
import java.security {
    MessageDigest{messageDigestInstance=getInstance},
    SecureRandom
}
shared {Byte*} stringToBytes(String text) 
        => createJavaByteArray(utf8.encode(text)).byteArray.sequence(); 

// TODO:  Find a better way to do this
shared [Byte+] integerToBytes(Integer integer, Integer bytesSize) {
    assert(bytesSize >= 1);
    
    return [for (index in bytesSize..1) integer.rightLogicalShift((index-1) * 8).byte];
}


// TODO: Use a native Ceylon md5 function when it's ready
shared Byte[] md5({Byte+} namedBytes)
    => encodeBytes(namedBytes,messageDigestInstance("MD5"));

// TODO: Use a native Ceylon sha1 function when it's ready
shared Byte[] sha1({Byte+} namedBytes)
    => encodeBytes(namedBytes,messageDigestInstance("SHA-1"));

shared Byte[] encodeBytes({Byte+} namedBytes,MessageDigest messageDigest)
    => messageDigest.digest(javaByteArray(Array(namedBytes))).byteArray.sequence();

// TODO: Use jvasileff's ceylon-random instead when it's ready
shared {Byte+} randomData(Integer size) 
    => javaRandomData(size);

{Byte+} javaRandomData(Integer size) {
    ByteArray data = ByteArray(size);
    SecureRandom().nextBytes(data);
    
    assert( nonempty dataSequence=data.byteArray.sequence());
    return dataSequence; 
}