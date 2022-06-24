# Toolchain file to cross compile with arm-none-eabi-gcc

# This toolchain passes "-nodefaultlibs" and as such gives full control over what to link.

# You may then want to link with libgcc.a and libc_nano.a
# target_link_libraries(my_target ${TOOLCHAIN_STDLIB_DIR}/libc_nano.a ${TOOLCHAIN_LIBGCC_DIR}/libgcc.a)

# Also, you need to set the CPU options for your cpu. If you leave them empty, you have to pass
# them to each single target.
# For example, for Cortex-M4F, use:
# set(TOOLCHAIN_CPU_OPTIONS "-mtune=cortex-m4 -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16")
# Note that the quotes in the variable definition are necessary. It must not be a cmake-list.

# Output Variables
# TOOLCHAIN_SYSROOT - sysroot of the toolchain, usually something like /usr/lib/arm-none-eabi
# TOOLCHAIN_LIBGCC_DIR - directory where libgcc.a is located
# TOOLCHAIN_INC_DIR - include dir for standard library headers
# TOOLCHAIN_STDLIB_DIR - directory where stdlibs are located
# TOOLCHAIN_ABI_DIR - Based on TOOLCHAIN_CPU_OPTIONS retrieves the ABI directory path where libraries are located. E.g. `thumb/v7e-m+fp/hard` for Cortex-M4F

# ---------------------------------------------------------------------------------------
# Setup Toolchain Paths
# ---------------------------------------------------------------------------------------

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR ARM)

if(NOT(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux))
    message(FATAL_ERROR "Not compatible with your OS")
endif()

set(TOOLCHAIN arm-none-eabi)

if(EXISTS /usr/lib/${TOOLCHAIN})
    set(TOOLCHAIN_SYSROOT /usr/lib/${TOOLCHAIN})
elseif(EXISTS /usr/${TOOLCHAIN})
    set(TOOLCHAIN_SYSROOT /usr/${TOOLCHAIN})
else()
    message(FATAL_ERROR "Could not find TOOLCHAIN_SYSROOT")
endif()

set(TOOLCHAIN_BIN_DIR /usr/bin)
set(TOOLCHAIN_INC_DIR ${TOOLCHAIN_SYSROOT}/include)


# Perform compiler test with static library
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

execute_process(COMMAND arm-none-eabi-gcc -print-libgcc-file-name OUTPUT_VARIABLE LIBGCC_PATH OUTPUT_STRIP_TRAILING_WHITESPACE)
get_filename_component(TOOLCHAIN_LIBGCC_DIR ${LIBGCC_PATH} DIRECTORY)

string(REPLACE " " ";" TOOLCHAIN_CPU_OPTIONS_LIST ${TOOLCHAIN_CPU_OPTIONS})
execute_process(COMMAND "arm-none-eabi-gcc" ${TOOLCHAIN_CPU_OPTIONS_LIST} -print-multi-directory OUTPUT_VARIABLE TOOLCHAIN_ABI_DIR OUTPUT_STRIP_TRAILING_WHITESPACE)

# ---------------------------------------------------------------------------------------
# Set compiler/linker flags
# ---------------------------------------------------------------------------------------
set(DIAGNOSTIC_OPTIONS "-Wall -Werror -Wno-unused-function -Wno-strict-aliasing")

# Object build options
# -O0                   No optimizations, reduce compilation time and make debugging produce the expected results.
# -mthumb               Generat thumb instructions.
# -Wall                 Print only standard warnings, for all use Wextra
# -ffunction-sections   Place each function item into its own section in the output file.
# -fdata-sections       Place each data item into its own section in the output file.
# -fomit-frame-pointer  Omit the frame pointer in functions that don’t need one.
# -mabi=aapcs           Defines enums to be a variable sized type.
set(OBJECT_GEN_FLAGS "-O0 -mthumb ${DIAGNOSTIC_OPTIONS} -ffunction-sections -fdata-sections -fomit-frame-pointer -mabi=aapcs -nodefaultlibs -I${TOOLCHAIN_INC_DIR} ${TOOLCHAIN_CPU_OPTIONS}")

