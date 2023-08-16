# ValueCopyMacro
A Swift Macro that generates a function that copies values like [Kotlin's data classes](https://kotlinlang.org/docs/data-classes.html#copying).

## Installation

```swift

let package = Package(
    name: "MyPackage",
    dependencies: [
        .package(
            url: "https://github.com/droibit/ValueCopyMacro", 
            exact: "0.0.1"
        ),
        // ...
    ],
    targets: [
        .target(
            name: "MyTarget",
            dependencies: [
                .product(name: "ValueCopyMacro", package: "ValueCopyMacro"),
            ]    
        ),
        // ...
    ]
)
```

## Usage
```swift
@ValueCopy
struct Person {
    var name: String
    var age: Int
}

let original = Person(name: "Alice", age: 25)
let updated = original.copy(age: 26)

print(original) // Person(name: "Alice", age: 25)
print(updated)  // Person(name: "Alice", age: 26)
```

### Limitations
- The macro can only be applied to structures.
- The structure must have a memberwise initializer.

# License
ValueCopyMacro is available under the MIT license. See the [LICENSE](https://github.com/droibit/ValueCopyMacro/blob/master/LICENSE) file for more information.