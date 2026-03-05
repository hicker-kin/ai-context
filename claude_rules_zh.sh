#!/usr/bin/env bash
set -euo pipefail

LANGUAGE="${1:-}"
if [[ -z "$LANGUAGE" ]]; then
  echo "用法: $0 <go|java|react>"
  exit 1
fi

BASE_URL="https://git.restosuite.cn/universe/ai-context/-/raw/main"

# Go 规则文件名（不含 .md 后缀），同时下载英文版和中文版到 .ai-context/rules/
GO_RULE_FILES="core_principles code_style project_architecture code_quality performance testing security documentation config_style http_response"

mkdir -p .claude/rules .ai-context/rules

case "$LANGUAGE" in
  go)
    # 1) 下载 Claude 规则摘要（.md 格式）
    curl -fsSL "$BASE_URL/.claude/rules/core-principles.md" \
      -o .claude/rules/core-principles.md
    curl -fsSL "$BASE_URL/.claude/rules/go-code-style.md" \
      -o .claude/rules/go-code-style.md
    curl -fsSL "$BASE_URL/.claude/rules/go-project-architecture.md" \
      -o .claude/rules/go-project-architecture.md
    curl -fsSL "$BASE_URL/.claude/rules/go-config-style.md" \
      -o .claude/rules/go-config-style.md
    curl -fsSL "$BASE_URL/.claude/rules/go-http-response.md" \
      -o .claude/rules/go-http-response.md

    # 2) 下载完整规则文档（英文版 + 中文版）
    for f in $GO_RULE_FILES; do
      curl -fsSL "$BASE_URL/ai_go/v1/rules/${f}.md" -o .ai-context/rules/${f}.md
      curl -fsSL "$BASE_URL/ai_go/v1/rules/${f}_zh.md" -o .ai-context/rules/${f}_zh.md
    done

    # 3) 生成 CLAUDE.md（中文优先）
    cat > .claude/CLAUDE.md <<'EOF'
# 项目规则

本项目遵循 Go 编码规范与清洁架构原则。

## 规则文件

- @.claude/rules/core-principles.md（每次交互必须遵守）
- @.claude/rules/go-code-style.md
- @.claude/rules/go-project-architecture.md
- @.claude/rules/go-config-style.md
- @.claude/rules/go-http-response.md

## 完整规则文档（中文版，优先参考）

- @.ai-context/rules/core_principles_zh.md
- @.ai-context/rules/code_style_zh.md
- @.ai-context/rules/project_architecture_zh.md
- @.ai-context/rules/config_style_zh.md
- @.ai-context/rules/http_response_zh.md

## 完整规则文档（English）

- @.ai-context/rules/core_principles.md
- @.ai-context/rules/code_style.md
- @.ai-context/rules/project_architecture.md
- @.ai-context/rules/config_style.md
- @.ai-context/rules/http_response.md
EOF
    echo "已生成 .claude/CLAUDE.md（中文优先）"
    ;;
  java)
    echo "Java 规则暂未配置"
    exit 1
    ;;
  react)
    echo "React 规则暂未配置"
    exit 1
    ;;
  *)
    echo "未知语言: $LANGUAGE"
    exit 1
    ;;
esac

echo "Claude Code 规则安装成功（语言: $LANGUAGE）!!!"
echo ""
echo "后续步骤："
echo "  1. 查看 .claude/CLAUDE.md 确认项目级规则配置"
echo "  2. 执行 'claude /init' 让 Claude 分析项目并增强规则"
echo "  3. 开始使用 Claude Code，AI 将遵循以上规则"
