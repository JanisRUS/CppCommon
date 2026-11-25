set(CPPCOMMON_EXAMPLES_DIR "${CMAKE_CURRENT_LIST_DIR}/../examples")
set(CPPCOMMON_EXAMPLES_TARGET_PREFIX "cppcommon-example-")

# @brief    Initialize the examples module
# @details  Create the examples settings targets
function(cppcommon_examples_init)
    add_library(cppcommon-examples-global-settings INTERFACE)
    add_library(cppcommon-examples-target-settings INTERFACE)
endfunction()

# @brief    Configure examples settings
# @details  Configure usage requirements shared by examples
function(cppcommon_examples_configure_settings)
    # No additional example-specific settings are required yet
endfunction()

# @brief    Create example targets and rules
# @details  Create example executables and connect the DLL fixtures used by system_dll
function(cppcommon_examples_create_targets)
    if(NOT CPPCOMMON_BUILD_EXAMPLES)
        return()
    endif()

    file(GLOB example_header_files
        "${CPPCOMMON_EXAMPLES_DIR}/*.h"
    )
    file(GLOB example_inline_files
        "${CPPCOMMON_EXAMPLES_DIR}/*.inl"
    )
    file(GLOB example_source_files
        "${CPPCOMMON_EXAMPLES_DIR}/*.cpp"
    )

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

# @brief    Install example artifacts
# @details  Register example executables in the Examples component
function(cppcommon_examples_install)
    if(NOT CPPCOMMON_BUILD_EXAMPLES)
        return()
    endif()

    file(GLOB example_source_files
        "${CPPCOMMON_EXAMPLES_DIR}/*.cpp"
    )

    foreach(example_source_file IN LISTS example_source_files)
        get_filename_component(example_name "${example_source_file}" NAME_WE)
        set(example_target "${CPPCOMMON_EXAMPLES_TARGET_PREFIX}${example_name}")

        install(TARGETS ${example_target}
            RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
            COMPONENT Examples
        )

        if(MSVC)
            install(FILES "$<TARGET_PDB_FILE:${example_target}>"
                DESTINATION "${CMAKE_INSTALL_BINDIR}"
                COMPONENT Examples
                OPTIONAL
            )
        endif()
    endforeach()
endfunction()
