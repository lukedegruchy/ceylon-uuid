import herd.uuid {
    UUID
}
import herd.uuid.utility {
    fromMostAndLeastSignficantBits
}

import java.util {
    JUUID=UUID {
        jFromString=fromString
    }
}
import com.vasileff.ceylon.xmath.long {
    longNumber
}

// TODO:  Optimize this  might need to expost most and least signficant bits
// TODO:  Documentation
shared JUUID toJavaUuid(UUID uuid) => jFromString(uuid.string);

"Convert a Java UUID to a Ceylon [UUID]."
shared UUID toUuid(JUUID jUuid) {
    value uuid = fromMostAndLeastSignficantBits(longNumber(jUuid.mostSignificantBits), 
                                                longNumber(jUuid.leastSignificantBits));
    
    assert(exists uuid);
    
    return uuid;
}