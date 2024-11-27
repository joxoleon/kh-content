```markdown
{| metadata |}
{
    "title": "Core Data Migration Strategies",
    "description": "This lesson covers Core Data migration strategies, focusing on lightweight migrations, versioning data models, and handling complex migrations effectively.",
    "proficiency": "intermediate",
    "tags": ["core data", "data migration", "ios", "data model", "lightweight migration", "software engineering", "versioning"]
}
{| endmetadata |}

=== Section: Core Data Migration Strategies Introduction ===
## Core Data Migration Strategies

Data migration is a crucial aspect of iOS development, especially when changes occur in your data model. This lesson delves into **Core Data migration strategies**, which help ensure that your application transitions smoothly between different versions of its data schema. 

> **Core Data Migration** is the process of updating a persistent store to match changes made to the data model.

Understanding how to implement these strategies can greatly impact the integrity and performance of your application. We will cover **lightweight migrations**, the importance of **versioning your data model**, and how to handle more **complex migrations** effectively.

=== EndSection: Core Data Migration Strategies Introduction ===

=== Section: Core Data Migration Strategies ===
## Core Data Migration Strategies

### Lightweight Migrations
**Lightweight migrations** are the simplest form of migration in Core Data. They are used when changes to the data model are compatible with existing data. This includes adding new attributes, changing attribute types (if compatible), or adding new entities.

To enable lightweight migration, you can use the following options when creating your `NSPersistentStoreCoordinator`:

    let storeURL = ... // Your store URL
    let options = [
        NSMigratePersistentStoresAutomaticallyOption: true,
        NSInferMappingModelAutomaticallyOption: true
    ]
    
    do {
        try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, 
                                                          configurationName: nil, 
                                                          at: storeURL, 
                                                          options: options)
    } catch {
        // Handle error
    }

This approach simplifies the process, as Core Data handles the migration automatically based on the changes detected in the model.

### Versioning Your Data Model
Versioning your data model is essential to track changes over time. Each time you modify your data model, you should create a new version of the model file. This can be done in Xcode by selecting your `.xcdatamodeld` file, choosing "Editor" from the menu, and then "Add Model Version".

When you create a new version, ensure to set the current model version in your project settings. 

### Handling Complex Migrations
For more complicated changes, such as deleting an entity or merging two entities, you may need to create a **mapping model**. A mapping model defines how the data from the old model should be transformed to fit the new model.

To create a mapping model:

1. In Xcode, select your `.xcdatamodeld` file.
2. Choose "Editor" > "Add Mapping Model".
3. Select the source and destination model versions.

Once your mapping model is set, you can perform the migration programmatically:

    let migrationManager = NSMigrationManager(sourceModel: sourceModel, destinationModel: destinationModel)
    
    do {
        try migrationManager.migrateStore(from: sourceStoreURL,
                                           sourceType: NSSQLiteStoreType,
                                           options: nil,
                                           withMappingModel: mappingModel,
                                           toDestinationURL: destinationStoreURL,
                                           destinationType: NSSQLiteStoreType,
                                           destinationOptions: nil)
    } catch {
        // Handle error
    }

This process allows for greater control over how data is transformed during migration, ensuring data integrity.

=== EndSection: Core Data Migration Strategies ===

=== Section: Discussion ===
## Discussion

When implementing Core Data migration strategies, it's important to weigh the pros and cons:

### Pros:
- **Automatic Handling**: Lightweight migrations allow for quick schema updates without manual handling.
- **Version Control**: Versioning your data model helps in maintaining a history of changes.
- **Flexible Mappings**: Complex migrations enable sophisticated data transformations.

### Cons:
- **Limited to Compatible Changes**: Lightweight migrations are not suitable for incompatible changes, necessitating more complex approaches.
- **Performance Overhead**: More complex migrations may introduce performance concerns during data transformation.

### Use Cases:
- **Lightweight migrations** are ideal during regular updates, such as adding new features.
- **Complex migrations** may be required during significant changes, like merging data from different models or changing the core structure.

Understanding these strategies is vital for ensuring that your Core Data stack remains stable and efficient as your application evolves.

=== EndSection: Discussion ===

=== Section: Key Takeaways ===
## Key Takeaways
- **Core Data migration** is essential for adapting to changes in your data model.
- **Lightweight migrations** are suitable for simple, compatible changes.
- **Versioning** helps maintain a clear history of model changes.
- **Complex migrations** require mapping models for transforming data accurately.
- Always test migrations thoroughly to ensure data integrity.

=== EndSection: Key Takeaways ===

{| questions |}
[
    {
        "id": "core_data_migration_q1",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "What is a lightweight migration in Core Data?",
        "answers": [
            "A migration that requires manual mapping of data.",
            "A simple migration for compatible changes.",
            "A migration that can only delete entities.",
            "A complex migration for merging multiple models."
        ],
        "correctAnswerIndex": 1,
        "explanation": "A lightweight migration is used for simple, compatible changes in the data model without requiring manual intervention."
    },
    {
        "id": "core_data_migration_q2",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "What is the purpose of versioning your data model?",
        "answers": [
            "To track changes and manage migrations.",
            "To improve performance during fetch requests.",
            "To reduce the size of the database.",
            "To create backup copies of the database."
        ],
        "correctAnswerIndex": 0,
        "explanation": "Versioning your data model helps track changes over time and manage migrations effectively."
    },
    {
        "id": "core_data_migration_q3",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "Which of the following changes is NOT suitable for lightweight migration?",
        "answers": [
            "Adding a new attribute to an existing entity.",
            "Changing an attribute type from String to Integer.",
            "Removing an existing attribute.",
            "Adding a new entity to the model."
        ],
        "correctAnswerIndex": 2,
        "explanation": "Removing an existing attribute is not compatible with lightweight migration, which can only handle certain types of changes."
    },
    {
        "id": "core_data_migration_q4",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "What does a mapping model do in Core Data migrations?",
        "answers": [
            "It defines the structure of the database.",
            "It specifies how data should be transformed between models.",
            "It provides a visual representation of the data model.",
            "It automatically migrates data without any configurations."
        ],
        "correctAnswerIndex": 1,
        "explanation": "A mapping model specifies how data should be transformed from the old model to the new model during a migration."
    },
    {
        "id": "core_data_migration_q5",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "Which option is required for enabling lightweight migration?",
        "answers": [
            "NSInferMappingModelAutomaticallyOption",
            "NSMigratePersistentStoresAutomaticallyOption",
            "NSPersistentStoreCoordinatorOption",
            "NSMigrationManagerOption"
        ],
        "correctAnswerIndex": 1,
        "explanation": "The option NSMigratePersistentStoresAutomaticallyOption enables automatic migration of persistent stores."
    }
]
{| endquestions |}
```