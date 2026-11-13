# 每个 app 打成一个独立的 zip：<源码根目录>/bin/<app>_v<版本>_<os>_<arch>[_<构建类型>].zip
# 顶层在 add_subdirectory 之前 include 本文件，各 app 调用 add_zip_package()，
# 所有 add_subdirectory 之后调用 finalize_zip_packages()。
# 已存在的同名 zip 不覆盖而是跳过，全部已存在时报错，见 package_skip_existing.cmake。

# 把 target 登记为同名的 CPack 组件，可在任意子目录调用。
# 要随包附带其他文件，用同名 COMPONENT 追加 install 规则，例如
#   install(FILES config.json DESTINATION . COMPONENT <target>)
function(add_zip_package target version)
    install(TARGETS ${target} RUNTIME DESTINATION . COMPONENT ${target})
    # 版本记在 target 属性、target 名记在全局属性，都不受目录作用域限制
    set_property(TARGET ${target} PROPERTY ZIP_PACKAGE_VERSION ${version})
    set_property(GLOBAL APPEND PROPERTY ZIP_PACKAGE_TARGETS ${target})
endfunction()

function(finalize_zip_packages)
    get_property(targets GLOBAL PROPERTY ZIP_PACKAGE_TARGETS)
    if(NOT targets)
        return()
    endif()

    # os / arch 取自三元组（x64-windows-static -> windows / x64）。不用 CPACK_SYSTEM_NAME：
    # 它在 Windows 上只按指针宽度给出 win32 / win64，分不出 x64 和 arm64
    if(NOT VCPKG_TARGET_TRIPLET MATCHES "^([^-]+)-([^-]+)")
        message(
            FATAL_ERROR
            "Invalid VCPKG_TARGET_TRIPLET: ${VCPKG_TARGET_TRIPLET}"
        )
    endif()
    set(suffix "_${CMAKE_MATCH_2}_${CMAKE_MATCH_1}")
    # release 是正式包，不带构建类型后缀
    string(TOLOWER "${CMAKE_BUILD_TYPE}" build_type)
    if(build_type AND NOT build_type STREQUAL "release")
        string(APPEND suffix "_${build_type}")
    endif()

    foreach(target IN LISTS targets)
        get_property(version TARGET ${target} PROPERTY ZIP_PACKAGE_VERSION)
        # 变量名中的组件名必须大写
        string(TOUPPER "${target}" component)
        set(CPACK_ARCHIVE_${component}_FILE_NAME
            "${target}_v${version}${suffix}"
        )
    endforeach()

    # 显式给出组件列表：交给 CPack 自动收集时，只有一个组件会被当作非组件安装，
    # 单 app 项目就会打出 <project>-<version>-<system>.zip
    set(CPACK_COMPONENTS_ALL ${targets})
    set(CPACK_ARCHIVE_COMPONENT_INSTALL ON)
    set(CPACK_GENERATOR ZIP)
    set(CPACK_PACKAGE_DIRECTORY "${PROJECT_SOURCE_DIR}/bin")
    # 默认 zip 内会套一层与包同名的目录
    set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF)
    set(CPACK_PROJECT_CONFIG_FILE
        "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/package_skip_existing.cmake"
    )
    set(CPACK_VERBATIM_VARIABLES ON)
    include(CPack)
endfunction()
