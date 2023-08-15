/// A Swift Macro that generates a function that copies values like Kotlin's data classes.
///
/// For example:
///
/// ```swift
/// @ValueCopy
/// struct UiState {
///     let message: String
///     let supplement: String?
///     let isInProgress: Bool
/// }
/// ```
///
/// generated:
///
/// ```swift
/// struct UiState {
///     let message: String
///     let supplement: String?
///     let isInProgress: Bool
///
///     func copy(
///         message: String? = nil,
///         supplement: String?? = nil,
///         isInProgress: Bool? = nil
///     ) -> Self {
///         .init(
///             message: message ?? self.message,
///             supplement: supplement ?? self.supplement,
///             isInProgress: isInProgress ?? self.isInProgress
///         )
///     }
/// }
/// ```
///
/// - Parameter public: A flag indicating whether the copy function is public.
@attached(member, names: named(copy))
public macro ValueCopy(
    public: Bool = false
) = #externalMacro(
    module: "ValueCopyMacroPlugin",
    type: "ValueCopyMacro"
)
