# @brief    Find Windows system and optional libraries
# @details  Discover Windows system libraries and optionally enable Visual Leak
#               Detector when both its header and library are available
# @note     Output variables:
#           - PLATFORM_LIBS
#           - PLATFORM_INCLUDE_DIRS
function(platform_find_libraries)
    set(_platform_libs         ${PLATFORM_LIBS})
    set(_platform_include_dirs ${PLATFORM_INCLUDE_DIRS})

    find_package(DbgHelp)
    find_package(RPC)
    find_package(Userenv)

    list(APPEND _platform_libs ${DBGHELP_LIBRARIES})
    list(APPEND _platform_libs ${RPC_LIBRARIES})
    list(APPEND _platform_libs ${USERENV_LIBRARIES})

    # Visual Leak Detector is optional
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

    set(PLATFORM_LIBS         "${_platform_libs}"         PARENT_SCOPE)
    set(PLATFORM_INCLUDE_DIRS "${_platform_include_dirs}" PARENT_SCOPE)
endfunction()

# @brief    Configure target-specific Windows settings
# @details  Apply Windows-specific settings to the requested target
# @param    target Target name
function(platform_configure_target target)
    if("${target}" STREQUAL "cppcommon" AND CPPCOMMON_ENABLE_VLD)
        target_include_directories(cppcommon PRIVATE "${VLD_INCLUDE_DIR}")
        target_link_libraries(     cppcommon PRIVATE VLD::VLD)
        target_compile_definitions(cppcommon PRIVATE VLD_SUPPORT)
    endif()

    if("${target}" STREQUAL "cppcommon-tests" OR "${target}" STREQUAL "cppcommon-example-system_dll")
        target_include_directories(${target} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/plugins")
    endif()
endfunction()

# @brief    Configure Windows compiler settings
# @details  Preserve caller-provided compiler settings and enable VLD support
#               only when the optional Visual Leak Detector components are available
# @note     Output variables:
#           - PLATFORM_COMPILE_DEFINITIONS
#           - PLATFORM_COMPILE_OPTIONS
#           - PLATFORM_LINK_OPTIONS
function(platform_configure_compiler)
    set(_platform_compile_definitions ${PLATFORM_COMPILE_DEFINITIONS})
    set(_platform_compile_options     ${PLATFORM_COMPILE_OPTIONS})
    set(_platform_link_options        ${PLATFORM_LINK_OPTIONS})

    if(VLD_INCLUDE_DIR AND VLD_LIBRARY)
        list(APPEND _platform_compile_definitions VLD_SUPPORT)
    endif()

    # Configure MinGW-w64 compiler options
    if(MINGW)
        # Increase the number of sections that an object file can contain
        list(APPEND _platform_compile_options -Wa,-mbig-obj)

        # Link the GCC and C++ standard libraries statically
        list(APPEND _platform_link_options -static-libgcc -static-libstdc++)
    endif()

    # Configure Visual Studio compiler options
    if(MSVC)
        # Increase the number of sections that an object file can contain
        list(APPEND _platform_compile_options /bigobj)

        # Use UTF-8 for source and execution character sets
        list(APPEND _platform_compile_options /utf-8)

        # Report the correct value of __cplusplus
        list(APPEND _platform_compile_options /Zc:__cplusplus)

        # Configure compiler warnings
        list(APPEND _platform_compile_options /W4 /WX /wd4100 /wd4250)
    endif()

    # Configure Windows platform definitions
    if(CYGWIN)
        list(APPEND _platform_compile_definitions
            WIN32
            WIN32_LEAN_AND_MEAN
            _WIN32_WINNT=0x0A00
        )
    elseif(WIN32)
        list(APPEND _platform_compile_definitions
            WIN32
            WIN32_LEAN_AND_MEAN
            _CRT_SECURE_NO_DEPRECATE
            _SILENCE_ALL_CXX17_DEPRECATION_WARNINGS
            _WIN32_WINNT=0x0A00
        )

        # Determine the Windows SDK version
        if(CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION AND NOT MINGW)
            string(REGEX REPLACE
                "^([0-9]+)\\.([0-9]+)\\.([0-9]+)\\.([0-9]+)$"
                "\\3"
                _windows_sdk_version
                "${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION}"
            )
        else()
            string(REGEX REPLACE
                "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$"
                "\\3"
                _windows_sdk_version
                "${CMAKE_SYSTEM_VERSION}"
            )
        endif()

        if(_windows_sdk_version)
            list(APPEND _platform_compile_definitions
                _WIN32_SDK=${_windows_sdk_version}
            )
        endif()
    endif()

    set(PLATFORM_COMPILE_DEFINITIONS "${_platform_compile_definitions}" PARENT_SCOPE)
    set(PLATFORM_COMPILE_OPTIONS     "${_platform_compile_options}"     PARENT_SCOPE)
    set(PLATFORM_LINK_OPTIONS        "${_platform_link_options}"        PARENT_SCOPE)
endfunction()

# @brief      Configure Windows installation rules
# @details    Provide the platform-specific installation hook. No additional
#               Windows installation rules are required at this stage
# @note       This function currently has no side effects
function(platform_configure_install)
endfunction()

# @brief      Configure Windows uninstallation rules
# @details    Provide the platform-specific uninstallation hook. No additional
#             Windows uninstallation rules are required at this stage
# @note       This function currently has no side effects
function(platform_configure_uninstall)
endfunction()
