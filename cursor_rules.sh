#!/usr/bin/env bash
set -euo pipefail

LANGUAGE="${1:-}"
if [[ -z "$LANGUAGE" ]]; then
  echo "Usage: $0 <go|java|react>"
  exit 1
fi

BASE_URL="https://raw.githubusercontent.com/hicker-kin/ai-context/main"

mkdir -p .cursor/rules .ai-context/rules

case "$LANGUAGE" in
  go)
    # 1) mdc rules
    curl -fsSL "$BASE_URL/.cursor/rules/go-code-style.mdc" \
      -o .cursor/rules/go-code-style.mdc
    curl -fsSL "$BASE_URL/.cursor/rules/go-project-architecture.mdc" \
      -o .cursor/rules/go-project-architecture.mdc

    # 2) full rules
    curl -fsSL "$BASE_URL/ai_go/v1/rules/code_style.md" \
      -o .ai-context/rules/code_style.md
    curl -fsSL "$BASE_URL/ai_go/v1/rules/project_architecture.md" \
      -o .ai-context/rules/project_architecture.md
    ;;
  java)
    # TODO: add java rules
    echo "java rules not configured yet"
    exit 1
    ;;
  react)
    # TODO: add react rules
    echo "react rules not configured yet"
    exit 1
    ;;
  *)
    echo "Unknown language: $LANGUAGE"
    exit 1
    ;;
esac

echo "Cursor rules installed for: $LANGUAGE successfully !!!"