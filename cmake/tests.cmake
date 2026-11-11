# @brief    Find libraries required by tests
# @details  Discover libraries required by tests and append their link dependencies
#               to the tests configuration variables
# @note     Output variables:
#           - TESTS_LIBS
#           - TESTS_INCLUDE_DIRS
function(tests_find_libraries)
    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    # Test dependency discovery will be configured separately
endfunction()

# @brief    Configure tests compiler settings
# @details  Writes tests compiler settings to the tests configurations variables
# @note     Output variables:
#           - TESTS_COMPILE_DEFINITIONS
#           - TESTS_COMPILE_OPTIONS
#           - TESTS_LINK_OPTIONS
function(tests_configure_compiler)
    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    # No additional test-specific compiler settings are required yet
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