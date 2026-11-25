# @brief    Initialize the performance module
# @details  Create the performance settings targets
# @note     Settings are currently empty
function(cppcommon_performance_init)
    add_library(cppcommon-performance-global-settings INTERFACE)
    add_library(cppcommon-performance-target-settings INTERFACE)
endfunction()

# @brief    Configure performance module settings
# @details  Configure usage requirements shared by performance benchmarks
# @note     Settings are currently empty
function(cppcommon_performance_configure_settings)
    if(NOT CPPCOMMON_BUILD_PERFORMANCE)
        return()
    endif()
endfunction()

# @brief    Create performance module targets
# @details  Create performance benchmark executables
function(cppcommon_performance_create_targets)
    if(NOT CPPCOMMON_BUILD_PERFORMANCE)
        return()
    endif()

    set(performance_directory "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../performance")

    file(GLOB performance_header_files "${performance_directory}/*.h")
    file(GLOB performance_inline_files "${performance_directory}/*.inl")
    file(GLOB performance_source_files "${performance_directory}/*.cpp")

    set(performance_targets)

    foreach(performance_source_file IN LISTS performance_source_files)
        get_filename_component(performance_name "${performance_source_file}" NAME_WE)
        set(performance_target "cppcommon-performance-${performance_name}")

        add_executable(${performance_target}
            ${performance_header_files}
            ${performance_inline_files}
            "${performance_source_file}"
        )

        target_link_libraries(${performance_target}
            PRIVATE
                cppcommon-global-settings
                cppcommon
                cppbenchmark
        )

        set_target_properties(${performance_target} PROPERTIES
            FOLDER "performance"
        )

        list(APPEND performance_targets ${performance_target})
    endforeach()

    set(CPPCOMMON_PERFORMANCE_TARGETS "${performance_targets}" PARENT_SCOPE)
endfunction()

# @brief    Install performance artifacts
# @details  Register benchmark executables in the Performance component
function(cppcommon_performance_install)
    if(NOT CPPCOMMON_BUILD_PERFORMANCE)
        return()
    endif()

    foreach(performance_target IN LISTS CPPCOMMON_PERFORMANCE_TARGETS)
        install(TARGETS ${performance_target}
            RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
            COMPONENT Performance
        )

        if(MSVC)
            install(FILES "$<TARGET_PDB_FILE:${performance_target}>"
                DESTINATION "${CMAKE_INSTALL_BINDIR}"
                COMPONENT Performance
                OPTIONAL
            )
        endif()
    endforeach()
endfunction()
