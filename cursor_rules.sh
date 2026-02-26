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
    for f in code_style project_architecture code_quality performance testing security documentation; do
      curl -fsSL "$BASE_URL/ai_go/v1/rules/${f}.md" -o .ai-context/rules/${f}.md
      curl -fsSL "$BASE_URL/ai_go/v1/rules/${f}_zh.md" -o .ai-context/rules/${f}_zh.md
    done
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