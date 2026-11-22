# Release notes

Write the notes of one GitHub release of this repository and publish them over the notes GitHub generated. A reader opens a release to learn why the version exists, what it changed and what they have to do. The answers come from what the work recorded: the commits in the release, the pull requests that merged them and the issues those pull requests close.

The release tag and the previous tag are given with these instructions. With no previous tag, the release covers the whole history: summarize it by area instead of by commit.

## 1. Gather

```sh
git log --reverse --format='%H%n%B%n----' <previous tag>..<tag>
git diff --stat <previous tag>..<tag>
```

Leave out the `chore(release): <tag>` commit the release action adds.

Find the pull request that merged each commit, then read each pull request once and every issue it closes:

```sh
gh api repos/{owner}/{repo}/commits/<sha>/pulls --jq '.[].number'
gh pr view <number> --json number,title,body,url,closingIssuesReferences
gh issue view <number> --json number,title,body,url,state
```

Then read the diff of each change (`git diff <previous tag>..<tag> -- <path>`). The notes explain what the implementation does, and a commit subject does not say that.

## 2. Write

In English, with these sections in this order. Every section is always present.

```markdown
## Why

<The problem or need this release answers, from the issues; with no issue, from the pull request's Purpose. One to three sentences.>

## What changed

- <One bullet per real change: what it does now and how, in plain words. The commits of one change, fixups included, make one bullet.>

## What you need to do

<What someone using this repository does to get or adopt the change: update a plugin, reinstall, migrate, set a secret. "Nothing." when nothing.>

## Version

<Patch, minor or major, and why: the commit whose `Release:` trailer asked for it and the reason in its body, or "Patch: no commit asked for more.">

## Not in this release

- <What the issues asked for and this release does not do, next steps the pull requests name, and referenced issues that stay open. "Nothing pending." when nothing.>

## Trace

- <[#issue title](url) → [#pull request title](url); a commit pushed without a pull request as its short hash and subject.>

**Full Changelog**: https://github.com/<owner>/<repo>/compare/<previous tag>...<tag>
```

- Every statement comes from a commit, the diff, a pull request or an issue. Do not add intent, benefits or impact the sources do not state; when a section has no source, say that plainly.
- Describe behavior, not files: "the desktop starts quest-x11 instead of Termux:X11", not "edited start-desktop.sh".
- With several pull requests, group the bullets of What changed by pull request, and give Why one sentence each.
- No marketing words, no emojis, no attribution to an agent or tool.

## 3. Publish

```sh
gh release edit <tag> --notes-file - <<'NOTES'
<notes>
NOTES
gh release view <tag>
```

The release must show the new notes.
