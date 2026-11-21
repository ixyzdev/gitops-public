# gitops-public

Shared CI building blocks for the public repositories of ixyzdev. A repository calls them from a thin workflow of its own, so the rules live here once.

It complements the private `ixyzdev/gitops`, which serves the private repositories: GitHub shares a private repository's actions only with private repositories, so public ones use this copy. Both keep the same contract, so a repository moves between them by changing only the repository in `uses:`. A change to an action goes to both.

## actions/release

Tags and publishes the next version of a repository each time its default branch receives commits. The version is decided by what the commits say:

| Version part | When it rises | How a commit asks for it |
|---|---|---|
| Patch `0.0.x` | Every release, by default | Nothing: any commit |
| Minor `0.x.0` | A concrete feature goes out to production | A line `Release: minor` in the commit message |
| Major `x.0.0` | The application moves up a version, stated explicitly by a person | A line `Release: major` in the commit message |

The commit type never decides the version: a `feat` commit or a breaking change is still a patch release until someone asks for more. A finished feature is not necessarily a feature in production. The highest level requested since the last tag wins, and a repository with no tag starts at `0.0.1`.

### Use it

```yaml
name: CD / Release

on:
  push:
    branches:
      - main

permissions:
  contents: write

concurrency:
  group: release
  cancel-in-progress: false

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: ixyzdev/gitops-public/actions/release@main
        with:
          version-files: package.json
```

`version-files` is optional: JSON files, separated by spaces, whose top-level `version` is set to the released version and committed as `chore(release): vX.Y.Z` before tagging. Leave it out when the tag is the only record of the version.

The action's `version` output carries the released version, empty when nothing was released, so a later job can build and attach files to that release.

### Requirements

- This repository is public, so any workflow can use its actions.
- With `version-files`, the workflow pushes a commit to the default branch. A branch protection rule that blocks direct pushes makes the release fail; pass a `token` allowed to bypass it.
