# @brief    Initialize Windows platform support
# @details  Create platform settings targets and discover enabled optional dependencies
function(cppcommon_platform_init)
    add_library(cppcommon-platform-global-settings INTERFACE)
    add_library(cppcommon_platform_target_settings INTERFACE)

    find_path(CPPCOMMON_RPC_INCLUDE_DIR
        NAMES rpc.h
        REQUIRED
    )
    mark_as_advanced(CPPCOMMON_RPC_INCLUDE_DIR)

    if(CPPCOMMON_ENABLE_STACKTRACE_SYMBOLS)
        find_library(CPPCOMMON_DBGHELP_LIBRARY
            NAMES dbghelp
            REQUIRED
        )
        mark_as_advanced(CPPCOMMON_DBGHELP_LIBRARY)

        add_library(cppcommon_platform_dbghelp UNKNOWN IMPORTED)
        set_target_properties(cppcommon_platform_dbghelp PROPERTIES
            IMPORTED_LOCATION "${CPPCOMMON_DBGHELP_LIBRARY}"
        )
    endif()

    if(CPPCOMMON_ENABLE_VLD)
        find_path(CPPCOMMON_VLD_INCLUDE_DIR
            NAMES vld.h
            HINTS "${CMAKE_CURRENT_SOURCE_DIR}/modules/vld/bin"
            REQUIRED
        )
        find_library(CPPCOMMON_VLD_LIBRARY
            NAMES vld
            HINTS "${CMAKE_CURRENT_SOURCE_DIR}/modules/vld/bin"
            REQUIRED
        )
        mark_as_advanced(CPPCOMMON_VLD_INCLUDE_DIR CPPCOMMON_VLD_LIBRARY)

        add_library(cppcommon_platform_vld UNKNOWN IMPORTED)
        set_target_properties(cppcommon_platform_vld PROPERTIES
            IMPORTED_LOCATION "${CPPCOMMON_VLD_LIBRARY}"
            INTERFACE_INCLUDE_DIRECTORIES "${CPPCOMMON_VLD_INCLUDE_DIR}"
        )
    endif()
endfunction()

# @brief    Configure Windows platform settings
# @details  Populate platform settings targets with compiler options and dependencies
function(cppcommon_platform_configure_settings)
    set(_platform_compile_definitions)
    set(_platform_compile_options)
    set(_platform_link_options)

    # Configure Clang compiler settings
    if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        target_compile_options(cppcommon-platform-global-settings
            INTERFACE $<$<COMPILE_LANGUAGE:CXX>:-stdlib=libc++>
        )
        target_link_options(cppcommon-platform-global-settings
            INTERFACE -stdlib=libc++
        )
    endif()

    # Configure GCC and Clang compiler warnings
    if(NOT MSVC)
        list(APPEND _platform_compile_options -Wall -Werror -Wshadow -pedantic)

        if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
            list(APPEND _platform_compile_options
                -Wno-maybe-uninitialized
                -Wno-overflow
                -Wno-restrict
                -Wno-stringop-overflow
            )
        endif()
    endif()

    # Configure MinGW-w64 compiler options
    if(MINGW)
        # Increase the number of sections that an object file can contain
        list(APPEND _platform_compile_options -Wa,-mbig-obj)

        # Link the GCC and C++ standard libraries statically
        list(APPEND _platform_link_options -static-libgcc -static-libstdc++)
    endif()

    # Configure Visual Studio compiler options
    if(MSVC)
        # Increase the number of sections that an object file can contain
        list(APPEND _platform_compile_options /bigobj)

        # Use UTF-8 for source and execution character sets
        list(APPEND _platform_compile_options /utf-8)

        # Report the correct value of __cplusplus
        list(APPEND _platform_compile_options /Zc:__cplusplus)

        # Configure compiler warnings
        list(APPEND _platform_compile_options /W4 /WX /wd4100 /wd4250)
    endif()

    # Configure Windows platform definitions
    if(CYGWIN)
        list(APPEND _platform_compile_definitions
            WIN32
            WIN32_LEAN_AND_MEAN
            _WIN32_WINNT=0x0A00
        )
    elseif(WIN32)
        list(APPEND _platform_compile_definitions
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
                _windows_sdk_version
                "${CMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION}"
            )
        else()
            string(REGEX REPLACE
                "^([0-9]+)\\.([0-9]+)\\.([0-9]+)$"
                "\\3"
                _windows_sdk_version
                "${CMAKE_SYSTEM_VERSION}"
            )
        endif()

        if(_windows_sdk_version)
            list(APPEND _platform_compile_definitions
                _WIN32_SDK=${_windows_sdk_version}
            )
        endif()
    endif()

    if(_platform_compile_definitions)
        target_compile_definitions(cppcommon-platform-global-settings
            INTERFACE ${_platform_compile_definitions}
        )
    endif()

    if(_platform_compile_options)
        target_compile_options(cppcommon-platform-global-settings
            INTERFACE ${_platform_compile_options}
        )
    endif()

    if(_platform_link_options)
        target_link_options(cppcommon-platform-global-settings
            INTERFACE ${_platform_link_options}
        )
    endif()

    # Configure Windows system and optional libraries for the core target
    target_include_directories(cppcommon_platform_target_settings
        INTERFACE "${CPPCOMMON_RPC_INCLUDE_DIR}"
    )

    target_link_libraries(cppcommon_platform_target_settings
        INTERFACE
            Rpcrt4 # Windows RPC Runtime
            Userenv
    )

    if(CPPCOMMON_ENABLE_STACKTRACE_SYMBOLS)
        target_compile_definitions(cppcommon_platform_target_settings
            INTERFACE DBGHELP_SUPPORT
        )
        target_link_libraries(cppcommon_platform_target_settings
            INTERFACE cppcommon_platform_dbghelp
        )
    endif()

    if(CPPCOMMON_ENABLE_VLD)
        target_compile_definitions(cppcommon_platform_target_settings
            INTERFACE VLD_SUPPORT
        )
        target_link_libraries(cppcommon_platform_target_settings
            INTERFACE cppcommon_platform_vld
        )
    endif()
endfunction()

# @brief    Create additional Windows platform targets
# @details  No additional platform targets are required
function(cppcommon_platform_create_targets)
endfunction()

# @brief    Configure Windows platform installation
# @details  No platform-specific installation entries are required
function(cppcommon_platform_install)
endfunction()
