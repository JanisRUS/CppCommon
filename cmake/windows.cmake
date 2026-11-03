# @brief      Find Windows system and optional libraries.
# @details    Discover Windows system libraries and optionally enable Visual Leak
#             Detector when both its header and library are available.
# @note       Output variables: PLATFORM_LIBS, PLATFORM_INCLUDE_DIRS.
function(platform_find_libraries)
    set(_platform_libs ${PLATFORM_LIBS})
    set(_platform_include_dirs ${PLATFORM_INCLUDE_DIRS})

    find_package(DbgHelp)
    find_package(RPC)
    find_package(Userenv)

    list(APPEND _platform_libs ${DBGHELP_LIBRARIES})
    list(APPEND _platform_libs ${RPC_LIBRARIES})
    list(APPEND _platform_libs ${USERENV_LIBRARIES})

    # Visual Leak Detector is optional.
    find_path(VLD_INCLUDE_DIR
        NAMES vld.h
        HINTS "${CMAKE_CURRENT_SOURCE_DIR}/modules/vld/bin"
    )
    find_library(VLD_LIBRARY
        NAMES vld
        HINTS "${CMAKE_CURRENT_SOURCE_DIR}/modules/vld/bin"
    )

    mark_as_advanced(VLD_INCLUDE_DIR VLD_LIBRARY)

    if(VLD_INCLUDE_DIR AND VLD_LIBRARY)
        if(NOT TARGET VLD::VLD)
            add_library(VLD::VLD UNKNOWN IMPORTED)
            set_target_properties(VLD::VLD PROPERTIES
                IMPORTED_LOCATION "${VLD_LIBRARY}"
            )
        endif()

        list(APPEND _platform_libs VLD::VLD)
        list(APPEND _platform_include_dirs "${VLD_INCLUDE_DIR}")
    endif()

    set(PLATFORM_LIBS "${_platform_libs}" PARENT_SCOPE)
    set(PLATFORM_INCLUDE_DIRS "${_platform_include_dirs}" PARENT_SCOPE)
endfunction()

# @brief      Configure Windows compiler settings.
# @details    Preserve caller-provided compiler settings and enable VLD support
#             only when the optional Visual Leak Detector components are available.
# @note       Output variables: PLATFORM_COMPILE_DEFINITIONS, PLATFORM_COMPILE_OPTIONS,
#             PLATFORM_LINK_OPTIONS.
function(platform_configure_compiler)
    set(_platform_compile_definitions ${PLATFORM_COMPILE_DEFINITIONS})
    set(_platform_compile_options ${PLATFORM_COMPILE_OPTIONS})
    set(_platform_link_options ${PLATFORM_LINK_OPTIONS})

    if(VLD_INCLUDE_DIR AND VLD_LIBRARY)
        list(APPEND _platform_compile_definitions VLD_SUPPORT)
    endif()

    set(PLATFORM_COMPILE_DEFINITIONS "${_platform_compile_definitions}" PARENT_SCOPE)
    set(PLATFORM_COMPILE_OPTIONS "${_platform_compile_options}" PARENT_SCOPE)
    set(PLATFORM_LINK_OPTIONS "${_platform_link_options}" PARENT_SCOPE)
endfunction()

# @brief      Configure Windows installation rules.
# @details    Provide the platform-specific installation hook. No additional
#             Windows installation rules are required at this stage.
# @note       This function currently has no side effects.
function(platform_configure_install)
endfunction()

# @brief      Configure Windows uninstallation rules.
# @details    Provide the platform-specific uninstallation hook. No additional
#             Windows uninstallation rules are required at this stage.
# @note       This function currently has no side effects.
function(platform_configure_uninstall)
endfunction()
