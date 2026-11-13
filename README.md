# cpp_project_template

<!-- 写给团队成员：项目是什么，怎么构建、使用、配置，发布策略。结构与设计写进 ARCHITECTURE.md。 -->

C/C++ 跨平台工程模板：CMake + CMakePresets + vcpkg（子模块）+ pre-commit，Windows（MSVC）、Linux（GCC/Clang，含 arm64 交叉编译）、macOS（AppleClang）共用一套命令。

## 用模板创建新项目

1. GitHub 上用 "Use this template" 创建仓库；或 `git clone --recursive` 后把 `origin` 指向新仓库。
2. 改顶层 `CMakeLists.txt` 中 `project()` 的名称。
3. 用自己的代码替换示例：`src/` 下的 `crc16.*`、`checksum.*`，`tests/checksum_test.cpp`，`apps/crc16sum/`、`apps/crc16file/`，同步改这几个目录的 `CMakeLists.txt` 和 ARCHITECTURE.md 的代码地图。
4. 重写本 README 的介绍并删掉本节；本模板以 MIT 发布，按新项目的需要处理 `LICENSE`。

## 环境要求

- CMake 3.22+、Ninja
- C++17 编译器：Windows 上 Visual Studio（MSVC），Linux 上 GCC 或 Clang，macOS 上 Xcode 命令行工具
- Git、pre-commit 4.4+（`pip install pre-commit`）
- 交叉编译 Linux arm64：`aarch64-linux-gnu-gcc` / `-g++`

## 首次准备

```bash
git clone --recursive <仓库地址>   # 已克隆的：git submodule update --init --recursive
pre-commit install
```

vcpkg 子模块不能浅克隆：vcpkg 按 baseline 从它的 git 历史取端口版本。VS Code 用户安装工作区推荐的扩展（`.vscode/extensions.json`）。

## 构建与测试

preset 名为 `<os>-<arch>-<debug|release>`，`cmake --list-presets` 列出本机可用的。Windows 上在 VS x64 开发者环境中执行。

```bash
cmake --preset linux-x64-debug
cmake --build --preset linux-x64-debug
ctest --preset linux-x64-debug
cmake --build --preset linux-x64-release --target package   # 打包 zip
```

产物在 `build/<preset>/`。每个 app 打成一个 zip，输出到 `bin/<app>_v<版本>_<os>_<arch>[_<构建类型>].zip`，release 包不带构建类型后缀。已存在的同名包会被跳过而不是覆盖，所有包都已存在时 `package` 报错退出；需要重新打包时先删掉对应的 zip。首次 configure 从源码编译依赖，之后命中 vcpkg 二进制缓存。

## 配置

- 个人 preset 写在 `CMakeUserPresets.json`（已被 git 忽略），继承已有 preset。
- configure 时加 `-DBUILD_TESTING=OFF` 不构建测试，加 `-DCMAKE_COMPILE_WARNING_AS_ERROR=ON` 把编译警告视为错误。

## 发布

各 app 独立发版，版本号只写在 `apps/<app>/CMakeLists.txt` 的 `APP_VERSION`，同时用于 `--version` 输出和 zip 文件名。每个 app 在 `apps/<app>/CHANGELOG.md` 记录自己的改动。发布时，`[Unreleased]` 非空的 app 都要提升 `APP_VERSION`，并把这些条目移到 `## [<版本>] - <YYYY-MM-DD>`。漏升的 app 打包时会因同名 zip 已存在而被跳过，bin 里只留下旧包。
