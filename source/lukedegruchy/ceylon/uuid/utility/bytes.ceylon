import ceylon.interop.java {
    createJavaByteArray,
    javaByteArray
}
import ceylon.io.charset {
    utf8
}

import com.vasileff.ceylon.random.api {
    LCGRandom
}

import java.security {
    MessageDigest {
        messageDigestInstance=getInstance
    }
}

shared {Byte*} stringToBytes(String text) 
    => createJavaByteArray(utf8.encode(text)).byteArray.sequence(); 

Integer numberOfBytesInInteger = 8;

shared [Byte+] integerToBytesNoZeros(Integer integer) {
    value bytes = integerToBytes(integer).filter(not<Byte>((byte) => byte == 0.byte)).sequence();
    
    assert(nonempty bytes);
    
    return bytes;
}

shared [Byte+] integerToBytes(Integer integer) 
    => [for (index in numberOfBytesInInteger..1) 
            integer.rightLogicalShift((index - 1) * numberOfBytesInInteger).byte];

// TODO: Use a native Ceylon md5 function when it's ready
shared Byte[] md5({Byte+} namedBytes)
    => encodeBytes(namedBytes,messageDigestInstance("MD5"));

// TODO: Use a native Ceylon sha1 function when it's ready
shared Byte[] sha1({Byte+} namedBytes)
    => encodeBytes(namedBytes,messageDigestInstance("SHA-1"));

shared Byte[] encodeBytes({Byte+} namedBytes,MessageDigest messageDigest)
    => messageDigest.digest(javaByteArray(Array(namedBytes))).byteArray.sequence();

shared {Byte+} randomData(Integer size) {
    Byte[] randomData = let (random=LCGRandom()) 
        (0:size).collect((thing) => random.nextByte());
    
    assert(nonempty randomData);
    
    return randomData;
}