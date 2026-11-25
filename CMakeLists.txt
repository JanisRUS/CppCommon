#
# Common project options
#

cmake_minimum_required(VERSION 3.20)
project(cppcommon)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

option(CPPCOMMON_ENABLE_TESTING            "Enable testing support"                    OFF)
option(CPPCOMMON_BUILD_EXAMPLES            "Build examples"                            OFF)
option(CPPCOMMON_BUILD_PERFORMANCE         "Build performance benchmarks"              OFF)
option(CPPCOMMON_BUILD_DOCUMENTATION       "Build documentation"                       OFF)
option(CPPCOMMON_ENABLE_STACKTRACE_SYMBOLS "Enable extended stack trace symbolization" OFF)
option(CPPCOMMON_ENABLE_VLD                "Enable Visual Leak Detector integration"   OFF)

set(CMAKE_CXX_STANDARD   23)
set(CMAKE_CXX_EXTENSIONS ON)

set(CPPCOMMON_INCLUDE_DIR       "${CMAKE_CURRENT_LIST_DIR}/include")
set(CPPCOMMON_SOURCE_DIR        "${CMAKE_CURRENT_LIST_DIR}/source")
set(CPPCOMMON_INSTALL_COMPONENT "Core")
set(CPPCOMMON_PACKAGE_DIR       "${CMAKE_INSTALL_LIBDIR}/cmake/CppCommon")

#
# Modules connection
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
# Modules initialization
#

add_library(cppcommon-global-settings INTERFACE)

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
find_package(fmt CONFIG REQUIRED)

cppcommon_platform_init()
cppcommon_tests_init()
cppcommon_examples_init()
cppcommon_performance_init()

target_link_libraries(cppcommon-global-settings
    INTERFACE
        cppcommon-platform-global-settings
        cppcommon-tests-global-settings
        cppcommon-examples-global-settings
        cppcommon-performance-global-settings
)

#
# Settings configuration
#

cppcommon_platform_configure_settings()
cppcommon_tests_configure_settings()
cppcommon_examples_configure_settings()
cppcommon_performance_configure_settings()

#
# Targets creation
#

file(GLOB_RECURSE CPPCOMMON_HEADER_FILES "${CPPCOMMON_INCLUDE_DIR}/*.h")
file(GLOB_RECURSE CPPCOMMON_INLINE_FILES "${CPPCOMMON_INCLUDE_DIR}/*.inl")
file(GLOB_RECURSE CPPCOMMON_SOURCE_FILES "${CPPCOMMON_SOURCE_DIR}/*.cpp")

add_library(cppcommon
    ${CPPCOMMON_HEADER_FILES}
    ${CPPCOMMON_INLINE_FILES}
    ${CPPCOMMON_SOURCE_FILES}
)

add_library(CppCommon::CppCommon ALIAS cppcommon)
set_target_properties(cppcommon
    PROPERTIES
        EXPORT_NAME CppCommon
        FOLDER      "libraries"
)

target_include_directories(cppcommon
    PUBLIC
        "$<BUILD_INTERFACE:${CPPCOMMON_INCLUDE_DIR}>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)

target_link_libraries(cppcommon
    PUBLIC
        Threads::Threads
        fmt::fmt
    PRIVATE
        "$<BUILD_INTERFACE:cppcommon-global-settings>"
        "$<BUILD_INTERFACE:cppcommon-platform-target-settings>"
)

cppcommon_platform_create_targets()
cppcommon_tests_create_targets()
cppcommon_examples_create_targets()
cppcommon_performance_create_targets()

#
# Install rule configuration
#

# Keep the core installation self-contained and relocatable.
install(
    TARGETS cppcommon
    EXPORT  CppCommonTargets
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}" COMPONENT "${CPPCOMMON_INSTALL_COMPONENT}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT "${CPPCOMMON_INSTALL_COMPONENT}"
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}" COMPONENT "${CPPCOMMON_INSTALL_COMPONENT}"
)

install(
    DIRECTORY   "${CPPCOMMON_INCLUDE_DIR}/"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
    COMPONENT   "${CPPCOMMON_INSTALL_COMPONENT}"
    FILES_MATCHING
        PATTERN "*.h"
        PATTERN "*.inl"
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CppCommonConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/CppCommonConfig.cmake"
    INSTALL_DESTINATION "${CPPCOMMON_PACKAGE_DIR}"
)

install(
    EXPORT      CppCommonTargets
    FILE        CppCommonTargets.cmake
    NAMESPACE   CppCommon::
    DESTINATION "${CPPCOMMON_PACKAGE_DIR}"
    COMPONENT   "${CPPCOMMON_INSTALL_COMPONENT}"
)

install(
    FILES       "${CMAKE_CURRENT_BINARY_DIR}/CppCommonConfig.cmake"
    DESTINATION "${CPPCOMMON_PACKAGE_DIR}"
    COMPONENT   "${CPPCOMMON_INSTALL_COMPONENT}"
)

cppcommon_platform_install()
cppcommon_tests_install()
cppcommon_examples_install()
cppcommon_performance_install()

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
