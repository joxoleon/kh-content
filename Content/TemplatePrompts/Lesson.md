
# **{{title}}**

### Focus:
**{{focus}}**

---

## Introduction to AI:

You are creating a structured **lesson** on software engineering concepts for a learning app. This lesson will help users prepare for technical interviews and deepen their understanding of iOS development, software engineering, and architecture concepts. While the lesson library will eventually expand to cover advanced topics, the current focus is technical interview preparation on the following topics: iOS, Software Engineering, Software Architecture, System Design, etc.

---

## Lesson Requirements:

### Format and Structure:

1. **Output**: Format the final lesson as a **single Markdown file (.md)** that follows a consistent structure for readability and compatibility with Markdown editors. **Each section should have a clear delimiter**.

2. **Follow this Rigid Structure with Delimiters**:

   - **Metadata Section**:
     - Begin the lesson with metadata in JSON-like format.
     - Include:
       - `title`: The lesson title.
       - `description`: A brief description of the lesson’s purpose.
       - `proficiency`: An estimated proficiency level of the lesson (e.g., `"basic"`, `"intermediate"`, or `"advanced"`). Only use one of these choices.
       - `tags`: An array of 5-8 keywords/tags encapsulating the essence of the lesson topic (e.g., `["solid", "solid principles", "clean", "clean architecture", "software architecture", "architecture", "software design"]`).
     - **Wrap the metadata** with delimiters:
       
       {| metadata |}
       {
           "title": "Example Lesson",
           "description": "A brief description of the lesson.",
           "proficiency": "basic",
           "tags": ["solid", "solid principles", "clean", "clean architecture", "software architecture", "architecture", "software design"]
       }
       {| endmetadata |}

   - **Sections**:
     - **Definition and Introduction**: 
       - Use the delimiter `=== Section: [Title] Introduction ===` to start this section (replace `[Title]` with the lesson title).
       - **Start this section with a clear, descriptive heading for the introduction - use the title of the lesson for this.**
       - Provide a concise definition and introduction, focusing on the topic’s purpose and significance.
       - Emphasize key definitions or principles with quotation blocks (e.g., `> Dependency Injection is...`).
       - Use **bold** formatting to highlight important acronyms, terms, or phrases that should be easily memorable.
       - Ensure each section begins with an introductory sentence to set context for the reader.
       - End this section with the delimiter `=== EndSection: [Title] Introduction ===`.
       
     - **Full Lesson**: 
       - Use the delimiter `=== Section: [Title] ===` to begin the main content section.
       - Start with a heading that appropriately describes the section.
       - Provide a thorough, structured explanation of the topic. Include all necessary details, examples, best practices, and relevant code snippets.
       - **Do not be stingy with examples**: Whenever a concept would benefit from one, provide a clear, relevant example, whether it be a code snippet or an illustrative scenario. Use sensible formatting and indentation for code examples.
       - **Examples should be practical and based on real-world scenarios**, not purely theoretical code.
       - **Subsections**: If the lesson covers multiple concepts, split the Full Lesson into up to 5-6 subsections only if needed for distinct topics.
       - End this section with the delimiter `=== EndSection: [Title] ===`.
       
     - **Discussion**: 
       - Use the delimiter `=== Section: Discussion ===` to start the discussion.
       - Start with a "Discussion" heading
       - Cover the topic’s pros, cons, common use cases, or comparisons with related concepts to provide a broader context.
       - End this section with the delimiter `=== EndSection: Discussion ===`.
       
     - **Key Takeaways**: 
       - Use the delimiter `=== Section: Key Takeaways ===`.
       - Start with a "Key Takeaways" heading
       - Summarize the lesson with concise, flashcard-friendly points.
       - Focus on “bite-sized” statements that serve as memory aids.
       - End this section with the delimiter `=== EndSection: Key Takeaways ===`.

