# @brief      Find macOS system libraries.
# @details    Provide the macOS library discovery hook. No additional platform
#             libraries are required at this stage.
# @note       Output variables: PLATFORM_LIBS, PLATFORM_INCLUDE_DIRS.
function(platform_find_libraries)
    set(_platform_libs ${PLATFORM_LIBS})
    set(_platform_include_dirs ${PLATFORM_INCLUDE_DIRS})

    set(PLATFORM_LIBS "${_platform_libs}" PARENT_SCOPE)
    set(PLATFORM_INCLUDE_DIRS "${_platform_include_dirs}" PARENT_SCOPE)
endfunction()

# @brief      Configure macOS compiler settings.
# @details    Preserve compiler settings supplied by the caller. Platform-specific
#             compiler options can be added here when required.
# @note       Output variables: PLATFORM_COMPILE_DEFINITIONS, PLATFORM_COMPILE_OPTIONS,
#             PLATFORM_LINK_OPTIONS.
function(platform_configure_compiler)
    set(_platform_compile_definitions ${PLATFORM_COMPILE_DEFINITIONS})
    set(_platform_compile_options ${PLATFORM_COMPILE_OPTIONS})
    set(_platform_link_options ${PLATFORM_LINK_OPTIONS})

    set(PLATFORM_COMPILE_DEFINITIONS "${_platform_compile_definitions}" PARENT_SCOPE)
    set(PLATFORM_COMPILE_OPTIONS "${_platform_compile_options}" PARENT_SCOPE)
    set(PLATFORM_LINK_OPTIONS "${_platform_link_options}" PARENT_SCOPE)
endfunction()

# @brief      Configure macOS installation rules.
# @details    Provide the platform-specific installation hook. No additional
#             macOS installation rules are required at this stage.
# @note       This function currently has no side effects.
function(platform_configure_install)
endfunction()

# @brief      Configure macOS uninstallation rules.
# @details    Provide the platform-specific uninstallation hook. No additional
#             macOS uninstallation rules are required at this stage.
# @note       This function currently has no side effects.
function(platform_configure_uninstall)
endfunction()
