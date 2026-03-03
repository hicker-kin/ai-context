# AI Coding Rules Installer

> **Repository:** https://github.com/hicker-kin/ai-context

This repository provides coding rule files for AI-powered IDEs and helper installer scripts.

## Quick Install via Makefile (Recommended)

Download the `Makefile` into your project root, then use `make` targets to install rules and skills.

```bash
curl -fsSL https://raw.githubusercontent.com/hicker-kin/ai-context/main/Makefile -o Makefile
```

### Common Makefile Targets

| Target | Description |
|--------|-------------|
| `make ai-context-install` | Install all rules (Cursor + Claude) **and** skills in one step |
| `make ai-rules-install` | Install rules for both Cursor and Claude |
| `make ai-skills-install` | Install Cursor skills only |
| `make cursor-rules` | Generate Cursor rules (runs `cursor_rules.sh go`) |
| `make claude-rules` | Generate Claude rules (runs `claude_rules.sh go`) |
| `make cursor-skills` | Generate Cursor skills (runs `cursor_skills.sh go`) |

**Examples:**

```bash
# Install everything (rules + skills) at once
make ai-context-install

# Install rules only
make ai-rules-install

# Install skills only
make ai-skills-install
```

> Scripts are downloaded into a local `scripts/` directory on first run; subsequent runs reuse them.

---

## Manual Install via Shell Scripts

### 🔷 Cursor IDE

**Rules (English)** – Run from the project root:

```bash
curl -fsSL https://raw.githubusercontent.com/hicker-kin/ai-context/main/cursor_rules.sh -o cursor_rules.sh
chmod +x cursor_rules.sh
sh cursor_rules.sh go
```

**Rules (中文)** – 在项目根目录执行：

```bash
curl -fsSL https://raw.githubusercontent.com/hicker-kin/ai-context/main/cursor_rules_zh.sh -o cursor_rules_zh.sh
chmod +x cursor_rules_zh.sh
sh cursor_rules_zh.sh go
```

Both scripts:

- Create `.cursor/rules` and `.ai-context/rules`
- Download `.mdc` summary rules into `.cursor/rules`
- Download full rule documents into `.ai-context/rules`

**Skills** – Run from the project root:

```bash
curl -fsSL https://raw.githubusercontent.com/hicker-kin/ai-context/main/cursor_skills.sh -o cursor_skills.sh
chmod +x cursor_skills.sh
sh cursor_skills.sh go
```

- Creates `.cursor/skills/`
- Downloads the following Go skills (each contains `SKILL.md` + `examples.md`):

| Skill | Description |
|-------|-------------|
| `go-logging` | Structured logging with zap, request context integration |
| `go-jwt` | JWT signing & verification — ES256 / PS256 / RS256 / HS256 |

### 🤖 Claude Code

**Rules (English)** – Run from the project root:

```bash
curl -fsSL https://raw.githubusercontent.com/hicker-kin/ai-context/main/claude_rules.sh -o claude_rules.sh
chmod +x claude_rules.sh
sh claude_rules.sh go
```

**Rules (中文)** – 在项目根目录执行：

```bash
curl -fsSL https://raw.githubusercontent.com/hicker-kin/ai-context/main/claude_rules_zh.sh -o claude_rules_zh.sh
chmod +x claude_rules_zh.sh
sh claude_rules_zh.sh go
```

Both scripts:

- Create `.claude/rules` and `.ai-context/rules`
- Download `.md` summary rules into `.claude/rules`
- Download full rule documents into `.ai-context/rules`
- Create `.claude/CLAUDE.md` with project-level instructions

The `_zh.sh` variant generates a Chinese-first `CLAUDE.md` that references Chinese rule documents as the primary source.

---

## Supported Languages

- `go` (configured)
- `java` (not configured yet)
- `react` (not configured yet)

## Script Overview

| Script | Tool | Language |
|--------|------|----------|
| `cursor_rules.sh` | Cursor IDE | English |
| `cursor_rules_zh.sh` | Cursor IDE | 中文 |
| `claude_rules.sh` | Claude Code | English |
| `claude_rules_zh.sh` | Claude Code | 中文 |
| `cursor_skills.sh` | Cursor IDE | English / 中文 |

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
- `make` (for Makefile installation)
- network access to GitHub raw files
