# @brief    Initialize the performance module
# @details  Creates settings provided by module
# @note     Settings are empty now
function(cppcommon_performance_init)
    add_library(cppcommon-performance-global-settings INTERFACE)
    add_library(cppcommon_performance_target_settings INTERFACE)
endfunction()

# @brief    Configure performance module settings
# @details  Configures settings provided by module
# @note     Empty now
function(cppcommon_performance_configure_settings)
    if(NOT CPPCOMMON_BUILD_BENCHMARKS)
        return()
    endif()
endfunction()

# @brief    Create performance module targets
# @details  Creates module targets
function(cppcommon_performance_create_targets)
    if(NOT CPPCOMMON_BUILD_BENCHMARKS)
        return()
    endif()

    set(_performance_directory "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../performance")

    file(GLOB _performance_header_files "${_performance_directory}/*.h")
    file(GLOB _performance_inline_files "${_performance_directory}/*.inl")
    file(GLOB _performance_source_files "${_performance_directory}/*.cpp")

    set(_performance_targets)

    foreach(_performance_source_file IN LISTS _performance_source_files)
        get_filename_component(_benchmark_name "${_performance_source_file}" NAME_WE)
        set(_benchmark_target "cppcommon-performance-${_benchmark_name}")

        add_executable(${_benchmark_target}
            ${_performance_header_files}
            ${_performance_inline_files}
            "${_performance_source_file}"
        )

        target_link_libraries(${_benchmark_target}
            PRIVATE
                cppcommon-global-settings
                cppcommon
                cppbenchmark
        )

        set_target_properties(${_benchmark_target} PROPERTIES
            FOLDER "performance"
        )

        list(APPEND _performance_targets ${_benchmark_target})
    endforeach()

    set(PERFORMANCE_TARGETS "${_performance_targets}" PARENT_SCOPE)
endfunction()

# @brief    Install performance artifacts
# @details  Register benchmark executables in the Performance component
function(cppcommon_performance_install)
    if(NOT CPPCOMMON_BUILD_BENCHMARKS)
        return()
    endif()

    foreach(_performance_target IN LISTS PERFORMANCE_TARGETS)
        install(TARGETS ${_performance_target}
            RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
            COMPONENT Performance
        )

        if(MSVC)
            install(FILES "$<TARGET_PDB_FILE:${_performance_target}>"
                DESTINATION "${CMAKE_INSTALL_BINDIR}"
                COMPONENT Performance
                OPTIONAL
            )
        endif()
    endforeach()
endfunction()
