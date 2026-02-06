#!/usr/bin/env bash
# Convert Cursor .mdc rules to Claude .md format

set -euo pipefail

INPUT_DIR="${1:-.cursor/rules}"
OUTPUT_DIR="${2:-.claude/rules}"

if [[ ! -d "$INPUT_DIR" ]]; then
  echo "Error: Input directory '$INPUT_DIR' does not exist"
  echo "Usage: $0 [input_dir] [output_dir]"
  echo "Example: $0 .cursor/rules .claude/rules"
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

count=0
for mdc_file in "$INPUT_DIR"/*.mdc; do
  [ -e "$mdc_file" ] || continue

  filename=$(basename "$mdc_file" .mdc)
  md_file="$OUTPUT_DIR/${filename}.md"

  # Convert frontmatter: globs -> paths, remove alwaysApply
  awk '
    BEGIN {
      in_frontmatter=0
      has_frontmatter=0
    }
    /^---$/ {
      if (in_frontmatter == 0) {
        in_frontmatter=1
        has_frontmatter=1
        print $0
        next
      } else {
        in_frontmatter=0
        print $0
        next
      }
    }
    in_frontmatter == 1 {
      # Convert globs to paths array format
      if ($0 ~ /^globs:/) {
        # Extract pattern after "globs:" using sub
        pattern = $0
        sub(/^globs:[[:space:]]*/, "", pattern)
        if (pattern != "") {
          print "paths:"
          print "  - \"" pattern "\""
        }
        next
      }
      # Skip alwaysApply field (both true and false)
      if ($0 ~ /^alwaysApply:/) {
        next
      }
      # Keep other frontmatter fields
      print $0
    }
    in_frontmatter == 0 {
      print $0
    }
  ' "$mdc_file" > "$md_file"

  echo "✓ Converted: $filename.mdc -> $filename.md"
  count=$((count + 1))
done

if [[ $count -eq 0 ]]; then
  echo "No .mdc files found in $INPUT_DIR"
  exit 1
fi

echo ""
echo "Successfully converted $count file(s) to $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "  1. Review the converted files in $OUTPUT_DIR"
echo "  2. Create .claude/CLAUDE.md to reference these rules"
echo "  3. Test with 'claude' command in your project"
