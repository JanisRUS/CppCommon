# @brief    Initialize Linux platform support
# @details  Discover optional Linux system libraries and create platform settings targets
function(platform_init)
    add_library(cppcommon_platform_global_settings INTERFACE)
    add_library(cppcommon_platform_target_settings INTERFACE)

    find_package(LibBFD)
    find_package(LibDL)
    find_package(LibRT)
    find_package(LibUUID)

    set(_platform_libraries
        ${LIBBFD_LIBRARIES}
        ${LIBDL_LIBRARIES}
        ${LIBRT_LIBRARIES}
        ${LIBUUID_LIBRARIES}
    )

    set(CPPCOMMON_PLATFORM_LIBRARIES
        "${_platform_libraries}"
        PARENT_SCOPE
    )
endfunction()

# @brief    Configure Linux platform settings
# @details  Populate the platform settings targets with discovered dependencies
function(platform_configure_settings)
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
