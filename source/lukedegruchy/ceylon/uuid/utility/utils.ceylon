import ceylon.collection {
    HashMap,
    unmodifiableMap
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

String? formatHex(Integer int) => formatInteger(int, 16);
