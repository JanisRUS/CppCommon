# @brief    Check whether plugin targets exist
# @details  Checks whether CPPCOMMON_PLUGINS_TARGETS is populated.
#           If not, it adds the plugins subdirectory.
#           Fails if plugin targets are still unavailable
function(cppcommon_plugins_check)
    get_property(plugin_targets GLOBAL PROPERTY CPPCOMMON_PLUGINS_TARGETS)

    if(NOT plugin_targets)
        add_subdirectory(
            "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../plugins"
            "${CMAKE_CURRENT_BINARY_DIR}/plugins"
        )

        get_property(plugin_targets GLOBAL PROPERTY CPPCOMMON_PLUGINS_TARGETS)
    endif()

    if(NOT plugin_targets)
        message(FATAL_ERROR "CppCommon plugins were not created")
    endif()
endfunction()
