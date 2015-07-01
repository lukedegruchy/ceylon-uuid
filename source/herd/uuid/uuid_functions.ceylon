import com.vasileff.ceylon.xmath.long {
    XLong=Long,
    zero,
    longNumber
}

import herd.uuid.utility {
    randomData,
    md5,
    stringToBytes,
    sha1,
    parseHexXLong,
    byteToXLong
}

// Top level attributes
Integer expectedUuidComponentSize = 5;
Integer numberOfUuidBytes = 16;

Integer timeLowExpectedNumChars = 8;
Integer timeMidExpectedNumChars = 4;
Integer timeHiVersionExpectedNumChars = 4;
Integer clockSeqExpectedNumChars = 4;
Integer nodeExpectedNumChars = 12;

"Enumerated type describing the supported UUID versions by the [[UUID]] class."
shared abstract class UuidSupportedVersion(shared Integer versionNumber, shared Boolean isRandom) 
    of uuidVersion0 | uuidVersion3 | uuidVersion4 | uuidVersion5 {}

"Version corresponding to blank UUIDs"
shared object uuidVersion0 extends UuidSupportedVersion(0,false) {}

"Version corresponding to MD5 encoded String and namespace UUIDs"
shared object uuidVersion3 extends UuidSupportedVersion(3,false) {}

"Version corresponding to randomly generated UUIDs"
shared object uuidVersion4 extends UuidSupportedVersion(4,true) {}

"Version corresponding to SHA1 encoded String and namespace UUIDs"
shared object uuidVersion5 extends UuidSupportedVersion(5,false) {}

"Versions 1 and 2 are not supported currently"
UuidSupportedVersion? determineVersion(Integer versionNumber)
    => switch(versionNumber)
        case (0) uuidVersion0
        case (3) uuidVersion3
        case (4) uuidVersion4
        case (5) uuidVersion5
        else null;

/*
 0 - Reserved, NCS backward compatibility.
 2 - DCE variant.
 6 Reserved, Microsoft Corporation GUID.
 7 Reserved for future definition. 
 */
//"Enumerated type describing the supported UUID variants by the [[UUID]] class."
shared abstract class UuidSupportedVariant(shared Integer variantNumber) 
    of uuidVariant0 | uuidVariant2 | uuidVariant6 | uuidVariant7 {}

object uuidVariant0 extends UuidSupportedVariant(0) {}
object uuidVariant2 extends UuidSupportedVariant(2) {}
object uuidVariant6 extends UuidSupportedVariant(6) {}
object uuidVariant7 extends UuidSupportedVariant(7) {}

UuidSupportedVariant? determineVariant(Integer variantNumber)
    => switch(variantNumber)
        case (0) uuidVariant0
        case (2) uuidVariant2
        else null;

// TODO:  consider use of type classes to distinguish among different types of integers

"A UUID corresponding to 00000000-0000-0000-0000-000000000000"
shared UUID blankUuid = UUID(zero,zero);

"A UUID string corresponding to UUID(0,0)"
shared String blankUuidString = "00000000-0000-0000-0000-000000000000";

// TODO:  More documentation
"Obtain a UUID from a UUID string.  If the UUID string is malformed or incorrect in any way including version
 and variant, null will be returned.  A blank UUID is supported but it must be well-formed (ie not 0-0-0-0-0)"
