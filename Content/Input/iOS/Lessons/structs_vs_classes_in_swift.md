```markdown
{| metadata |}
{ 
    "title": "Structs vs. Classes in Swift", 
    "description": "An in-depth exploration of the differences between structs and classes in Swift, focusing on their use cases, mutability, and data handling implications.",
    "proficiency": "intermediate",
    "tags": ["swift", "structs", "classes", "value types", "reference types", "iOS", "software engineering"]
}
{| endmetadata |}

=== Section: Structs vs. Classes in Swift Introduction ===
# Structs vs. Classes in Swift

In Swift, understanding the differences between **structs** and **classes** is essential for effective programming. Both are used to create complex data types, but they differ significantly in how they handle data and memory management.

> **Structs** are **value types**, meaning they are copied when they are assigned to a new variable or constant, or when they are passed to a function.  
> **Classes**, on the other hand, are **reference types**, which means they share a single instance when assigned or passed around.

This lesson will delve into these distinctions and discuss when to use each type, along with the implications of mutability and data copying.

=== EndSection: Structs vs. Classes in Swift Introduction ===

=== Section: Structs vs. Classes in Swift ===
# Understanding Structs and Classes

## Value Types vs. Reference Types

### Structs
When you create a new instance of a `struct`, Swift makes a copy of that instance. This behavior means that changes to one instance do not affect another. This is particularly useful for representing simple data models, such as **coordinates** or **dimensions**.

Example of a struct:

    struct Point {
        var x: Int
        var y: Int
        
        func description() -> String {
            return "Point at (\(x), \(y))"
        }
    }

Creating two instances:

    var pointA = Point(x: 10, y: 20)
    var pointB = pointA  // pointB is a copy of pointA
    pointB.x = 30       // Changing pointB does not affect pointA

### Classes
In contrast, when you create a new instance of a `class`, you're working with a reference to that instance. This means that if you modify the instance through one reference, all references will reflect that change.

Example of a class:

    class Rectangle {
        var width: Int
        var height: Int
        
        init(width: Int, height: Int) {
            self.width = width
            self.height = height
        }
        
        func area() -> Int {
            return width * height
        }
    }

Creating two instances:

    var rectangleA = Rectangle(width: 10, height: 20)
    var rectangleB = rectangleA  // rectangleB references rectangleA
    rectangleB.width = 30         // Changing rectangleB affects rectangleA

## Inheritance Capabilities

- **Structs** do not support inheritance. You cannot derive one struct from another. This can make them simpler and safer for certain use cases.
- **Classes**, however, can inherit from other classes. This enables a more complex and flexible architecture.

Example of class inheritance:

    class Shape {
        var numberOfSides: Int
        
        init(sides: Int) {
            self.numberOfSides = sides
        }
    }

    class Triangle: Shape {
        init() {
            super.init(sides: 3)
        }
    }

## Mutability

Structs and classes also differ in how they handle mutability. 

### Mutability in Structs
To modify properties of a struct, you need to define the instance as `var`. If a struct instance is assigned to a constant (`let`), its properties cannot be altered:

    let pointC = Point(x: 5, y: 5)
    // pointC.x = 10  // This would cause a compile-time error

### Mutability in Classes
Classes can have their properties modified regardless of whether they are declared with `let` or `var`, as long as the properties themselves are declared as `var`:

    let rectangleC = Rectangle(width: 5, height: 10)
    rectangleC.width = 15  // This is valid

## Use Cases and Best Practices

When deciding whether to use a struct or a class, consider the following:

- **Use structs** when you need a lightweight data structure that encapsulates a few related values and doesn't require inheritance. They are ideal for representing simple data models.
- **Use classes** when you need reference semantics or when you require inheritance. Classes are better for managing shared state and complex relationships between objects.

=== EndSection: Structs vs. Classes in Swift ===

=== Section: Discussion ===
# Discussion

### Pros and Cons
- **Pros of Structs**:
    - Simplicity: Structs are generally simpler to use and understand due to their value type nature.
    - Safety: There’s less risk of unintended side effects since structs are copied, leading to safer code.
  
- **Cons of Structs**:
    - No inheritance: Structs cannot be extended through inheritance, limiting their use in certain design patterns.

- **Pros of Classes**:
    - Inheritance: Classes can be extended, allowing for a more flexible and reusable codebase.
    - Reference semantics: Classes enable shared state across multiple references.

- **Cons of Classes**:
    - Complexity: Classes can introduce complexity with shared mutable state, leading to potential bugs if not managed carefully.

### Common Use Cases
Structs are commonly used for model data in applications, such as a user profile or geometric shapes. Classes are often used for more complex entities, such as view controllers or data managers in an app.

=== EndSection: Discussion ===

=== Section: Key Takeaways ===
# Key Takeaways

- **Structs are value types**: Changes create a new instance, ensuring data integrity.
- **Classes are reference types**: Changes affect all references to the same instance.
- **Structs do not support inheritance**: They are simpler and safer for small data models.
- **Classes support inheritance**: This allows for more complex relationships and behaviors.
- **Choose structs for data**: Use when you need lightweight and independent data structures.
- **Choose classes for shared state**: Use when you need reference semantics or a more complex hierarchy.

=== EndSection: Key Takeaways ===

{| questions |}
[
    {
        "id": "structs_classes_q1",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "What is the primary difference between structs and classes in Swift?",
        "answers": [
            "Structs can inherit from other structs, while classes cannot.",
            "Structs are reference types, while classes are value types.",
            "Structs are value types, while classes are reference types.",
            "Classes have fewer features than structs."
        ],
        "correctAnswerIndex": 2,
        "explanation": "Structs are value types, which means they are copied when assigned or passed, whereas classes are reference types that are shared."
    },
    {
        "id": "structs_classes_q2",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "When would you typically prefer to use a struct over a class?",
        "answers": [
            "When you need shared mutable state.",
            "When you need to define a complex hierarchy.",
            "When you want to ensure data integrity and simplicity.",
            "When you require polymorphism."
        ],
        "correctAnswerIndex": 2,
        "explanation": "Structs are preferred for their simplicity and safety, especially when you want to ensure that data remains unchanged."
    },
    {
        "id": "structs_classes_q3",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "Which of the following statements is true about classes?",
        "answers": [
            "Classes cannot have methods.",
            "Classes can be inherited from.",
            "Classes are copied when passed around.",
            "Classes are always more efficient than structs."
        ],
        "correctAnswerIndex": 1,
        "explanation": "Classes can inherit from other classes, enabling a more flexible and reusable code structure."
    },
    {
        "id": "structs_classes_q4",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "What happens when you assign a class instance to a new variable?",
        "answers": [
            "A new instance is created.",
            "The new variable references the same instance.",
            "A copy of the instance is made.",
            "The instance is deleted."
        ],
        "correctAnswerIndex": 1,
        "explanation": "When you assign a class instance to a new variable, both variables reference the same instance."
    },
    {
        "id": "structs_classes_q5",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "If you declare a struct property as 'let', what can you do?",
        "answers": [
            "You can change the property values.",
            "You cannot change the property values.",
            "You can only read the properties.",
            "You can delete the struct."
        ],
        "correctAnswerIndex": 1,
        "explanation": "If a struct is declared with 'let', it is immutable, meaning you cannot change its properties."
    }
]
{| endquestions |}
```