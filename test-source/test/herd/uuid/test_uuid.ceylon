// TODO:  Figure out separate module/package for unit tests

import ceylon.test {
    test,
    assertEquals,
    assertNull,
    assertNotEquals,
    assertTrue
}

import herd.uuid {
    ...
}

import java.util {
    JUUID=UUID {
        jRandomUUID=randomUUID,
        jFromString=fromString
    }
}

String version1 = "13F5E487-097B-1597-A67E-D8346BB8B221";
String version2 = "13F5E487-097B-2597-A67E-D8346BB8B221";
String version3 = "13F5E487-097B-2597-A67E-D8346BB8B221";

String withSecondLeadingZero = "13F5E487-097B-4597-A67E-D8346BB8B221";
String withFirstLeadingZero = "08866de9-5d0b-4392-8e64-53375499776e";
String withLastLeadingZero = "b583bf49-3d99-446c-8eb9-06f3c0a7c5e0";
String properBlank = "00000000-0000-0000-0000-000000000000";

String invalidVersion6 = "13F5E487-097B-6597-A67E-D8346BB8B221";
String invalidVariantF = "13F5E487-097B-4597-F67E-D8346BB8B221";

String badTooManyTimeLow = "13F5E4877-097B-1597-A67E-D8346BB8B221";
String badMissingNode = "13F5E4877-097B-1597-A67E";
String badTooShortNode = "13F5E4877-097B-1597-A67E-D8346BB8B22";
String badTooLongTimeMid = "13F5E487-097BA-4597-A67E-D8346BB8B221";
String badTooShortTimeHiVersion = "13F5E487-097BA-459-A67E-D8346BB8B221";
String badTooLongClockSeq = "13F5E487-097BA-459-A67E2-D8346BB8B221";
String badInvalidChars = "13F5X487-097B-4597-A67E-D8346BB8B221";

{String+} badUuidStrings = 
    [badTooManyTimeLow,
     badMissingNode,
     badTooShortNode,
     badTooLongTimeMid,
     badTooShortTimeHiVersion,
     badTooLongClockSeq,
     badInvalidChars,
     invalidVersion6,
     invalidVariantF];

test 
void testFromString() {
    void assertMe(String uuidString) {
        // Round trip
        String ceylonUuidString = fromString(uuidString)?.string else "INVALID";
        
        assertEquals(ceylonUuidString.lowercased,uuidString.lowercased);
    }
    
    assertMe(withFirstLeadingZero);
    assertMe(withSecondLeadingZero);
    assertMe(withLastLeadingZero);
    assertMe(properBlank);
    
    for(ii in 1..20) {
        assertMe(jRandomUUID().string);
    }
}

test 
void testInvalidFromString() {
    String invalid = "INVALID";

    void assertMe(String uuidString) {
        // Round trip
        String ceylonUuidString = fromString(uuidString)?.string else invalid;
        
        assertEquals(ceylonUuidString,invalid);
    }
    
    for (badUuidString in badUuidStrings) {
        assertMe(badUuidString);
    }
}

test
void invalidVersion() {
    assertNull(fromString(invalidVersion6));
}

test
void invalidVariant() {
    assertNull(fromString(invalidVariantF));
}

test
void testUuid3Md5() {
    void assertMatches(String name, UUID? uuidNamespace=null) {
        UUID md5UuidNamespaceFirstTry = uuid3Md5(name, uuidNamespace);
        UUID md5UuidNamespaceSecondTry = uuid3Md5(name, uuidNamespace);
        
        // Ensure algorythm to generate UUID 3 is deterministic
        assertEquals(md5UuidNamespaceFirstTry,md5UuidNamespaceSecondTry);
        assertEquals(md5UuidNamespaceFirstTry.version, uuidVersion3);
    }

    // Note:  The RFC spec says that not matching is with "very high probability", not "always"
    void assertNotMatchesNames([String,String] names, UUID? uuidNamespace=null) {
        UUID uuid1= uuid3Md5(names[0], uuidNamespace);
        UUID uuid2 = uuid3Md5(names[1], uuidNamespace);
        
        assertNotEquals(uuid1,uuid2);
        assertEquals(uuid1.version, uuidVersion3);
    }

    // Note:  The RFC spec says that not matching is with "very high probability", not "always"
    void assertNotMatchesNamespaces(String name, [UUID?,UUID?] uuidNamespaces) {
        UUID uuid1= uuid3Md5(name, uuidNamespaces[0]);
        UUID uuid2 = uuid3Md5(name, uuidNamespaces[1]);
        
        assertNotEquals(uuid1,uuid2);
        assertEquals(uuid1.version, uuidVersion3);
    }

    String name1 = "md5Name1";
    String name2 = "md5Name2";
    UUID? uuid1 = fromString(withSecondLeadingZero);
    UUID? uuid2 = fromString(withFirstLeadingZero);
    
    assert(exists uuid1);
    assert(exists uuid2);

    assertMatches(name1);
    assertMatches(name1, uuid1);
    assertMatches(name1, uuid2);
    assertMatches(name2, uuid1);

    assertNotMatchesNames([name1,name2]);
    assertNotMatchesNames([name1,name2],uuid1);

    assertNotMatchesNamespaces(name1,[uuid1,uuid2]);
    assertNotMatchesNamespaces(name2,[null,uuid2]);
}

