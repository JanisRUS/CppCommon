# @brief    Configure Clang compiler settings
# @details  Populate platform settings targets with Clang compiler and linker options
function(cppcommon_platform_configure_compiler_settings)
    target_compile_options(cppcommon-platform-global-settings
        INTERFACE
            $<$<COMPILE_LANGUAGE:CXX>:-stdlib=libc++>
    )

    target_link_options(cppcommon-platform-global-settings
        INTERFACE
            -stdlib=libc++
    )

    if(NOT MSVC)
        target_compile_options(cppcommon-platform-global-settings
            INTERFACE
                -Wall
                -Werror
                -Wshadow
                -pedantic
        )
    endif()

    if(MINGW)
        target_compile_options(cppcommon-platform-global-settings
            INTERFACE
                -Wa,-mbig-obj
        )

        target_link_options(cppcommon-platform-global-settings
            INTERFACE
                -static-libgcc
                -static-libstdc++
        )
    endif()

    if(MSVC)
        target_compile_options(cppcommon-platform-global-settings
            INTERFACE
                /bigobj
                /utf-8
                /Zc:__cplusplus
                /W4
                /WX
                /wd4100
                /wd4250
        )
    endif()
endfunction()
