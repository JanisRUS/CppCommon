# @brief    Configure Clang compiler settings
# @details  Populate platform settings targets with Clang compiler and linker options
function(cppcommon_platform_configure_compiler_settings)
    target_compile_options(cppcommon-platform-global-settings
        INTERFACE
            $<$<COMPILE_LANGUAGE:CXX>:-stdlib=libc++>
            -Wall
            -Werror
            -Wshadow
            -pedantic
    )

    target_link_options(cppcommon-platform-global-settings
        INTERFACE
            -stdlib=libc++
            -Wl,-no_warn_duplicate_libraries
    )
endfunction()
