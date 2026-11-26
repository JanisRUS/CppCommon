# @brief    Initialize macOS platform support
# @details  Create platform settings targets
function(cppcommon_platform_init)
    add_library(cppcommon-platform-global-settings INTERFACE)
    add_library(cppcommon-platform-target-settings INTERFACE)
endfunction()

# @brief    Configure macOS platform settings
# @details  Configure compiler and linker options shared by project targets
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

    # Ignore duplicate libraries when linking with Apple Clang
    target_link_options(cppcommon-platform-global-settings
        INTERFACE
            -Wl,-no_warn_duplicate_libraries
    )
endfunction()

# @brief    Create additional macOS platform targets
# @details  No additional platform targets are required
function(cppcommon_platform_create_targets)
endfunction()

# @brief    Configure macOS platform installation
# @details  No platform-specific installation entries are required
function(cppcommon_platform_install)
endfunction()
