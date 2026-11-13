# 构建系统

<!-- 写构建系统中代码和配置看不出来的部分：设计原因、必须一起改的设置、已知的坑。命令写进 README，只关乎单个文件的说明写在该文件的注释里。 -->

## Preset

- 始终经 preset 构建：平台相关的设置（编译器、三元组、MSVC 运行库、警告即错误）都在 `CMakePresets.json`，手工 `cmake -S . -B` 要自己补齐。
- Windows preset 固定用 `cl`，免得 CMake 选中 PATH 里的 clang 或 gcc。`architecture` / `toolset` 设为 `external`，VS Code CMake Tools 和 Visual Studio 会自动进入 x64 开发者环境；命令行下要先自己进入。
- `linux-x64-asan` 只插桩本仓库的代码；vcpkg 按三元组单独编译依赖，不带这些标志。

## 三元组与链接方式

- Windows：三元组 `x64-windows-static` 与 `CMAKE_MSVC_RUNTIME_LIBRARY` 都用静态 CRT，两处一起改，否则链接报 `LNK2038 RuntimeLibrary` 不匹配。
- Linux：依赖静态链接，C/C++ 运行库动态链接，产物要求目标机的 glibc 不低于构建机；要兼容更老的发行版，在老系统或其容器里构建。不用 `-static`：静态链接的 glibc 用到 `getaddrinfo` 等 NSS 功能时，运行时仍需与构建时同版本的共享库。
- 新增交叉编译目标（如 armv7）：照 `linux-arm64` 在 `cmake/toolchains/` 加工具链文件，按需加 overlay triplet，再加 preset。

## 打包

- `package` 目标把每个调用了 `add_zip_package` 的 app 打成独立的 zip，app 数量是一个还是多个都适用。命名规则和用法见 `cmake/package.cmake` 开头的注释。
- zip 输出到源码根目录的 `bin/`，不放在构建目录里，这样各 preset 的包汇集在一处。`bin/_CPack_Packages/` 是 CPack 的暂存目录。
- 已存在的同名 zip 会被跳过而不是覆盖，免得冲掉已发布的包；所有包都已存在时 `package` 目标报错退出。所以改了 app 要先提升它的 `APP_VERSION`，否则要先删掉对应的 zip 再打包。`linux-x64-asan`、`linux-x64-clang-tidy` 与 `linux-x64-debug` 的包同名，先打出的那个会让后面两个被跳过。
- 打包按组件进行，所以每条 `install()` 都要带 `COMPONENT <app>`，否则会多出一个 `Unspecified` 包。

## 已知的坑

- 顶层 `CMakeLists.txt` 去掉了 Release 类构建的 `NDEBUG`，所以本仓库代码 include 的头文件库（如 Eigen）的断言也会生效，热路径上要留意开销。vcpkg 编译出的依赖库不受影响，其 Release 版仍定义 `NDEBUG`。
- Windows 上把仓库放在短路径下：`build/<preset>` 加 vcpkg 的构建目录层级很深，超过 260 字符时 MSVC 报 `C1083`。
- clangd 从 `build/<preset>/compile_commands.json` 读编译参数；VS Code 之外的编辑器给 clangd 传 `--compile-commands-dir=build/<preset>`。
