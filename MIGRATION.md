# Migration Guide: Cursor to Claude Code

This guide explains how to adapt Cursor IDE rules for Claude Code.

## Quick Start

If you already have Cursor rules installed, run:

```bash
# Install Claude Code rules alongside Cursor rules
sh claude_rules.sh go
```

Both tools can coexist in the same project!

## Format Differences

### 1. File Extension
- **Cursor**: `.mdc` files
- **Claude**: `.md` files

### 2. Directory Structure
```
project/
├── .cursor/
│   └── rules/
│       ├── go-code-style.mdc        # Cursor format
│       └── go-project-architecture.mdc
├── .claude/
│   ├── CLAUDE.md                     # Claude project config
│   └── rules/
│       ├── go-code-style.md         # Claude format
│       └── go-project-architecture.md
└── .ai-context/
    └── rules/
        ├── code_style.md            # Shared detailed docs
        └── project_architecture.md
```

### 3. YAML Frontmatter

**Cursor format (.mdc):**
```yaml
---
description: Go code style summary
globs: **/*.go
alwaysApply: false
---
```

**Claude format (.md):**
```yaml
---
description: Go code style summary
paths:
  - "**/*.go"
---
```

For global rules (Cursor's `alwaysApply: true`), simply omit the `paths` field:

```yaml
---
description: Go project architecture rules
---
```

### 4. File References

Both use the same `@` syntax:
```markdown
See full rules:
- @.ai-context/rules/code_style.md
- @ai_go/v1/rules/code_style.md
```

## Converting Existing Rules

### Automated Conversion Script

Create a conversion script to transform `.mdc` to `.md`:

```bash
#!/usr/bin/env bash
# convert_to_claude.sh

set -euo pipefail

INPUT_DIR=".cursor/rules"
OUTPUT_DIR=".claude/rules"

mkdir -p "$OUTPUT_DIR"

for mdc_file in "$INPUT_DIR"/*.mdc; do
  [ -e "$mdc_file" ] || continue

  filename=$(basename "$mdc_file" .mdc)
  md_file="$OUTPUT_DIR/${filename}.md"

  # Convert frontmatter
  awk '
    BEGIN { in_frontmatter=0 }
    /^---$/ {
      if (in_frontmatter == 0) {
        in_frontmatter=1
        print $0
        next
      } else {
        in_frontmatter=0
        print $0
        next
      }
    }
    in_frontmatter == 1 {
      if ($0 ~ /^globs:/) {
        # Convert globs to paths array
        sub(/^globs:/, "paths:")
        pattern = $2
        print "  - \"" pattern "\""
        next
      }
      if ($0 ~ /^alwaysApply: true$/) {
        # Skip alwaysApply: true (omit paths instead)
        next
      }
      if ($0 ~ /^alwaysApply: false$/) {
        # Skip alwaysApply: false (default behavior)
        next
      }
      print $0
    }
    in_frontmatter == 0 {
      print $0
    }
  ' "$mdc_file" > "$md_file"

  echo "Converted: $filename.mdc -> $filename.md"
done

echo "Conversion complete!"
```

### Manual Conversion

1. Copy `.cursor/rules/*.mdc` to `.claude/rules/*.md`
2. Update frontmatter:
   - Change `globs: **/*.go` to `paths: ["**/*.go"]`
   - Remove `alwaysApply` field (omit `paths` for global rules)
3. Content remains the same

## Project Configuration

### Cursor: `.cursor/rules/README.md`
Simple documentation only.

### Claude: `.claude/CLAUDE.md`
Main project configuration file:

```markdown
# Project Rules

This project follows Go coding standards.

See detailed rules:
- @.claude/rules/go-code-style.md
- @.claude/rules/go-project-architecture.md

For complete documentation:
- @.ai-context/rules/code_style.md
```

## Best Practices

### 1. Keep Both Formats (Recommended)
Support both tools in your repository:

```
project/
├── .cursor/rules/       # Cursor users
├── .claude/rules/       # Claude users
└── .ai-context/rules/   # Shared documentation
```

Both installers download to `.ai-context/rules/`, so detailed docs are shared.

### 2. Version Control
Add to `.gitignore` if rules are user-specific:
```
.cursor/rules/
.claude/rules/
CLAUDE.local.md
.claude/settings.local.json
```

Or commit them for team-wide standards:
```
# Keep in git
.cursor/rules/
.claude/rules/
.claude/CLAUDE.md
```

### 3. Shared Documentation
Keep detailed rules in `.ai-context/rules/`:
- Both tools reference the same detailed docs
- Update once, benefits both formats
- Easier to maintain consistency

## Testing Your Rules

### Cursor
1. Open project in Cursor IDE
2. Create a `.go` file
3. Check if AI suggestions follow rules

### Claude Code
1. Run `claude` in project directory
2. Ask Claude to review code or write new code
3. Verify it follows the rules

## Troubleshooting

### Rules Not Loading in Claude

1. Check file location:
   ```bash
   ls -la .claude/rules/
   ```

2. Verify frontmatter syntax:
   ```bash
   head -5 .claude/rules/go-code-style.md
   ```

3. Check CLAUDE.md references:
   ```bash
   cat .claude/CLAUDE.md
   ```

4. Run Claude with verbose output:
   ```bash
   claude --verbose
   ```

### Path Patterns Not Matching

Claude uses glob patterns:
- `**/*.go` - All .go files recursively
- `src/**/*.go` - Only under src/
- `**/*_test.go` - All test files
- `{src,lib}/**/*.go` - Multiple directories

## Example: Complete Migration

Starting with Cursor setup:
```bash
# Current structure
.cursor/rules/go-code-style.mdc
.cursor/rules/go-project-architecture.mdc
```

Run Claude installer:
```bash
sh claude_rules.sh go
```

Final structure:
```bash
.cursor/rules/go-code-style.mdc
.cursor/rules/go-project-architecture.mdc
.claude/CLAUDE.md
.claude/rules/go-code-style.md
.claude/rules/go-project-architecture.md
.ai-context/rules/code_style.md
.ai-context/rules/project_architecture.md
```

Now both Cursor and Claude users can use the same project!

## Contributing

When adding new language support:

1. Add rules to `ai_{language}/v1/rules/`
2. Create `.cursor/rules/{language}-*.mdc` files
3. Create `.claude/rules/{language}-*.md` files
4. Update both installer scripts
5. Test with both tools
6. Update README.md

## Further Reading

- [Cursor Rules Documentation](https://cursor.sh/docs)
- [Claude Code Rules Documentation](https://docs.anthropic.com/claude-code)
- [Project Architecture Guide](./ai_go/v1/rules/project_architecture.md)
