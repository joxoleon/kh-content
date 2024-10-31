# ContentChef 

# ContentChefNetworking

I need to create a ContentCheft networking service. There still needs to be a proper name for this.
- For the initial implementation this is only going to fetch all of the data from the kh-content github repository
- There needs to be a content_metadata.json file that is going to have a timestamp in it that will determine if the used data is stale in order to tell the if the new data needs to be fetched or not.
- If the data is stale it is going to fetch the lessons and modules json files and store them into a two private maps that are going to store lessons and modules based on their ids.
- This data needs to be persisted locally, and right now the best way for this would be in user defaults, is it is just two pretty large json files,
- It needs to have a public API that is going to allow for fetching of modules and lessons (as in fetchLesson or fetchLearningModule), but under the hood, those are always going to be prefetched and most likely cached so it's always going to read it from the in-memory-storage within those maps
- The idea behind this service is to abstract the networking for the app in it's entirety and have an agnostic API, that can work as a backend if intended (but for now it will all be prefetched from github and stored locally in user defaults)
    - In this way in the future if data fetching is any different, the implementation of fetching can be changed but the APIs will remain the same and not break the application logic that is dependent on it
- Naturally, the parsing models will be public as well


I need you to analyze this idea. I need you to really get into it. Tell me what I should do differently.
Let's first just have a discussion on this where you list out the way this service should work.
It really must be designed in entirety with all of the sensible abstractions, protocols, etc before I start implementing it
But even more, does having something like this make sense and what should be done differently



# KHDataRepository

I want to create a new package that is going to be called something like KHDataRepository, but we will need to think of a better name for this.
I'll explain to you what this module does and you can think of various names that can fit into this logic.

This module should abstract everything regarding to data fetching and even lesson/module domain models.
- It should have a protocol that can allow for multiple implementations of the repository
- The initial one is going to fetch the json files from the kh-content repository and is going to deserialize them and store all of the modules and repositories into maps for quick access
    - The lessons are going to be stored in a map that is going to map lessonId into the entire lesson
    - The modules can also be stored based on their id within a map
- It needs to define all domain models in it's entirety:
    - Basically I will move all of the domain models from KnowledgeHub app here

