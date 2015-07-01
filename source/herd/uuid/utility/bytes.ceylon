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
import com.vasileff.ceylon.xmath.long {
    XLong=Long,
    longNumber
}

import herd.chayote.bytes {
    binaryToBytesNoZeros,
    binaryToBytes
}

import java.security {
    MessageDigest {
        messageDigestInstance=getInstance
    }
}

// TODO:  Chayote
Integer numBitsInByte = 8;
// TODO:  Chayote
Integer numBytesInInteger = runtime.integerAddressableSize / numBitsInByte;

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
    Byte[] randomData = let (random=LCGRandom()) 
        (0:size).collect((thing) => random.nextByte());
    
    assert(nonempty randomData);
    
    return randomData;
}

// TODO: Ask John Vasileff about this
shared XLong byteToXLong(Byte byte) => longNumber(byte.unsigned);

// TODO:  To Chayote
// TODO:  Strip out leading zeros only
shared [Byte+] xLongToBytesNoLeadingZeros(XLong xLong)
    => binaryToBytesNoZeros(xLong, xLongToByte);

// TODO:  To Chayote
// TODO:  How to convert XLong to byte
shared [Byte+] xLongToBytes(XLong xLong) 
    => binaryToBytes(xLong, xLongToByte);

// TODO: Check for size of xLong and return absent if overflow
Byte xLongToByte(XLong xLong) => xLong.integer.byte;