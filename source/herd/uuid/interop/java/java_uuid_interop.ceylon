import java.util {
    JUUID=UUID{jFromString=fromString}
}

import herd.uuid {
    fromString,
    UUID
}

// TODO:  Optimize this
// TODO:  Documentation
shared JUUID toJavaUuid(UUID uuid) => jFromString(uuid.string);

// TODO:  Optimize this
// TODO:  Documentation
shared UUID toUuid(JUUID jUuid) {
    value uuid = fromString(jUuid.string);
    
    assert(exists uuid);
    
    return uuid;
}