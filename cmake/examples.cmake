# @brief    Find libraries required by examples
# @details  Discover libraries required by example executables
# @note     Output variables:
#           - EXAMPLES_LIBS
#           - EXAMPLES_INCLUDE_DIRS
function(examples_get_libraries)
    set(EXAMPLES_LIBS)
    set(EXAMPLES_INCLUDE_DIRS)

    # Examples currently depend only on cppcommon

    set(EXAMPLES_LIBS         "${EXAMPLES_LIBS}"         PARENT_SCOPE)
    set(EXAMPLES_INCLUDE_DIRS "${EXAMPLES_INCLUDE_DIRS}" PARENT_SCOPE)
endfunction()

# @brief    Configure examples compiler settings
# @details  Initialize compiler settings required by examples
# @note     Output variables:
#           - EXAMPLES_COMPILE_DEFINITIONS
#           - EXAMPLES_COMPILE_OPTIONS
#           - EXAMPLES_LINK_OPTIONS
function(examples_get_compiler_settings)
    set(EXAMPLES_COMPILE_DEFINITIONS)
    set(EXAMPLES_COMPILE_OPTIONS)
    set(EXAMPLES_LINK_OPTIONS)

    # No additional example-specific compiler settings are required yet

    set(EXAMPLES_COMPILE_DEFINITIONS "${EXAMPLES_COMPILE_DEFINITIONS}" PARENT_SCOPE)
    set(EXAMPLES_COMPILE_OPTIONS     "${EXAMPLES_COMPILE_OPTIONS}"     PARENT_SCOPE)
    set(EXAMPLES_LINK_OPTIONS        "${EXAMPLES_LINK_OPTIONS}"        PARENT_SCOPE)
endfunction()

# @brief    Configure a target for examples
# @details  Apply examples-module settings to the requested target
# @param    target Target name
function(examples_setup_target target)
    if(NOT CPPCOMMON_BUILD_EXAMPLES)
        return()
    endif()

    # No example-specific settings are required by the target yet
endfunction()

# @brief      Configure example installation rules
# @details    Add example targets to the project installation target lists
function(examples_setup_install)
    if(NOT CPPCOMMON_BUILD_EXAMPLES)
        return()
    endif()

    file(GLOB EXAMPLE_SOURCE_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/examples/*.cpp"
    )

    foreach(EXAMPLE_SOURCE_FILE IN LISTS EXAMPLE_SOURCE_FILES)
        get_filename_component(EXAMPLE_NAME "${EXAMPLE_SOURCE_FILE}" NAME_WE)
        set(EXAMPLE_TARGET "cppcommon-example-${EXAMPLE_NAME}")

        list(APPEND INSTALL_TARGETS     ${EXAMPLE_TARGET})
        list(APPEND INSTALL_TARGETS_PDB ${EXAMPLE_TARGET})
    endforeach()

    set(INSTALL_TARGETS     "${INSTALL_TARGETS}"     PARENT_SCOPE)
    set(INSTALL_TARGETS_PDB "${INSTALL_TARGETS_PDB}" PARENT_SCOPE)
endfunction()

# @brief      Configure example uninstallation rules
# @details    Provide the example uninstallation hook
function(examples_setup_uninstall)
    if(NOT CPPCOMMON_BUILD_EXAMPLES)
        return()
    endif()
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
        get_property(PLUGIN_TARGETS GLOBAL PROPERTY CPPCOMMON_PLUGIN_TARGETS)

        if(NOT PLUGIN_TARGETS)
            add_subdirectory(
                "${CMAKE_CURRENT_SOURCE_DIR}/plugins"
                "${CMAKE_CURRENT_BINARY_DIR}/plugins"
            )

            get_property(PLUGIN_TARGETS GLOBAL PROPERTY CPPCOMMON_PLUGIN_TARGETS)
        endif()

        if(NOT PLUGIN_TARGETS)
            message(FATAL_ERROR "CppCommon plugin fixtures were not created")
        endif()

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

        platform_setup_target(${EXAMPLE_TARGET})

        if(EXAMPLES_INCLUDE_DIRS)
            target_include_directories(${EXAMPLE_TARGET}
                PRIVATE ${EXAMPLES_INCLUDE_DIRS}
            )
        endif()

        target_link_libraries(${EXAMPLE_TARGET}
            PRIVATE
                cppcommon
                ${EXAMPLES_LIBS}
        )

        set_target_properties(${EXAMPLE_TARGET} PROPERTIES
            FOLDER "examples"
        )

        if(EXAMPLE_NAME STREQUAL "system_dll")
            add_dependencies(${EXAMPLE_TARGET} ${PLUGIN_TARGETS})
        endif()
    endforeach()
endfunction()
