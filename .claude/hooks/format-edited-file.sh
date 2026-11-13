#!/usr/bin/env bash
# Claude Code 的 PostToolUse 钩子（注册在 .claude/settings.json）：Write / Edit 之后
# 对该文件运行 pre-commit，代理接着在与提交时相同的格式上工作。
# 退出码按 Claude Code 的约定：0 通过且不出声；2 把 stderr 交给 Claude 修复；
# 其他非零值只在界面上提示用户。
set -u

# 输入是 Claude Code 生成的单行 JSON，文件内容里的引号都转义成了 \"，只有真正的
# "file_path" 键能匹配。不用 jq / python：它们在各平台上不一定有，可执行文件名也不统一。
file=$(sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)
# Windows 路径以反斜杠分隔，在 JSON 里写作 \\
file=${file//\\\\//}
[ -f "$file" ] || exit 0
dir=${file%/*}

# 只处理带 pre-commit 配置的仓库里未被忽略的文件；子模块（如 vcpkg/）是上游代码，保持原样
top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -z "$(git -C "$dir" rev-parse --show-superproject-working-tree)" ] || exit 0
[ -f "$top/.pre-commit-config.yaml" ] || exit 0
rel=$(git -C "$dir" rev-parse --show-prefix)${file##*/}
cd "$top" || exit 1
git check-ignore -q -- "$rel" && exit 0

if ! command -v pre-commit >/dev/null 2>&1; then
    echo "pre-commit not found on PATH, $rel was not formatted" >&2
    exit 1
fi
# vcpkg-baseline 比较的是暂存区，与刚编辑的文件无关，且在升级 vcpkg 的中途必然失败
export SKIP="${SKIP:+$SKIP,}vcpkg-baseline"
# --color never 管不到钩子自己的输出（如 prettier），颜色码会混进交给 Claude 的文字
export NO_COLOR=1
# 格式化器改了文件时 pre-commit 也返回 1，所以再跑一次：仍然失败的才是需要修的问题
pre-commit run --color never --files "$rel" >/dev/null 2>&1 && exit 0
out=$(pre-commit run --color never --files "$rel" 2>&1) && exit 0
printf '%s\n' "$out" >&2
exit 2
