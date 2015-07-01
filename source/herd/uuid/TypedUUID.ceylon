import herd.chayote.type_classes {
    TypedClass
}

"[[TypedClass]] implementation for uniquely typing UUIDs among different domains."
shared abstract class TypedUUID(UUID baseValue) extends TypedClass<UUID>(baseValue) {}