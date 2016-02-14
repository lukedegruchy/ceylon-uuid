import com.vasileff.ceylon.integer64 {
    integer64
}

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

// TODO:  Optimize this  might need to expose most and least signficant bits
"Convert a Ceylon UUID to a Java [UUID]."
shared JUUID toJavaUuid(UUID uuid) => jFromString(uuid.string);

"Convert a Java UUID to a Ceylon [UUID]."
shared UUID? toUuid(JUUID jUuid)
    => fromMostAndLeastSignficantBits{ mostSignificantBits = integer64(jUuid.mostSignificantBits);
                                       leastSignificantBits = integer64(jUuid.leastSignificantBits); };