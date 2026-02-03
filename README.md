# Cursor Rules Installer

This repository provides Cursor rule files and a helper installer script.

## Usage
Run the installer from the project root:

```
curl -fsSL https://raw.githubusercontent.com/hicker-kin/ai-context/main/cursor_rules.sh -o cursor_rules.sh
chmod +x cursor_rules.sh
sh cursor_rules.sh go
```

## What the Script Does
- Creates `.cursor/rules` and `.ai-context/rules`
- Downloads `.mdc` files into `.cursor/rules`
- Downloads full rule documents into `.ai-context/rules`

## Supported Languages
- `go` (configured)
- `java` (not configured yet)
- `react` (not configured yet)

## Requirements
- `curl`
- network access to GitHub raw files
