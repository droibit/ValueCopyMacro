// swiftlint:disable function_body_length

import Foundation
import SwiftDiagnostics
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
@testable import ValueCopyMacroPlugin

final class ValueCopyMacroTest: XCTestCase {
    private let macros: [String: Macro.Type] = [
        "ValueCopy": ValueCopyMacro.self,
    ]

    func test_expansion_hasMemberwiseInitializer() throws {
        assertMacroExpansion(
            """
            @ValueCopy
            struct Test {
                let value1: String
                let value2: Int?
                let value3: [Double]
                let value4: [String: Double]?
            }
            """,
            expandedSource:
            """
            struct Test {
                let value1: String
                let value2: Int?
                let value3: [Double]
                let value4: [String: Double]?
                func copy(
                    value1: String? = nil,
                    value2: Int?? = nil,
                    value3: [Double]? = nil,
                    value4: [String: Double]?? = nil
                ) -> Self {
                    .init(
                        value1: value1 ?? self.value1,
                        value2: value2 ?? self.value2,
                        value3: value3 ?? self.value3,
                        value4: value4 ?? self.value4
                    )
                }
            }
            """,
            macros: macros
        )

        assertMacroExpansion(
            """
            @ValueCopy(public: true)
            struct Test {
                let value1: String = "value1"
                let value2: Int?
                var value3: String = ""
                private (set) var value4: String
                var value5: Int? = nil
                var value6: String {
                    "test"
                }
            }
            """,
            expandedSource:
            """
            struct Test {
                let value1: String = "value1"
                let value2: Int?
                var value3: String = ""
                private (set) var value4: String
                var value5: Int? = nil
                var value6: String {
                    "test"
                }
                public func copy(
                    value2: Int?? = nil,
                    value3: String? = nil,
                    value4: String? = nil,
                    value5: Int?? = nil
                ) -> Self {
                    .init(
                        value2: value2 ?? self.value2,
                        value3: value3 ?? self.value3,
                        value4: value4 ?? self.value4,
                        value5: value5 ?? self.value5
                    )
                }
            }
            """,
            macros: macros
        )
    }

    func test_expansion_hasMemberwiseInitializerEquivalent() {
        assertMacroExpansion(
            """
            @ValueCopy
            struct Test {
                let value1: String
                let value2: Int?
                let value3: Bool

                init(_ value1: String, v2 value2: Int?, value3: Bool) {
                    self.value1 = value1
                    self.value2 = value2
                    self.value3 = value3
                }
            }
            """,
            expandedSource:
            """
            struct Test {
                let value1: String
                let value2: Int?
                let value3: Bool

                init(_ value1: String, v2 value2: Int?, value3: Bool) {
                    self.value1 = value1
                    self.value2 = value2
                    self.value3 = value3
                }
                func copy(
                    value1: String? = nil,
                    value2: Int?? = nil,
                    value3: Bool? = nil
                ) -> Self {
                    .init(
                        value1 ?? self.value1,
                        v2: value2 ?? self.value2,
                        value3: value3 ?? self.value3
                    )
                }
            }
            """,
            macros: macros
        )

        assertMacroExpansion(
            """
            @ValueCopy(public: true)
            struct Test {
                let value1: String
                let value2: Int?

                init(value1: String = "", value2: Int? = nil) {
                    self.value1 = value1
                    self.value2 = value2
                }

                init(_ test: Test) {
                    self.value1 = test.value1
                    self.value2 = test.value2
                }
            }
            """,
            expandedSource:
            """
            struct Test {
                let value1: String
                let value2: Int?

                init(value1: String = "", value2: Int? = nil) {
                    self.value1 = value1
                    self.value2 = value2
                }

                init(_ test: Test) {
                    self.value1 = test.value1
                    self.value2 = test.value2
                }
                public func copy(
                    value1: String? = nil,
                    value2: Int?? = nil
                ) -> Self {
                    .init(
                        value1: value1 ?? self.value1,
                        value2: value2 ?? self.value2
                    )
                }
            }
            """,
            macros: macros
        )
    }

    func test_expansion_notCorrectType() {
        let expMessage: DiagnosticMessage = ValueCopyMacroDiagnostics.notCorrectType
        assertMacroExpansion(
            """
            @ValueCopy
            class Test {
            }
            """,
            expandedSource:
            """
            class Test {
            }
            """,
            diagnostics: [
                .init(
                    id: expMessage.diagnosticID,
                    message: expMessage.message,
                    line: 1,
                    column: 1,
                    severity: expMessage.severity
                ),
            ],
            macros: macros
        )
    }

    func test_expansion_needsMemberwiseInitializer() {
        let expMessage: DiagnosticMessage = ValueCopyMacroDiagnostics.needsMemberwiseInitializer
        assertMacroExpansion(
            """
            import Foundation

            @ValueCopy
            struct Test {
                let value: String

                init(value: URL) {
                    self.value = value.absoluteString
                }
            }
            """,
            expandedSource:
            """
            import Foundation
            struct Test {
                let value: String

                init(value: URL) {
                    self.value = value.absoluteString
                }
            }
            """,
            diagnostics: [
                .init(
                    id: expMessage.diagnosticID,
                    message: expMessage.message,
                    line: 3,
                    column: 1,
                    severity: expMessage.severity
                ),
            ],
            macros: macros
        )
    }
}
