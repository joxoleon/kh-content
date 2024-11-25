## This is a CLI Tool named ContentChef

What I am about to send is a very raw main.swift file where I've only done a single step (CLI COMMAND) that I want this CLI tool to perform. This step should be called publish_content, and as you can see it takes in the input and output directories as parameters.
What I really need to do is implement multiple CLI commands, that can all be regularly invoked with this cli tool.
How should I approach that.
For starters, let's say that I want to have a CLI command that is going to called generate_lessons:
    - Arguments:
        - input file path // A path for a file that will be loaded to get the input for this step
        - output dir // A path where this command will output the files it has generated

How would I go about doing this? Please describe in detail, and then generate what I want to do in Swift according to the best guidelines and pracices.
Here's the main.swift file that I have now:


