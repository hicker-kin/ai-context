#!/usr/bin/env bash
set -euo pipefail

# 用法说明
usage() {
  echo "用法: $0 <go|java|react> [--update] [--zh]"
  echo ""
  echo "参数:"
  echo "  语言      要安装规则的语言 (go|java|react)"
  echo "  --update  更新本地仓库后再安装"
  echo "  --zh      入口文档使用仅中文版（JOYCODE 为中文引导；CLAUDE 模板为中文）"
  echo ""
  echo "IDE 检测（在项目根目录执行）:"
  echo "  存在 .claude  → 仅安装 Claude Code 侧（.claude/rules 简要 + 入口文档）"
  echo "  否则 .cursor  → 仅安装 Cursor 侧（.cursor/rules）"
  echo "  否则 .joycode → 仅安装 JoyCode 侧（.joycode 入口文档）"
  echo "  均不存在      → 默认按 JoyCode 处理（会创建 .joycode）"
  echo ""
  echo "完整规则始终写入 .ai-context/rules/；其他目录仅保留简要或 IDE 格式，详情用 @.ai-context/rules/ 引用。"
  echo ""
  echo "示例:"
  echo "  $0 go              # 安装 Go 规则"
  echo "  $0 go --update     # 更新仓库后安装 Go 规则"
  echo "  $0 go --zh         # 仅中文版入口文档（如 JOYCODE.md）"
  exit 1
}

# 解析参数
LANGUAGE=""
UPDATE=false
ZH_PRIORITY=false

while [[ $# -gt 0 ]]; do
  case $1 in
    go|java|react)
      LANGUAGE="$1"
      shift
      ;;
    --update)
      UPDATE=true
      shift
      ;;
    --zh)
      ZH_PRIORITY=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "未知参数: $1"
      usage
      ;;
  esac
done

if [[ -z "$LANGUAGE" ]]; then
  usage
fi

# 配置
REPO_URL="https://github.com/hicker-kin/ai-context.git"
REPO_DIR="$HOME/.github/ai-context"
CURRENT_DIR=$(pwd)

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

# Step 1: 克隆或更新仓库
setup_repo() {
  # 确保 ~/.github 目录存在
  if [[ ! -d "$HOME/.github" ]]; then
    log_info "创建目录 ~/.github"
    mkdir -p "$HOME/.github"
  fi

  if [[ -d "$REPO_DIR" ]]; then
    if [[ "$UPDATE" == true ]]; then
      log_info "更新本地仓库..."
      cd "$REPO_DIR"
      git pull origin main
      cd "$CURRENT_DIR"
      log_success "仓库已更新"
    else
      log_info "使用本地缓存仓库: $REPO_DIR"
    fi
  else
    log_info "首次安装，克隆仓库到 $REPO_DIR ..."
    git clone "$REPO_URL" "$REPO_DIR"
    log_success "仓库克隆完成"
  fi
}

# 检测当前项目使用的 IDE 规则目标（优先级: Claude > Cursor > JoyCode；无则 JoyCode）
detect_ide() {
  if [[ -d ".claude" ]]; then
    echo "claude"
  elif [[ -d ".cursor" ]]; then
    echo "cursor"
  elif [[ -d ".joycode" ]]; then
    echo "joycode"
  else
    echo "joycode"
  fi
}

