# @brief    Configure Cygwin compiler settings
# @details  Populate platform settings targets with Cygwin compile definitions and compiler and linker options
function(cppcommon_platform_configure_compiler_settings)
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

    if(NOT MSVC)
        target_compile_options(cppcommon-platform-global-settings
            INTERFACE
                -Wall
                -Werror
                -Wshadow
                -pedantic
        )

        if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
            target_compile_options(cppcommon-platform-global-settings
                INTERFACE
                    -Wno-maybe-uninitialized
                    -Wno-overflow
                    -Wno-restrict
                    -Wno-stringop-overflow
            )
        endif()
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

    target_compile_definitions(cppcommon-platform-global-settings
        INTERFACE
            WIN32
            WIN32_LEAN_AND_MEAN
            _WIN32_WINNT=0x0A00
    )
endfunction()
