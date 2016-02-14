import com.vasileff.ceylon.integer64 {
    Integer64,
    parseInteger64
}

import herd.uuid {
    UUID
}

shared Integer? parseHex(String hexAsString) => parseInteger(hexAsString, 16);

shared Integer64? parseHexInteger64(String hexAsString) => parseInteger64(hexAsString, 16);

shared UUID? fromMostAndLeastSignficantBits(Integer64? mostSignificantBits, Integer64? leastSignificantBits) {
    if (exists mostSignificantBits, exists leastSignificantBits ) {
        try {
            // TODO:  Check the most and least significant bits in a more elegant way
            return UUID(mostSignificantBits,leastSignificantBits);
        }
        catch (Exception exception) {
            return null;
        }
    }

    return null;
}
