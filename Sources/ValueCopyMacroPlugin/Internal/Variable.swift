import SwiftSyntax

struct Variable: Equatable {
    let name: String
    let type: String

    func toFunctionParameter() -> String {
        "\(name): \(type)? = nil"
    }

    func toCallArgument() -> String {
        "\(name): \(name) ?? self.\(name)"
    }
}

extension Variable {
    init?(_ decl: VariableDeclSyntax) {
        guard
            let binding = decl.bindings.first?.as(PatternBindingSyntax.self),
            let variableName = binding.pattern.as(IdentifierPatternSyntax.self),
            let variableType = binding.typeAnnotation?.as(TypeAnnotationSyntax.self)?.type
        else {
            return nil
        }
        guard binding.accessorBlock == nil else {
            return nil
        }

        if decl.bindingSpecifier.tokenKind == .keyword(.let),
           binding.initializer != nil
        {
            return nil
        }
        self.init(
            name: "\(variableName)",
            type: "\(variableType)".trimmingCharacters(in: .whitespaces)
        )
    }
}

struct InitializerParameter {
    let label: Label?
    let variable: Variable

    func toFunctionParameter() -> String {
        "\(variable.name): \(variable.type)? = nil"
    }

    func toCallArgument() -> String {
        guard let label else {
            return variable.toCallArgument()
        }
        return switch label {
        case .wildcard:
            "\(variable.name) ?? self.\(variable.name)"
        case let .identifier(id):
            "\(id): \(variable.name) ?? self.\(variable.name)"
        }
    }
}

extension InitializerParameter {
    enum Label {
        case wildcard
        case identifier(String)
    }
}

extension InitializerParameter {
    init?(_ syntax: FunctionParameterSyntax) {
        let label: Label?
        let name: String
        if let secondName = syntax.secondName {
            switch syntax.firstName.tokenKind {
            case let .identifier(id):
                label = .identifier(id)
            case .wildcard:
                label = .wildcard
            default:
                return nil
            }
            name = "\(secondName)"
        } else {
            guard case let .identifier(firstName) = syntax.firstName.tokenKind else {
                return nil
            }
            label = nil
            name = "\(firstName)"
        }

        self.init(
            label: label,
            variable: .init(
                name: "\(name)",
                type: "\(syntax.type)".trimmingCharacters(in: .whitespaces)
            )
        )
    }
}