shared UUID? fromString(String uuidString) {
    if (uuidString.trimmed.empty) {
        return null;
    }

    [String*] uuidStringComponents = uuidString.split((char) => char == '-').sequence();

    if (uuidStringComponents.empty || 
        uuidStringComponents.size != expectedUuidComponentSize) {
        return null;
    }

    if (exists timeLowString=uuidStringComponents[0],
        exists timeMidString=uuidStringComponents[1], 
        exists timeHiVersionString=uuidStringComponents[2], 
        exists clockSeqString=uuidStringComponents[3], 
        exists nodeString=uuidStringComponents[4],
        timeLowString.size == timeLowExpectedNumChars,
        timeMidString.size == timeMidExpectedNumChars,
        timeHiVersionString.size == timeHiVersionExpectedNumChars,
        clockSeqString.size == clockSeqExpectedNumChars,
        nodeString.size == nodeExpectedNumChars) {
        
        XLong? timeLow = parseHexXLong(timeLowString);
        XLong? timeMid = parseHexXLong(timeMidString);
        XLong? timeHiVersion = parseHexXLong(timeHiVersionString);
        XLong? clockSeq = parseHexXLong(clockSeqString);
        XLong? node = parseHexXLong(nodeString);
        
        // Support supplied blank UUID
        Integer? getVersionOrZero(XLong timeHiVersion)
            => if (getVersion(timeHiVersion) == 0) then 0 else getValidVersion(timeHiVersion);
        Integer? getVariantOrZero(XLong clockSeqHiVariant)
            => if (getVariant(clockSeqHiVariant) == 0) then 0 else getValidVariant(clockSeqHiVariant);
        
        if (exists timeLow, 
            exists timeMid, 
            exists timeHiVersion, 
            exists clockSeq, 
            exists node,
            exists version = getVersionOrZero(timeHiVersion)) {
            XLong? clockSeqHiVariant = clockSeq.rightLogicalShift(8);
            XLong? clockSeqLow = clockSeq.and(longNumber(#ff));
            
            if (exists clockSeqHiVariant, 
                exists clockSeqLow,
                exists variant=getVariantOrZero(clockSeqHiVariant)) {
                return fromComponents { timeLow = timeLow; 
                                        timeMid = timeMid; 
                                        timeHiVersion = timeHiVersion; 
                                        clockSeqHiVariant = clockSeqHiVariant; 
                                        clockSeqLow = clockSeqLow; 
                                        node = node; };
            }
        }
    }
    
    return null;
}

// TODO: More documentation including reference to RFC requirements for equality and non-equality
"UUID version 3:  A UUID generated from MD5 of namespace and name. The namespace parameter is optional
 and if its argument is not provided  blank UUID (00000000-0000-0000-0000-0000000000000) will be used in its 
 place."
shared UUID uuid3Md5(String name, UUID? namespace=null)
    => convertedNamespaceAndName(namespace,name,uuidVersion3,md5);

// TODO:  More documentation
"UUID version 4:  A random UUID generated from randomly generated bytes."
shared UUID uuid4Random() {
    {Byte+} randomBytes = randomData(numberOfUuidBytes);
    
    assert(exists randomUUID=bytesToUuid(randomBytes.sequence(),uuidVersion4));
    
    return randomUUID;
}

// TODO: More documentation including reference to RFC requirements for equality and non-equality
"UUID version 5:  A UUID generated from SHA-1 of namespace and name. The namespace parameter is optional
 and if its argument is not provided  blank UUID (00000000-0000-0000-0000-0000000000000) will be used in its 
 place."
shared UUID uuid5Sha1(String name,UUID? namespace=null)
    => convertedNamespaceAndName(namespace,name,uuidVersion5,sha1);

UUID convertedNamespaceAndName(UUID? namespace, 
                               String name, 
                               UuidSupportedVersion uuidVersion,
                               Byte[] convertBytes({Byte+} bytesToConvert)) {
    assert(! uuidVersion.isRandom);

    [Byte+] bytes = 
        bytesFromNamespaceAndName(namespace else blankUuid,name);

    Byte[] bytesConverted = convertedBytes(bytes,convertBytes);

    assert (nonempty bytesConverted,
           exists uuidFromBytes = bytesToUuid(bytesConverted, uuidVersion));

    return uuidFromBytes;
}

Byte[] convertedBytes({Byte+} bytes, Byte[] convertBytes({Byte+} bytesToConvert))
    => convertBytes(bytes);

[Byte+] bytesFromNamespaceAndName(UUID namespace, String name) {
    assert (nonempty bytes=concatenate(namespace.bytes,stringToBytes(name).sequence()) );
    
    return bytes;
}

// TODO:  Documentation
shared UUID? bytesToUuid(Byte[] randomData, UuidSupportedVersion uuidVersion) {
    if (randomData.every((element) => element == 0.byte)) {
        return blankUuid;
    }

    if (exists byte1=randomData[0],
        exists byte2=randomData[1],
        exists byte3=randomData[2],
        exists byte4=randomData[3],
        exists byte5=randomData[4],
        exists byte6=randomData[5],
        exists byte7=randomData[6],
        exists byte8=randomData[7],
        exists byte9=randomData[8],
        exists byte10=randomData[9],
        exists byte11=randomData[10],
        exists byte12=randomData[11],
        exists byte13=randomData[12],
        exists byte14=randomData[13],
        exists byte15=randomData[14],
        exists byte16=randomData[15]) {

        XLong timeLow = 
            byteToXLong(byte1).leftLogicalShift(24)
                .or(byteToXLong(byte2).leftLogicalShift(16)
                .or(byteToXLong(byte3).leftLogicalShift(8)))
                .or(byteToXLong(byte4));

        // TODO:  Ask John about Byte to XLong
        XLong timeMid = 
            byteToXLong(byte5).leftLogicalShift(8).or(byteToXLong(byte6));
                
        XLong timeHiVersion =
            byteToXLong(setVersion(byte7,uuidVersion)).leftLogicalShift(8).or(byteToXLong(byte8));
        
        XLong clockSeqHiVariant = byteToXLong(setVariant(byte9));
        XLong clockSeqLow = byteToXLong(byte10);
        XLong node = 
            byteToXLong(byte11).leftLogicalShift(40)
                .or(byteToXLong(byte12).leftLogicalShift(32))
                .or(byteToXLong(byte13).leftLogicalShift(24)
                .or(byteToXLong(byte14).leftLogicalShift(16)))
                .or(byteToXLong(byte15).leftLogicalShift(8))
                .or(byteToXLong(byte16));

        return fromComponents { timeLow = timeLow; 
                                timeHiVersion = timeHiVersion; 
                                timeMid = timeMid; 
                                clockSeqHiVariant = clockSeqHiVariant; 
                                clockSeqLow = clockSeqLow; 
                                node = node; };
    }

    return null;
}

UUID fromComponents(XLong timeLow, 
                    XLong timeMid,
                    XLong timeHiVersion,
                    XLong clockSeqHiVariant,
                    XLong clockSeqLow,
                    XLong node) {
    XLong toMostBits(XLong timeLow, XLong timeMid, XLong timeHiVersion) {
        XLong shift32MostOne = timeLow.leftLogicalShift(32);
        
        XLong shift16MostTwo = timeMid.leftLogicalShift(16);
        
        XLong mostOneTwoThree = shift32MostOne.or(shift16MostTwo).or(timeHiVersion);
        
        return mostOneTwoThree;
    }
    
    XLong toLeastBits(XLong clockSeqHiVariant, XLong clockSeqLow, XLong node) {
        XLong shift48ClockSeqHiVariant = clockSeqHiVariant.leftLogicalShift(56);
        
        XLong shift40ClockSeqLow = clockSeqLow.leftLogicalShift(48);
        
        XLong clockSeq = shift48ClockSeqHiVariant.or(shift40ClockSeqLow);
        
        XLong clockSeqOrNode = clockSeq.or(node);
        
        return clockSeqOrNode;
    }
    
    XLong mostSignificantBits = toMostBits(timeLow, timeMid, timeHiVersion);
    XLong leastSignificantBits = toLeastBits(clockSeqHiVariant, clockSeqLow, node);
    
    return UUID { mostSignificantBits = mostSignificantBits; 
                  leastSignificantBits = leastSignificantBits; };
}

Integer? getValidVersion(XLong timeHiVersion)
    => let (actualVersion = getVersion(timeHiVersion))
       if (exists determinedVersion=determineVersion(actualVersion)) 
           then actualVersion
           else null;

Integer? getValidVariant(XLong clockSeqHiVariant)
        // First two bits of clockSeqHiVariant
    => let(actualVariant = getVariant(clockSeqHiVariant))
       if (exists determinedVariant=determineVariant(actualVariant))
            then actualVariant
            else null;

// TODO:  Handle overflow javascript vs. jvm? as optional?
Integer getVersion(XLong timeHiVersion)
    =>  timeHiVersion.rightLogicalShift(12).preciseInteger;

// TODO:  Handle overflow javascript vs. jvm? as optional?
Integer getVariant(XLong clockSeqHiVariant)
    => clockSeqHiVariant.rightLogicalShift(6).preciseInteger;

// TODO:  Handle overflow javascript vs. jvm? as optional?
Integer getVersionFromMostSignificantBits(XLong mostSignificantBits) 
    => if (mostSignificantBits == 0) 
        then 0 
        else mostSignificantBits.rightArithmeticShift(12).and(longNumber(#f)).preciseInteger;

// TODO:  Handle overflow javascript vs. jvm? as optional?
Integer getVariantFromLeastSignificantBits(XLong leastSignificantBits) 
    => leastSignificantBits.rightLogicalShift(62).preciseInteger;

Byte setVersion(Byte timeHiVersionPart, UuidSupportedVersion version)
    => timeHiVersionPart.and($1111.byte).or(version.versionNumber.leftLogicalShift(4).byte);

Byte setVariant(Byte clockSeqHiVariant)
    => clockSeqHiVariant.and($11_1111.byte).or($1000_0000.byte);
