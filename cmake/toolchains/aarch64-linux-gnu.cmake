# linux-arm64 preset 经 VCPKG_CHAINLOAD_TOOLCHAIN_FILE 加载，只作用于项目自身；
# vcpkg 构建依赖时用的是它自带的 scripts/toolchains/linux.cmake。
# 判断条件和编译器名与 vcpkg 的那份保持一致，保证项目与依赖用同一套交叉编译器：
# 在 aarch64 主机上什么都不做（本机编译），在其他 Linux 主机上用 aarch64-linux-gnu-*。

set(CMAKE_SYSTEM_PROCESSOR aarch64)
if(
    CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux"
    AND NOT CMAKE_HOST_SYSTEM_PROCESSOR STREQUAL CMAKE_SYSTEM_PROCESSOR
)
    set(CMAKE_SYSTEM_NAME Linux)
    set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
    set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)
endif()
