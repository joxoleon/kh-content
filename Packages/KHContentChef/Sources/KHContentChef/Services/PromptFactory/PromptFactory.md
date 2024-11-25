# Prompt Factory

I need a prompt factory service that is going to have the following functionalities:
- It will have a Path where the prompt templates are store - and that should be a default value configured
- Upon creation it will load all of those prompts and and keep them in an in-memory storage (map, array, whatever makes sense)
- It will define an enum that will be the be PromptType, and single one of those will correlate to the existing prompt templates
- That prompt type will have in it's associated value all of the generic parameters that need to be injected into the prompt
- The prompt templates will have placeholders such as: *{{title}}*, and *{{focus}}*, and whatever else, that the prompt factory will use when transforming a prompt upon request
- It should load all prompts actually lazilly once anything from it was requested, then it should keep them in memory
- It should have a very minimalistic API where you provide it with a promptType (enum) where the parameters are stored in it's associated value
- It will then proceed to inject those parameters into the prompt and return it all to you

Does this implementation make sense?
What should be changed?
Don't implement it immediately, let's discuss it first, then go and make it work!