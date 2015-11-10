import herd.chayote.type_classes {
    TypedClass
}

"[[TypedClass]] implementation for uniquely typing [[UUID]]s among different domains."
shared abstract class TypedUUID(UUID baseValue) extends TypedClass<UUID>(baseValue) {}