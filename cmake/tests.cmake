# @brief    Initialize the tests module
# @details  Create the tests settings targets and find required dependencies
function(tests_init)
    add_library(cppcommon_tests_global_settings INTERFACE)
    add_library(cppcommon_tests_target_settings INTERFACE)

    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    find_package(Catch2 3 CONFIG REQUIRED)
endfunction()

# @brief    Configure tests settings
# @details  Configure usage requirements shared by tests
function(tests_configure_settings)
    # No additional test-specific settings are required yet
endfunction()

# @brief    Create test-related targets and rules
# @details  Create the test executable, its plugin fixtures, and register it with CTest
function(tests_create_targets)
    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    plugins_check()
    get_property(PLUGIN_TARGETS GLOBAL PROPERTY CPPCOMMON_PLUGIN_TARGETS)

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

    add_dependencies(cppcommon-tests ${PLUGIN_TARGETS})

    set_target_properties(cppcommon-tests PROPERTIES
        FOLDER "tests"
    )

    target_link_libraries(cppcommon-tests
        PRIVATE
            cppcommon_tests_global_settings
            cppcommon
            Catch2::Catch2WithMain
    )

    enable_testing()
    add_test(NAME cppcommon-tests
        COMMAND cppcommon-tests --durations yes --order lex
    )
endfunction()

# @brief    Prepare test installation data
# @details  Add the test executable and its destination to the project install lists
function(tests_install)
    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    list(APPEND INSTALL_TARGETS cppcommon-tests)
    list(APPEND INSTALL_PATHS "${PROJECT_SOURCE_DIR}/bin")

    set(INSTALL_TARGETS "${INSTALL_TARGETS}" PARENT_SCOPE)
    set(INSTALL_PATHS "${INSTALL_PATHS}" PARENT_SCOPE)
endfunction()
