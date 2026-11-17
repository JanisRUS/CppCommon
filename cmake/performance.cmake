# @brief    Initialize the performance module
# @details  Creates settings provided by module
# @note     Settings are empty now
function(performance_init)
    add_library(cppcommon_performance_global_settings INTERFACE)
    add_library(cppcommon_performance_target_settings INTERFACE)
endfunction()

# @brief    Configure performance module settings
# @details  Configures settings provided by module
# @note     Empty now
function(performance_configure_settings)
    if(NOT CPPCOMMON_BUILD_BENCHMARKS)
        return()
    endif()
endfunction()

# @brief    Create performance module targets
# @details  Creates module targets
function(performance_create_targets)
    if(NOT CPPCOMMON_BUILD_BENCHMARKS)
        return()
    endif()

    set(_performance_directory "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../performance")

    file(GLOB _performance_header_files "${_performance_directory}/*.h")
    file(GLOB _performance_inline_files "${_performance_directory}/*.inl")
    file(GLOB _performance_source_files "${_performance_directory}/*.cpp")

    plugins_check()
    get_property(_performance_plugin_targets GLOBAL PROPERTY CPPCOMMON_PLUGIN_TARGETS)

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
                cppcommon_global_settings
                cppcommon_performance_global_settings
                cppcommon_plugins_global_settings
                cppcommon
                cppbenchmark
        )

        if(_performance_plugin_targets)
            add_dependencies(${_benchmark_target} ${_performance_plugin_targets})
        endif()

        set_target_properties(${_benchmark_target} PROPERTIES
            FOLDER "performance"
        )

        list(APPEND _performance_targets ${_benchmark_target})
    endforeach()

    set(PERFORMANCE_TARGETS "${_performance_targets}" PARENT_SCOPE)
endfunction()

# @brief    Configure install variables
# @details  Configures install variables for module targets 
function(performance_install)
    if(NOT CPPCOMMON_BUILD_BENCHMARKS)
        return()
    endif()

    foreach(_performance_target IN LISTS PERFORMANCE_TARGETS)
        list(APPEND INSTALL_TARGETS "${_performance_target}")
        list(APPEND INSTALL_PATHS   "${PROJECT_SOURCE_DIR}/bin")
    endforeach()

    set(INSTALL_TARGETS "${INSTALL_TARGETS}" PARENT_SCOPE)
    set(INSTALL_PATHS   "${INSTALL_PATHS}"   PARENT_SCOPE)
endfunction()
