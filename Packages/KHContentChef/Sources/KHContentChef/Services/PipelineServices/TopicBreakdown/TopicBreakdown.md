# Topic Breakdown


## Context for the Topic Breakdown Step

This is a step within the pipeline of creating learning content. 
The learning content is right now focused on creating content regarding software engineering, software architecture, and general technical knowledge, all in the purpose of preparation for a technical interview (knowledge, system design, architecture, etc) for a Senior iOS Developer.
This step should take a detailed, structured description regarding a certain topic (ie: concurrency, design patterns used in iOS development, In deth guide to iOS architectures (MVC, MVVM, VIP, MVP, TCA, UDF, etc), etc.)
And based on that input it should give a very detailed breakdown of this topic, where it would generate a list of "Lessons" that would encopass this topic.
The list should be big, but not too big. It shoudl perfecly cover everything that is required for someone to master this topic.
In a sense that that for a given topic, it would output a very exhaustive, comprehensive and sensible list of small-to-medium sized concise lessons (3-10 minutes long to read) that would entail everything that is is required of someone to know regarding that topic. Taking into account the context for which it is being used.
So for now that context is a technical interview for a Senior iOS Engineer/Developer position at a very prestigions company.
All of the topics, lessons should be self containing, they shouldn't be organized like: MVVM part 1, MVVM part2. But they can be split up in a different way, such as: introduction to MVVM, Advanced MVVM Concepts, Coordination functionality in MVVM, and so on.
**It is extremely important that this breakdown is done sensibly, and thoughtfully, describing what each of the lessons should contain**
**this step is something that needs to be automated by AI** in the following senese:
- Input:
    - provide AI with a very detailed topic description, formatted in markdown
- Output:
    - The ai should breakdown that topic into bite sized lessons as mentioned, and all of those should be in a json format where each lesson has a concise *title* what it is, and a *very detailed description and focus* of what that lesson should contain and what is the main focus point of that lesson
    - The output should be in in the following **json** format, and it is very important that the output generated is **ONLY IN THIS FORMAT** no additional text should be provided
    - The output needs to be deserialized and persisted afterwards and it shouldn't ever be anything else other than this json file
    ```
    {
        "lessons": [
            {
                "title": "GCD in Swift",
                "description": "Deep dive into how GCD works in Swift."
            },
            {
                "title": "Task in Swift",
                "description": "Learn how to use Tasks in Swift and how to invoke async functions from sync functions."
            }
        ]
    }
    ```

## Additional focus points and Instructions to AI

- **Number of lessons to generate**
    - That is entirely up to you, but a topic breakdown should be very sensible and it should ensure that the lessons generated would cover everything regarding that topic

- **Lessons should be standalone**
    - Again, each lesson should be a sensible monolithic moment, cover a certain topic and cover it in its entirely. Of course, various levels of depth are acceptable. And a single concept can be broken down into multiple lessons, but those lessons must be approachable as a standalone lesson and not refer to other lessons (they can be of abritrary depth)

- **Leverage Lesson Descriptions as much as possible**
    - Write very detailed lesson descriptions should be generated. Not that they should be big, but they should contain everything that lesson should focus on. They need to describe what the lesson should be about in a very detailed way

- **Stick to the very rigid json output**
    - The output should be in the already mentioned **strict** format which is a **json** which contains the **lessons** array and each of the lessons contains a **title** and **description**
