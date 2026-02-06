# Claude Code Rules

This directory contains Claude Code rule files (`.md`) that Claude loads to apply
coding conventions.

## Files
- `go-code-style.md` - Go code style summary, applies to `**/*.go`
- `go-project-architecture.md` - Go architecture rules, always apply

## Full Rule Sources
The `.md` files reference detailed rules from either of these locations
under the project root:

- `.ai-context/rules/`
- `ai_go/v1/rules/`

## Installation
From the project root, run:

```bash
curl -fsSL https://raw.githubusercontent.com/hicker-kin/ai-context/main/claude_rules.sh -o claude_rules.sh
chmod +x claude_rules.sh
sh claude_rules.sh go
```

This downloads `.md` files into `.claude/rules` and full rules into
`.ai-context/rules`.

## Difference from Cursor

Claude Code uses:
- `.claude/rules/*.md` instead of `.cursor/rules/*.mdc`
- `paths: ["**/*.go"]` instead of `globs: **/*.go`
- No `alwaysApply` field (omit `paths` for global rules)
- Same `@path` syntax for file references
