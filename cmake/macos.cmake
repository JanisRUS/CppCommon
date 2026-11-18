# @brief    Initialize macOS platform support
# @details  Create platform settings targets
function(platform_init)
    add_library(cppcommon_platform_global_settings INTERFACE)
    add_library(cppcommon_platform_target_settings INTERFACE)
endfunction()

# @brief    Configure macOS platform settings
# @details  Configure compiler and linker options shared by project targets
function(platform_configure_settings)
    # Configure Clang compiler settings
    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        target_compile_options(cppcommon_platform_global_settings
            INTERFACE $<$<COMPILE_LANGUAGE:CXX>:-stdlib=libc++>
        )
        target_link_options(cppcommon_platform_global_settings
            INTERFACE -stdlib=libc++
        )
    endif()

    # Configure common compiler warnings
    target_compile_options(cppcommon_platform_global_settings
        INTERFACE -Wall -Werror -Wshadow -pedantic
    )

    # Configure GCC compiler warnings
    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        target_compile_options(cppcommon_platform_global_settings
            INTERFACE
                -Wno-maybe-uninitialized
                -Wno-overflow
                -Wno-restrict
                -Wno-stringop-overflow
        )
    endif()

    # Ignore duplicate libraries when linking with Apple Clang
    target_link_options(cppcommon_platform_global_settings
        INTERFACE -Wl,-no_warn_duplicate_libraries
    )
endfunction()

# @brief    Create additional macOS platform targets
# @details  No additional platform targets are required
function(platform_create_targets)
endfunction()

# @brief    Configure macOS platform installation
# @details  No platform-specific installation entries are required
function(platform_install)
endfunction()
