// TODO:  When shared is parameterized move this back to test-source
import ceylon.test {
    test,
    assertEquals
}

import herd.uuid {
    UuidSupportedVersion {
        uuidVersion3, uuidVersion4, uuidVersion5
    }
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

        value expectedBytes =
                bytes.span(0, 5)
                .withTrailing(setVersion(bytes[6] else 0.byte, version))
                .withTrailing(bytes[7])
                .withTrailing(setVariant(bytes[8] else 0.byte))
                .append(bytes.span(9, 15));

        assertEquals(uuid.bytes, expectedBytes);
    }

    Byte[] first16Bytes = [#dc,#5a,#99,#15,#5d,#0c,#5b,#09,#64,#d5,#c5,#d6,#62,#9c,#29,#dd]
            .map(Integer.byte).sequence();
    Byte[] second16Bytes = [#27,#c6,#54,#0e,#a0,#43,#47,#df,#9e,#7b,#3f,#3c,#50,#17,#04,#66]
            .map(Integer.byte).sequence();
    Byte[] third16Bytes = [#2d,#61,#fe,#4b,#63,#48,#4e,#5a,#b8,#05,#e6,#6f,#ae,#18,#85,#4d ]
            .map(Integer.byte).sequence();

    assertMe(first16Bytes, uuidVersion3, "dc5a9915-5d0c-3b09-a4d5-c5d6629c29dd");
    assertMe(first16Bytes, uuidVersion4, "dc5a9915-5d0c-4b09-a4d5-c5d6629c29dd");
    assertMe(first16Bytes, uuidVersion5, "dc5a9915-5d0c-5b09-a4d5-c5d6629c29dd");

    assertMe(second16Bytes, uuidVersion3, "27c6540e-a043-37df-9e7b-3f3c50170466");
    assertMe(second16Bytes, uuidVersion4, "27c6540e-a043-47df-9e7b-3f3c50170466");
    assertMe(second16Bytes, uuidVersion5, "27c6540e-a043-57df-9e7b-3f3c50170466");

    assertMe(third16Bytes, uuidVersion3, "2d61fe4b-6348-3e5a-b805-e66fae18854d");
    assertMe(third16Bytes, uuidVersion4, "2d61fe4b-6348-4e5a-b805-e66fae18854d");
    assertMe(third16Bytes, uuidVersion5, "2d61fe4b-6348-5e5a-b805-e66fae18854d");


}