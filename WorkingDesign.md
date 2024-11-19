I want to streamline content generation, for now it was done using GPT chat, but I want to use the OpenAI API and leverage that to iterate on creating an abriratry number of lessons all at once.
I want to have a cli tool that is going to support various flows within this, and I want that CLI tool to be able to pipeline the entire content generation just from starting the initial module, and then recursively start generating all of the steps in between.
I'm going to try and breakdown everything that comes to mind.

- Lesson generation:
    - Use a templated prompt where the title, and general description of what needs to be there are parameters within that prompt
    - Invoke the api call to generate that lesson
    - Store it in a file and validate via the parser that it's working completely

- Topic Generation - A topic is a structure that contains an array of metadata required to generate an arbitrary amount of lessons for that specific topics:
    - This file needs to be able to be generated via AI wtih it's own specific prompt. Let's say that I want to generate any number of lessons on the Combine framwework and it's usages and implementations, everything you need to know about combine (up to an arbitrary depth)
    - Once this generates it should output the list and show it to you in the cl and persist it in a file somewhere, you can verify and change it manually
    - So the input would be:
        - Topic summary - for example: "Everything You need to know about Combine Framework"
        - Description -  A detaild description of everyting that should be included here, something like: "Random " 

- Generate Lessons from Topic Description File.
    - Go through a list of lessons from a Topic file andtrigger lessonGeneration for each of them -> if one fails implement some sort of a retry mechanism (maybe 1-2 times to retry) and continue with other lessons
    - This should have some sort of a user friendly output in the CLI to tell what is being generated right now and how it is going
    - There should be a specified data structure that is used for this input format, and that needs to be a persistable file that can also be generated via AI - probably a json or yaml - this is the topic file!

- Course generation
    - This is the top level flow of generation. A course is just a big collection of various topics that need to be covered in that course.
    - You should input a pretty big text that describes a full course, what it should cover, what it should contain, what is it's purpose, the level of depth, basically everything about that course in a high level overview.
    - Then it would proceed to generate a list of Topic Metadata (so for each topic a title and what should be covered there - not how they are broken down in lessons).
    - The output of this should also be a structured, persistable file that can be viewed and edited.
    - And based on that outputted file, Entire topics can be generated, and those topics can be used to generate concrete lessons, and so on.


- Module generation - this is just for organizing lessons within the course. The in app course won't know anything about topics, course random items etc. The in-app representation of everything is composable modules that contain other modules and/or lessons.
    - This should work as it currently does.
    - It should provide the AI with it's title, description and with a list of all lessons metadata, (titles, descriptions) and prompt it with that data to actually organize it in sensible modules up to a certain level.



General:
- All of these features need to be available both in standalone, as well as chainable in a pipeline that would allow for some control - finished one step, verified everything, you can check locally how it looks on your system and proceed with the next step
- The endgame of this would be to allow for a content generation pipeline that would actually allow the user to input a whole document that woul
- Each of the steps that exist here should be a standalone step- as well as a step that can be chained into a pipeline
- Each of these steps need to have a well defined and verifiable input and output (even though input can sometimes be just plain text - the output needs to be very verifiable).
- Each of these steps should have it's own proper abstraction within the code, maybe even as a custom service, that has a proper base class /protocol.
- And the pipeline that works for creating it should be configured in a way that it can contain an array of those, and maybe pause in between to allow for verification before proceeding to next steps
- Everything needs to be completely testable and be able to work in various modes of execution (full content mode, single step mode, define custom paths of the pipeline, etc.)


So, first what I want you to do is revise what I have here so far.
Organize what I just sent you into sensible text in markdown with headiings and formatting and whatnot, and output it to me organized and cleaned up with removed redundancies, in a markdown text box.

And here is the outputted initial version of this document.

--- 

Reorganiz