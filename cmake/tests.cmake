# @brief    Find libraries required by tests
# @details  Discover libraries required by tests
# @note     Output variables:
#           - TESTS_LIBS
#           - TESTS_INCLUDE_DIRS
function(tests_get_libraries)
    set(TESTS_LIBS)
    set(TESTS_INCLUDE_DIRS)

    if(CPPCOMMON_ENABLE_TESTING)
        find_package(Catch2 3 CONFIG REQUIRED)
    endif()

    set(TESTS_LIBS         "${TESTS_LIBS}"         PARENT_SCOPE)
    set(TESTS_INCLUDE_DIRS "${TESTS_INCLUDE_DIRS}" PARENT_SCOPE)
endfunction()

# @brief    Configure tests compiler settings
# @details  Writes tests compiler settings to the tests configurations variables
# @note     Output variables:
#           - TESTS_COMPILE_DEFINITIONS
#           - TESTS_COMPILE_OPTIONS
#           - TESTS_LINK_OPTIONS
function(tests_get_compiler_settings)
    set(TESTS_COMPILE_DEFINITIONS)
    set(TESTS_COMPILE_OPTIONS)
    set(TESTS_LINK_OPTIONS)

    # No additional test-specific compiler settings are required yet

    set(TESTS_COMPILE_DEFINITIONS "${TESTS_COMPILE_DEFINITIONS}" PARENT_SCOPE)
    set(TESTS_COMPILE_OPTIONS     "${TESTS_COMPILE_OPTIONS}"     PARENT_SCOPE)
    set(TESTS_LINK_OPTIONS        "${TESTS_LINK_OPTIONS}"        PARENT_SCOPE)
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

    if(NOT TARGET plugin-function)
        add_subdirectory(
            "${CMAKE_CURRENT_SOURCE_DIR}/plugins"
            "${CMAKE_CURRENT_BINARY_DIR}/plugins"
        )
    endif()

    if(NOT TARGET plugin-function OR NOT TARGET plugin-interface)
        message(FATAL_ERROR "CppCommon plugin fixtures were not created")
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

    add_dependencies(cppcommon-tests
        plugin-function
        plugin-interface
    )

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
