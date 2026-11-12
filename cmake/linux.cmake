set(PLATFORM_COMPILE_DEFINITIONS)
set(PLATFORM_COMPILE_OPTIONS)
set(PLATFORM_LINK_OPTIONS)

# @brief    Find Linux system libraries
# @details  Discover optional Linux libraries and append their link dependencies
#               to the platform configuration variables
# @note     Output variables:
#           - PLATFORM_LIBS
#           - PLATFORM_INCLUDE_DIRS
function(platform_get_libraries)
    set(_platform_libs         ${PLATFORM_LIBS})
    set(_platform_include_dirs ${PLATFORM_INCLUDE_DIRS})

    find_package(LibBFD)
    find_package(LibDL)
    find_package(LibRT)
    find_package(LibUUID)

    list(APPEND _platform_libs ${LIBBFD_LIBRARIES})
    list(APPEND _platform_libs ${LIBDL_LIBRARIES})
    list(APPEND _platform_libs ${LIBRT_LIBRARIES})
    list(APPEND _platform_libs ${LIBUUID_LIBRARIES})

    set(PLATFORM_LIBS         "${_platform_libs}"         PARENT_SCOPE)
    set(PLATFORM_INCLUDE_DIRS "${_platform_include_dirs}" PARENT_SCOPE)
endfunction()

# @brief    Link Linux system libraries to a target
# @details  Apply platform-specific dependencies to the requested target
# @param    target Target name

# @brief    Configure Linux compiler settings
# @details  Preserve compiler settings supplied by the caller. Platform-specific
#               compiler options can be added here when required
# @note     Output variables: 
#           - PLATFORM_COMPILE_DEFINITIONS
#           - PLATFORM_COMPILE_OPTIONS
#           - PLATFORM_LINK_OPTIONS
function(platform_get_compiler_settings)
    set(_platform_compile_definitions ${PLATFORM_COMPILE_DEFINITIONS})
    set(_platform_compile_options     ${PLATFORM_COMPILE_OPTIONS})
    set(_platform_link_options        ${PLATFORM_LINK_OPTIONS})

    # No additional Linux-specific compiler settings are required

    set(PLATFORM_COMPILE_DEFINITIONS "${_platform_compile_definitions}" PARENT_SCOPE)
    set(PLATFORM_COMPILE_OPTIONS     "${_platform_compile_options}"     PARENT_SCOPE)
    set(PLATFORM_LINK_OPTIONS        "${_platform_link_options}"        PARENT_SCOPE)
endfunction()

# @brief    Configure target-specific Linux settings
# @details  Apply Linux-specific settings to the requested target
# @param    target Target name
function(platform_setup_target target)
    if("${target}" STREQUAL "cppcommon-tests"              OR 
       "${target}" STREQUAL "cppcommon-example-system_dll")
        target_include_directories(${target} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/plugins")
    endif()

    if("${target}" STREQUAL "cppcommon")
        if(PLATFORM_INCLUDE_DIRS)
            target_include_directories(${target} PRIVATE ${PLATFORM_INCLUDE_DIRS})
        endif()

        if(PLATFORM_LIBS)
            target_link_libraries(${target} PRIVATE ${PLATFORM_LIBS})
        endif()
    endif()
endfunction()

# @brief      Configure Linux installation rules
# @details    Provide the platform-specific installation hook. No additional
#               Linux installation rules are required at this stage
# @note       This function currently has no side effects
function(platform_setup_install)

endfunction()

# @brief      Configure Linux uninstallation rules
# @details    Provide the platform-specific uninstallation hook. No additional
#             Linux uninstallation rules are required at this stage
# @note       This function currently has no side effects
function(platform_setup_uninstall)

endfunction()

# @brief      Create additional platform targets
# @details    Provide the platform-specific target creation hook
# @note       This function currently has no side effects
function(platform_create_targets)
endfunction()
