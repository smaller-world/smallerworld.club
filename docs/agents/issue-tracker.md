# Issue tracker: GitHub

Issues and specs live in smaller-world/smallerworld.club. Use the gh CLI from
this clone.

- Publish a ticket: gh issue create
- Fetch a ticket: gh issue view <number> --json
  number,title,body,labels,comments
- List tickets: gh issue list with appropriate state and label filters
- Update labels: gh issue edit <number> --add-label / --remove-label
- Comment: gh issue comment <number>
- Close: gh issue close <number>

For multiline bodies, write the text to a temporary file and use --body-file.
Link child tickets using native sub-issues when available; otherwise put “Part
of #<parent>” in the child and a task list in the parent. Use native issue
dependencies for blockers when available; otherwise put “Blocked by: #<number>”
in the child.

PRs as a request surface: no.
