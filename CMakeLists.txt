#
# Common project settings
#

cmake_minimum_required(VERSION 3.20)
project(cppcommon)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
    include(cmake/windows.cmake)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    include(cmake/macos.cmake)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    include(cmake/linux.cmake)
else()
    message(FATAL_ERROR "Unsupported platform: ${CMAKE_SYSTEM_NAME}")
endif()

# TODO options like ENABLE_TESTS, ENABLE_BENCHMARKS 

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

# Modules
add_subdirectory("modules")

# Link libraries
list(APPEND LINKLIBS Threads::Threads)

# System directories
include_directories(SYSTEM "${CMAKE_CURRENT_SOURCE_DIR}/modules")
include_directories(SYSTEM "${CMAKE_CURRENT_SOURCE_DIR}/plugins")

# Library
file(GLOB_RECURSE LIB_HEADER_FILES "include/*.h" "source/*.h")
file(GLOB_RECURSE LIB_INLINE_FILES "include/*.inl" "source/*.inl")
file(GLOB_RECURSE LIB_SOURCE_FILES "include/*.cpp" "source/*.cpp")
add_library(cppcommon ${LIB_HEADER_FILES} ${LIB_INLINE_FILES} ${LIB_SOURCE_FILES})
set_target_properties(cppcommon PROPERTIES FOLDER "libraries")
target_include_directories(cppcommon PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include" PUBLIC ${vld})
target_link_libraries(cppcommon ${LINKLIBS} fmt)
list(APPEND INSTALL_TARGETS cppcommon)
list(APPEND LINKLIBS cppcommon)

# Additional module components: benchmarks, examples, plugins, tests, tools and install
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
find_program(DOXYGEN doxygen)
if(DOXYGEN)
    message(STATUS "Doxygen found: ${DOXYGEN}")
    add_custom_target(
        doxygen 
        COMMAND ${DOXYGEN} Doxyfile
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/documents
        VERBATIM
    )
endif()