# 完整规则复制到 .ai-context/rules（逻辑与原先一致）
install_ai_context_rules() {
  local source_dir="$REPO_DIR/ai_${LANGUAGE}/v1/rules"

  if [[ ! -d "$source_dir" ]]; then
    log_warn "语言 '$LANGUAGE' 的规则尚未配置"
    log_info "目前支持的语言: go"
    exit 1
  fi

  mkdir -p ".ai-context/rules"

  log_info "复制完整规则文档到 .ai-context/rules/ ..."
  shopt -s nullglob
  local md_files=("$source_dir"/*.md)
  shopt -u nullglob
  if [[ ${#md_files[@]} -eq 0 ]]; then
    log_warn "源目录无 .md 文件: $source_dir"
  else
    cp "${md_files[@]}" ".ai-context/rules/"
    local file_count
    file_count=$(ls -1 ".ai-context/rules"/*.md 2>/dev/null | wc -l | tr -d ' ')
    log_success "已复制 $file_count 个文件到 .ai-context/rules/"
  fi
}

# Claude Code：复制仓库内简要 .md，生成 CLAUDE.md（若不存在）
install_claude_bundle() {
  local src_rules="$REPO_DIR/.claude/rules"
  mkdir -p ".claude/rules"

  if [[ ! -d "$src_rules" ]]; then
    log_warn "仓库中无 $src_rules，跳过 .claude/rules 复制"
  else
    shopt -s nullglob
    local brief=("$src_rules"/*.md)
    shopt -u nullglob
    if [[ ${#brief[@]} -eq 0 ]]; then
      log_warn "未找到 $src_rules/*.md"
    else
      cp "${brief[@]}" ".claude/rules/"
      log_success "已复制 ${#brief[@]} 个简要规则到 .claude/rules/"
    fi
  fi

  local config_file=".claude/CLAUDE.md"
  if [[ -f "$config_file" ]]; then
    log_info "$config_file 已存在，跳过生成"
    return
  fi

  log_info "生成 $config_file ..."
  case "$LANGUAGE" in
    go)
      if [[ "$ZH_PRIORITY" == true ]]; then
        cat > "$config_file" <<'EOF'
# 项目规则

本项目遵循 Go 编码规范与清洁架构原则。

## 简要规则（必读）

- @.claude/rules/core-principles.md（每次交互必须遵守）
- @.claude/rules/go-code-style.md
- @.claude/rules/go-project-architecture.md
- @.claude/rules/go-config-style.md
- @.claude/rules/go-http-response.md

## 完整规则文档（英文）

详情见项目内完整副本：

- @.ai-context/rules/core_principles.md
- @.ai-context/rules/code_style.md
- @.ai-context/rules/project_architecture.md
- @.ai-context/rules/config_style.md
- @.ai-context/rules/http_response.md
- @.ai-context/rules/code_quality.md
- @.ai-context/rules/performance.md
- @.ai-context/rules/testing.md
- @.ai-context/rules/security.md
- @.ai-context/rules/documentation.md

## 完整规则文档（中文）

- @.ai-context/rules/core_principles_zh.md
- @.ai-context/rules/code_style_zh.md
- @.ai-context/rules/project_architecture_zh.md
- @.ai-context/rules/config_style_zh.md
- @.ai-context/rules/http_response_zh.md
- @.ai-context/rules/code_quality_zh.md
- @.ai-context/rules/performance_zh.md
- @.ai-context/rules/testing_zh.md
- @.ai-context/rules/security_zh.md
- @.ai-context/rules/documentation_zh.md
EOF
      else
        cat > "$config_file" <<'EOF'
# Project Rules

This project follows Go coding standards and clean architecture principles.

## Summary rules (read first)

- @.claude/rules/core-principles.md (MUST follow in every interaction)
- @.claude/rules/go-code-style.md
- @.claude/rules/go-project-architecture.md
- @.claude/rules/go-config-style.md
- @.claude/rules/go-http-response.md

## Full documentation (English)

- @.ai-context/rules/core_principles.md
- @.ai-context/rules/code_style.md
- @.ai-context/rules/project_architecture.md
- @.ai-context/rules/config_style.md
- @.ai-context/rules/http_response.md
- @.ai-context/rules/code_quality.md
- @.ai-context/rules/performance.md
- @.ai-context/rules/testing.md
- @.ai-context/rules/security.md
- @.ai-context/rules/documentation.md

## Full documentation (中文)

- @.ai-context/rules/core_principles_zh.md
- @.ai-context/rules/code_style_zh.md
- @.ai-context/rules/project_architecture_zh.md
- @.ai-context/rules/config_style_zh.md
- @.ai-context/rules/http_response_zh.md
- @.ai-context/rules/code_quality_zh.md
- @.ai-context/rules/performance_zh.md
- @.ai-context/rules/testing_zh.md
- @.ai-context/rules/security_zh.md
- @.ai-context/rules/documentation_zh.md
EOF
      fi
      ;;
    java|react)
      log_warn "语言 '$LANGUAGE' 的 Claude 简要规则尚未在仓库中配置；已生成仅指向 .ai-context 的入口。"
      cat > "$config_file" <<EOF
# Project Rules

完整规则文档请见：

- @.ai-context/rules/
EOF
      ;;
    *)
      log_warn "未知语言: $LANGUAGE"
      ;;
  esac
  if [[ -f "$config_file" ]]; then
    log_success "已生成 $config_file"
  fi
}

# Cursor：复制仓库内 .mdc（及 README）到 .cursor/rules
install_cursor_bundle() {
  local src_rules="$REPO_DIR/.cursor/rules"
  mkdir -p ".cursor/rules"

  if [[ ! -d "$src_rules" ]]; then
    log_warn "仓库中无 $src_rules，跳过 .cursor/rules 复制"
    return
  fi

  shopt -s nullglob
  local mdc_files=("$src_rules"/*.mdc)
  shopt -u nullglob
  if [[ ${#mdc_files[@]} -gt 0 ]]; then
    cp "${mdc_files[@]}" ".cursor/rules/"
    log_success "已复制 ${#mdc_files[@]} 个 .mdc 到 .cursor/rules/"
  else
    log_warn "未找到 $src_rules/*.mdc"
  fi

  if [[ -f "$src_rules/README.md" ]]; then
    cp "$src_rules/README.md" ".cursor/rules/README.md"
    log_info "已更新 .cursor/rules/README.md"
  fi
}

# JoyCode：不复制完整 md 到 .joycode/rules，仅生成 JOYCODE.md，全部指向 .ai-context/rules
# 语言由安装参数 --zh 决定：有 --zh 则仅中文版；否则仅英文版。传 --zh 时会覆盖已存在的 JOYCODE.md 以与参数一致。
generate_joycode_config() {
  mkdir -p ".joycode"

  local config_file=".joycode/JOYCODE.md"

  if [[ -f "$config_file" && "$ZH_PRIORITY" != true ]]; then
    log_info ".joycode/JOYCODE.md 已存在且未使用 --zh，跳过生成。如需按参数重写：删除该文件后重装；带 --zh 重装可覆盖为仅中文版。"
    return
  fi

  if [[ "$ZH_PRIORITY" == true ]]; then
    log_info "生成 .joycode/JOYCODE.md（参数 --zh：仅中文版引导）..."
    cat > "$config_file" <<'EOF'
# 项目规则

本项目遵循编码规范与清洁架构原则。**完整规则均在 `.ai-context/rules/`，此处仅列入口引用。**

## 规则文件

- @.ai-context/rules/core_principles_zh.md（每次交互必须遵守）
- @.ai-context/rules/code_style_zh.md
- @.ai-context/rules/project_architecture_zh.md
- @.ai-context/rules/config_style_zh.md
- @.ai-context/rules/http_response_zh.md
- @.ai-context/rules/code_quality_zh.md
- @.ai-context/rules/performance_zh.md
- @.ai-context/rules/testing_zh.md
- @.ai-context/rules/security_zh.md
- @.ai-context/rules/documentation_zh.md
EOF
  else
    log_info "生成 .joycode/JOYCODE.md（默认：仅英文版引导）..."
    cat > "$config_file" <<'EOF'
# Project Rules

This project follows coding standards and clean architecture principles.
**Authoritative full text lives under `.ai-context/rules/`; this file lists entry references only.**

## Rule files

- @.ai-context/rules/core_principles.md (MUST follow in every interaction)
- @.ai-context/rules/code_style.md
- @.ai-context/rules/project_architecture.md
- @.ai-context/rules/config_style.md
- @.ai-context/rules/http_response.md
- @.ai-context/rules/code_quality.md
- @.ai-context/rules/performance.md
- @.ai-context/rules/testing.md
- @.ai-context/rules/security.md
- @.ai-context/rules/documentation.md
EOF
  fi

  log_success "已生成 $config_file"
}

install_rules() {
  install_ai_context_rules

  # 单行初始化：在 set -u 下，分行的 `local var` 与 `var=...` 会使 var 在赋值前处于未设置，下一行若展开 $var 会报 “unbound variable”。
  local ide_target="$(detect_ide || echo joycode)"

  log_info "检测到 IDE 规则目标: ${ide_target}（优先级: .claude > .cursor > .joycode；均无则 joycode）"

  case "${ide_target}" in
    claude)
      install_claude_bundle
      ;;
    cursor)
      install_cursor_bundle
      ;;
    joycode)
      generate_joycode_config
      ;;
    *)
      log_warn "未知 detect_ide 结果: ${ide_target}，回退为 joycode"
      generate_joycode_config
      ;;
  esac
}

# 主流程
main() {
  echo ""
  echo "========================================"
  echo "  AI Rules Installer"
  echo "========================================"
  echo ""

  setup_repo
  install_rules

  echo ""
  echo "========================================"
  log_success "规则安装完成！"
  echo "========================================"
  echo ""
  echo "后续步骤："
  echo "  1. 确认 .ai-context/rules/ 已包含完整规则"
  echo "  2. 根据检测到的 IDE 查看对应入口（.claude/CLAUDE.md、.cursor/rules、或 .joycode/JOYCODE.md）"
  echo ""
}

main
