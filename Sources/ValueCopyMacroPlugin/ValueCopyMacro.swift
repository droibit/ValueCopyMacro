import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

public struct ValueCopyMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            let error = Diagnostic(
                node: node._syntaxNode,
                message: ValueCopyMacroDiagnostics.notCorrectType
            )
            context.diagnose(error)
            return []
        }
        let args = if case let .argumentList(arguments) = node.argument {
            Arguments(arguments)
        } else {
            Arguments(public: false)
        }

        let members = structDecl.memberBlock.members
        let initializerDecls = members.compactMap { $0.decl.as(InitializerDeclSyntax.self) }
        let storedProps = members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .compactMap { Variable($0) }

        let copyParams: [String]
        let callArgs: [String]
        if initializerDecls.isEmpty {
            copyParams = storedProps.map { $0.toFunctionParameter() }
            callArgs = storedProps.map { $0.toCallArgument() }
        } else {
            guard let memberwiseInitParams = initializerDecls
                .compactMap({ $0.obtain(with: storedProps) })
                .first,
                !memberwiseInitParams.isEmpty
            else {
                let error = Diagnostic(
                    node: node._syntaxNode,
                    message: ValueCopyMacroDiagnostics.needsMemberwiseInitializer
                )
                context.diagnose(error)
                return []
            }
            copyParams = memberwiseInitParams.map { $0.toFunctionParameter() }
            callArgs = memberwiseInitParams.map { $0.toCallArgument() }
        }

        let copyFunc = try FunctionDeclSyntax(
            "\(raw: args.accessLevel)func copy(\n\(raw: copyParams.joined(separator: ",\n"))\n) -> Self"
        ) {
            """
            .init(
                \(raw: callArgs.joined(separator: ",\n"))
            )
            """
        }
        return [DeclSyntax(copyFunc)]
    }
}

// MARK: - Utils

private extension InitializerDeclSyntax {
    func obtain(with storedProperties: [Variable]) -> [IintializerParameter] {
        guard let function = signature.as(FunctionSignatureSyntax.self),
              let input = function.input.as(ParameterClauseSyntax.self),
              let srcParameters = input.parameterList.as(FunctionParameterListSyntax.self)
        else {
            return []
        }

        let destParameters = srcParameters
            .compactMap { $0.as(FunctionParameterSyntax.self) }
            .compactMap { IintializerParameter($0) }
            .filter { parameter in
                storedProperties.contains { $0 == parameter.variable }
            }
        guard destParameters.count == storedProperties.count else {
            return []
        }
        return destParameters
    }
}
