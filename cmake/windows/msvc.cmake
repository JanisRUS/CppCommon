# @brief    Configure MSVC compiler settings
# @details  Populate platform settings targets with MSVC compiler and linker options
function(cppcommon_platform_configure_compiler_settings)
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
endfunction()
