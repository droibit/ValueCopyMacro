import SwiftSyntax

struct Arguments {
    let `public`: Bool

    var accessLevel: String {
        `public` ? "public " : ""
    }
}

extension Arguments {
    init(_ arguments: LabeledExprListSyntax) {
        let `public` = if let publicAttr = arguments.first(where: { "\($0)".contains("public") })?
            .expression.as(BooleanLiteralExprSyntax.self)?
            .literal
        {
            Bool("\(publicAttr)")!
        } else {
            false
        }
        self.init(public: `public`)
    }
}
