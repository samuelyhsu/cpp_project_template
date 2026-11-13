# 代码质量

<!-- 写格式化、静态检查和提交门禁中配置看不出来的部分：版本如何对齐、每项检查在哪里运行、升级步骤。 -->

## 格式化器版本

格式由配置文件和工具版本共同决定。版本钉在 `.pre-commit-config.yaml` 的 `rev`，以 pre-commit 的结果为准；编辑器格式化器与钩子同版本，保存时才得到同样的结果。

| 文件类型 | 钩子 | 编辑器侧的版本取决于 |
| --- | --- | --- |
| C / C++ | clang-format | 本机安装的 LLVM / clangd |
| CMake | gersemi | PATH 中 pip 安装的 `gersemi` |
| JSON / YAML | prettier | prettier 扩展自带的版本 |
| Markdown | markdownlint-cli2 | markdownlint 扩展自带的版本 |

升级：

1. `pre-commit autoupdate`，或手工改单个钩子的 `rev`。
2. `pre-commit run --all-files`，纯格式化带来的改动单独提交。
3. 编辑器侧对齐：LLVM 升到与 clang-format 钩子相同的版本，`pip install gersemi==<rev>`，更新扩展后核对它自带的版本。编辑器侧先升级时，反过来改钩子的 `rev`。

## 检查在哪里运行

- `git commit`：pre-commit 检查暂存的文件。构建、测试、clang-tidy 太慢，不进钩子，靠 AGENTS.md 的完成标准在本地执行；没有 CI 兜底。
- Claude Code：每次 Write / Edit 后由 `.claude/hooks/format-edited-file.sh` 对该文件运行 pre-commit，需要 bash（Windows 上用 Git Bash）。其他代理没有这个 hook。
- markdownlint：规则都是 warning，不拦截提交，pre-commit 也不显示；查看用 `pre-commit run markdownlint-cli2 --verbose --files <路径>`。
- clang-tidy：clangd 在编辑器里显示结果；`linux-x64-clang-tidy` preset 构建时逐文件检查，告警即错误；其他平台构建后运行 `clang-tidy -p build/<preset> <源文件>`。确需例外时在该行上方加 `// NOLINTNEXTLINE(<检查名>)` 并写明原因。
