include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/common.cmake")
include("${CMAKE_CURRENT_SOURCE_DIR}/app/sources.cmake")
include("${CMAKE_CURRENT_SOURCE_DIR}/hal/test/sources.cmake")

target_sources(app PUBLIC ${app_sources} ${test_sources} ${hal_sources})
target_compile_definitions(app PUBLIC ${app_defines} ${test_defines} ${hal_defines})
target_include_directories(app PUBLIC ${app_includes} ${test_includes} ${hal_includes})

target_compile_options(app PUBLIC -Wall -Werror -Wno-unused-function)

target_link_libraries(app PRIVATE
        pthread
        gtest
)
setup_target_for_coverage_gcovr_html(
        NAME app-coverage
        EXECUTABLE app
        EXCLUDE "${CMAKE_CURRENT_BINARY_DIR}/_deps/*"
)

add_dependencies(app generate_version_header)
target_include_directories(app PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/config)