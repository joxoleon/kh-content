```markdown
{| metadata |}
{
    "title": "Querying SQLite Databases",
    "description": "A comprehensive lesson on querying data in SQLite, covering SELECT statements, WHERE clauses, sorting, and aggregation.",
    "proficiency": "intermediate",
    "tags": ["SQLite", "SQL", "database", "querying", "data retrieval", "software engineering", "iOS"]
}
{| endmetadata |}

=== Section: Querying SQLite Databases Introduction ===
# Querying SQLite Databases

In this lesson, we will explore the **art of querying data** in SQLite, a lightweight database commonly used in iOS applications. Understanding how to efficiently retrieve data is crucial for building responsive applications. 

> **SQL (Structured Query Language)** is the standard language for interacting with relational databases, including SQLite.

We will cover the syntax of **SELECT** statements, how to filter results with **WHERE** clauses, sort data, and group results using aggregate functions like **COUNT**, **SUM**, and others. 

=== EndSection: Querying SQLite Databases Introduction ===

=== Section: Querying SQLite Databases ===
# Querying SQLite Databases

## Basic SELECT Statement

The **SELECT** statement is the fundamental command in SQL for retrieving data from a database. Here's the basic syntax:

    SELECT column1, column2, ...
    FROM table_name;

For example, to retrieve names and ages from a table called `Users`, you would write:

    SELECT name, age 
    FROM Users;

If you want to select all columns, you can use the asterisk (`*`):

    SELECT * 
    FROM Users;

## Filtering with WHERE Clauses

To filter results, we use the **WHERE** clause. This allows us to specify conditions that the data must meet to be included in the results. 

For instance, if you want to find users older than 18:

    SELECT * 
    FROM Users 
    WHERE age > 18;

You can also combine multiple conditions using **AND** and **OR**:

    SELECT * 
    FROM Users 
    WHERE age > 18 AND city = 'New York';

## Sorting Results

To sort the results of your query, you can use the **ORDER BY** clause. By default, it sorts in ascending order, but you can specify **DESC** for descending order.

For example, to sort users by age in descending order:

    SELECT * 
    FROM Users 
    ORDER BY age DESC;

## Grouping Data with Aggregate Functions

Aggregate functions allow you to perform calculations on your data. Common aggregate functions include:

- **COUNT()**: Counts the number of rows.
- **SUM()**: Adds up values.
- **AVG()**: Calculates the average.

You often use aggregate functions with the **GROUP BY** clause to group results by one or more columns. 

For example, to count users per city:

    SELECT city, COUNT(*) 
    FROM Users 
    GROUP BY city;

To filter groups based on aggregate results, you can use the **HAVING** clause. For instance, to find cities with more than 5 users:

    SELECT city, COUNT(*) 
    FROM Users 
    GROUP BY city 
    HAVING COUNT(*) > 5;

## Real-World Application

In an iOS application, you might use SQLite to store and retrieve user data. For instance, if you have a contacts app, you can query the database to find all contacts in a specific city or sort them by last name.

Here’s a quick example of how you might implement fetching users in Swift using SQLite:

```swift
let query = "SELECT * FROM Users WHERE age > 18 ORDER BY name ASC"
if let results = try? database.execute(query) {
    for row in results {
        print("Name: \(row["name"]), Age: \(row["age"])")
    }
}
```

This example demonstrates how to use a SELECT statement in a real-world context, enhancing your app's functionality.

=== EndSection: Querying SQLite Databases ===

=== Section: Discussion ===
# Discussion

Querying databases efficiently is vital for performance and user experience. Here are some pros and cons of using SQLite for querying:

### Pros:
- **Lightweight and Fast**: SQLite is fast and requires minimal setup, making it suitable for mobile applications.
- **ACID Compliance**: It supports transactions, ensuring data integrity.
- **Cross-Platform**: The same database file can be used across different platforms.

### Cons:
- **Limited Multi-User Support**: SQLite is not designed for high-concurrency scenarios with many write operations.
- **Database Size**: While it can handle large databases, it may not perform as well as other options for extremely large datasets.

### Use Cases:
SQLite is especially useful in mobile applications for storing user preferences, local caches, and small to medium-sized datasets. In iOS development, leveraging SQLite for offline capabilities can improve the user experience.

=== EndSection: Discussion ===

=== Section: Key Takeaways ===
# Key Takeaways

- The **SELECT** statement is essential for retrieving data from SQLite.
- Use the **WHERE** clause for filtering results based on specific conditions.
- Sort results using the **ORDER BY** clause, and aggregate data with functions like **COUNT()** and **SUM()**.
- The **GROUP BY** clause is used to group results for aggregate functions, while **HAVING** filters the grouped results.
- SQLite is lightweight and suitable for mobile applications, but it has limitations in high-concurrency scenarios.

=== EndSection: Key Takeaways ===

{| questions |}
[
    {
        "id": "querying_sqlite_q1",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "What does the SELECT statement do in SQL?",
        "answers": [
            "Inserts new data into a table",
            "Retrieves data from a database",
            "Updates existing data",
            "Deletes data from a table"
        ],
        "correctAnswerIndex": 1,
        "explanation": "The SELECT statement is used to retrieve data from a database, making it one of the most fundamental SQL commands."
    },
    {
        "id": "querying_sqlite_q2",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "How can you filter results in a SQL query?",
        "answers": [
            "Using the ORDER BY clause",
            "Using the WHERE clause",
            "Using the GROUP BY clause",
            "Using the SELECT clause"
        ],
        "correctAnswerIndex": 1,
        "explanation": "The WHERE clause is used to filter records based on specified conditions."
    },
    {
        "id": "querying_sqlite_q3",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "Which of the following is an aggregate function in SQL?",
        "answers": [
            "SELECT",
            "ORDER BY",
            "COUNT()",
            "WHERE"
        ],
        "correctAnswerIndex": 2,
        "explanation": "COUNT() is an aggregate function that returns the number of rows that match a specified condition."
    },
    {
        "id": "querying_sqlite_q4",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "What does the HAVING clause do in a SQL query?",
        "answers": [
            "Sorts the results",
            "Filters groups after aggregation",
            "Selects specific columns",
            "Updates records in the database"
        ],
        "correctAnswerIndex": 1,
        "explanation": "The HAVING clause is used to filter groups based on aggregate results, unlike WHERE, which filters individual records."
    },
    {
        "id": "querying_sqlite_q5",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "Which SQLite statement would you use to retrieve all columns from the Users table?",
        "answers": [
            "SELECT * FROM Users",
            "RETRIEVE ALL FROM Users",
            "SELECT ALL FROM Users",
            "GET * FROM Users"
        ],
        "correctAnswerIndex": 0,
        "explanation": "The correct syntax to retrieve all columns from a table is SELECT * FROM table_name."
    },
    {
        "id": "querying_sqlite_q6",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "Which clause is used to sort the results of a SQL query?",
        "answers": [
            "FILTER BY",
            "ORDER BY",
            "SORT BY",
            "GROUP BY"
        ],
        "correctAnswerIndex": 1,
        "explanation": "The ORDER BY clause is used to sort the results of a query in ascending or descending order."
    },
    {
        "id": "querying_sqlite_q7",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "What would be the result of the query 'SELECT city, COUNT(*) FROM Users GROUP BY city'?",
        "answers": [
            "List of all users",
            "Count of users by age",
            "Count of users per city",
            "List of cities with users"
        ],
        "correctAnswerIndex": 2,
        "explanation": "This query groups users by city and counts how many users are in each city, resulting in a count of users for each unique city."
    },
    {
        "id": "querying_sqlite_q8",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "Which SQL command is used to insert new records into a table?",
        "answers": [
            "INSERT INTO",
            "ADD RECORD",
            "CREATE TABLE",
            "UPDATE"
        ],
        "correctAnswerIndex": 0,
        "explanation": "The INSERT INTO command is used to add new records into a specified table."
    }
]
{| endquestions |}
```