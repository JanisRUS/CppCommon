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

    foreach(EXAMPLE_SOURCE_FILE IN LISTS EXAMPLE_SOURCE_FILES)
        get_filename_component(EXAMPLE_NAME "${EXAMPLE_SOURCE_FILE}" NAME_WE)
        set(EXAMPLE_TARGET "cppcommon-example-${EXAMPLE_NAME}")

        if(EXAMPLE_NAME STREQUAL "system_dll")
            get_property(PLUGIN_TARGETS GLOBAL PROPERTY CPPCOMMON_PLUGIN_TARGETS)

            if(NOT PLUGIN_TARGETS)
                add_subdirectory(
                    "${CMAKE_CURRENT_SOURCE_DIR}/plugins"
                    "${CMAKE_CURRENT_BINARY_DIR}/plugins"
                )

                get_property(PLUGIN_TARGETS GLOBAL PROPERTY CPPCOMMON_PLUGIN_TARGETS)
            endif()

            if(NOT PLUGIN_TARGETS)
                message(FATAL_ERROR "CppCommon plugin targets were not created")
            endif()

            set_target_properties(${PLUGIN_TARGETS} PROPERTIES
                LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
                RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
            )
        endif()

        add_executable(${EXAMPLE_TARGET}
            ${EXAMPLE_HEADER_FILES}
            ${EXAMPLE_INLINE_FILES}
            "${EXAMPLE_SOURCE_FILE}"
        )

        platform_setup_target(${EXAMPLE_TARGET})

        target_link_libraries(${EXAMPLE_TARGET}
            PRIVATE cppcommon
        )

        if(EXAMPLE_NAME STREQUAL "system_dll")
            add_dependencies(${EXAMPLE_TARGET} ${PLUGIN_TARGETS})
        endif()

        set_target_properties(${EXAMPLE_TARGET} PROPERTIES
            FOLDER "examples"
        )
    endforeach()
endfunction()
