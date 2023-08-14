/// This macro generates a function that copies values like Kotlin's data classes.
@attached(member, names: named(copy))
public macro ValueCopy(
    public: Bool = false
) = #externalMacro(
    module: "ValueCopyMacroPlugin",
    type: "ValueCopyMacro"
)
