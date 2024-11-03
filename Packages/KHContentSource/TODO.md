# KHContentSource TODO

### High Priority

### Medium Priority

- When `baking` files into jsons, figure out a way to avoid recreating/saving the same file:
    - if the same json is created but it it has different ordering, it will pollute the content history so this should be avoided. 
    - Potential options for this are:
        - Implement some form of json comparisson so when a content is created, it could be compared to the already exsiting json file, and if the contents match in it's entirety, it won't be saved. This comparisson can be optimized
        - Implement custom ordering within json files, so that only real updates to the json will count as diffs within version control

### Low Priority

### Backlog

---
---

# Done
