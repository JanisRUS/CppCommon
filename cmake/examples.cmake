# @brief    Initialize the examples module
# @details  Create the examples settings targets
function(examples_init)
    add_library(cppcommon_examples_global_settings INTERFACE)
    add_library(cppcommon_examples_target_settings INTERFACE)
endfunction()

# @brief    Configure examples settings
# @details  Configure usage requirements shared by examples
function(examples_configure_settings)
    # No additional example-specific settings are required yet
endfunction()

# @brief    Create example targets and rules
# @details  Create example executables and connect the DLL fixtures used by system_dll
function(examples_create_targets)
    if(NOT CPPCOMMON_BUILD_EXAMPLES)
        return()
    endif()

    file(GLOB EXAMPLE_HEADER_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/examples/*.h"
    )
    file(GLOB EXAMPLE_INLINE_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/examples/*.inl"
    )
    file(GLOB EXAMPLE_SOURCE_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/examples/*.cpp"
    )

    list(FIND EXAMPLE_SOURCE_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/examples/system_dll.cpp"
        SYSTEM_DLL_EXAMPLE_INDEX
    )

    if(NOT SYSTEM_DLL_EXAMPLE_INDEX EQUAL -1)
        plugins_check()
        get_property(PLUGIN_TARGETS GLOBAL PROPERTY CPPCOMMON_PLUGIN_TARGETS)

        set_target_properties(${PLUGIN_TARGETS} PROPERTIES
            LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
            RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
        )
    endif()

    foreach(EXAMPLE_SOURCE_FILE IN LISTS EXAMPLE_SOURCE_FILES)
        get_filename_component(EXAMPLE_NAME "${EXAMPLE_SOURCE_FILE}" NAME_WE)
        set(EXAMPLE_TARGET "cppcommon-example-${EXAMPLE_NAME}")

        add_executable(${EXAMPLE_TARGET}
            ${EXAMPLE_HEADER_FILES}
            ${EXAMPLE_INLINE_FILES}
            "${EXAMPLE_SOURCE_FILE}"
        )

        target_link_libraries(${EXAMPLE_TARGET}
            PRIVATE
                cppcommon_global_settings
                cppcommon
        )

        set_target_properties(${EXAMPLE_TARGET} PROPERTIES
            FOLDER "examples"
        )

        if(EXAMPLE_NAME STREQUAL "system_dll")
            target_link_libraries(${EXAMPLE_TARGET}
                PRIVATE cppcommon_plugins_target_settings
            )

            add_dependencies(${EXAMPLE_TARGET} ${PLUGIN_TARGETS})
        endif()
    endforeach()
endfunction()

# @brief    Install example artifacts
# @details  Register example executables in the Examples component
function(examples_install)
    if(NOT CPPCOMMON_BUILD_EXAMPLES)
        return()
    endif()

    file(GLOB EXAMPLE_SOURCE_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/examples/*.cpp"
    )

    foreach(EXAMPLE_SOURCE_FILE IN LISTS EXAMPLE_SOURCE_FILES)
        get_filename_component(EXAMPLE_NAME "${EXAMPLE_SOURCE_FILE}" NAME_WE)
        set(EXAMPLE_TARGET "cppcommon-example-${EXAMPLE_NAME}")

        install(TARGETS ${EXAMPLE_TARGET}
            RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
            COMPONENT Examples
        )

        if(MSVC)
            install(FILES "$<TARGET_PDB_FILE:${EXAMPLE_TARGET}>"
                DESTINATION "${CMAKE_INSTALL_BINDIR}"
                COMPONENT Examples
                OPTIONAL
            )
        endif()
    endforeach()
endfunction()
