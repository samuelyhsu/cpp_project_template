get_filename_component(APP_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME)
set(APP_VERSION 0.1.0)
add_executable(${APP_NAME} main.cpp)
target_compile_definitions(${APP_NAME} PRIVATE APP_NAME="${APP_NAME}")
target_compile_definitions(${APP_NAME} PRIVATE APP_VERSION="${APP_VERSION}")
target_link_libraries(${APP_NAME} PRIVATE checksum::checksum)

add_zip_package(${APP_NAME} ${APP_VERSION})
