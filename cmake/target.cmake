include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/common.cmake")
include("${CMAKE_CURRENT_SOURCE_DIR}/app/sources.cmake")
include("${CMAKE_CURRENT_SOURCE_DIR}/btl/sources.cmake")
include("${CMAKE_CURRENT_SOURCE_DIR}/target/sources.cmake")

# ---------------------------------------------------------------------------------------
# Application
# ---------------------------------------------------------------------------------------
target_sources(app PRIVATE
    ${target_sources}
    ${app_sources}
)

target_include_directories(app PUBLIC
    ${app_includes}
    ${target_includes}
    ${CMAKE_CURRENT_SOURCE_DIR}/hal/target
)

target_compile_definitions(app PUBLIC
    ${app_defines}
    ${target_defines}
)

add_dependencies(app generate_version_header)
target_include_directories(app PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/config)

target_link_libraries(app ${TOOLCHAIN_STDLIB_DIR}/libc_nano.a ${TOOLCHAIN_LIBGCC_DIR}/libgcc.a)
target_link_options(app PUBLIC "-T${CMAKE_CURRENT_SOURCE_DIR}/app/target/soc.ld")
create_hex_output(app)

# ---------------------------------------------------------------------------------------
# Bootloader
# ---------------------------------------------------------------------------------------
add_executable(btl ${btl_sources})

target_sources(btl PRIVATE
    ${btl_sources}
    ${target_sources}
)

target_include_directories(btl PUBLIC
    ${btl_includes}
    ${target_includes}
)

target_compile_definitions(btl PUBLIC
    ${btl_defines}
    ${target_defines}
)

target_link_libraries(btl ${TOOLCHAIN_STDLIB_DIR}/libc_nano.a ${TOOLCHAIN_LIBGCC_DIR}/libgcc.a)

target_link_options(btl PUBLIC "-T${CMAKE_CURRENT_SOURCE_DIR}/btl/soc.ld")

create_hex_output(btl)

add_dependencies(btl generate_version_header)
target_include_directories(btl PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/config)

# ---------------------------------------------------------------------------------------
# Merge Tool
# ---------------------------------------------------------------------------------------
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/cfg/target.gctmrg" "${CMAKE_CURRENT_BINARY_DIR}/target.gctmrg" COPYONLY)
merge_tool("${CMAKE_CURRENT_BINARY_DIR}/target.gctmrg")
