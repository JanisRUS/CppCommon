if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    include("${CMAKE_CURRENT_LIST_DIR}/gnu.cmake")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    include("${CMAKE_CURRENT_LIST_DIR}/clang.cmake")
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
    include("${CMAKE_CURRENT_LIST_DIR}/appleclang.cmake")
else()
    message(FATAL_ERROR "Unsupported macOS compiler: ${CMAKE_CXX_COMPILER_ID}")
endif()

# @brief    Initialize macOS platform support
# @details  Create platform settings targets
function(cppcommon_platform_init)
    add_library(cppcommon-platform-global-settings INTERFACE)
    add_library(cppcommon-platform-target-settings INTERFACE)
endfunction()

# @brief    Configure macOS platform settings
# @details  Configure platform settings targets for the selected compiler
function(cppcommon_platform_configure_settings)
    cppcommon_platform_configure_compiler_settings()
endfunction()

# @brief    Create additional macOS platform targets
# @details  No additional platform targets are required
function(cppcommon_platform_create_targets)
endfunction()

# @brief    Configure macOS platform installation
# @details  No platform-specific installation entries are required
function(cppcommon_platform_install)
endfunction()
