# @brief    Configure AppleClang compiler settings
# @details  Populate platform settings targets with AppleClang compiler and linker options
function(cppcommon_platform_configure_compiler_settings)
    target_compile_options(cppcommon-platform-global-settings
        INTERFACE
            -Wall
            -Werror
            -Wshadow
            -pedantic
    )

    target_link_options(cppcommon-platform-global-settings
        INTERFACE
            -Wl,-no_warn_duplicate_libraries
    )
endfunction()
