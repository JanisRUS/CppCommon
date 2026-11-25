set(CPPCOMMON_TESTS_DIR               "${CMAKE_CURRENT_LIST_DIR}/../tests")
set(CPPCOMMON_TESTS_INSTALL_COMPONENT "Tests")

# @brief    Initialize the tests module
# @details  Create the tests settings targets and initialize the target list.
#           Discover required dependencies when testing is enabled
function(cppcommon_tests_init)
    add_library(cppcommon-tests-global-settings INTERFACE)
    add_library(cppcommon-tests-target-settings INTERFACE)

    set_property(GLOBAL PROPERTY CPPCOMMON_TESTS_TARGETS "")

    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    find_package(Catch2 3 CONFIG REQUIRED)
endfunction()

# @brief    Configure tests module settings
# @details  No additional test-specific settings are required
function(cppcommon_tests_configure_settings)
endfunction()

# @brief    Create tests module targets
# @details  Create the test executable, connect its plugin fixtures, and register it with CTest
function(cppcommon_tests_create_targets)
    if(NOT CPPCOMMON_ENABLE_TESTING)
        return()
    endif()

    cppcommon_plugins_check()
    get_property(plugin_targets GLOBAL PROPERTY CPPCOMMON_PLUGINS_TARGETS)

    file(GLOB tests_header_files "${CPPCOMMON_TESTS_DIR}/*.h")
    file(GLOB tests_inline_files "${CPPCOMMON_TESTS_DIR}/*.inl")
    file(GLOB tests_source_files "${CPPCOMMON_TESTS_DIR}/*.cpp")

    cmake_path(GET CPPCOMMON_TESTS_DIR FILENAME tests_folder)

    add_executable(cppcommon-tests
        ${tests_header_files}
        ${tests_inline_files}
        ${tests_source_files}
    )

    set_property(GLOBAL APPEND PROPERTY CPPCOMMON_TESTS_TARGETS cppcommon-tests)

    add_dependencies(cppcommon-tests ${plugin_targets})

    set_target_properties(cppcommon-tests
        PROPERTIES
            FOLDER "${tests_folder}"
    )

    target_link_libraries(cppcommon-tests
        PRIVATE
            cppcommon-global-settings
            cppcommon-plugins-target-settings
            cppcommon
            Catch2::Catch2WithMain
    )

    enable_testing()
    add_test(
        NAME    cppcommon-tests
        COMMAND cppcommon-tests --durations yes --order lex
    )
endfunction()

# @brief    Configure tests module installation
# @details  Register the created test targets in the Tests component
function(cppcommon_tests_install)
    get_property(tests_targets GLOBAL PROPERTY CPPCOMMON_TESTS_TARGETS)

    if(NOT tests_targets)
        return()
    endif()

    install(
        TARGETS ${tests_targets}
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
        COMPONENT "${CPPCOMMON_TESTS_INSTALL_COMPONENT}"
    )

    if(MSVC)
        foreach(tests_target IN LISTS tests_targets)
            install(
                FILES       "$<TARGET_PDB_FILE:${tests_target}>"
                DESTINATION "${CMAKE_INSTALL_BINDIR}"
                COMPONENT   "${CPPCOMMON_TESTS_INSTALL_COMPONENT}"
                OPTIONAL
            )
        endforeach()
    endif()
endfunction()
