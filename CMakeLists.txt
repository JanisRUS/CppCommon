cmake_minimum_required(VERSION 3.20)

project(cppcommon)

# Platform configuration
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  include(cmake/windows.cmake)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  include(cmake/macos.cmake)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  include(cmake/linux.cmake)
else()
  message(FATAL_ERROR "Unsupported platform: ${CMAKE_SYSTEM_NAME}")
endif()

# Doxygen
find_package(Doxygen)
if(DOXYGEN_FOUND)
  set(DOXYGEN "doxygen")
  if(NOT TARGET ${DOXYGEN})
    add_custom_command(OUTPUT "Doxyfile" COMMAND ${DOXYGEN_EXECUTABLE} "Doxyfile" WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/documents")
    add_custom_target(${DOXYGEN} DEPENDS "Doxyfile")
    set_target_properties(${DOXYGEN} PROPERTIES FOLDER "doxygen")
  endif()
endif()

# CMake module path
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Compiler features
include(CodeCoverage)
include(SetCompilerFeatures)
include(SetCompilerWarnings)
include(SetPlatformFeatures)
include(SystemInformation)

# External packages
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
set_target_properties(cppcommon PROPERTIES COMPILE_FLAGS "${PEDANTIC_COMPILE_FLAGS}" FOLDER "libraries")
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
