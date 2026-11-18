# @brief    Initialize Linux platform support
# @details  Discover optional Linux system libraries and create platform settings targets
function(platform_init)
    add_library(cppcommon_platform_global_settings INTERFACE)
    add_library(cppcommon_platform_target_settings INTERFACE)

    find_package(LibBFD)
    find_package(LibDL)
    find_package(LibRT)
    find_package(LibUUID)

    set(_platform_libraries)
    set(_platform_include_directories)

    if(LIBBFD_FOUND)
        list(APPEND _platform_libraries ${LIBBFD_LIBRARIES})
        list(APPEND _platform_include_directories ${LIBBFD_INCLUDE_DIR})
    endif()

    if(LIBDL_FOUND)
        list(APPEND _platform_libraries ${LIBDL_LIBRARIES})
        list(APPEND _platform_include_directories ${LIBDL_INCLUDE_DIR})
    endif()

    if(LIBRT_FOUND)
        list(APPEND _platform_libraries ${LIBRT_LIBRARIES})
        list(APPEND _platform_include_directories ${LIBRT_INCLUDE_DIR})
    endif()

    if(LIBUUID_FOUND)
        list(APPEND _platform_libraries ${LIBUUID_LIBRARIES})
        list(APPEND _platform_include_directories ${LIBUUID_INCLUDE_DIR})
    endif()

    set(CPPCOMMON_PLATFORM_LIBRARIES
        "${_platform_libraries}"
        PARENT_SCOPE
    )
    set(CPPCOMMON_PLATFORM_INCLUDE_DIRECTORIES
        "${_platform_include_directories}"
        PARENT_SCOPE
    )
endfunction()

# @brief    Configure Linux platform settings
# @details  Populate the platform settings targets with discovered dependencies
function(platform_configure_settings)
    if(CPPCOMMON_PLATFORM_INCLUDE_DIRECTORIES)
        target_include_directories(cppcommon_platform_target_settings
            INTERFACE ${CPPCOMMON_PLATFORM_INCLUDE_DIRECTORIES}
        )
    endif()

    if(CPPCOMMON_PLATFORM_LIBRARIES)
        target_link_libraries(cppcommon_platform_target_settings
            INTERFACE ${CPPCOMMON_PLATFORM_LIBRARIES}
        )
    endif()
endfunction()

# @brief    Create additional Linux platform targets
# @details  No additional platform targets are required
function(platform_create_targets)
endfunction()

# @brief    Configure Linux platform installation
# @details  No platform-specific installation entries are required
function(platform_install)
endfunction()
