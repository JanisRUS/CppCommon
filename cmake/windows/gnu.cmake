# @brief    Configure GNU compiler settings
# @details  Populate platform settings targets with GNU compile definitions and compiler and linker options
function(cppcommon_platform_configure_compiler_settings)
    target_compile_options(cppcommon-platform-global-settings
        INTERFACE
            -Wall
            -Werror
            -Wshadow
            -pedantic
            -Wno-maybe-uninitialized
            -Wno-overflow
            -Wno-restrict
            -Wno-stringop-overflow
    )

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

    if(WIN32)
        target_compile_definitions(cppcommon-platform-global-settings
            INTERFACE
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
                windows_sdk_version
                "${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION}"
            )
        else()
            string(REGEX REPLACE
                "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$"
                "\\3"
                windows_sdk_version
                "${CMAKE_SYSTEM_VERSION}"
            )
        endif()

        if(windows_sdk_version)
            target_compile_definitions(cppcommon-platform-global-settings
                INTERFACE
                    _WIN32_SDK=${windows_sdk_version}
            )
        endif()
    endif()
endfunction()
