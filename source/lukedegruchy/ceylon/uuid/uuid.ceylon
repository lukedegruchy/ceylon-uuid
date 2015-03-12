import lukedegruchy.ceylon.uuid.utility {
    assertSameSizeAsCoalesced,
    parseHexAndAssert,
    hashes,
    formatAndPadHex,
    immutableMap
}


" An implementation of Universal Unique Identifier (UUID).  See http://tools.ietf.org/html/rfc4122."

// TODO:  More documentation

Integer expectedUuidComponentSize = 5;

shared class UUID(timeLow,timeMid,timeHiVersion,clockSeqHiVariant,clockSeqLow,node) {
    Integer timeLow;
    Integer timeMid;
    Integer timeHiVersion;
    Integer clockSeqHiVariant;
    Integer clockSeqLow;
    Integer node;
    
    Integer clockSeq = clockSeqHiVariant.leftLogicalShift(8).or(clockSeqLow);

    Map<Integer,Integer> toPad = 
        immutableMap<Integer,Integer>({timeLow->8, 
                                      timeMid->4, 
                                      timeHiVersion->0,
                                      clockSeq->0,
                                      node->12});

    Integer[] components = toPad.keys.sequence();
    
    shared actual Boolean equals(Object other) 
        => if (is UUID other) 
            then timeLow == other.timeLow && 
                 timeMid == other.timeMid &&
                 timeHiVersion == other.timeHiVersion &&
                 clockSeqHiVariant == other.clockSeqHiVariant &&
                 clockSeqLow == other.clockSeqLow &&
                 node == other.node
           else false;

    shared actual Integer hash 
                => hashes(timeLow, timeMid, timeHiVersion, clockSeqHiVariant, clockSeqLow, node);

    // TODO:  Implement this
    shared actual String string {
        Integer padWith(Integer component) {
            assert(exists padWith=toPad.get(component));
            
            return padWith;
        }

        String[] hexSubValues = 
            components.map((component) => formatAndPadHex(component,padWith(component)))
                      .coalesced
                      .sequence();
        
        assert(nonempty hexSubValues);
        
        return "-".join(hexSubValues);
    }
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
    
// TODO:  Implement this
void assertComponentSupportedVersion(String versionComponent) {}

// TODO:  Implement this
void assertComponentSupportedVariant(String variantComponent) {}