set(CMAKE_C_FLAGS "${OBJECT_GEN_FLAGS} -std=gnu99 " CACHE INTERNAL "C Compiler options")
set(CMAKE_CXX_FLAGS "${OBJECT_GEN_FLAGS} -std=c++20 -fno-exceptions" CACHE INTERNAL "C++ Compiler options")
set(CMAKE_ASM_FLAGS "${OBJECT_GEN_FLAGS} -x assembler-with-cpp " CACHE INTERNAL "ASM Compiler options")

# -Wl,--gc-sections     Perform the dead code elimination.
set(CMAKE_EXE_LINKER_FLAGS "-Wl,--gc-sections -mthumb -mabi=aapcs" CACHE INTERNAL "Linker options")

# The application must manually link in those static libraries
set(TOOLCHAIN_STDLIB_DIR "${TOOLCHAIN_SYSROOT}/lib/${TOOLCHAIN_ABI_DIR}")
set(TOOLCHAIN_LIBGCC_DIR "${TOOLCHAIN_LIBGCC_DIR}/${TOOLCHAIN_ABI_DIR}")

# ---------------------------------------------------------------------------------------
# Set debug/release build configuration Options
# ---------------------------------------------------------------------------------------
set(DEBUG_FLAGS "-g2 -gdwarf-2")

# Options for DEBUG build
# -Og   Enables optimizations that do not interfere with debugging.
# -g    Produce debugging information in the operating system’s native format.
set(CMAKE_C_FLAGS_DEBUG "-O0 ${DEBUG_FLAGS}" CACHE INTERNAL "C Compiler options for debug build type")
set(CMAKE_CXX_FLAGS_DEBUG "-O0 ${DEBUG_FLAGS}" CACHE INTERNAL "C++ Compiler options for debug build type")
set(CMAKE_ASM_FLAGS_DEBUG "${DEBUG_FLAGS}" CACHE INTERNAL "ASM Compiler options for debug build type")

# Options for RELEASE build
# -Os   Optimize for size. -Os enables all -O2 optimizations.
set(CMAKE_C_FLAGS_RELEASE "-Os ${DEBUG_FLAGS}" CACHE INTERNAL "C Compiler options for release build type")
set(CMAKE_CXX_FLAGS_RELEASE "-Os ${DEBUG_FLAGS}" CACHE INTERNAL "C++ Compiler options for release build type")
set(CMAKE_ASM_FLAGS_RELEASE "${DEBUG_FLAGS}" CACHE INTERNAL "ASM Compiler options for release build type")

# ---------------------------------------------------------------------------------------
# Set compilers
# ---------------------------------------------------------------------------------------
set(CMAKE_C_COMPILER ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-gcc${TOOLCHAIN_EXT} CACHE INTERNAL "C Compiler")
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-g++${TOOLCHAIN_EXT} CACHE INTERNAL "C++ Compiler")
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-gcc${TOOLCHAIN_EXT} CACHE INTERNAL "ASM Compiler")

set(CMAKE_OBJCOPY ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-objcopy)
set(CMAKE_OBJDUMP ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-objdump)
set(CMAKE_SIZE ${TOOLCHAIN_BIN_DIR}/${TOOLCHAIN}-size)

# Prints the section sizes
function(print_section_sizes TARGET)
    add_custom_command(TARGET ${TARGET} POST_BUILD COMMAND ${CMAKE_SIZE} ${TARGET})
endfunction()

# Creates output in hex format
function(create_hex_output TARGET)
    add_custom_target(${TARGET}.hex ALL DEPENDS ${TARGET} COMMAND ${CMAKE_OBJCOPY} -Oihex ${TARGET} ${TARGET}.hex)
endfunction()
