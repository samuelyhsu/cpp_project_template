find_package(Catch2 3 CONFIG REQUIRED)
include(Catch)

add_executable(unit_tests checksum_test.cpp build_options_test.cpp)
target_link_libraries(
    unit_tests
    PRIVATE checksum::checksum Catch2::Catch2WithMain
)
# 推迟到 ctest 运行时再枚举用例：交叉编译出的测试程序在构建机上无法运行
catch_discover_tests(unit_tests DISCOVERY_MODE PRE_TEST)
