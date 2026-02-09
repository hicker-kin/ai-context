# Claude Code Adaptation Summary

This document summarizes the adaptation work to support Claude Code alongside Cursor IDE.

## What Was Done

### 1. Created Claude-Compatible Rules

**New Files:**

- `.claude/rules/go-code-style.md` - Go code style rules for Claude
- `.claude/rules/go-project-architecture.md` - Go architecture rules for Claude
- `.claude/rules/README.md` - Documentation for Claude rules
- `.claude/CLAUDE.md` - Main project configuration for Claude

**Key Changes from Cursor Format:**

```diff
# Cursor format (.mdc)
---
description: Go code style summary
- globs: **/*.go
- alwaysApply: false
+ paths:
+   - "**/*.go"
---

# For global rules (alwaysApply: true in Cursor)
---
description: Go project architecture rules
- alwaysApply: true
+ # (omit paths field entirely)
---
```

### 2. Created Installation Scripts

**`claude_rules.sh`** - New installer for Claude Code

- Downloads `.md` files to `.claude/rules/`
- Downloads detailed docs to `.ai-context/rules/`
- Creates `.claude/CLAUDE.md` if it doesn't exist
- Provides post-installation guidance

**`convert_to_claude.sh`** - Conversion utility

- Automatically converts `.cursor/rules/*.mdc` to `.claude/rules/*.md`
- Converts `globs:` to `paths:` array format
- Removes `alwaysApply` field
- Preserves all other frontmatter and content

### 3. Updated Documentation

**`README.md`** - Updated main README

- Added section for both Cursor IDE and Claude Code
- Added comparison table of format differences
- Provides usage instructions for both tools

**`MIGRATION.md`** - New migration guide

- Detailed explanation of format differences
- Step-by-step conversion instructions
- Examples of both manual and automated conversion
- Troubleshooting section
- Best practices for supporting both tools

**`CLAUDE_ADAPTATION.md`** - This file

- Summary of all changes
- Quick reference for developers

### 4. Preserved Backward Compatibility

- Original Cursor files unchanged (`.cursor/rules/*.mdc`)
- Shared detailed documentation (`.ai-context/rules/*.md`)
- Both tools can coexist in the same project
- No breaking changes to existing Cursor setup

## Directory Structure (After Adaptation)

```
project/
├── .cursor/                              # Cursor IDE support
│   └── rules/
│       ├── README.md
│       ├── go-code-style.mdc
│       └── go-project-architecture.mdc
│
├── .claude/                              # Claude Code support (NEW)
│   ├── CLAUDE.md                         # Project config
│   └── rules/
│       ├── README.md
│       ├── go-code-style.md
│       └── go-project-architecture.md
│
├── .ai-context/                          # Shared documentation
│   └── rules/
│       ├── code_style.md                 # Detailed rules
│       └── project_architecture.md
│
├── ai_go/                                # Language-specific rules
│   ├── AGENGTS.md
│   └── v1/
│       ├── README.md
│       ├── rules/
│       │   ├── code_style.md
│       │   └── project_architecture.md
│       └── skills/
│
├── cursor_rules.sh                       # Cursor installer
├── claude_rules.sh                       # Claude installer (NEW)
├── convert_to_claude.sh                  # Conversion tool (NEW)
├── README.md                             # Updated
├── MIGRATION.md                          # New
├── CLAUDE_ADAPTATION.md                  # This file (NEW)
└── LICENSE
```

## Usage Examples

### For New Claude Code Users

```bash
# Install rules for a Go project
curl -fsSL https://raw.githubusercontent.com/hicker-kin/ai-context/main/claude_rules.sh -o claude_rules.sh
chmod +x claude_rules.sh
sh claude_rules.sh go
```

### For Existing Cursor Users

```bash
# Option 1: Run Claude installer (downloads fresh copy)
sh claude_rules.sh go

# Option 2: Convert existing Cursor rules
sh convert_to_claude.sh .cursor/rules .claude/rules
```

### Supporting Both Tools

```bash
# Install both
sh cursor_rules.sh go
sh claude_rules.sh go

# Now both Cursor and Claude users can work on the same project!
```

## Format Comparison Quick Reference

| Feature | Cursor IDE | Claude Code |
|---------|-----------|-------------|
| **Directory** | `.cursor/rules/` | `.claude/rules/` |
| **Extension** | `.mdc` | `.md` |
| **File matching** | `globs: **/*.go` | `paths: ["**/*.go"]` |
| **Global rules** | `alwaysApply: true` | Omit `paths` field |
| **References** | `@path/to/file` | `@path/to/file` ✓ Same |
| **Frontmatter** | YAML | YAML ✓ Same |
| **Content** | Markdown | Markdown ✓ Same |

## Testing

Both formats have been tested with:

- ✅ Code style rules with file patterns
- ✅ Architecture rules (global application)
- ✅ File references using `@` syntax
- ✅ Automated conversion script

## Next Steps for Contributors

When adding support for new languages (Java, React, etc.):

1. **Create language-specific rules**
   - Add to `ai_{language}/v1/rules/`

2. **Create Cursor format**
   - Add `.mdc` files to `.cursor/rules/`
   - Update `cursor_rules.sh`

3. **Create Claude format**
   - Add `.md` files to `.claude/rules/`
   - Update `claude_rules.sh`
   - Or use `convert_to_claude.sh` to generate

4. **Update documentation**
   - Update README.md
   - Test both installers

5. **Commit both formats**
   - Maintain parity between Cursor and Claude versions

## Related Files

- [README.md](./README.md) - Main project documentation
- [MIGRATION.md](./MIGRATION.md) - Detailed migration guide
- [.claude/rules/README.md](./.claude/rules/README.md) - Claude rules documentation
- [.cursor/rules/README.md](./.cursor/rules/README.md) - Cursor rules documentation

## Questions?

For issues or suggestions:

- Check [MIGRATION.md](./MIGRATION.md) for troubleshooting
- Review format examples in `.cursor/rules/` and `.claude/rules/`
- Test with the conversion script: `./convert_to_claude.sh`
