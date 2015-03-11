
" An implementation of Universal Unique Identifier (UUID). "

// TODO:  More documentation

shared class UUID(timeLow,timeMid,timeHiVersion,clockSeqHiVariant,clockSeqLow,node) {
    Integer timeLow;
    Integer timeMid;
    Integer timeHiVersion;
    Integer clockSeqHiVariant;
    Integer clockSeqLow;
    Integer node;
}

shared UUID fromString(String uuidString) {
    [String*] uuidStringComponents = uuidString.split((char) => char == '-').sequence();
    
    assert(nonempty uuidStringComponents);
    assertSameSizeAsCoalesced(uuidStringComponents);
    assert(uuidStringComponents.size == expectedUuidComponentSize);
    
    assert(exists versionComponent = uuidStringComponents.sequence()[2]);
    assert(exists variantComponent = uuidStringComponents.sequence()[3]);
    
    assertComponentSupportedVersion(versionComponent);
    assertComponentSupportedVariant(variantComponent);
    
    String timeLowString=uuidStringComponents[0];
    assert(exists timeMidString=uuidStringComponents[1], 
           exists timeHighVersionString=uuidStringComponents[2], 
           exists clockSeqString=uuidStringComponents[3], 
           exists nodeString=uuidStringComponents[4]);
    
    Integer timeLow = parseHexAndAssert(timeLowString);
    Integer timeMid = parseHexAndAssert(timeMidString);
    Integer timeHiVersion = parseHexAndAssert(timeHighVersionString);
    
    Integer clockSeq = parseHexAndAssert(clockSeqString);
    
    Integer clockSeqHiVariant = clockSeq.rightLogicalShift(8);
    Integer clockSeqLow = clockSeq.and(#ff);
    
    Integer node = parseHexAndAssert(nodeString);
    
    return UUID { timeLow = timeLow; 
                  timeMid = timeMid; 
                  timeHiVersion = timeHiVersion; 
                  clockSeqHiVariant = clockSeqHiVariant; 
                  clockSeqLow = clockSeqLow; 
                  node = node; };
    }
    
    Integer expectedUuidComponentSize = 5;
    
    Integer parseHexAndAssert(String hexString) {
        assert(exists parsedHex=parseHex(hexString));
        
        return parsedHex;
    }
    
    // TODO: Framework code
    shared Integer? parseHex(String hexAsString) => parseInteger(hexAsString, 16);
    
    // TODO: Framework code
    void assertSameSizeAsCoalesced<in Element>({Element?*} elements) given Element satisfies Object {
        assert(elements.size == elements.coalesced.size);
    }
    
    // TODO:  Implement this
    void assertComponentSupportedVersion(String versionComponent) {}
    
    // TODO:  Implement this
    void assertComponentSupportedVariant(String variantComponent) {}