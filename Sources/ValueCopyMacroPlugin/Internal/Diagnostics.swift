import SwiftDiagnostics
import SwiftSyntax

private let domain = "ValueCopyMacro"

enum ValueCopyMacroDiagnostics: Error {
    case notCorrectType
    case needsMemberwiseInitializer
}

extension ValueCopyMacroDiagnostics: DiagnosticMessage {
    var message: String {
        switch self {
        case .notCorrectType:
            "@ValueCopy can only be applied to a struct."
        case .needsMemberwiseInitializer:
            "@ValueCopy needs a memberwise initializer."
        }
    }

    var diagnosticID: MessageID {
        let id = switch self {
        case .notCorrectType:
            "notCorrectType"
        case .needsMemberwiseInitializer:
            "needsMemberwiseInitializer"
        }
        return .init(domain: domain, id: id)
    }

    var severity: DiagnosticSeverity {
        switch self {
        case .notCorrectType, .needsMemberwiseInitializer: .error
        }
    }
}
