I need to create a very simple OpenAIAPI service for prompting GPT via a REST request (This is to used in a Swift executable package, CLI tool, and potentially other swift projects).
- It should have a very minimalist API, mostly for firing prompts
- Also I would like to be able to fire batched prompts as I hope they are faster and less expensive
- It should have a base protocol so that it can be mocked and tested properly

Requirements for the basic API call:
    - PromptRequest:
        - prompt: String // Should have a string that is the prompt
        - model
        - tempatature
        - Whatever else you deem is necessary for this to go in
    - PromptResponse:
        - responseString // At least I think it comes in this way
        - Whatever else might be necessary, this is the first time I'm doing this

Just do the straightforward version for now, and we'll discuss batching once this is working flawlessly
Please generate everything in a single Swift file!
     