

function(merge_tool CONFIG_FILE)
    add_custom_target(
        script ALL
        COMMAND "${MERGE_TOOL}" -c "${CONFIG_FILE}" -o "${CMAKE_CURRENT_BINARY_DIR}" script
        DEPENDS app.hex btl.hex
    )
    add_custom_target(
        info ALL
        COMMAND "${MERGE_TOOL}" -c "${CONFIG_FILE}" -o "${CMAKE_CURRENT_BINARY_DIR}" info
        DEPENDS app.hex btl.hex
    )
    add_custom_target(
        merge ALL
        COMMAND "${MERGE_TOOL}" -c "${CONFIG_FILE}" -o "${CMAKE_CURRENT_BINARY_DIR}" merge
        DEPENDS app.hex btl.hex
    )
endfunction()
