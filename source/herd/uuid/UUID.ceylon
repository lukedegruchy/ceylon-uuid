import com.vasileff.ceylon.xmath.long {
    XLong=Long,
    longNumber
}

import herd.chayote.bytes {
    longToBytesNoZeros
}
import herd.chayote.format {
    formatAndPadAsHexNoUnderscores
}
import herd.chayote.object_helpers {
    equalsWithMulitple,
    hashes
}
import herd.uuid {
    UuidSupportedVersion
}

"An implementation of Universal Unique Identifier (UUID).  See [http://tools.ietf.org/html/rfc4122](http://tools.ietf.org/html/rfc4122)

 The current impelementation supports only a JDK backend due to dependencies upon [[java.security::MessageDigest]],
 to produce random bytes, and to implement MD5/SHA-1 hashing, respectively.

 According to the standard, the following components make up a UUID:

  - timeLow (8 digits)
  - timeMid (4 digits)
  - timeHiVersion (4 digits)
  - clockSeqHiVariant (2 digits)
  - clockSeqLow (2 digits)
  - node (12 digits)

 For example, for the following UUID:  5561de0e-64ad-4d9b-94f2-46926fc44121:

 - timeLow = 5561de0e
 - timeMid = 64ad
 - timeHiVersion = 4d9b
 - clockSeqHiVariant = 94
 - clockSeqLow = f2
 - node = 46926fc44121

 Since the above UUID was generated randomly, its version is 4, and is the first digit of the timeHiVersion.

 The variant is 2.  Despite any variant with a leading bit of 1 being supported, with all variants
 supported for either backward of future compatbility, only variant 2 is in actual use.

 Currently, only versions 3 (MD5 sum), 4 (randomly generated), and 5 (SHA1) are supported.
"
shared class UUID {
    // TODO:  Consider supporting this as multiple components (ex timeLo, timeMid, etc) for JavaScript VM
    XLong mostSignificantBits;
    XLong leastSignificantBits;

    "This constructor is not meant to be exposed outside of the module.  Clients should invoke
     one of the top-level functions to obtain a UUID."
    sealed shared new(XLong mostSignificantBits,XLong leastSignificantBits) {
        this.mostSignificantBits = mostSignificantBits;
        this.leastSignificantBits = leastSignificantBits;

        UuidSupportedVersion? determinedVersion =
            determineVersion(getVersionFromMostSignificantBits(mostSignificantBits));
        UuidSupportedVariant? determinedVariant =
            determineVariant(getVariantFromLeastSignificantBits(leastSignificantBits));

        "Calculated version is invalid"
        assert(exists determinedVersion);

        "Calculated variant is invalid"
        assert(exists determinedVariant);
    }

    Byte[] uuidComponentAsBytes(XLong valParam, Integer digits, Integer? rightShift=null)
        => longToBytesNoZeros(uuidComponentAsXLong(valParam, digits, rightShift));

    XLong uuidComponentAsXLong(XLong valParam, Integer digits, Integer? rightShift=null)
        => let(val = if (exists rightShift)
                        then valParam.rightLogicalShift(rightShift)
                        else valParam )
           val.and(longNumber((16 ^ digits) -1));

    String uuidComponentAsString(XLong valParam, Integer digits, Integer? rightShift=null) {
        XLong uuidComponentXLong = uuidComponentAsXLong(valParam,digits,rightShift);
        assert(exists asHex=formatAndPadAsHexNoUnderscores(uuidComponentXLong,digits));
        return asHex;
    }

    "The [[Byte]] [[Sequence]] for this [[UUID]]"
    shared Byte[] bytes {
        Byte[] timeLowBytes = uuidComponentAsBytes(mostSignificantBits, 8, 32);
        Byte[] timeMidBytes = uuidComponentAsBytes(mostSignificantBits, 4, 16);
        Byte[] timeHiVersionBytes = uuidComponentAsBytes(mostSignificantBits, 4);
        Byte[] clockSeqHiVariantBytes = uuidComponentAsBytes(leastSignificantBits, 2, 56);
        Byte[] clockSeqLowBytes = uuidComponentAsBytes(leastSignificantBits, 2, 48);
        Byte[] nodeBytes = uuidComponentAsBytes(leastSignificantBits, 12);

        return concatenate(timeLowBytes,
                           timeMidBytes,
                           timeHiVersionBytes,
                           clockSeqHiVariantBytes,
                           clockSeqLowBytes,
                           nodeBytes);
    }

    "The UUID version belonging to this UUID.  Only versions 3, 4, and 5 are currently supported."
    shared UuidSupportedVersion version {
        Integer versionInt = getVersionFromMostSignificantBits(mostSignificantBits);

        "Version is invalid. This should not happen if the UUID was constructed properly."
        assert(exists version = determineVersion(versionInt));

        return version;
    }

    "The UUID variant belonging to this UUID.  Only variant 2 is in actual use."
    shared Integer variant => getVariantFromLeastSignificantBits(leastSignificantBits);

    shared actual Boolean equals(Object other)
        => if (is UUID other)
            then equalsWithMulitple({[mostSignificantBits, other.mostSignificantBits],
                                     [leastSignificantBits, other.leastSignificantBits]})
            else false;

    shared actual Integer hash => hashes(mostSignificantBits, leastSignificantBits);

    "Obtain the [[String]] representation of this [[UUID]].
     Example: c7761fd5-ee11-46ce-a0cc-ff8f8fb72a23"
    shared actual String string {
        String timeLo = uuidComponentAsString(mostSignificantBits, 8, 32);
        String timeMid = uuidComponentAsString(mostSignificantBits, 4, 16);
        String timeHiVersion = uuidComponentAsString(mostSignificantBits, 4);
        String clockSeqHiVariant = uuidComponentAsString(leastSignificantBits, 2, 56);
        String clockSeqLow = uuidComponentAsString(leastSignificantBits, 2, 48);
        String node = uuidComponentAsString(leastSignificantBits, 12);

        return "-".join([timeLo, timeMid, timeHiVersion, clockSeqHiVariant + clockSeqLow, node]);
    }
}