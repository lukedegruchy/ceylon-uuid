import com.vasileff.ceylon.integer64 {
    Integer64,
    integer64
}

import herd.uuid.utility {
    md5,
    randomData,
    sha1,
    stringToBytes,
    byteToInteger64,
    parseHexInteger64
}


// Top level attributes
Integer expectedUuidComponentSize = 5;
Integer numberOfUuidBytes = 16;

Integer timeLowExpectedNumChars = 8;
Integer timeMidExpectedNumChars = 4;
Integer timeHiVersionExpectedNumChars = 4;
Integer clockSeqExpectedNumChars = 4;
Integer nodeExpectedNumChars = 12;

"Enumerated type describing the supported UUID versions by the [[UUID]] class.

 - 3: UUID generated from MD5 hashing a [[String]] and a namespace [[UUID]]?
 - 4: UUID generated randomly according to a randomization library
 - 5: UUID generated from SHA1 hashing a [[String]] and a namespace [[UUID]]?

 Versions 1 and 2 are not supported currently."
shared class UuidSupportedVersion
        of uuidVersion3 | uuidVersion4 | uuidVersion5 {
    "The [[Integer]] corresponding to the [[UUID]] version."
    shared Integer versionNumber;

    abstract new named(Integer pVersionNumber) {
        versionNumber = pVersionNumber;
    }

    "Version corresponding to MD5 encoded String and namespace UUIDs"
    shared new uuidVersion3 extends named(3) {}

    "Version corresponding to randomly generated UUIDs"
    shared new uuidVersion4 extends named(4) {}

    "Version corresponding to SHA1 encoded String and namespace UUIDs"
    shared new uuidVersion5 extends named(5) {}
}

"Determine a [[UuidSupportedVersion]] from a version number [[Integer]] (ex 3)."
shared UuidSupportedVersion? determineVersion("Number corresponding to the version" Integer versionNumber)
    => switch(versionNumber)
        case (3) UuidSupportedVersion.uuidVersion3
        case (4) UuidSupportedVersion.uuidVersion4
        case (5) UuidSupportedVersion.uuidVersion5
        else null;

"Enumerated type describing the supported UUID variants by the [[UUID]] class.
 - 0 - Reserved, NCS backward compatibility.
 - 2 - DCE variant (curently used by UUID).
 - 6 - Reserved, Microsoft Corporation GUID.
 - 7 - Reserved for future definition.
"
shared class UuidSupportedVariant
    of uuidVariant0 | uuidVariant2 | uuidVariant6 | uuidVariant7 {
    "The [[Integer]] corresponding to the [[UUID]] variant."
    shared Integer variantNumber;

    abstract new named(Integer pVariantNumber) {
        variantNumber = pVariantNumber;
    }

    "0 - Reserved, NCS backward compatibility"
    shared new uuidVariant0 extends named(0) {}

     "2 - DCE variant. (curently used by UUID)"
    shared new uuidVariant2 extends named(2) {}

     "6 - Reserved, Microsoft Corporation GUID."
    shared new uuidVariant6 extends named(6) {}

     "7 - Reserved for future definition."
    shared new uuidVariant7 extends named(7) {}

}

"Determine the [[UuidSupportedVariant]] from a variant number [[Integer]] (ex 2)."
shared UuidSupportedVariant? determineVariant("Number corrsponding to the variant" Integer variantNumber)
    => switch(variantNumber)
        case (0) UuidSupportedVariant.uuidVariant0
        case (2) UuidSupportedVariant.uuidVariant2
        else null;

"Obtain a [[UUID]] from a UUID string.  If the UUID string is malformed or incorrect in any way including
 version and variant, null will be returned."
