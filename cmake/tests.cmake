#
# Tests configuration
#

# @brief    Configure compiler settings for tests
# @details  Preserve the caller's test-specific compiler settings
function(tests_configure_compiler)
    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    # No additional test-specific compiler settings are required yet
endfunction()

# @brief    Find libraries required by tests
# @details  Discover test dependencies when testing is enabled
function(tests_find_libraries)
    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    # Test dependency discovery will be configured separately
endfunction()

# @brief    Configure a target for testing
# @details  Apply test-related settings to the requested target
# @param    target Target name
function(tests_configure_target target)
    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    # No target-specific test instrumentation is configured yet
endfunction()

# @brief    Link test-related libraries to a target
# @details  Apply test-related link dependencies to the requested target
# @param    target Target name
function(tests_link_libraries target)
    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    # No additional libraries are linked to the core target
endfunction()

# @brief    Create the test executable
# @details  Add the test sources and configure the test target
function(tests_create_target)
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

    target_include_directories(cppcommon-tests PRIVATE Catch2)
    target_link_libraries(cppcommon-tests ${LINKLIBS} Catch2)

    list(APPEND INSTALL_TARGETS cppcommon-tests)
    list(APPEND INSTALL_TARGETS_PDB cppcommon-tests)

    set(INSTALL_TARGETS "${INSTALL_TARGETS}" PARENT_SCOPE)
    set(INSTALL_TARGETS_PDB "${INSTALL_TARGETS_PDB}" PARENT_SCOPE)
endfunction()

# @brief    Create test-related CMake rules
# @details  Enable CTest and register the test executable
function(tests_create_rules)
    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    enable_testing()
    add_test(NAME cppcommon-tests
        COMMAND cppcommon-tests --durations yes --order lex
    )
endfunction()
