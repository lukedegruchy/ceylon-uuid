import ceylon.test {
    assertEquals,
    assertTrue,
    test
}

// TODO:  Once the language supports parameterized shared annotations, try to move this unit test to the
//        test module
test
void testBytesToUuid() {
    void assertMe(Byte[] bytes, Integer version, String expectedUuid) {
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
    assertMe(_16Bytes, 3, "dc5a9915-5d0c-3b09-a4d5-c5d6629c29dd");
    assertMe(_16Bytes, 4, "dc5a9915-5d0c-4b09-a4d5-c5d6629c29dd");
    assertMe(_16Bytes, 5, "dc5a9915-5d0c-5b09-a4d5-c5d6629c29dd");
    assertMe([], 5, blankUuidString);
    assertMe(zeros, 5, blankUuidString);
}