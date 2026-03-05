# Claude Code Rules

This directory contains Claude Code rule files (`.md`) that Claude loads to apply
coding conventions.

## Files

- `core-principles.md` - Core principles (no speculation, confirm first, YAGNI), always apply
- `go-code-style.md` - Go code style summary, applies to `**/*.go`
- `go-project-architecture.md` - Go architecture rules, always apply
- `go-config-style.md` - Config struct and YAML annotation rules, applies to `**/config*.go`, `**/config*.yaml`, `**/config*.yml`

## Full Rule Sources

The `.md` files reference detailed rules from either of these locations
under the project root:

- `.ai-context/rules/`
- `ai_go/v1/rules/`

Chinese versions (`*_zh.md`) are available under `ai_go/v1/rules/` or `.ai-context/rules/` (e.g. `code_style_zh.md`). In third-party projects, use `.ai-context/rules/`.

## Installation

From the project root, run:

```bash
curl -fsSL https://git.restosuite.cn/devops-pub/ai-context/-/raw/main/claude_rules.sh -o claude_rules.sh
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
