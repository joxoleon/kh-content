# LessonGenerationService

This service is going to do the following:
- Have two main API methods, one is generateLeson, the other one is GenerateLessons
    - Both of these will do the same thing, only the second one will do batch calls to OpenAIAPIService instead of a single call(prompt)
- For simplicity we will work just on the single one for now, but the batchOne needs to be implemented in the same way
- Heres the basic idea of the flow:
    - Receive the following input in the form of a struct called LessonGenerationInput:
        - Lesson title (doesn't necessary have to be a title, just something that describes the lesson in detpth)
        - In depth lesson description that really describes everything that the lesson needs to contain
    - It will load the lesson query prompt from a file and it will place the input strings in the designated locations
    - It will fire the API call and receive the response (the generated lesson raw text)
    - Then it will save it to a temporary working directory (this too can be configured somewhere within the init, but it should have a default value)
    - It will use the LessonParser to test if the generated lesson was Valid by parsing it and makig sure it all goes well
    - If the lesson is parsed ok, it will move it from the temporary directory to the designated output directory that also needs to be parametrized for this service
    - That is the main flow of how this should look like

- This needs to be a singleton like service, with a proper abastraction (protocol) in case it needs to be tested
- This will be used by other services in various pipelines so anything that should be added, please add, think sensibly what else should be there
- There should also be a designated location where it would keep it's prompts and those prompts and paths to them should be somehow hardcoded in code - for now, in the future this can be improved


