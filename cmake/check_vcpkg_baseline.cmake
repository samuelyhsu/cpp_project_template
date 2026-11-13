# 检查 vcpkg.json 的 builtin-baseline 是否等于 vcpkg 子模块的提交，让"用的是哪一版 vcpkg"只有
# 一个答案：两者错开时 vcpkg 要么报难懂的版本解析错误，要么静默沿用旧版本。两种用法：
#   include()：configure 时比较子模块当前检出的提交，拦住拉代码后忘了 git submodule update
#   cmake -P：pre-commit 时比较暂存区里的子模块提交，拦住升级了子模块却没同步 baseline

function(check_vcpkg_baseline)
    cmake_path(GET CMAKE_CURRENT_FUNCTION_LIST_DIR PARENT_PATH root)
    file(READ "${root}/vcpkg.json" manifest)
    string(JSON baseline GET "${manifest}" builtin-baseline)

    if(CMAKE_SCRIPT_MODE_FILE)
        execute_process(
            COMMAND git ls-files --stage -- vcpkg
            WORKING_DIRECTORY "${root}"
            OUTPUT_VARIABLE entry
            COMMAND_ERROR_IS_FATAL ANY
        )
        if(NOT entry MATCHES "^160000 ([0-9a-f]+) ")
            message(FATAL_ERROR "vcpkg is not registered as a submodule")
        endif()
        set(commit "${CMAKE_MATCH_1}")
    else()
        execute_process(
            COMMAND git rev-parse HEAD
            WORKING_DIRECTORY "${root}/vcpkg"
            OUTPUT_VARIABLE commit
            OUTPUT_STRIP_TRAILING_WHITESPACE
            RESULT_VARIABLE result
            ERROR_QUIET
        )
        # 不是 git 检出（如源码包）时无从比较，交给 vcpkg 自己处理
        if(NOT result EQUAL 0)
            return()
        endif()
    endif()

    if(NOT commit STREQUAL baseline)
        message(
            FATAL_ERROR
            "vcpkg submodule is at ${commit}, but builtin-baseline in "
            "vcpkg.json is ${baseline}.\n"
            "After pulling, run: git submodule update --init --recursive\n"
            "After upgrading vcpkg, set builtin-baseline to ${commit}"
        )
    endif()
endfunction()

check_vcpkg_baseline()
