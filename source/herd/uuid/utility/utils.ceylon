import com.vasileff.ceylon.xmath.long {
    XLong=Long,
    parseLong
}

import herd.uuid {
    UUID
}

shared Integer? parseHex(String hexAsString) => parseInteger(hexAsString, 16);

shared XLong? parseHexXLong(String hexAsString) => parseLong(hexAsString, 16);

shared UUID? fromMostAndLeastSignficantBits(XLong mostSignificantBits, XLong leastSignificantBits) {
    // TODO:  Check the most and least significant bits in a more elegant way

    try {
        return UUID(mostSignificantBits,leastSignificantBits);
    }
    catch (Exception exception) {
        return null;
    }
}
