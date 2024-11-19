
# KnowledgeHub Content Generation CLI Proposal

This proposal reorganizes and refines the original approach for developing the KnowledgeHub content generation CLI. It emphasizes simplicity, flexibility, and modularity while avoiding overengineering. The goal is to streamline workflows, ensure content quality, and provide intuitive manual intervention points.

---

## Key Components

### 1. **Content Workflow Engine**
A centralized service to manage the content generation pipeline. It handles all steps (from courses to lessons) using shared utilities for API calls, validation, and file storage.

**Responsibilities:**
- Orchestrate execution flows (pipeline or standalone).
- Facilitate retries, validation, and persistence.
- Pause at key checkpoints for manual review.
- Ensure consistency in output formats (e.g., JSON/YAML).

---

### 2. **Simplified Pipeline Structure**
Rather than rigid separation for lessons, topics, and courses, focus on lessons as the atomic unit. Topics and courses act as higher-level groupings with metadata that drive lesson generation.

**Pipeline Steps:**
1. **Course Generation:** Generates metadata for topics based on a high-level description of the course.
2. **Topic Generation:** Produces metadata for lessons within a topic.
3. **Lesson Generation:** Creates the content for each lesson using the OpenAI API.
4. **Validation and Review:** A unified process for verifying generated content and allowing manual edits.

---

### 3. **Unified CLI**
A single entry-point command (`content`) with subcommands for flexibility. This reduces complexity while retaining modular functionality.

**Subcommands:**
- `content generate`: Handles content creation at any level.
  - Flags:
    - `--course`: Generate a course with topics.
    - `--topic`: Generate lessons from a topic.
    - `--lesson`: Generate a single lesson.
    - `--pause`: Pause after each step for review.
    - `--validate`: Validate outputs after generation.
- `content review`: Opens a file for manual review and editing.
  - Flags:
    - `--file <path>`: Specify the file to review.
- `content validate`: Validates content files against predefined schemas.
  - Flags:
    - `--file <path>`: Specify the file to validate.

**Examples:**
1. Generate a course with pauses for review:
   ```bash
   content generate --course --input "SwiftUI Advanced Course" --pause
   ```
2. Generate lessons from a topic file:
   ```bash
   content generate --topic --input topic.json
   ```
3. Review and edit generated lessons:
   ```bash
   content review --file lessons.json
   ```
4. Validate a topic file:
   ```bash
   content validate --file topic.json
   ```

---

### 4. **Abstract Shared Utilities**
Centralize reusable components like:
- API calls to OpenAI.
- File storage and retrieval.
- Validation tools for schemas (e.g., JSON Schema).

This avoids duplication while keeping the system simple and efficient.

---

### 5. **Default vs. Configurable Behavior**
The CLI should work out-of-the-box with sensible defaults while allowing advanced users to customize workflows.

**Defaults:**
- Automatic retries for failed steps (1-2 attempts).
- Validation of outputs unless `--skip-validation` is specified.
- Pausing for manual review unless `--auto-approve` is set.

**Custom Options:**
- Specify custom pipelines with manual interventions at key checkpoints.
- Enable or disable certain steps in the pipeline (e.g., skip validation).

---

## Benefits of This Approach

1. **Simplicity:** Reduces overengineering by centralizing workflows and utilities.
2. **Flexibility:** Retains standalone steps while enabling full pipelines.
3. **Scalability:** A unified CLI and workflow engine are easier to extend with new features.
4. **User-Friendly:** Provides clear checkpoints and review processes without unnecessary complexity.
5. **Consistency:** Enforces consistent data structures and validation across all steps.

---

## Example Workflow

### Generate a Course
```bash
content generate --course --input "Full SwiftUI Course" --pause
```
- Creates topics based on the course description.
- Pauses for user review and editing of the topic file.

### Generate Lessons from a Topic File
```bash
content generate --topic --input topic.json
```
- Iterates through lessons, validating and retrying failed generations.

### Full Pipeline with Validation and Pauses
```bash
content generate --course --pause --validate
```
- Runs the entire pipeline from courses to lessons with pauses at key checkpoints.

### Review Output
```bash
content review --file lessons.json
```
- Opens the generated file for manual edits before proceeding.

---

## Summary
This proposal emphasizes:
1. A **Content Workflow Engine** to centralize processes.
2. A **simplified pipeline** with modular steps.
3. A **unified CLI** for straightforward user interaction.
4. Shared utilities to avoid duplication and ensure consistency.
5. Flexible, configurable workflows to adapt to user needs.

The result is a powerful, user-friendly CLI for generating and organizing content in KnowledgeHub.
