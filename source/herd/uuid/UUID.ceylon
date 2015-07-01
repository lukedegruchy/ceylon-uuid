import com.vasileff.ceylon.xmath.long {
    XLong=Long,
    longNumber,
    zero
}

import herd.chayote.object_helpers {
    equalsWithMulitple,
    hashes
}
import herd.uuid.utility {
    formatAndPadAsHexNoUnderscoresXLong,
    xLongToBytesNoLeadingZeros
}

" An implementation of Universal Unique Identifier (UUID).  See http://tools.ietf.org/html/rfc4122.
  The current impelementation supports only a JDK backend due to dependencies upon [[java.security::MessageDigest]], 
  to produce random bytes, and to implement MD5/SHA-1 hashing, respectively.
  
  Currently, only versions 3,4, and 5 are supported, as well as version 0 for a blank UUID.
  
  In contrast to the strict interpretation of the standard, a blank UUID of 
  00000000-0000-0000-0000-000000000000 is supported."
// TODO:  More documentation
// TODO:  consider better handling of blank UUID logic:   subclass UUID and add hooks??

shared class UUID {
    XLong mostSignificantBits;
    XLong leastSignificantBits;

    Boolean isAllZeros(XLong mostSignificantBits, XLong leastSignificantBits)
        => [mostSignificantBits, leastSignificantBits].every((element) => element == zero);
    
    "This constructor is not meant to be exposed outside of the module.  Clients should invoke
     either of the top-level functions to obtain a UUID."
    sealed shared new(XLong mostSignificantBits,XLong leastSignificantBits) {
        this.mostSignificantBits = mostSignificantBits;
        this.leastSignificantBits = leastSignificantBits;

        UuidSupportedVersion? determinedVersion = 
            determineVersion(getVersionFromMostSignificantBits(mostSignificantBits));
        UuidSupportedVariant? determinedVariant = 
            determineVariant(getVariantFromLeastSignificantBits(leastSignificantBits));

        if (! isAllZeros(mostSignificantBits,leastSignificantBits)) {
            "Calculated version is invalid"
            assert(exists determinedVersion);

            "Calculated variant is invalid"
            assert(exists determinedVariant);
        }
        else {
            "Calculated version is invalid since it does not exist for a blank UUID"
            assert(exists determinedVersion);

            "Calculated variant is invalid since it does not exist for a blank UUID"
            assert(exists determinedVariant);

            "Calculated version is not 0, which is invalid since this is a blank UUID"
            assert(determinedVersion == uuidVersion0);

            "Calculated variant is not 0, which is invalid since this is a blank UUID"
            assert(determinedVariant == uuidVariant0);
        }
    }

    Byte[] uuidComponentAsBytes(XLong valParam, Integer digits, Integer? rightShift=null) 
        => xLongToBytesNoLeadingZeros(uuidComponentAsXLong(valParam, digits, rightShift));
    
    XLong uuidComponentAsXLong(XLong valParam, Integer digits, Integer? rightShift=null) 
        => let(val = if (exists rightShift) 
                        then valParam.rightLogicalShift(rightShift) 
                        else valParam )
           val.and(longNumber((16 ^ digits) -1));
    
    String uuidComponentAsString(XLong valParam, Integer digits, Integer? rightShift=null) {
        XLong uuidComponentXLong = uuidComponentAsXLong(valParam,digits,rightShift);
        assert(exists asHex=formatAndPadAsHexNoUnderscoresXLong(uuidComponentXLong,digits));
        return asHex;
    }

    shared Boolean isBlankUuid => isAllZeros(mostSignificantBits, leastSignificantBits);

    shared Byte[] bytes {
        if (isBlankUuid) {
            return [];
        }

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

    shared UuidSupportedVersion version {
        Integer versionInt = getVersionFromMostSignificantBits(mostSignificantBits);

        "Version is invalid. This should not happen if the UUID was constructed properly."
        assert(exists version = determineVersion(versionInt));
         
        return version;
    }

    shared Integer variant => getVariantFromLeastSignificantBits(leastSignificantBits);

    shared actual Boolean equals(Object other) 
        => if (is UUID other) 
            then equalsWithMulitple({[mostSignificantBits, other.mostSignificantBits],
                                     [leastSignificantBits, other.leastSignificantBits]})
            else false;

    shared actual Integer hash => hashes(mostSignificantBits, leastSignificantBits);

    // TODO:  More documentation
    "Obtain the [[String]] representation of this [[UUID]].  Example: c7761fd5-ee11-46ce-a0cc-ff8f8fb72a23"
    shared actual String string {
        if (isBlankUuid) {
            return blankUuidString;
        }

        String timeLo = uuidComponentAsString(mostSignificantBits, 8, 32);
        String timeMid = uuidComponentAsString(mostSignificantBits, 4, 16);
        String timeHiVersion = uuidComponentAsString(mostSignificantBits, 4);
        String clockSeqHiVariant = uuidComponentAsString(leastSignificantBits, 2, 56);
        String clockSeqLow = uuidComponentAsString(leastSignificantBits, 2, 48);
        String node = uuidComponentAsString(leastSignificantBits, 12);

        return "-".join([timeLo, timeMid, timeHiVersion, clockSeqHiVariant + clockSeqLow, node]);
    }
}