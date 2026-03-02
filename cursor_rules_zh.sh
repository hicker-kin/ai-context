#!/usr/bin/env bash
set -euo pipefail

LANGUAGE="${1:-}"
if [[ -z "$LANGUAGE" ]]; then
  echo "用法: $0 <go|java|react>"
  exit 1
fi

BASE_URL="https://raw.githubusercontent.com/hicker-kin/ai-context/main"

# Go 规则文件名（不含 .md 后缀），同时下载英文版和中文版到 .ai-context/rules/
GO_RULE_FILES="core_principles code_style project_architecture code_quality performance testing security documentation config_style http_response"

mkdir -p .cursor/rules .ai-context/rules

case "$LANGUAGE" in
  go)
    # 1) 下载 Cursor mdc 摘要规则
    curl -fsSL "$BASE_URL/.cursor/rules/core-principles.mdc" \
      -o .cursor/rules/core-principles.mdc
    curl -fsSL "$BASE_URL/.cursor/rules/go-code-style.mdc" \
      -o .cursor/rules/go-code-style.mdc
    curl -fsSL "$BASE_URL/.cursor/rules/go-project-architecture.mdc" \
      -o .cursor/rules/go-project-architecture.mdc
    curl -fsSL "$BASE_URL/.cursor/rules/go-config-style.mdc" \
      -o .cursor/rules/go-config-style.mdc
    curl -fsSL "$BASE_URL/.cursor/rules/go-http-response.mdc" \
      -o .cursor/rules/go-http-response.mdc

    # 2) 下载完整规则文档（英文版 + 中文版）
    for f in $GO_RULE_FILES; do
      curl -fsSL "$BASE_URL/ai_go/v1/rules/${f}.md" -o .ai-context/rules/${f}.md
      curl -fsSL "$BASE_URL/ai_go/v1/rules/${f}_zh.md" -o .ai-context/rules/${f}_zh.md
    done
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

echo "Cursor 规则安装成功（语言: $LANGUAGE）!!!"