test 
void testUuid4Random() {
    void assertMe() {
        UUID uUID = uuid4Random();
        
        JUUID jUUID = jFromString(uUID.string);
        
        assertEquals(jUUID.string.lowercased, uUID.string.lowercased);

        assertEquals(uUID.version, uuidVersion4);
    }
    
    for(ii in 1..20) {
        assertMe();
    }
}

test
void testUuid5Sha1() {
    void assertMatches(String name, UUID? uuidNamespace=null) {
        UUID sha1UuidNamespaceFirstTry = uuid5Sha1(name, uuidNamespace);
        UUID sha1UuidNamespaceSecondTry = uuid5Sha1(name, uuidNamespace);
        
        // Ensure algorythm to generate UUID 5 is deterministic
        assertEquals(sha1UuidNamespaceFirstTry,sha1UuidNamespaceSecondTry);
        assertEquals(sha1UuidNamespaceFirstTry.version, uuidVersion5);
    }

    void assertNotMatchesNames([String,String] names, UUID? uuidNamespace=null) {
        UUID sha1Uuid1= uuid5Sha1(names[0], uuidNamespace);
        UUID sha1Uuid2 = uuid5Sha1(names[1], uuidNamespace);
        
        assertNotEquals(sha1Uuid1,sha1Uuid2);
        assertEquals(sha1Uuid1.version, uuidVersion5);
    }

    void assertNotMatchesNamespaces(String name, [UUID?,UUID?] uuidNamespaces) {
        UUID sha1Uuid1= uuid5Sha1(name, uuidNamespaces[0]);
        UUID sha1Uuid2 = uuid5Sha1(name, uuidNamespaces[1]);
        
        assertNotEquals(sha1Uuid1,sha1Uuid2);
        assertEquals(sha1Uuid1.version, uuidVersion5);
    }

    String name1 = "sha1Name1";
    String name2 = "sha1Name2";
    UUID? uuid1 = fromString(withSecondLeadingZero);
    UUID? uuid2 = fromString(withFirstLeadingZero);
    
    assert(exists uuid1);
    assert(exists uuid2);

    assertMatches(name1);
    assertMatches(name1, uuid1);
    assertMatches(name1, uuid2);
    assertMatches(name2, uuid1);

    assertNotMatchesNames([name1,name2]);
    assertNotMatchesNames([name1,name2],uuid1);

    assertNotMatchesNamespaces(name1,[uuid1,uuid2]);
    assertNotMatchesNamespaces(name2,[null,uuid2]);
}

test
void testBytesToUuid() {
    Byte setVersion(Byte timeHiVersionPart, UuidSupportedVersion version)
        => timeHiVersionPart.and($1111.byte).or(version.versionNumber.leftLogicalShift(4).byte);

    Byte setVariant(Byte clockSeqHiVariant)
        => clockSeqHiVariant.and($11_1111.byte).or($1000_0000.byte);

    void assertMe(Byte[] bytes, UuidSupportedVersion version, String expectedUuid) {
        assert(exists uuid=bytesToUuid(bytes, version));
        assertEquals(uuid.string.lowercased, expectedUuid.lowercased);
        
        if (uuid.isBlankUuid) {
            assertTrue(bytes.every((element) => element == 0.byte) || bytes.empty);
        }
        else {
            value expectedBytes = 
                    bytes.span(0, 5)
                    .withTrailing(setVersion(bytes[6] else 0.byte, version))
                    .withTrailing(bytes[7])
                    .withTrailing(setVariant(bytes[8] else 0.byte))
                    .append(bytes.span(9, 15));
            
            assertEquals(uuid.bytes, expectedBytes);
        }
        
    }
    
    Byte[] _16Bytes = [#dc,#5a,#99,#15,#5d,#0c,#5b,#09,#64,#d5,#c5,#d6,#62,#9c,#29,#dd ]
            .map(Integer.byte).sequence();
    Byte[] zeros = [for (count in 1..16) 0.byte];
    
    //TODO:  more bytes to test
    assertMe(_16Bytes, uuidVersion3, "dc5a9915-5d0c-3b09-a4d5-c5d6629c29dd");
    assertMe(_16Bytes, uuidVersion4, "dc5a9915-5d0c-4b09-a4d5-c5d6629c29dd");
    assertMe(_16Bytes, uuidVersion5, "dc5a9915-5d0c-5b09-a4d5-c5d6629c29dd");
    assertMe([], uuidVersion5, blankUuidString);
    assertMe(zeros, uuidVersion5, blankUuidString);
}