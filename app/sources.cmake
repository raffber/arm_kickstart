

if(TARGET_ARM)
    set(app_sources
        target/main.c
    )
    set(app_includes)
    set(app_defines PRODUCT_ID=0x1234)
elseif(TARGET_TEST)
    set(app_sources
        test/main.cpp
    )
    set(app_includes)
    set(app_defines)
endif()

list(TRANSFORM app_sources PREPEND ${CMAKE_CURRENT_SOURCE_DIR}/app/)
