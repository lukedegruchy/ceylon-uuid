import ceylon.collection {
    HashMap,
    unmodifiableMap
}

import java.lang {
    ByteArray
}
import java.security {
    SecureRandom
}
// TODO: Framework code
shared void assertSameSizeAsCoalesced<in Element>({Element?*} elements) given Element satisfies Object {
    assert(elements.size == elements.coalesced.size);
}

// TODO: Framework code
shared Integer hashes(Object?* objects)
        => let (value prime = 31) 
            objects.map((obj) => obj?.hash else 0) 
                   .fold(0)((result,hash) => (result*prime) + hash);

// TODO: Framework code
shared String? formatAndPadHex(Integer int,Integer toPad) => formatInteger(int, 16).padLeading(toPad, '0');

// TODO: Framework code
shared Integer? parseHex(String hexAsString) => parseInteger(hexAsString, 16);

shared Map<Key,Item> immutableMap<Key,Item>({<Key->Item>*} entries) 
        given Key satisfies Object 
        given Item satisfies Object 
    => unmodifiableMap(HashMap{ entries=entries; });

shared {Byte+} randomData(Integer size) 
    => javaRandomData(size);

{Byte+} javaRandomData(Integer size) {
    ByteArray data = ByteArray(size);
    SecureRandom().nextBytes(data);
    
    assert( nonempty dataSequence=data.byteArray.sequence());
    return dataSequence; 
}

String? formatHex(Integer int) => formatInteger(int, 16);
