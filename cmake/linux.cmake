include(CheckIncludeFileCXX)

function(cppcommon_configure_platform target)
  # Dynamic loader support is used by DLL and stack trace implementations.
  check_include_file_cxx("dlfcn.h" CPPCOMMON_HAVE_DLFCN_H)
  if(CPPCOMMON_HAVE_DLFCN_H)
    target_compile_definitions(${target} PRIVATE LIBDL_SUPPORT)
    if(CMAKE_DL_LIBS)
      target_link_libraries(${target} PRIVATE ${CMAKE_DL_LIBS})
    endif()
  endif()

  # BFD enriches stack traces with source file and line information.
  # The implementation also uses Dl_info, so BFD is enabled only with dlfcn.h.
  if(CPPCOMMON_HAVE_DLFCN_H)
    find_path(CPPCOMMON_BFD_INCLUDE_DIR bfd.h)
    find_library(CPPCOMMON_BFD_LIBRARY NAMES bfd)
    if(CPPCOMMON_BFD_INCLUDE_DIR AND CPPCOMMON_BFD_LIBRARY)
      target_compile_definitions(${target} PRIVATE LIBBFD_SUPPORT)
      target_include_directories(${target} PRIVATE ${CPPCOMMON_BFD_INCLUDE_DIR})
      target_link_libraries(${target} PRIVATE ${CPPCOMMON_BFD_LIBRARY})
    endif()
  endif()

  # librt is needed by some older Linux distributions for POSIX realtime APIs.
  find_library(CPPCOMMON_RT_LIBRARY NAMES rt)
  if(CPPCOMMON_RT_LIBRARY)
    target_link_libraries(${target} PRIVATE ${CPPCOMMON_RT_LIBRARY})
  endif()

  # UUID support is optional at configure time, matching the previous build.
  find_path(CPPCOMMON_UUID_INCLUDE_DIR uuid/uuid.h)
  find_library(CPPCOMMON_UUID_LIBRARY NAMES uuid)
  if(CPPCOMMON_UUID_INCLUDE_DIR)
    target_include_directories(${target} PRIVATE ${CPPCOMMON_UUID_INCLUDE_DIR})
  endif()
  if(CPPCOMMON_UUID_LIBRARY)
    target_link_libraries(${target} PRIVATE ${CPPCOMMON_UUID_LIBRARY})
  endif()
endfunction()
