import lukedegruchy.ceylon.uuid.utility {
    hashes,
    formatAndPadHex,
    randomData,
    parseHex,
    md5,
    integerToBytes,
    stringToBytes,
    sha1
}

" An implementation of Universal Unique Identifier (UUID).  See http://tools.ietf.org/html/rfc4122.
  The current impelementation supports only a JDK backend due to dependencies upon [[java.security::SecureRandom]], and
  [[java.security::MessageDigest]], to produce random bytes, and to implement MD5/SHA-1 hashing, respectively."

// TODO:  More documentation

// Top level attributes
Integer uuidVersion3 = 3;
Integer uuidVersion4 = 4;
Integer uuidVersion5 = 5;

Integer expectedUuidComponentSize = 5;
Integer numberOfUuidBytes = 16;

Integer timeLowExpectedNumChars = 8;
Integer timeMidExpectedNumChars = 4;
Integer timeHiVersionExpectedNumChars = 4;
Integer clockSeqExpectedNumChars = 4;
Integer nodeExpectedNumChars = 12;

// TODO: Consider not supporting version 1 or 2 seeing as their limited use and potential leakage of MAC address
[Integer+] supportedVersions = [1,2,3,4,5];
Integer supportedVariantBit = 1;

// TODO: Take into account other variants such as reserved_microsoft or reserved_future
[Integer] supportedVariants = [2];

// TODO:  consider better handling of blank UUID logic:   sublcass UUID and add hooks??

// TODO:  consider use of type classes to distinguish among different types of integers

"A UUID corresponding to 00000000-0000-0000-0000-000000000000"
shared UUID blankUuid = UUID(0,0);

"A UUID string corresponding to UUID(0,0,0,0,0,0)"
shared String blankUuidString = "00000000-0000-0000-0000-000000000000";

