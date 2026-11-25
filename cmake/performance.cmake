set(CPPCOMMON_PERFORMANCE_DIR               "${CMAKE_CURRENT_LIST_DIR}/../performance")
set(CPPCOMMON_PERFORMANCE_TARGET_PREFIX     "cppcommon-performance-")
set(CPPCOMMON_PERFORMANCE_INSTALL_COMPONENT "Performance")

# @brief    Initialize the performance module
# @details  Create the performance settings targets and initialize the target list
function(cppcommon_performance_init)
    add_library(cppcommon-performance-global-settings INTERFACE)
    add_library(cppcommon-performance-target-settings INTERFACE)

    set_property(GLOBAL PROPERTY CPPCOMMON_PERFORMANCE_TARGETS "")
endfunction()

# @brief    Configure performance module settings
# @details  No additional performance-specific settings are required
function(cppcommon_performance_configure_settings)
endfunction()

# @brief    Create performance module targets
# @details  Create performance benchmark executables
function(cppcommon_performance_create_targets)
    if(NOT CPPCOMMON_BUILD_PERFORMANCE)
        return()
    endif()

    file(GLOB performance_header_files "${CPPCOMMON_PERFORMANCE_DIR}/*.h")
    file(GLOB performance_inline_files "${CPPCOMMON_PERFORMANCE_DIR}/*.inl")
    file(GLOB performance_source_files "${CPPCOMMON_PERFORMANCE_DIR}/*.cpp")

    cmake_path(GET CPPCOMMON_PERFORMANCE_DIR FILENAME performance_folder)

    foreach(performance_source_file IN LISTS performance_source_files)
        cmake_path(GET performance_source_file STEM performance_name)
        set(performance_target "${CPPCOMMON_PERFORMANCE_TARGET_PREFIX}${performance_name}")

        add_executable(${performance_target}
            ${performance_header_files}
            ${performance_inline_files}
            "${performance_source_file}"
        )

        set_property(GLOBAL APPEND PROPERTY CPPCOMMON_PERFORMANCE_TARGETS ${performance_target})

        target_link_libraries(${performance_target}
            PRIVATE
                cppcommon-global-settings
                cppcommon
                cppbenchmark
        )

        set_target_properties(${performance_target}
            PROPERTIES
                FOLDER "${performance_folder}"
        )
    endforeach()
endfunction()

# @brief    Configure performance module installation
# @details  Register the created benchmark targets in the Performance component
function(cppcommon_performance_install)
    get_property(performance_targets GLOBAL PROPERTY CPPCOMMON_PERFORMANCE_TARGETS)

    if(NOT performance_targets)
        return()
    endif()

    install(
        TARGETS ${performance_targets}
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
        COMPONENT "${CPPCOMMON_PERFORMANCE_INSTALL_COMPONENT}"
    )

    if(MSVC)
        foreach(performance_target IN LISTS performance_targets)
            install(
                FILES       "$<TARGET_PDB_FILE:${performance_target}>"
                DESTINATION "${CMAKE_INSTALL_BINDIR}"
                COMPONENT   "${CPPCOMMON_PERFORMANCE_INSTALL_COMPONENT}"
                OPTIONAL
            )
        endforeach()
    endif()
endfunction()
