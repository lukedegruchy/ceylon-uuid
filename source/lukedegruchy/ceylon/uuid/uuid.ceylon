import lukedegruchy.ceylon.uuid.utility {
    hashes,
    formatAndPadHex,
    immutableMap,
    randomData,
    parseHex
}

" An implementation of Universal Unique Identifier (UUID).  See http://tools.ietf.org/html/rfc4122."

// TODO:  More documentation

Integer uuid4Version = 4;

Integer expectedUuidComponentSize = 5;
Integer numberOfUuidBytes = 16;

Integer timeLowExpectedNumChars = 8;
Integer timeMidExpectedNumChars = 4;
Integer timeHiVersionExpectedNumChars = 4;
Integer clockSeqExpectedNumChars = 4;
Integer nodeExpectedNumChars = 12;

[Integer+] supportedVersions = [1,2,3,4,5];
Integer supportedVariantBit = 1;
[Integer] supportedVariants = [2];

shared class UUID(timeLow,timeMid,timeHiVersion,clockSeqHiVariant,clockSeqLow,node) {
    // Start initialization
    Integer timeLow;
    Integer timeMid;
    Integer timeHiVersion;
    Integer clockSeqHiVariant;
    Integer clockSeqLow;
    Integer node;

    Integer getVersionAndValidate(Integer timeHiVersion)  {
        Integer? actualVersion = getVersion(timeHiVersion);

        assert (exists actualVersion); 
        
        return actualVersion;
    }
    
    Integer getVariantAndValidate(Integer clockSeqHiVariant) {
        assert (exists variant = getVariant(clockSeqHiVariant));

        return variant;
    }

    shared Integer version = getVersionAndValidate(timeHiVersion);
    shared Integer variant = getVariantAndValidate(clockSeqHiVariant);

    Integer clockSeq = clockSeqHiVariant.leftLogicalShift(8).or(clockSeqLow);

    Map<Integer,Integer> toPad = 
        immutableMap<Integer,Integer>({timeLow->timeLowExpectedNumChars, 
                                      timeMid->timeMidExpectedNumChars, 
                                      timeHiVersion->timeHiVersionExpectedNumChars,
                                      clockSeq->clockSeqExpectedNumChars,
                                      node->nodeExpectedNumChars});

    Integer[] components = toPad.keys.sequence();
    
    Integer padWith(Integer component) {
        assert(exists padWith=toPad.get(component));
        
        return padWith;
    }

    String[] hexSubValues = 
        components.map((component) => formatAndPadHex(component,padWith(component)))
                  .coalesced
                  .sequence();
    
    assert(nonempty hexSubValues);
    
    String toString = "-".join(hexSubValues);
    // End initialization

    shared actual Boolean equals(Object other) 
        => if (is UUID other) 
            then timeLow == other.timeLow && 
                 timeMid == other.timeMid &&
                 timeHiVersion == other.timeHiVersion &&
                 clockSeqHiVariant == other.clockSeqHiVariant &&
                 clockSeqLow == other.clockSeqLow &&
                 node == other.node
           else false;

    shared actual Integer hash 
        => hashes(timeLow, timeMid, timeHiVersion, clockSeqHiVariant, clockSeqLow, node);

    // TODO:  More documentation
    "Obtain the [[String]] representation of this [[UUID]].  Example: c7761fd5-ee11-46ce-a0cc-ff8f8fb72a23"
    shared actual String string => toString;
}

// TODO:  More documentation
"Obtain a UUID from a UUID string.  If the UUID string is malformed or incorrect in any way including version
 and variant, null will be returned"
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
        
        if (exists timeLow, 
            exists timeMid, 
            exists timeHiVersion, 
            exists clockSeq, 
            exists node,
            exists version = getVersion(timeHiVersion)) {
            Integer? clockSeqHiVariant = clockSeq.rightLogicalShift(8);
            Integer? clockSeqLow = clockSeq.and(#ff);
            
            if (exists clockSeqHiVariant, 
                exists clockSeqLow,
                exists variant=getVariant(clockSeqHiVariant)) {
                return UUID { timeLow = timeLow; 
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

// TODO:  More documentation
"UUID version 4:  A random UUID generated from randomly generated bytes."
shared UUID uuid4Random() {
    {Byte+} randomBytes = randomData(numberOfUuidBytes);
    
    assert(exists randomUUID=bytesToUuid(randomBytes.sequence()));
    
    return randomUUID;
}

UUID? bytesToUuid(Byte[] randomData) {
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
                setVersion(byte7).unsigned.leftLogicalShift(8).or(byte8.unsigned);
            
            Integer clockSeqHiVariant = setVariant(byte9).unsigned;
            Integer clockSeqLow = byte10.unsigned;
            Integer node = 
                byte11.unsigned.leftLogicalShift(40)
                    .or(byte12.unsigned.leftLogicalShift(32))
                    .or(byte13.unsigned.leftLogicalShift(24)
                    .or(byte14.unsigned.leftLogicalShift(16)))
                    .or(byte15.unsigned.leftLogicalShift(8))
                    .or(byte16.unsigned);

            return UUID { timeLow = timeLow; 
                          timeMid = timeMid; 
                          timeHiVersion = timeHiVersion; 
                          clockSeqHiVariant = clockSeqHiVariant; 
                          clockSeqLow = clockSeqLow; 
                          node = node; };
    }
    
    return null;
}

Integer? getVersion(Integer timeHiVersion)
    => let (actualVersion = timeHiVersion.rightLogicalShift(12))
       if (supportedVersions.contains(actualVersion)) 
           then actualVersion
           else null;

Integer? getVariant(Integer clockSeqHiVariant)
        // First two bits of clockSeqHiVariant
    => let(variantTwoBits = clockSeqHiVariant.rightLogicalShift(6))
       if (supportedVariants.contains(variantTwoBits))
            then variantTwoBits
            else null;

Byte setVersion(Byte timeHiVersionPart)
    => timeHiVersionPart.and($1111.byte).or(uuid4Version.leftLogicalShift(4).byte);

Byte setVariant(Byte clockSeqHiVariant)
    => clockSeqHiVariant.and($11_1111.byte).or($1000_0000.byte);
