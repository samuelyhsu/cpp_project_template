# CPack 运行时经 CPACK_PROJECT_CONFIG_FILE 加载，此时 CPackConfig.cmake 里的 CPACK_* 变量已可用。
# 从组件列表中去掉 zip 已存在的 app，避免覆盖已发布的包。
set(remaining "")
foreach(target IN LISTS CPACK_COMPONENTS_ALL)
    string(TOUPPER "${target}" component)
    set(zip
        "${CPACK_PACKAGE_DIRECTORY}/${CPACK_ARCHIVE_${component}_FILE_NAME}.zip"
    )
    if(EXISTS "${zip}")
        message(STATUS "package: ${zip} already exists, skip ${target}")
    else()
        list(APPEND remaining ${target})
    endif()
endforeach()
# 组件列表为空时 CPack 会退回整体安装、打出 <project>-<version>-<system>.zip，
# 它没有"什么都不打"的成功出口，只能报错退出
if(NOT remaining)
    message(
        FATAL_ERROR
        "package: all zips already exist, nothing to do "
        "(bump APP_VERSION, or delete the zip to repackage)"
    )
endif()
set(CPACK_COMPONENTS_ALL "${remaining}")
