#!/usr/bin/env bash
set -euo pipefail

version_files="${VERSION_FILES:-}"

last_tag="$(git describe --tags --abbrev=0 --match 'v[0-9]*.[0-9]*.[0-9]*' 2>/dev/null || true)"

if [ -n "$last_tag" ]; then
  commit_range="${last_tag}..HEAD"
  current_version="${last_tag#v}"
else
  commit_range="HEAD"
  current_version="0.0.0"
fi

if [ "$(git rev-list --count "$commit_range")" -eq 0 ]; then
  echo "No commits since ${last_tag}: nothing to release."
  exit 0
fi

commit_messages="$(git log --format=%B "$commit_range")"

requests_release_level() {
  grep -Eq "^[[:space:]]*Release:[[:space:]]*$1[[:space:]]*$" <<<"$commit_messages"
}

IFS=. read -r major_number minor_number patch_number <<<"$current_version"

if requests_release_level major; then
  release_level=major
  next_version="$((major_number + 1)).0.0"
elif requests_release_level minor; then
  release_level=minor
  next_version="${major_number}.$((minor_number + 1)).0"
else
  release_level=patch
  next_version="${major_number}.${minor_number}.$((patch_number + 1))"
fi

next_tag="v${next_version}"
echo "Releasing ${next_tag} (${release_level}) from ${current_version}."

for version_file in $version_files; do
  updated_file="$(mktemp)"
  jq --arg version "$next_version" '.version = $version' "$version_file" >"$updated_file"
  cat "$updated_file" >"$version_file"
  rm "$updated_file"
  git add "$version_file"
done

if ! git diff --cached --quiet; then
  git -c user.name="github-actions[bot]" \
    -c user.email="41898282+github-actions[bot]@users.noreply.github.com" \
    commit --message "chore(release): ${next_tag}"
  git push origin HEAD
fi

git tag "$next_tag"
git push origin "$next_tag"
gh release create "$next_tag" --verify-tag --generate-notes

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "version=${next_version}" >>"$GITHUB_OUTPUT"
fi
