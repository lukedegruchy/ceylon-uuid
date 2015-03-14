// TODO:  Figure out separate module/package for unit tests

import ceylon.test {
    test,
    assertEquals,
    assertNull
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
void testuuid4Random() {
    void assertMe() {
        UUID uUID = uuid4Random();
        
        print(uUID.string);
        
        JUUID jUUID = jFromString(uUID.string);
        
        assertEquals(jUUID.string.lowercased, uUID.string.lowercased);
    }
    
    for(ii in 1..20) {
        assertMe();
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
void testBytesToUuid() {
    void assertMe(UUID? uuid, String expectedUuid) {
        assert(exists uuid);

        assertEquals(uuid.string.lowercased, expectedUuid.lowercased);
    }
    
    {Byte+} _16Bytes = [#dc,#5a,#99,#15,#5d,#0c,#5b,#09,#64,#d5,#c5,#d6,#62,#9c,#29,#dd ].map(Integer.byte);
    
    //TODO:  more bytes to test
    UUID? uuid = bytesToUuid(_16Bytes.sequence());
    
    assertMe(uuid, "dc5a9915-5d0c-4b09-a4d5-c5d6629c29dd");
}