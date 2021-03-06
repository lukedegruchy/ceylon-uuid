import ceylon.collection {
    HashSet,
    MutableSet
}
import ceylon.test {
    test,
    assertEquals,
    assertNull,
    assertNotEquals,
    assertFalse
}

import herd.uuid {
    UuidSupportedVersion {
        uuidVersion3,
        uuidVersion4,
        uuidVersion5
    },
    fromString,
    uuid3Md5,
    UUID,
    uuid4Random,
    uuid5Sha1
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
     invalidVariantF,
     properBlank];

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
    UUID assertMeAndGetLast(Set<UUID> previousUuids) {
        UUID uUID = uuid4Random();

        JUUID jUUID = jFromString(uUID.string);

        assertEquals(jUUID.string.lowercased, uUID.string.lowercased);

        assertEquals(uUID.version, uuidVersion4);

        // We should never generate the same UUID more than once
        assertFalse(previousUuids.contains(uUID));

        return uUID;
    }

    MutableSet<UUID> previousUuids = HashSet<UUID>();

    for(ii in 1..20) {
        previousUuids.add(assertMeAndGetLast(previousUuids));
        assertEquals(ii, previousUuids.size);
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