# @brief    Check is plugins targets exist
# @details  Checks if CPPCOMMON_PLUGIN_TARGETS exists. 
#           If not, it adds plugins.
#           If impossible, throws an error
function(plugins_check)
    get_property(_plugin_targets GLOBAL PROPERTY CPPCOMMON_PLUGIN_TARGETS)

    if(NOT _plugin_targets)
        add_subdirectory(
            "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../plugins"
            "${CMAKE_CURRENT_BINARY_DIR}/plugins"
        )

        get_property(_plugin_targets GLOBAL PROPERTY CPPCOMMON_PLUGIN_TARGETS)
    endif()

    if(NOT _plugin_targets)
        message(FATAL_ERROR "CppCommon plugins were not created")
    endif()
endfunction()
