cmake_minimum_required(VERSION 3.16)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

include(ClangFormat)

# NOTE: target is either set to "arm" or "test". "arm" is implicit
if(NOT TARGET)
    set(TARGET arm)
endif()

if(${TARGET} STREQUAL arm)
    set(TARGET_ARM TRUE)

    # TODO: set your cpu flags correctly, this if cortex M4F
    set(TOOLCHAIN_CPU_OPTIONS "-mtune=cortex-m4 -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16")

    # TODO: Choose whether you want to compile with gcc or clang
    include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/toolchain-arm-none-eabi.cmake")

# include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/toolchain-clang.cmake")
elseif(${TARGET} STREQUAL test)
    set(TARGET_TEST TRUE)
    set(CMAKE_BUILD_TYPE Debug)

    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m32")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -m32 -std=c++20")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -m32")
    set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -m32")
    include(FetchContent)
    FetchContent_Declare(
        googletest
        URL https://github.com/google/googletest/archive/609281088cfefc76f9d0ce82e1ff6c30cc3591e5.zip
    )
    FetchContent_MakeAvailable(googletest)
else()
    message(FATAL_ERROR "Invalid target configured. Use either `arm` or `test`.")
endif()

# TODO: replace project name
project(my_project C CXX ASM)
set(CMAKE_EXPORT_COMPILE_COMMANDS TRUE)

if(TARGET_TEST)
    include(cmake/CodeCoverage.cmake)
    append_coverage_compiler_flags()
endif()

set(MERGE_TOOL "${CMAKE_CURRENT_SOURCE_DIR}/tools/merge_tool_cli")
include(cmake/merge_tool.cmake)

if(CMAKE_BUILD_TYPE MATCHES Debug)
    add_definitions("-DDEBUG")
else()
    add_definitions("-DNDEBUG")
endif()

if(TARGET_ARM)
    include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/target.cmake")
else()
    include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/test.cmake")
endif()

set(config_header ${CMAKE_CURRENT_BINARY_DIR}/config/config_version.h)
set(changelog_script ${CMAKE_CURRENT_SOURCE_DIR}/cmake/parse_changelog.py)
set(changelog_file ${CMAKE_CURRENT_SOURCE_DIR}/CHANGELOG.md)

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/config)
add_custom_target(
    generate_version_header ALL
    DEPENDS
    ${config_header}
)
add_custom_command(
    COMMAND python ${changelog_script} ${CMAKE_CURRENT_SOURCE_DIR}/CHANGELOG.md ${config_header}
    DEPENDS ${changelog_file}
    OUTPUT ${config_header}
)

# TODO: add here whatever you want to be subject to clang-format
clangformat_setup(${app_sources} ${app_headers})

# NOTE: typically those are manufacturer provided files so you don't want to format
set(CPPCHECK_EXCLUDES
    ${CMAKE_SOURCE_DIR}/target
)

set(CPPCHECK_ARGS
    "-j10"
    "--project=${PROJECT_BINARY_DIR}/compile_commands.json"
    "--inline-suppr"
    "--error-exitcode=1"
    "--enable=all"
    "--library=googletest"
    "--file-filter=*.c"
    "--addon=jenkins/misra.json"
    "--suppress=unusedFunction"
    "--suppress=unmatchedSuppression"
    "--suppress=misra-c2012-15.5" # function has only a single point of exit
    "--suppress=misra-c2012-19.2" # we allow unions for bitfields and ADTs
    "--suppress=unusedStructMember" # temporary, not considered harmful
    "--suppress=objectIndex" # temporary, not considered harmful
)

find_program(CPPCHECK_BIN NAMES cppcheck)

foreach(ex ${CPPCHECK_EXCLUDES})
    list(APPEND _CPPCHECK_EXCLUDES "--suppress=*:${ex}/*")
endforeach(ex)

set(CPPCHECK_COMMAND
    ${CPPCHECK_BIN}
    ${CPPCHECK_ARGS}
    ${_CPPCHECK_EXCLUDES}
)

add_custom_target(cppcheck
    COMMAND ${CPPCHECK_COMMAND}
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})

find_program(CLANG_TIDY_BIN NAMES clang-tidy)

set(CLANG_TIDY_ARGS
    -p ${CMAKE_CURRENT_BINARY_DIR}
    --fix
)

set(CLANG_TIDY_COMMAND
    ${CLANG_TIDY_BIN}
    ${CLANG_TIDY_ARGS}
    ${app_sources}
    ${app_headers}
)

add_custom_target(clang-tidy
    COMMAND ${CLANG_TIDY_COMMAND}
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