3. **Questions Section**:
   - Conclude the lesson with a set of multiple-choice questions in JSON format.
   - **Wrap the questions section** with delimiters:

       {| questions |}
       [
           {
               "id": "example_lesson_q1",
               "type": "multiple_choice",
               "proficiency": "basic",
               "question": "What is Dependency Injection?",
               "answers": [
                   "A way to protect data within an object",
                   "A method to manage object dependencies",
                   "A programming loop",
                   "A type of data structure"
               ],
               "correctAnswerIndex": 1,
               "explanation": "Dependency Injection is a design pattern that manages dependencies by injecting them, making code more modular and testable."
           },
           // Additional questions following the same structure
       ]
       {| endquestions |}

   - **Each question should include**:
     - `id`: A unique identifier based on the lesson title and question number (e.g., `"solid_principles_q1"`).
     - `type`: `"multiple_choice"`.
     - `proficiency`: The difficulty level (e.g., `"basic"`, `"intermediate"`, or `"advanced"`).
     - `question`: The question text, formatted as a markdown string.
     - **Complexity and Variability**: Include questions with varied difficulty and some that involve code snippets or practical scenarios.
     - `answers`: An array of answer choices.
     - `correctAnswerIndex`: Index of the correct answer within the `answers` array.
     - `explanation`: A markdown-formatted explanation that clarifies why the correct answer is right and why other options are incorrect.
   - **Requirements**:
     - Generate at least 8 well-thought-out questions based on topic difficulty - if you deem the topic important for an iOS interview then generate up to 15 questions

4. **Quality and Readability**:
    - Use clear, professional language suitable for an advanced audience.
    - Ensure examples are easily understandable and demonstrate real-world applicability.
    - Write high-quality, concise key takeaways suitable for flashcard-style review.
    - Emphasize important keywords or concepts using **bold** formatting in all sections of the lesson, but apply sparingly and only to essential terms:
        - For example, highlight terms like **SOLID principles** in a lesson on SOLID, or emphasize **contract** and **blueprint** when discussing protocols in Swift.
    - Structure paragraphs and explanations to be professional yet easy to read. Avoid large text blocks by formatting with readable spacing and breaking down complex explanations.

---

### Instructions to AI:
- **Use clear, professional language suitable for an advanced audience (Senior iOS Engineer).**
- **Ensure examples are easily understandable and demonstrate real-world applicability.**
- **Structure paragraphs and explanations to be professional yet easy to read. Avoid large text blocks by formatting with readable spacing and breaking down complex explanations.**
- **Start each lesson section with an appropriate heading of the same weight (let's say ##)**
- **Generate a lesson with the following structure**:

1. Metadata:

    {| metadata |}
    { 
        "title": "Dependency Injection in iOS", 
        "description": "An introductory lesson on Dependency Injection and its benefits in iOS applications.",
        "proficiency": "basic",
        "tags": ["dependency injection", "di", "software architecture", "design pattern", "dependency", "dependencies"]
    }
    {| endmetadata |}

2. Sections:
    - `=== Section: Dependency Injection Introduction ===`
      Provide a short, concise definition of Dependency Injection, explaining its purpose in software engineering.
      `=== EndSection: Dependency Injection Introduction ===`

    - `=== Section: Dependency Injection ===`
      Provide an in-depth explanation of Dependency Injection, covering what it is, why it’s beneficial, and how it can be implemented in iOS. Include examples to show how DI can make code more modular and testable. Avoid using three backticks ("```") for code blocks; indent instead to maintain text flow. For example:

          struct MyDependency {
              func performAction() {
                  print("Action performed.")
              }
          }

      `=== EndSection: Dependency Injection ===`

    - `=== Section: Discussion ===`
      Discuss the pros and cons of Dependency Injection, alternative approaches, and real-world applications where DI is especially useful in iOS development.
      `=== EndSection: Discussion ===`

    - `=== Section: Key Takeaways ===`
      Summarize the main points with concise, flashcard-friendly statements.
      `=== EndSection: Key Takeaways ===`

3. Questions:
    - Create at least 5 multiple-choice questions relevant to Dependency Injection. Include an explanation for each answer to reinforce understanding.
    - Wrap the question section as follows:

      {| questions |}
      [
          {
              "id": "dependency_injection_q1",
              "type": "multiple_choice",
              "proficiency": "basic",
              "question": "What is Dependency Injection?",
              "answers": [
                  "A way to protect data within an object",
                  "A method to manage object dependencies",
                  "A programming loop",
                  "A type of data structure"
              ],
              "correctAnswerIndex": 1,
              "explanation": "Dependency Injection is a design pattern that manages dependencies by injecting them, making code more modular and testable."
          },
          // Additional questions following the same structure
      ]
      {| endquestions |}

