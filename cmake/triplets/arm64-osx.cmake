# 覆盖 vcpkg 内置的 arm64-osx，只多固定一项部署目标（最低支持的 macOS 版本）。
# 不固定时 clang 取构建机的系统版本，产物只能在同版本或更新的系统上运行。
# 顶层 CMakeLists.txt 读取本文件，让项目自身与依赖使用同一部署目标。
# 11.0 是首个支持 Apple Silicon 的版本，写更低的值也会被抬到 11.0。

set(VCPKG_TARGET_ARCHITECTURE arm64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

set(VCPKG_CMAKE_SYSTEM_NAME Darwin)
set(VCPKG_OSX_ARCHITECTURES arm64)
set(VCPKG_OSX_DEPLOYMENT_TARGET 11.0)