shared class UUID(Integer mostSignificantBits, Integer leastSignificantBits) {
    // Start initialization
    Boolean isBlankUuid
        => [mostSignificantBits, leastSignificantBits].every((element) => element == 0);
    
    Integer? getValidVersion(Integer mostSignificantBits)
        => let(innerVersion = getVersionFromMostSignificantBits(mostSignificantBits))
            if (supportedVersions.contains(innerVersion) || isBlankUuid)
                then innerVersion
                else null;
    
    Integer? getValidVariant(Integer leastSignificantBits)
        => let(innerVariant = getVariantFromLeastSignificantBits(leastSignificantBits))
            if (supportedVariants.contains(innerVariant) || isBlankUuid)
                then innerVariant
                else null;
    
    void validate() {
        assert(exists x=getValidVersion(mostSignificantBits));
        assert(exists y=getValidVariant(leastSignificantBits));
    }

    validate();

    Integer uuidComponentAsInteger(Integer valParam, Integer digits, Integer? rightShift=null) {
        Integer val = 
            if (exists rightShift) 
                    then valParam.rightLogicalShift(rightShift)
                     else valParam;
        
        return val.and((16 ^ digits) -1);
    }
    
    String uuidComponentAsString(Integer valParam, Integer digits, Integer? rightShift=null) {
        Integer uuidComponentInteger = uuidComponentAsInteger(valParam,digits,rightShift);

        assert(exists asHex=formatAndPadHex(uuidComponentInteger,digits));
        
        return asHex;
    }

    shared Byte[] bytes {
        if (isBlankUuid) {
            return [];
        }

        Integer timeLow = uuidComponentAsInteger(mostSignificantBits, 8, 32);
        Integer timeMid = uuidComponentAsInteger(mostSignificantBits, 4, 16);
        Integer timeHiVersion = uuidComponentAsInteger(mostSignificantBits, 4);
        Integer clockSeqHiVariant = uuidComponentAsInteger(mostSignificantBits, 2, 48);
        Integer clockSeqLow = uuidComponentAsInteger(mostSignificantBits, 2, 40);
        Integer node = uuidComponentAsInteger(mostSignificantBits, 12);

        Byte[] timeLowBytes = integerToBytes(timeLow);
        Byte[] timeMidBytes = integerToBytes(timeMid);
        Byte[] timeHiVersionBytes = integerToBytes(timeHiVersion);
        Byte[] clockSeqHiVariantBytes = integerToBytes(clockSeqHiVariant);
        Byte[] clockSeqLowBytes = integerToBytes(clockSeqLow);
        Byte[] nodeBytes = integerToBytes(node);
        
        return concatenate(timeLowBytes, 
                           timeMidBytes, 
                           timeHiVersionBytes, 
                           clockSeqHiVariantBytes, 
                           clockSeqLowBytes, 
                           nodeBytes);
    }

    shared Integer version => getVersionFromMostSignificantBits(mostSignificantBits);
    shared Integer variant => getVariantFromLeastSignificantBits(leastSignificantBits);

    shared actual Boolean equals(Object other) 
        => if (is UUID other) 
            then mostSignificantBits == other.mostSignificantBits && 
                 leastSignificantBits == other.leastSignificantBits
           else false;

    shared actual Integer hash 
        => hashes(mostSignificantBits, leastSignificantBits);

    // TODO:  More documentation
    "Obtain the [[String]] representation of this [[UUID]].  Example: c7761fd5-ee11-46ce-a0cc-ff8f8fb72a23"
    shared actual String string {
        if ( isBlankUuid) {
            return blankUuidString;
        }

        String timeLo = uuidComponentAsString(mostSignificantBits, 8, 32);
        String timeMid = uuidComponentAsString(mostSignificantBits, 4, 16);
        String timeHiVersion = uuidComponentAsString(mostSignificantBits, 4);
        String clockSeq = uuidComponentAsString(leastSignificantBits, 4, 48);
        String node = uuidComponentAsString(leastSignificantBits, 12);

        return "-".join([timeLo, timeMid, timeHiVersion, clockSeq, node]);
    }
}

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
        
        Integer? timeLow = parseHex(timeLowString);
        Integer? timeMid = parseHex(timeMidString);
        Integer? timeHiVersion = parseHex(timeHiVersionString);
        Integer? clockSeq = parseHex(clockSeqString);
        Integer? node = parseHex(nodeString);
        
        // Support supplied blank UUID
        Integer? getVersionOrZero(Integer timeHiVersion)
            => if (getVersion(timeHiVersion) == 0) then 0 else getValidVersion(timeHiVersion);
        Integer? getVariantOrZero(Integer clockSeqHiVariant)
            => if (getVariant(clockSeqHiVariant) == 0) then 0 else getValidVariant(clockSeqHiVariant);
        
        if (exists timeLow, 
            exists timeMid, 
            exists timeHiVersion, 
            exists clockSeq, 
            exists node,
            exists version = getVersionOrZero(timeHiVersion)) {
            Integer? clockSeqHiVariant = clockSeq.rightLogicalShift(8);
            Integer? clockSeqLow = clockSeq.and(#ff);
            
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
                               Integer uuidVersion,
                               Byte[] convertBytes({Byte+} bytesToConvert)) {
    assert([uuidVersion3,uuidVersion5].contains(uuidVersion));

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

UUID? bytesToUuid(Byte[] randomData,Integer uuidVersion) {
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

        Integer timeLow = 
            byte1.unsigned.leftLogicalShift(24)
                .or(byte2.unsigned.leftLogicalShift(16)
                .or(byte3.unsigned.leftLogicalShift(8)))
                .or(byte4.unsigned);

        Integer timeMid = 
            byte5.unsigned.leftLogicalShift(8).or(byte6.unsigned);
                
        Integer timeHiVersion =
            setVersion(byte7,uuidVersion).unsigned.leftLogicalShift(8).or(byte8.unsigned);
        
        Integer clockSeqHiVariant = setVariant(byte9).unsigned;
        Integer clockSeqLow = byte10.unsigned;
        Integer node = 
            byte11.unsigned.leftLogicalShift(40)
                .or(byte12.unsigned.leftLogicalShift(32))
                .or(byte13.unsigned.leftLogicalShift(24)
                .or(byte14.unsigned.leftLogicalShift(16)))
                .or(byte15.unsigned.leftLogicalShift(8))
                .or(byte16.unsigned);

        return fromComponents { timeLow = timeLow; 
                                timeMid = timeMid; 
                                timeHiVersion = timeHiVersion; 
                                clockSeqHiVariant = clockSeqHiVariant; 
                                clockSeqLow = clockSeqLow; 
                                node = node; };
    }

    return null;
}

UUID fromComponents(Integer timeLow, 
                    Integer timeMid,
                    Integer timeHiVersion,
                    Integer clockSeqHiVariant,
                    Integer clockSeqLow,
                    Integer node) {
    Integer toMostBits(Integer timeLow, Integer timeMid, Integer timeHiVersion) {
        Integer shift32MostOne = timeLow.leftLogicalShift(32);
        
        Integer shift16MostTwo = timeMid.leftLogicalShift(16);
        
        Integer mostOneTwoThree = shift32MostOne.or(shift16MostTwo).or(timeHiVersion);
        
        return mostOneTwoThree;
    }
    
    Integer toLeastBits(Integer clockSeqHiVariant, Integer clockSeqLow, Integer node) {
        Integer shift48ClockSeqHiVariant = clockSeqHiVariant.leftLogicalShift(56);
        
        Integer shift40ClockSeqLow = clockSeqLow.leftLogicalShift(48);
        
        Integer clockSeq = shift48ClockSeqHiVariant.or(shift40ClockSeqLow);
        
        Integer clockSeqOrNode = clockSeq.or(node);
        
        return clockSeqOrNode;
    }
    
    Integer mostSignificantBits = toMostBits(timeLow, timeMid, timeHiVersion);
    Integer leastSignificantBits = toLeastBits(clockSeqHiVariant, clockSeqLow, node);
    
    return UUID { mostSignificantBits = mostSignificantBits; 
                  leastSignificantBits = leastSignificantBits; };
}

Integer? getValidVersion(Integer timeHiVersion)
    => let (actualVersion = getVersion(timeHiVersion))
       if (supportedVersions.contains(actualVersion)) 
           then actualVersion
           else null;

Integer? getValidVariant(Integer clockSeqHiVariant)
        // First two bits of clockSeqHiVariant
    => let(variantTwoBits = getVariant(clockSeqHiVariant))
       if (supportedVariants.contains(variantTwoBits))
            then variantTwoBits
            else null;

Integer getVersion(Integer timeHiVersion)
    =>  timeHiVersion.rightLogicalShift(12);

Integer getVariant(Integer clockSeqHiVariant)
    => clockSeqHiVariant.rightLogicalShift(6);

Integer getVersionFromMostSignificantBits(Integer mostSignificantBits) 
    => mostSignificantBits.rightArithmeticShift(12).and(#f);

Integer getVariantFromLeastSignificantBits(Integer leastSignificantBits) 
    => leastSignificantBits.rightLogicalShift(62);

Byte setVersion(Byte timeHiVersionPart, Integer version)
    => timeHiVersionPart.and($1111.byte).or(version.leftLogicalShift(4).byte);

Byte setVariant(Byte clockSeqHiVariant)
    => clockSeqHiVariant.and($11_1111.byte).or($1000_0000.byte);
