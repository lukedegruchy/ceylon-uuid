import com.vasileff.ceylon.xmath.long {
    XLong=Long,
    parseLong,
    formatLong
}

import herd.uuid {
    UUID
}

//// TODO: Framework code
shared Integer? parseHex(String hexAsString) => parseInteger(hexAsString, 16);

//// TODO: Framework code
shared XLong? parseHexXLong(String hexAsString) => parseLong(hexAsString, 16);

// TODO: Framework code
shared String? formatAndPadAsHexNoUnderscoresInteger(Integer int, Integer toPad) 
    => formatAndPadAsHexNoUnderscores(int, toPad, formatInteger);

// TODO: Framework code
shared String? formatAndPadAsHexNoUnderscoresXLong(XLong xLong,Integer toPad) 
    => formatAndPadAsHexNoUnderscores(xLong, toPad, formatLong);

shared String? formatAndPadAsHexNoUnderscores<Number>(Number binary, 
                                                      Integer toPad, 
                                                      String(Number,Integer) format) 
        given Number satisfies Binary<Number>
    => format(binary, 16).padLeading(toPad, '0');

shared UUID? fromMostAndLeastSignficantBits(XLong mostSignificantBits, XLong leastSignificantBits) {
    // TODO:  Check the most and least significant bits in a more elegant way
    try {
        return UUID(mostSignificantBits,leastSignificantBits);
    }
    catch (Exception exception) {
        return null;
    }
}