if(CYGWIN)
    if(NOT CMAKE_CXX_COMPILER_ID MATCHES "^(GNU|Clang|MSVC)$")
        message(FATAL_ERROR "Unsupported Cygwin compiler: ${CMAKE_CXX_COMPILER_ID}")
    endif()
    include("${CMAKE_CURRENT_LIST_DIR}/cygwin.cmake")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    include("${CMAKE_CURRENT_LIST_DIR}/gnu.cmake")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    include("${CMAKE_CURRENT_LIST_DIR}/clang.cmake")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    include("${CMAKE_CURRENT_LIST_DIR}/msvc.cmake")
else()
    message(FATAL_ERROR "Unsupported Windows compiler: ${CMAKE_CXX_COMPILER_ID}")
endif()

# @brief    Initialize Windows platform support
# @details  Create platform settings targets and discover enabled optional dependencies
function(cppcommon_platform_init)
    add_library(cppcommon-platform-global-settings INTERFACE)
    add_library(cppcommon-platform-target-settings INTERFACE)

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

        add_library(cppcommon-platform-dbghelp UNKNOWN IMPORTED)
        set_target_properties(cppcommon-platform-dbghelp
            PROPERTIES
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

        add_library(cppcommon-platform-vld UNKNOWN IMPORTED)
        set_target_properties(cppcommon-platform-vld
            PROPERTIES
                IMPORTED_LOCATION             "${CPPCOMMON_VLD_LIBRARY}"
                INTERFACE_INCLUDE_DIRECTORIES "${CPPCOMMON_VLD_INCLUDE_DIR}"
        )
    endif()
endfunction()

# @brief    Configure Windows platform settings
# @details  Populate platform settings targets with compiler options and dependencies
function(cppcommon_platform_configure_settings)
    cppcommon_platform_configure_compiler_settings()

    # Configure Windows system and optional libraries for the core target
    target_include_directories(cppcommon-platform-target-settings
        INTERFACE
            "${CPPCOMMON_RPC_INCLUDE_DIR}"
    )

    target_link_libraries(cppcommon-platform-target-settings
        INTERFACE
            Rpcrt4 # Windows RPC Runtime
            Userenv
    )

    if(CPPCOMMON_ENABLE_STACKTRACE_SYMBOLS)
        target_compile_definitions(cppcommon-platform-target-settings
            INTERFACE
                DBGHELP_SUPPORT
        )
        target_link_libraries(cppcommon-platform-target-settings
            INTERFACE
                cppcommon-platform-dbghelp
        )
    endif()

    if(CPPCOMMON_ENABLE_VLD)
        target_compile_definitions(cppcommon-platform-target-settings
            INTERFACE
                VLD_SUPPORT
        )
        target_link_libraries(cppcommon-platform-target-settings
            INTERFACE
                cppcommon-platform-vld
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
