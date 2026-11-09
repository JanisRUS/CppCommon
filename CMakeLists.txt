#
# Common project settings
#

cmake_minimum_required(VERSION 3.20)
project(cppcommon)

#
# Project options
#
option(BUILD_TESTING                       "Build unit and integration tests"          OFF)
option(CPPCOMMON_BUILD_EXAMPLES            "Build examples"                            OFF)
option(CPPCOMMON_BUILD_BENCHMARKS          "Build performance benchmarks"              OFF)
option(CPPCOMMON_BUILD_PLUGINS             "Build plugins"                             OFF)
option(CPPCOMMON_BUILD_DOCUMENTATION       "Build documentation"                       OFF)
option(CPPCOMMON_ENABLE_STACKTRACE_SYMBOLS "Enable extended stack trace symbolization" OFF)
option(CPPCOMMON_ENABLE_VLD                "Enable Visual Leak Detector integration"   OFF)

#
# Platform detection
#

if(CMAKE_SYSTEM_NAME     STREQUAL "Windows")
    include(cmake/windows.cmake)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    include(cmake/macos.cmake)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    include(cmake/linux.cmake)
else()
    message(FATAL_ERROR "Unsupported platform: ${CMAKE_SYSTEM_NAME}")
endif()

#
# Compiler features setup
#

# TODO Move to the cmake/codeCoverage.cmake
include(CodeCoverage)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_EXTENSIONS ON)

set(COMMON_COMPILE_OPTIONS)
set(COMMON_CXX_COMPILE_OPTIONS)
set(COMMON_LINK_OPTIONS)
set(PEDANTIC_COMPILE_OPTIONS)

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    list(APPEND COMMON_CXX_COMPILE_OPTIONS -stdlib=libc++)
    list(APPEND COMMON_LINK_OPTIONS        -stdlib=libc++)
endif()

if(NOT MSVC)
    list(APPEND COMMON_COMPILE_OPTIONS   -Wall    -Werror)
    list(APPEND PEDANTIC_COMPILE_OPTIONS -Wshadow -pedantic)

    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        list(APPEND PEDANTIC_COMPILE_OPTIONS
            -Wno-maybe-uninitialized
            -Wno-overflow
            -Wno-restrict
            -Wno-stringop-overflow
        )
    endif()
endif()

set(PLATFORM_COMPILE_DEFINITIONS)
set(PLATFORM_COMPILE_OPTIONS)
set(PLATFORM_LINK_OPTIONS)

platform_configure_compiler()

message("-- The System identification is ${CMAKE_SYSTEM_NAME} ${CMAKE_SYSTEM_VERSION} ${CMAKE_SYSTEM_INFO_FILE}")

#
# TODO Common and Platform libraries search
#
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

# The fmt module is required by the core library.
add_subdirectory("modules")

# System include directories for internal modules and plugins.
include_directories(SYSTEM "${CMAKE_CURRENT_SOURCE_DIR}/modules")
include_directories(SYSTEM "${CMAKE_CURRENT_SOURCE_DIR}/plugins")

# Apply project-wide compiler and linker settings.
# The module targets above keep their own compiler configuration.
add_compile_options(
    ${COMMON_COMPILE_OPTIONS}
    ${COMMON_CXX_COMPILE_OPTIONS}
    ${PEDANTIC_COMPILE_OPTIONS}
    ${PLATFORM_COMPILE_OPTIONS}
)
add_compile_definitions(${PLATFORM_COMPILE_DEFINITIONS})
add_link_options(${COMMON_LINK_OPTIONS} ${PLATFORM_LINK_OPTIONS})

#
# Library
#
file(GLOB_RECURSE LIB_HEADER_FILES "include/*.h"   "source/*.h")
file(GLOB_RECURSE LIB_INLINE_FILES "include/*.inl" "source/*.inl")
file(GLOB_RECURSE LIB_SOURCE_FILES "include/*.cpp" "source/*.cpp")

add_library(cppcommon
    ${LIB_HEADER_FILES}
    ${LIB_INLINE_FILES}
    ${LIB_SOURCE_FILES}
)

set_property(TARGET cppcommon PROPERTY FOLDER "libraries")

target_include_directories(cppcommon
    PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include"
)

target_link_libraries(cppcommon
    PUBLIC
        Threads::Threads
        fmt
)

# Visual Leak Detector is an optional Windows-only core integration.
if(CPPCOMMON_ENABLE_VLD)
    target_include_directories(cppcommon PRIVATE "${VLD_INCLUDE_DIR}")
    target_link_libraries(     cppcommon PRIVATE VLD::VLD)
    target_compile_definitions(cppcommon PRIVATE VLD_SUPPORT)
endif()

list(APPEND INSTALL_TARGETS cppcommon)

# Keep the legacy dependency list for the existing optional component scripts.
set(LINKLIBS cppcommon)

# Optional components
# Include component scripts from the project root because their source paths
# are intentionally relative to CMAKE_CURRENT_SOURCE_DIR.
if(CPPCOMMON_BUILD_PLUGINS)
    include(plugins/CMakeLists.txt)
endif()

if(BUILD_TESTING)
    include(CTest)
    include(tests/CMakeLists.txt)
endif()

if(CPPCOMMON_BUILD_EXAMPLES)
    include(examples/CMakeLists.txt)
endif()

if(CPPCOMMON_BUILD_BENCHMARKS)
    include(performance/CMakeLists.txt)
endif()

# Additional module components: installation
if(NOT CPPCOMMON_MODULE)

  # Install
  install(TARGETS ${INSTALL_TARGETS}
    RUNTIME DESTINATION "${PROJECT_SOURCE_DIR}/bin"
    LIBRARY DESTINATION "${PROJECT_SOURCE_DIR}/bin"
    ARCHIVE DESTINATION "${PROJECT_SOURCE_DIR}/bin")

  # Install *.pdb files
  if(MSVC)
    foreach(INSTALL_TARGET_PDB ${INSTALL_TARGETS_PDB})
      install(FILES $<TARGET_PDB_FILE:${INSTALL_TARGET_PDB}> DESTINATION "${PROJECT_SOURCE_DIR}/bin")
    endforeach()
  endif()

endif()

# Rule "documentation" setup
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
