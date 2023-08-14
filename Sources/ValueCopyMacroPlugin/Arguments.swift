import SwiftSyntax

struct Arguments {
    let `public`: Bool

    var accessControl: String {
        `public` ? "public " : ""
    }
}

extension Arguments {
    init(_ arguments: TupleExprElementListSyntax) {
        let `public` = if let publicAttr = arguments.first(where: { "\($0)".contains("public") })?
            .expression.as(BooleanLiteralExprSyntax.self)?
            .booleanLiteral
        {
            Bool("\(publicAttr)")!
        } else {
            false
        }
        self.init(public: `public`)
    }
}
