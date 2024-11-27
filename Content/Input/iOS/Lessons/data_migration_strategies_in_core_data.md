```markdown
{| metadata |}
{
    "title": "Data Migration Strategies in Core Data",
    "description": "A comprehensive guide on data migration techniques in Core Data, focusing on lightweight and heavyweight strategies.",
    "proficiency": "intermediate",
    "tags": ["core data", "data migration", "ios development", "heavyweight migration", "lightweight migration", "data integrity"]
}
{| endmetadata |}

=== Section: Data Migration Strategies in Core Data Introduction ===
# Data Migration Strategies in Core Data

Data migration in **Core Data** is a vital process that allows developers to effectively manage changes in data models over time. As applications evolve, schema changes are often necessary, and understanding how to migrate existing data is crucial for maintaining data integrity and usability. 

> **Data migration** refers to the process of transferring data between storage types, formats, or systems, particularly when changes are made to data structures.

In this lesson, we will explore two primary types of migration strategies: **lightweight** and **heavyweight** migration, along with best practices to ensure a seamless transition and maintain data integrity.

=== EndSection: Data Migration Strategies in Core Data Introduction ===

=== Section: Data Migration Strategies in Core Data ===
# Understanding Data Migration Strategies

## Lightweight Migration

**Lightweight migrations** are the preferred method when making simple changes to your data model. This type of migration allows Core Data to automatically handle schema changes without requiring a lot of manual intervention. 

### When to Use Lightweight Migration

Lightweight migration is suitable for the following changes:
- Adding new attributes to existing entities
- Renaming attributes
- Changing attribute types (under certain conditions)
- Adding new entities to the model

### Example of Lightweight Migration

To enable lightweight migration, you need to set specific options while initializing your `NSPersistentStoreCoordinator`. Here’s an example:

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
        fatalError("Unresolved error \(error)")
    }

In this example, the options allow Core Data to infer the mapping model and handle the migration automatically.

## Heavyweight Migration

**Heavyweight migrations** are necessary when your changes are more complex, such as:
- Deleting existing entities
- Reorganizing the data model significantly
- Changing relationships between entities

### Creating a Mapping Model

To perform a heavyweight migration, you need to create a mapping model. This mapping model defines how to transform data from the old model to the new model. 

1. In Xcode, select your data model file.
2. Choose `Editor` > `Add Mapping Model`.
3. Follow the wizard to create a mapping model between the source and destination models.

### Implementing Heavyweight Migration

Once you have your mapping model, you can perform the migration like so:

    let mappingModel = NSMappingModel(from: [sourceModel, destinationModel])
    let migrationManager = NSMigrationManager(sourceModel: sourceModel, destinationModel: destinationModel)

    do {
        try migrationManager.migrateStore(from: sourceStoreURL, 
                                           sourceType: NSSQLiteStoreType, 
                                           options: nil, 
                                           with: mappingModel, 
                                           toDestinationURL: destinationStoreURL, 
                                           destinationType: NSSQLiteStoreType, 
                                           destinationOptions: nil)
    } catch {
        fatalError("Migration failed: \(error)")
    }

This approach gives you more control over how data is transformed, making it suitable for complex scenarios.

## Best Practices for Data Migration

- **Test Migrations Thoroughly**: Always simulate migrations in a test environment before deploying them in production. 
- **Backup Data**: Ensure that you have backups of your data before performing any migration. This precaution helps prevent data loss.
- **Monitor Performance**: Keep an eye on the performance of your application during migration, as large datasets can lead to performance bottlenecks.

=== EndSection: Data Migration Strategies in Core Data ===

=== Section: Discussion ===
# Discussion

The choice between lightweight and heavyweight migration techniques depends largely on the complexity of the changes being made to the data model. 

### Pros and Cons

- **Lightweight Migration**:
  - **Pros**: Simple to implement, requires less code, and allows for quick updates.
  - **Cons**: Limited to straightforward changes; not suitable for complex data model alterations.

- **Heavyweight Migration**:
  - **Pros**: Provides control over data transformations and is suitable for complex changes.
  - **Cons**: Requires more setup (e.g., creating mapping models) and can be more error-prone.

### Common Use Cases

Lightweight migrations are common in iterative development where new features are added frequently, while heavyweight migrations are often necessary during significant updates or overhauls of the application data structure.

=== EndSection: Discussion ===

=== Section: Key Takeaways ===
# Key Takeaways

- **Data Migration** is essential for managing schema changes in Core Data.
- **Lightweight Migration** is best for simple changes like adding attributes.
- **Heavyweight Migration** is necessary for complex changes that require explicit mapping.
- Always test migrations thoroughly and back up data to ensure integrity.

=== EndSection: Key Takeaways ===

{| questions |}
[
    {
        "id": "data_migration_q1",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "What is the primary advantage of lightweight migration in Core Data?",
        "answers": [
            "It requires creating a mapping model.",
            "It allows automatic handling of simple schema changes.",
            "It is the only method for migrating data.",
            "It is slower than heavyweight migration."
        ],
        "correctAnswerIndex": 1,
        "explanation": "Lightweight migration allows Core Data to automatically handle simple schema changes without requiring extensive manual setup."
    },
    {
        "id": "data_migration_q2",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "Which of the following changes typically requires heavyweight migration?",
        "answers": [
            "Adding a new attribute to an entity.",
            "Renaming an existing attribute.",
            "Deleting an existing entity.",
            "Changing an attribute's type from string to integer."
        ],
        "correctAnswerIndex": 2,
        "explanation": "Deleting an existing entity is a complex change that typically requires heavyweight migration due to the need for explicit mapping."
    },
    {
        "id": "data_migration_q3",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "What are the two options to enable lightweight migration?",
        "answers": [
            "NSMigratePersistentStoresAutomaticallyOption and NSInferMappingModelAutomaticallyOption",
            "NSLightweightMigrationOption and NSHeavyweightMigrationOption",
            "NSAutomaticMigrationOption and NSModelVersionOption",
            "NSPersistentStoreCoordinatorOption and NSMigrationManagerOption"
        ],
        "correctAnswerIndex": 0,
        "explanation": "The two options NSMigratePersistentStoresAutomaticallyOption and NSInferMappingModelAutomaticallyOption allow Core Data to perform lightweight migrations automatically."
    },
    {
        "id": "data_migration_q4",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "Why is it important to backup data before migration?",
        "answers": [
            "To ensure faster migration.",
            "To prevent data loss in case of migration failure.",
            "To allow multiple migrations at once.",
            "To decrease the size of the database."
        ],
        "correctAnswerIndex": 1,
        "explanation": "Backing up data before migration is crucial to prevent data loss if the migration fails or encounters issues."
    },
    {
        "id": "data_migration_q5",
        "type": "multiple_choice",
        "proficiency": "intermediate",
        "question": "What is a mapping model in the context of heavyweight migration?",
        "answers": [
            "A model that represents the database schema.",
            "A model that defines how to transform data from the old model to the new model.",
            "A model that automatically detects changes in the schema.",
            "A model used for lightweight migration only."
        ],
        "correctAnswerIndex": 1,
        "explanation": "A mapping model defines the transformation rules for migrating data from the old data model to the new data model during heavyweight migration."
    }
]
{| endquestions |}
```