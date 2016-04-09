import herd.chayote.wrapper_type {
    WrapperType
}

"[[herd.chayote.wrapper_type::WrapperType]] implementation for uniquely typing [[UUID]]s among different domains."
shared abstract class WrappedUUID(UUID baseValue) extends WrapperType<UUID>(baseValue) {}