shared UUID? fromString("UUID as String to parse" String uuidString) {
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

        Integer64? timeLow = parseHexInteger64(timeLowString);
        Integer64? timeMid = parseHexInteger64(timeMidString);
        Integer64? timeHiVersion = parseHexInteger64(timeHiVersionString);
        Integer64? clockSeq = parseHexInteger64(clockSeqString);
        Integer64? node = parseHexInteger64(nodeString);

        if (exists timeLow,
            exists timeMid,
            exists timeHiVersion,
            exists clockSeq,
            exists node,
            exists version = getValidVersion(timeHiVersion)) {
            Integer64 clockSeqHiVariant = clockSeq.rightLogicalShift(8);

            // TODO:  Assert #ff
            "Impossible for a base64 #FF to not fit within a platform's Integer64"
            assert(exists ffAs64 = integer64(#ff));
            Integer64 clockSeqLow = clockSeq.and(ffAs64);

            if (exists variant=getValidVariant(clockSeqHiVariant)) {
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

"UUID version 3: A [[UUID]] generated from MD5 of namespace and name. The namespace parameter is optional
 and if its argument is not provided a randomly generated (version 4) UUID will be used in its
 in its place.  The UUID generated will overwrite the hex value for version to 3 and variant with
 the two most significant bits of 1 and 0 for values of either 8, 9, A, or B."
shared UUID uuid3Md5("Text to hash as UUID" String name, "Optional namespace" UUID? namespace=null)
    => convertedNamespaceAndName(namespace,name,UuidSupportedVersion.uuidVersion3,md5);

"UUID version 4: A random [[UUID]] generated from randomly generated bytes using the applicable
 platform's randomization library."
shared UUID uuid4Random() {
    {Byte+} randomBytes = randomData(numberOfUuidBytes);

    assert(exists randomUUID=bytesToUuid(randomBytes.sequence(),UuidSupportedVersion.uuidVersion4));

    return randomUUID;
}

"UUID version 5: A [[UUID]] generated from SHA-1 of namespace and name. The namespace parameter is optional
 and if its argument is not provided a randomly generated (version 4) UUID will be used in its
 place.  The UUID generated will overwrite the hex value for version to 3 and variant with
 the two most significant bits of 1 and 0 for values of either 8, 9, A, or B."
shared UUID uuid5Sha1("Text to hash as UUID" String name, "Optional namespace" UUID? namespace=null)
    => convertedNamespaceAndName(namespace,name,UuidSupportedVersion.uuidVersion5,sha1);

UUID convertedNamespaceAndName(UUID? namespace,
                               String name,
                               UuidSupportedVersion uuidVersion,
                               Byte[] convertBytes({Byte+} bytesToConvert)) {
    assert(UuidSupportedVersion.uuidVersion4 != uuidVersion);

    [Byte+] bytes = bytesFromNamespaceAndName(namespace, name);

    Byte[] bytesConverted = convertedBytes(bytes,convertBytes);

    assert (nonempty bytesConverted,
           exists uuidFromBytes = bytesToUuid(bytesConverted, uuidVersion));

    return uuidFromBytes;
}

Byte[] convertedBytes({Byte+} bytes, Byte[] convertBytes({Byte+} bytesToConvert))
    => convertBytes(bytes);

[Byte+] bytesFromNamespaceAndName(UUID? namespace, String name) {
    value concatenated = concatenate(namespace?.bytes else [],stringToBytes(name).sequence());

    assert (nonempty bytes=concatenated);

    return bytes;
}

"Convert a [[Sequence]] of [[Byte]s to a [[UUID]? using a [[UuidSupportedVersion]. Returns a UUID if the
 bytes are those of a correct UUID, otherwise, [[null]]."
UUID? bytesToUuid(Byte[] randomData, UuidSupportedVersion uuidVersion) {
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

        Integer64 timeLow =
            byteToInteger64(byte1).leftLogicalShift(24)
                .or(byteToInteger64(byte2).leftLogicalShift(16)
                .or(byteToInteger64(byte3).leftLogicalShift(8)))
                .or(byteToInteger64(byte4));

        Integer64 timeMid =
            byteToInteger64(byte5).leftLogicalShift(8).or(byteToInteger64(byte6));

        Integer64 timeHiVersion =
            byteToInteger64(setVersion(byte7,uuidVersion)).leftLogicalShift(8).or(byteToInteger64(byte8));

        Integer64 clockSeqHiVariant = byteToInteger64(setVariant(byte9));
        Integer64 clockSeqLow = byteToInteger64(byte10);
        Integer64 node =
            byteToInteger64(byte11).leftLogicalShift(40)
                .or(byteToInteger64(byte12).leftLogicalShift(32))
                .or(byteToInteger64(byte13).leftLogicalShift(24)
                .or(byteToInteger64(byte14).leftLogicalShift(16)))
                .or(byteToInteger64(byte15).leftLogicalShift(8))
                .or(byteToInteger64(byte16));

        return fromComponents { timeLow = timeLow;
                                timeHiVersion = timeHiVersion;
                                timeMid = timeMid;
                                clockSeqHiVariant = clockSeqHiVariant;
                                clockSeqLow = clockSeqLow;
                                node = node; };
    }

    return null;
}

UUID fromComponents(Integer64 timeLow,
                    Integer64 timeMid,
                    Integer64 timeHiVersion,
                    Integer64 clockSeqHiVariant,
                    Integer64 clockSeqLow,
                    Integer64 node) {
    Integer64 toMostBits(Integer64 timeLow, Integer64 timeMid, Integer64 timeHiVersion) {
        Integer64 shift32MostOne = timeLow.leftLogicalShift(32);

        Integer64 shift16MostTwo = timeMid.leftLogicalShift(16);

        Integer64 mostOneTwoThree = shift32MostOne.or(shift16MostTwo).or(timeHiVersion);

        return mostOneTwoThree;
    }

    Integer64 toLeastBits(Integer64 clockSeqHiVariant, Integer64 clockSeqLow, Integer64 node) {
        Integer64 shift48ClockSeqHiVariant = clockSeqHiVariant.leftLogicalShift(56);

        Integer64 shift40ClockSeqLow = clockSeqLow.leftLogicalShift(48);

        Integer64 clockSeq = shift48ClockSeqHiVariant.or(shift40ClockSeqLow);

        Integer64 clockSeqOrNode = clockSeq.or(node);

        return clockSeqOrNode;
    }

    Integer64 mostSignificantBits = toMostBits(timeLow, timeMid, timeHiVersion);
    Integer64 leastSignificantBits = toLeastBits(clockSeqHiVariant, clockSeqLow, node);

    return UUID { mostSignificantBits = mostSignificantBits;
                  leastSignificantBits = leastSignificantBits; };
}

Integer? getValidVersion(Integer64 timeHiVersion)
    => let (actualVersion = getVersion(timeHiVersion))
       if (exists determinedVersion=determineVersion(actualVersion))
           then actualVersion
           else null;

Integer? getValidVariant(Integer64 clockSeqHiVariant)
        // First two bits of clockSeqHiVariant
    => let(actualVariant = getVariant(clockSeqHiVariant))
       if (exists determinedVariant=determineVariant(actualVariant))
            then actualVariant
            else null;

Integer getVersion(Integer64 timeHiVersion)
    =>  timeHiVersion.rightLogicalShift(12).preciseInteger;

Integer getVariant(Integer64 clockSeqHiVariant)
    => clockSeqHiVariant.rightLogicalShift(6).preciseInteger;

Integer getVersionFromMostSignificantBits(Integer64 mostSignificantBits) {
    if (mostSignificantBits == 0) {
        return 0;
    }

    "Impossible for a base64 #F to not fit within a platform's Integer64"
    assert(exists fAs64=integer64(#f));

    return mostSignificantBits.rightArithmeticShift(12).and(fAs64).preciseInteger;
}

Integer getVariantFromLeastSignificantBits(Integer64 leastSignificantBits)
    => leastSignificantBits.rightLogicalShift(62).preciseInteger;

Byte setVersion(Byte timeHiVersionPart, UuidSupportedVersion version)
    => timeHiVersionPart.and($1111.byte).or(version.versionNumber.leftLogicalShift(4).byte);

Byte setVariant(Byte clockSeqHiVariant)
    => clockSeqHiVariant.and($11_1111.byte).or($1000_0000.byte);
