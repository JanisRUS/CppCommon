# @brief    Initialize the tests module
# @details  Create the tests settings targets and find required dependencies
function(cppcommon_tests_init)
    add_library(cppcommon-tests-global-settings INTERFACE)
    add_library(cppcommon-tests-target-settings INTERFACE)

    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    find_package(Catch2 3 CONFIG REQUIRED)
endfunction()

# @brief    Configure tests settings
# @details  Configure usage requirements shared by tests
function(cppcommon_tests_configure_settings)
    # No additional test-specific settings are required yet
endfunction()

# @brief    Create test-related targets and rules
# @details  Create the test executable, its plugin fixtures, and register it with CTest
function(cppcommon_tests_create_targets)
    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    cppcommon_plugins_check()
    get_property(plugin_targets GLOBAL PROPERTY CPPCOMMON_PLUGINS_TARGETS)

    file(GLOB tests_header_files
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/*.h"
    )
    file(GLOB tests_inline_files
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/*.inl"
    )
    file(GLOB tests_source_files
        "${CMAKE_CURRENT_SOURCE_DIR}/tests/*.cpp"
    )

    add_executable(cppcommon-tests
        ${tests_header_files}
        ${tests_inline_files}
        ${tests_source_files}
    )

    add_dependencies(cppcommon-tests ${plugin_targets})

    set_target_properties(cppcommon-tests PROPERTIES
        FOLDER "tests"
    )

    target_link_libraries(cppcommon-tests
        PRIVATE
            cppcommon-global-settings
            cppcommon-plugins-target-settings
            cppcommon
            Catch2::Catch2WithMain
    )

    enable_testing()
    add_test(NAME cppcommon-tests
        COMMAND cppcommon-tests --durations yes --order lex
    )
endfunction()

# @brief    Install test artifacts
# @details  Register the test executable in the Tests component
function(cppcommon_tests_install)
    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    install(TARGETS cppcommon-tests
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
        COMPONENT Tests
    )

    if(MSVC)
        install(FILES "$<TARGET_PDB_FILE:cppcommon-tests>"
            DESTINATION "${CMAKE_INSTALL_BINDIR}"
            COMPONENT Tests
            OPTIONAL
        )
    endif()
endfunction()
