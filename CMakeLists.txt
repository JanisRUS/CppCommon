cmake_minimum_required(VERSION 3.20)
project(cppcommon)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

#
# Project options
#

option(CPPCOMMON_ENABLE_TESTING            "Enable testing support"                    OFF)
option(CPPCOMMON_BUILD_EXAMPLES            "Build examples"                            OFF)
option(CPPCOMMON_BUILD_BENCHMARKS          "Build performance benchmarks"              OFF)
option(CPPCOMMON_BUILD_DOCUMENTATION       "Build documentation"                       OFF)
option(CPPCOMMON_ENABLE_STACKTRACE_SYMBOLS "Enable extended stack trace symbolization" OFF)
option(CPPCOMMON_ENABLE_VLD                "Enable Visual Leak Detector integration"   OFF)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_EXTENSIONS ON)

#
# Module selection
#

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    include(cmake/windows.cmake)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    include(cmake/macos.cmake)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    include(cmake/linux.cmake)
else()
    message(FATAL_ERROR "Unsupported platform: ${CMAKE_SYSTEM_NAME}")
endif()

include(cmake/plugins.cmake)
include(cmake/tests.cmake)
include(cmake/examples.cmake)
include(cmake/performance.cmake)

#
# 1. Initialization
#

add_library(cppcommon_global_settings INTERFACE)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
find_package(fmt CONFIG REQUIRED)

platform_init()
tests_init()
examples_init()
performance_init()

target_link_libraries(cppcommon_global_settings
    INTERFACE
        cppcommon_platform_global_settings
        cppcommon_tests_global_settings
        cppcommon_examples_global_settings
        cppcommon_performance_global_settings
)

#
# 2. Configure settings
#

platform_configure_settings()
tests_configure_settings()
examples_configure_settings()
performance_configure_settings()

#
# 3. Create targets
#

file(GLOB_RECURSE LIB_HEADER_FILES "include/*.h"   "source/*.h")
file(GLOB_RECURSE LIB_INLINE_FILES "include/*.inl" "source/*.inl")
file(GLOB_RECURSE LIB_SOURCE_FILES "include/*.cpp" "source/*.cpp")

add_library(cppcommon
    ${LIB_HEADER_FILES}
    ${LIB_INLINE_FILES}
    ${LIB_SOURCE_FILES}
)

add_library(CppCommon::CppCommon ALIAS cppcommon)
set_target_properties(cppcommon PROPERTIES
    EXPORT_NAME CppCommon
)

set_target_properties(cppcommon PROPERTIES
    FOLDER "libraries"
)

target_include_directories(cppcommon
    PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)

target_link_libraries(cppcommon
    PUBLIC
        Threads::Threads
        fmt::fmt
    PRIVATE
        "$<BUILD_INTERFACE:cppcommon_global_settings>"
        "$<BUILD_INTERFACE:cppcommon_platform_target_settings>"
)

platform_create_targets()
tests_create_targets()
examples_create_targets()
performance_create_targets()

#
# 4. Install
#

# Keep the core installation self-contained and relocatable.
install(TARGETS cppcommon
    EXPORT CppCommonTargets
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}" COMPONENT Core
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT Core
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT Core
)

install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/include/"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
    COMPONENT Core
    FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.inl"
)

set(_cppcommon_package_dir "${CMAKE_INSTALL_LIBDIR}/cmake/CppCommon")

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CppCommonConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/CppCommonConfig.cmake"
    INSTALL_DESTINATION "${_cppcommon_package_dir}"
)

install(EXPORT CppCommonTargets
    FILE CppCommonTargets.cmake
    NAMESPACE CppCommon::
    DESTINATION "${_cppcommon_package_dir}"
    COMPONENT Core
)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/CppCommonConfig.cmake"
    DESTINATION "${_cppcommon_package_dir}"
    COMPONENT Core
)

platform_install()
tests_install()
examples_install()
performance_install()

#
# Documentation
#

if(CPPCOMMON_BUILD_DOCUMENTATION)
    find_program(DOXYGEN doxygen)
    if(DOXYGEN)
        message(STATUS "Doxygen found: ${DOXYGEN}")
        add_custom_target(
            doxygen
            COMMAND ${DOXYGEN} Doxyfile
            WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/documents
            VERBATIM
        )
    else()
        message(FATAL_ERROR "CPPCOMMON_BUILD_DOCUMENTATION is enabled, but Doxygen was not found")
    endif()
endif()
