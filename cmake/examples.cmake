set(CPPCOMMON_EXAMPLES_DIR "${CMAKE_CURRENT_LIST_DIR}/../examples")
set(CPPCOMMON_EXAMPLES_TARGET_PREFIX "cppcommon-example-")

# @brief    Initialize the examples module
# @details  Create the examples settings targets and initialize the target list
function(cppcommon_examples_init)
    add_library(cppcommon-examples-global-settings INTERFACE)
    add_library(cppcommon-examples-target-settings INTERFACE)

    set_property(GLOBAL PROPERTY CPPCOMMON_EXAMPLES_TARGETS "")
endfunction()

# @brief    Configure examples module settings
# @details  No additional example-specific settings are required
function(cppcommon_examples_configure_settings)
endfunction()

# @brief    Create examples module targets
# @details  Create example executables and connect the DLL fixtures used by system_dll
function(cppcommon_examples_create_targets)
    if(NOT CPPCOMMON_BUILD_EXAMPLES)
        return()
    endif()

    file(GLOB example_header_files "${CPPCOMMON_EXAMPLES_DIR}/*.h")
    file(GLOB example_inline_files "${CPPCOMMON_EXAMPLES_DIR}/*.inl")
    file(GLOB example_source_files "${CPPCOMMON_EXAMPLES_DIR}/*.cpp")

    if(EXISTS "${CPPCOMMON_EXAMPLES_DIR}/system_dll.cpp")
        cppcommon_plugins_check()
        get_property(plugin_targets GLOBAL PROPERTY CPPCOMMON_PLUGINS_TARGETS)

        set_target_properties(${plugin_targets} PROPERTIES
            LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
            RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        )
    endif()

    foreach(example_source_file IN LISTS example_source_files)
        get_filename_component(example_name "${example_source_file}" NAME_WE)
        set(example_target "${CPPCOMMON_EXAMPLES_TARGET_PREFIX}${example_name}")

        add_executable(${example_target}
            ${example_header_files}
            ${example_inline_files}
            "${example_source_file}"
        )

        set_property(GLOBAL APPEND PROPERTY CPPCOMMON_EXAMPLES_TARGETS ${example_target})

        target_link_libraries(${example_target}
            PRIVATE
                cppcommon-global-settings
                cppcommon
        )

        set_target_properties(${example_target} PROPERTIES
            FOLDER "examples"
        )

        if(example_name STREQUAL "system_dll")
            target_link_libraries(${example_target}
                PRIVATE
                    cppcommon-plugins-target-settings
            )

            add_dependencies(${example_target} ${plugin_targets})
        endif()
    endforeach()
endfunction()

# @brief    Configure examples module installation
# @details  Register the created example targets in the Examples component
function(cppcommon_examples_install)
    get_property(example_targets GLOBAL PROPERTY CPPCOMMON_EXAMPLES_TARGETS)

    if(NOT example_targets)
        return()
    endif()

    install(TARGETS ${example_targets}
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
        COMPONENT Examples
    )

    if(MSVC)
        foreach(example_target IN LISTS example_targets)
            install(FILES "$<TARGET_PDB_FILE:${example_target}>"
                DESTINATION "${CMAKE_INSTALL_BINDIR}"
                COMPONENT Examples
                OPTIONAL
            )
        endforeach()
    endif()
endfunction()
