# AGENTS.md

<!-- 写给所有代理，每轮都加载：完成标准、改动放哪里、代码看不出的约束、按需阅读的指针。只放多数任务需要的内容。 -->

C/C++ 工程：CMake + CMakePresets + vcpkg（子模块），pre-commit 统一格式。
动手前读 [ARCHITECTURE.md](ARCHITECTURE.md)；构建命令见 [README.md](README.md)。

## 完成标准

一项改动完成，当且仅当下面两条都通过：

1. `cmake --preset <p> && cmake --build --preset <p> && ctest --preset <p>`，`<p>` 为 `windows-x64-debug` / `linux-x64-debug` / `osx-arm64-debug`，警告即错误。Windows 下先进入 VS x64 开发者环境，否则 MSVC 找不到标准头文件。
2. `pre-commit run --files <本次改动和新增的文件>`：钩子改了文件就再跑，直到全部 Passed。`--all-files` 只覆盖已跟踪文件，会漏掉新文件。

行为改动配测试；结构、数据流或特性行为变了，同一改动里更新 ARCHITECTURE.md 和对应的 `docs/` 文档；改动影响到某个 app 时，记入 `apps/<app>/CHANGELOG.md` 的 `## [Unreleased]`；改了 `src/` 的库，逐个检查链接它的 app，受影响的都要记。不影响任何 app 的改动（构建、工具链、规范）只写进提交信息。

## 改动放哪里

- 模块：`src/` 下平铺 `.cpp` / `.hpp`（C 用 `.c` / `.h`），头文件按文件名引用。每个模块在 `src/CMakeLists.txt` 定义一个库和 `<name>::<name>` 别名，其他 target 按别名链接。
- 测试：`tests/<模块>_test.cpp`，加进 `tests/CMakeLists.txt` 的 `unit_tests` 并链接被测模块。
- 可执行程序：`apps/<app>/`，只做参数解析和组装，逻辑放进库里才能测试。要发布的 app 调用 `add_zip_package`（`cmake/package.cmake`）。
- 第三方依赖：只经 vcpkg 引入。
- 平台、编译器、三元组相关的设置：`CMakePresets.json`；对所有 target 生效的编译选项：顶层 `CMakeLists.txt`。

## 约束

- CMake 最低 3.22，只用 3.22 已有的功能，限制见顶层 `CMakeLists.txt` 开头。
- `vcpkg/` 是上游子模块，保持原样；`vcpkg.json` 的 `builtin-baseline` 始终等于它的提交，由 `cmake/check_vcpkg_baseline.cmake` 校验。
- 格式交给 pre-commit 钩子；钩子或检查失败时修问题本身。
- `assert` 在所有构建类型下都生效，Release 也一样，按线上会触发来写断言。
- 命名约定见 `.clang-tidy` 的 `readability-identifier-naming`。
- 注释可以用中文；字符串字面量、标识符、日志和错误信息只用 ASCII。

## 按需阅读

- [docs/build-system.md](docs/build-system.md)：改 preset、三元组、交叉编译时
- [docs/code-quality.md](docs/code-quality.md)：改格式化、clang-tidy 或 pre-commit 钩子时
