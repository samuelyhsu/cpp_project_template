# 3.22 是 Ubuntu 22.04 软件源的版本，只用它已有的功能：CMakePresets.json 保持 version 3
# （workflow preset 要 version 6，即 CMake 3.25）；不用 block()（3.25），隔离变量作用域改用 function()。
# 提高版本时同步改 presets 的 version，并删掉下文按 CMAKE_VERSION 做的兼容。
cmake_minimum_required(VERSION 3.22)

# 平台相关的配置（生成器、vcpkg 三元组、编译器、MSVC 运行库、警告视为错误）都在
# CMakePresets.json，这里只放与平台无关、或必须在 project() 之前完成的部分。
# 工具链文件（vcpkg）在第一次 project() 时才加载，下面几步必须排在它前面。

if(DEFINED CMAKE_TOOLCHAIN_FILE AND NOT EXISTS "${CMAKE_TOOLCHAIN_FILE}")
    message(
        FATAL_ERROR
        "${CMAKE_TOOLCHAIN_FILE} not found, "
        "run: git submodule update --init --recursive"
    )
endif()
include(cmake/check_vcpkg_baseline.cmake)

# macOS 的架构与部署目标以 overlay triplet 为准，项目自身与 vcpkg 依赖保持一致。
# 在函数里 include，triplet 设置的 VCPKG_* 变量不会泄漏到顶层、影响随后加载的 vcpkg 工具链
function(sync_osx_settings_from_triplet triplet_file)
    include("${triplet_file}")
    set(CMAKE_OSX_ARCHITECTURES
        "${VCPKG_OSX_ARCHITECTURES}"
        CACHE STRING
        ""
        FORCE
    )
    set(CMAKE_OSX_DEPLOYMENT_TARGET
        "${VCPKG_OSX_DEPLOYMENT_TARGET}"
        CACHE STRING
        ""
        FORCE
    )
endfunction()
if(
    VCPKG_TARGET_TRIPLET MATCHES "-osx$"
    AND EXISTS "${CMAKE_SOURCE_DIR}/cmake/triplets/${VCPKG_TARGET_TRIPLET}.cmake"
)
    sync_osx_settings_from_triplet(
        "${CMAKE_SOURCE_DIR}/cmake/triplets/${VCPKG_TARGET_TRIPLET}.cmake"
    )
endif()

# 不设项目版本：各 app 独立发版，版本号在 apps/<app>/CMakeLists.txt 的 APP_VERSION
project(cpp_project_template LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Release / RelWithDebInfo / MinSizeRel 也保留 assert：断言表达的不变式在线上同样要成立。
# 默认标志里 MSVC 写作 /DNDEBUG，GCC/Clang 写作 -DNDEBUG，正则同时匹配两种
foreach(lang C CXX)
    foreach(config RELEASE MINSIZEREL RELWITHDEBINFO)
        string(
            REGEX REPLACE "[-/]D[ ]?NDEBUG"
            ""
            CMAKE_${lang}_FLAGS_${config}
            "${CMAKE_${lang}_FLAGS_${config}}"
        )
    endforeach()
endforeach()

# 以下作用于本仓库定义的所有 target；vcpkg 依赖是 IMPORTED target，不受影响
if(MSVC)
    add_compile_options(
        /W4
        # 源码是无 BOM 的 UTF-8，不加 /utf-8 时 MSVC 按系统代码页（如 GBK）解析
        /utf-8
        # 重度使用模板库的翻译单元会超出 .obj 默认 65,279 个段的上限，报 C1128
        /bigobj
        # 只有 /std:c++20 及以上才隐含 /permissive-，C++17 下要显式开启标准符合模式
        $<$<COMPILE_LANGUAGE:CXX>:/permissive->
        # 不加时 __cplusplus 恒为 199711L，/permissive- 也不会改变它
        $<$<COMPILE_LANGUAGE:CXX>:/Zc:__cplusplus>
    )
    add_compile_definitions(
        # windows.h 的 min/max 宏会破坏 std::min / std::max
        NOMINMAX
        # 最低支持 Windows 10；不定义时 Asio 等库会自行假定一个更老的版本（Asio 假定 Windows 7）
        _WIN32_WINNT=0x0A00
    )
else()
    add_compile_options(
        -Wall
        -Wextra
        -Wpedantic
        -Wshadow
        -Wconversion
        -Wsign-conversion
        $<$<COMPILE_LANGUAGE:CXX>:-Wnon-virtual-dtor>
        $<$<COMPILE_LANGUAGE:CXX>:-Woverloaded-virtual>
        $<$<COMPILE_LANGUAGE:CXX>:-Wold-style-cast>
    )
endif()

# CMAKE_COMPILE_WARNING_AS_ERROR 从 CMake 3.24 起由 CMake 自己处理，更早的版本在这里补上
if(CMAKE_COMPILE_WARNING_AS_ERROR AND CMAKE_VERSION VERSION_LESS 3.24)
    if(MSVC)
        add_compile_options(/WX)
    else()
        add_compile_options(-Werror)
    endif()
endif()

include(cmake/package.cmake)

add_subdirectory(src)
add_subdirectory(apps)

option(BUILD_TESTING "Build unit tests" ${PROJECT_IS_TOP_LEVEL})
if(BUILD_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()

finalize_zip_packages()
