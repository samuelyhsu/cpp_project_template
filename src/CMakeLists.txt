add_library(checksum crc16.c checksum.cpp)
# 其他 target 链接 checksum::checksum 而不是 checksum：名字带 :: 时 CMake 在生成阶段检查
# target 是否存在，拼错会直接报错，而不是被当成系统库名变成 -lchecksum
add_library(checksum::checksum ALIAS checksum)
target_include_directories(checksum PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
