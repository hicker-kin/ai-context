#!/usr/bin/env bash
set -euo pipefail

LANGUAGE="${1:-}"
if [[ -z "$LANGUAGE" ]]; then
  echo "Usage: $0 <go|java|react>"
  exit 1
fi

BASE_URL="https://raw.githubusercontent.com/hicker-kin/ai-context/main"

# Go skills to install (directory names under .cursor/skills/)
GO_SKILLS="go-logging go-jwt"

# React skills to install (directory names under .cursor/skills/)
REACT_SKILLS="frontend-architecture"

# React skill sub-files to download (relative to skill dir)
REACT_SKILL_FILES="SKILL.md stacks.md templates/nextjs.md templates/vite-spa.md templates/astro.md"

mkdir -p .cursor/skills

case "$LANGUAGE" in
  go)
    for skill in $GO_SKILLS; do
      mkdir -p ".cursor/skills/${skill}"
      curl -fsSL "$BASE_URL/.cursor/skills/${skill}/SKILL.md" \
        -o ".cursor/skills/${skill}/SKILL.md"
      curl -fsSL "$BASE_URL/.cursor/skills/${skill}/examples.md" \
        -o ".cursor/skills/${skill}/examples.md"
    done
    ;;
  java)
    # TODO: add java skills
    echo "java skills not configured yet"
    exit 1
    ;;
  react)
    for skill in $REACT_SKILLS; do
      for file in $REACT_SKILL_FILES; do
        dir=".cursor/skills/${skill}/$(dirname "$file")"
        mkdir -p "$dir"
        curl -fsSL "$BASE_URL/.cursor/skills/${skill}/${file}" \
          -o ".cursor/skills/${skill}/${file}"
      done
    done
    ;;
  *)
    echo "Unknown language: $LANGUAGE"
    exit 1
    ;;
esac

echo "Cursor skills installed for: $LANGUAGE successfully !!!"
