# @brief    Initialize Linux platform support
# @details  Discover Linux system libraries and create platform settings targets
function(cppcommon_platform_init)
    add_library(cppcommon-platform-global-settings INTERFACE)
    add_library(cppcommon-platform-target-settings INTERFACE)

    find_package(PkgConfig REQUIRED)
    pkg_check_modules(LibUUID REQUIRED IMPORTED_TARGET uuid)

    find_library(CPPCOMMON_RT_LIBRARY
        NAMES rt
        REQUIRED
    )
    mark_as_advanced(CPPCOMMON_RT_LIBRARY)

    if(CPPCOMMON_ENABLE_STACKTRACE_SYMBOLS)
        find_path(CPPCOMMON_BFD_INCLUDE_DIR
            NAMES bfd.h
            REQUIRED
        )
        find_library(CPPCOMMON_BFD_LIBRARY
            NAMES bfd
            REQUIRED
        )
        mark_as_advanced(CPPCOMMON_BFD_INCLUDE_DIR CPPCOMMON_BFD_LIBRARY)

        add_library(cppcommon-platform-bfd UNKNOWN IMPORTED)
        set_target_properties(cppcommon-platform-bfd PROPERTIES
            IMPORTED_LOCATION "${CPPCOMMON_BFD_LIBRARY}"
            INTERFACE_INCLUDE_DIRECTORIES "${CPPCOMMON_BFD_INCLUDE_DIR}"
        )
    endif()
endfunction()

# @brief    Configure Linux platform settings
# @details  Populate platform settings targets with compiler options and dependencies
function(cppcommon_platform_configure_settings)
    # Configure Clang compiler settings
    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        target_compile_options(cppcommon-platform-global-settings
            INTERFACE
                $<$<COMPILE_LANGUAGE:CXX>:-stdlib=libc++>
        )
        target_link_options(cppcommon-platform-global-settings
            INTERFACE
                -stdlib=libc++
        )
    endif()

    # Configure common compiler warnings
    target_compile_options(cppcommon-platform-global-settings
        INTERFACE
            -Wall -Werror -Wshadow -pedantic
    )

    # Configure GCC compiler warnings
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        target_compile_options(cppcommon-platform-global-settings
            INTERFACE
                -Wno-maybe-uninitialized
                -Wno-overflow
                -Wno-restrict
                -Wno-stringop-overflow
        )
    endif()

    target_compile_definitions(cppcommon-platform-global-settings
        INTERFACE
            LIBUUID_SUPPORT
            LIBDL_SUPPORT
            LIBRT_SUPPORT
    )

    target_link_libraries(cppcommon-platform-target-settings
        INTERFACE
            PkgConfig::LibUUID
            ${CMAKE_DL_LIBS}
            "${CPPCOMMON_RT_LIBRARY}"
    )

    if(CPPCOMMON_ENABLE_STACKTRACE_SYMBOLS)
        target_compile_definitions(cppcommon-platform-global-settings
            INTERFACE
                LIBBFD_SUPPORT
        )
        target_link_libraries(cppcommon-platform-target-settings
            INTERFACE
                cppcommon-platform-bfd
        )
    endif()
endfunction()

# @brief    Create additional Linux platform targets
# @details  No additional platform targets are required
function(cppcommon_platform_create_targets)
endfunction()

# @brief    Configure Linux platform installation
# @details  Preserve the system link dependencies of an installed static library
function(cppcommon_platform_install)
    target_link_libraries(cppcommon
        INTERFACE
            "$<INSTALL_INTERFACE:$<LINK_ONLY:PkgConfig::LibUUID>>"
            "$<INSTALL_INTERFACE:$<LINK_ONLY:${CMAKE_DL_LIBS}>>"
            "$<INSTALL_INTERFACE:$<LINK_ONLY:rt>>"
    )

    if(CPPCOMMON_ENABLE_STACKTRACE_SYMBOLS)
        message(WARNING
            "Installed static CppCommon with BFD support requires separate "
            "validation of BFD transitive link dependencies"
        )
    endif()
endfunction()
