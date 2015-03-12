// TODO:  Figure out separate module/package for unit tests

import ceylon.test {
    test,
    assertEquals
}

import java.util {
    JUUID=UUID {
        jRandomUUID=randomUUID
    }
}

String version1 = "13F5E487-097B-1597-A67E-D8346BB8B221";
String version2 = "13F5E487-097B-2597-A67E-D8346BB8B221";
String version3 = "13F5E487-097B-2597-A67E-D8346BB8B221";
String version6 = "13F5E487-097B-6597-A67E-D8346BB8B221";
String badVariant = "13F5E487-097B-6597-F67E-D8346BB8B221";
String withSecondLeadingZero = "13F5E487-097B-4597-A67E-D8346BB8B221";
String withFirstLeadingZero = "08866de9-5d0b-4392-8e64-53375499776e";
String withLastLeadingZero = "b583bf49-3d99-446c-8eb9-06f3c0a7c5e0";

test 
void ceylonUuid() {
    void assertMe(String uuidString) {
        print("-------------------------");
        // Round trip
        String ceylonUuidString = fromString(uuidString).string;
        
        print("original UUID:``uuidString.uppercased``
               convertedUuid:``ceylonUuidString.uppercased``");
        
        assertEquals(ceylonUuidString.lowercased,uuidString.lowercased);
        print("-------------------------");
    }
    
    assertMe(withFirstLeadingZero);
    assertMe(withSecondLeadingZero);
    assertMe(withLastLeadingZero);
    
    for(ii in 1..20) {
        assertMe(jRandomUUID().string);
    }
}