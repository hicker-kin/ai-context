#!/usr/bin/env bash
set -euo pipefail

LANGUAGE="${1:-}"
if [[ -z "$LANGUAGE" ]]; then
  echo "Usage: $0 <go|java|react>"
  exit 1
fi

BASE_URL="https://raw.githubusercontent.com/hicker-kin/ai-context/main"

# Go rule files (without .md) to download into .ai-context/rules/
GO_RULE_FILES="core_principles code_style project_architecture code_quality performance testing security documentation"

mkdir -p .claude/rules .ai-context/rules

case "$LANGUAGE" in
  go)
    # 1) Claude rules (.md format for .claude/rules/)
    curl -fsSL "$BASE_URL/.claude/rules/core-principles.md" \
      -o .claude/rules/core-principles.md
    curl -fsSL "$BASE_URL/.claude/rules/go-code-style.md" \
      -o .claude/rules/go-code-style.md
    curl -fsSL "$BASE_URL/.claude/rules/go-project-architecture.md" \
      -o .claude/rules/go-project-architecture.md

    # 2) Full rules (detailed documentation)
    for f in $GO_RULE_FILES; do
      curl -fsSL "$BASE_URL/ai_go/v1/rules/${f}.md" -o .ai-context/rules/${f}.md
      curl -fsSL "$BASE_URL/ai_go/v1/rules/${f}_zh.md" -o .ai-context/rules/${f}_zh.md
    done

    # 3) CLAUDE.md (force overwrite)
    cat > .claude/CLAUDE.md <<'EOF'
# Project Rules

This project follows Go coding standards and clean architecture principles.

See detailed rules:
- @.claude/rules/core-principles.md (MUST follow in every interaction)
- @.claude/rules/go-code-style.md
- @.claude/rules/go-project-architecture.md

For complete documentation:
- @.ai-context/rules/core_principles.md
- @.ai-context/rules/code_style.md
- @.ai-context/rules/project_architecture.md
- @.ai-context/rules/core_principles_zh.md (中文版)
- @.ai-context/rules/code_style_zh.md (中文版)
- @.ai-context/rules/project_architecture_zh.md (中文版)
EOF
    echo "Updated .claude/CLAUDE.md"
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

echo "Claude Code rules installed for: $LANGUAGE successfully !!!"
echo ""
echo "Next steps:"
echo "  1. Review .claude/CLAUDE.md for project-level instructions"
echo "  2. Run 'claude /init' to analyze your project and enhance rules"
echo "  3. Start using Claude Code with your project-specific rules"
