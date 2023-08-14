#if canImport(SwiftCompilerPlugin)
    import SwiftCompilerPlugin
    import SwiftSyntaxMacros

    @main
    struct ValueCopyMacroPlugin: CompilerPlugin {
        let providingMacros: [Macro.Type] = [
            ValueCopyMacro.self,
        ]
    }
#endif
