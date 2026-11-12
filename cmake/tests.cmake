set(TESTS_COMPILE_DEFINITIONS)
set(TESTS_COMPILE_OPTIONS)
set(TESTS_LINK_OPTIONS)

# @brief    Find libraries required by tests
# @details  Discover libraries required by tests
function(tests_get_libraries)
    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    find_package(Catch2 3 CONFIG REQUIRED)
endfunction()

# @brief    Configure tests compiler settings
# @details  Writes tests compiler settings to the tests configurations variables
# @note     Output variables:
#           - TESTS_COMPILE_DEFINITIONS
#           - TESTS_COMPILE_OPTIONS
#           - TESTS_LINK_OPTIONS
function(tests_get_compiler_settings)
    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    # No additional test-specific compiler settings are required yet
endfunction()

# @brief    Configure a target for testing
# @details  Apply test-related settings to the requested target
# @param    target Target name
function(tests_setup_target target)
    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    # No target-specific test instrumentation is configured yet
endfunction()

# @brief      Configure test installation rules
# @details    Add test targets to the project installation target lists
function(tests_setup_install)
    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    list(APPEND INSTALL_TARGETS cppcommon-tests)
    list(APPEND INSTALL_TARGETS_PDB cppcommon-tests)

    set(INSTALL_TARGETS "${INSTALL_TARGETS}" PARENT_SCOPE)
    set(INSTALL_TARGETS_PDB "${INSTALL_TARGETS_PDB}" PARENT_SCOPE)
endfunction()

# @brief      Configure test uninstallation rules
# @details    Provide the test uninstallation hook
function(tests_setup_uninstall)
    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()
endfunction()

# @brief    Create test-related targets and rules
# @details  Create the test executable, enable CTest and register the test
function(tests_create_targets)
    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    file(GLOB TESTS_HEADER_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/*.h"
    )
    file(GLOB TESTS_INLINE_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/*.inl"
    )
    file(GLOB TESTS_SOURCE_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/*.cpp"
    )

    add_executable(cppcommon-tests
        ${TESTS_HEADER_FILES}
        ${TESTS_INLINE_FILES}
        ${TESTS_SOURCE_FILES}
    )

    platform_configure_target(cppcommon-tests)

    if(PLUGINS)
        add_dependencies(cppcommon-tests ${PLUGINS})
    endif()

    set_target_properties(cppcommon-tests PROPERTIES
        COMPILE_FLAGS "${PEDANTIC_COMPILE_FLAGS}"
        FOLDER "tests"
    )

    target_link_libraries(cppcommon-tests PRIVATE Catch2::Catch2WithMain)

    enable_testing()
    add_test(NAME cppcommon-tests
        COMMAND cppcommon-tests --durations yes --order lex
    )
endfunction()
