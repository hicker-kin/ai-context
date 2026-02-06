# AI Coding Rules Installer

This repository provides coding rule files for AI-powered IDEs and a helper installer script.

## Supported AI Tools

### 🔷 Cursor IDE
Run the installer from the project root:

```bash
curl -fsSL https://raw.githubusercontent.com/hicker-kin/ai-context/main/cursor_rules.sh -o cursor_rules.sh
chmod +x cursor_rules.sh
sh cursor_rules.sh go
```

What it does:
- Creates `.cursor/rules` and `.ai-context/rules`
- Downloads `.mdc` files into `.cursor/rules`
- Downloads full rule documents into `.ai-context/rules`

### 🤖 Claude Code
Run the installer from the project root:

```bash
curl -fsSL https://raw.githubusercontent.com/hicker-kin/ai-context/main/claude_rules.sh -o claude_rules.sh
chmod +x claude_rules.sh
sh claude_rules.sh go
```

What it does:
- Creates `.claude/rules` and `.ai-context/rules`
- Downloads `.md` files into `.claude/rules`
- Downloads full rule documents into `.ai-context/rules`
- Creates `.claude/CLAUDE.md` with project-level instructions

## Supported Languages
- `go` (configured)
- `java` (not configured yet)
- `react` (not configured yet)

## File Format Comparison

| Feature | Cursor IDE | Claude Code |
|---------|-----------|-------------|
| Rules directory | `.cursor/rules/` | `.claude/rules/` |
| File format | `.mdc` | `.md` |
| File matching | `globs: **/*.go` | `paths: ["**/*.go"]` |
| Global rules | `alwaysApply: true` | Omit `paths` field |
| File references | `@path/to/file` | `@path/to/file` |

## Requirements
- `curl`
- network access to GitHub raw files
