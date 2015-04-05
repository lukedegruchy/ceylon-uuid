//// TODO: Framework code
shared Integer? parseHex(String hexAsString) => parseInteger(hexAsString, 16);

// TODO: Framework code
shared String? formatAndPadAsHexNoUnderscores(Integer int,Integer toPad) 
    => formatInteger(int, 16).padLeading(toPad, '0');
