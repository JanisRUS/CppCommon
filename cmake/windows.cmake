include(CheckIncludeFileCXX)

function(cppcommon_configure_platform target)
  # Keep platform definitions scoped to CppCommon.
  if(CYGWIN)
    target_compile_definitions(${target} PRIVATE WIN32 WIN32_LEAN_AND_MEAN _WIN32_WINNT=0x0A00)

    # Cygwin follows the POSIX stack-trace implementation in stack_trace.cpp.
    check_include_file_cxx("dlfcn.h" CPPCOMMON_HAVE_DLFCN_H)
    if(CPPCOMMON_HAVE_DLFCN_H)
      target_compile_definitions(${target} PRIVATE LIBDL_SUPPORT)
      if(CMAKE_DL_LIBS)
        target_link_libraries(${target} PRIVATE ${CMAKE_DL_LIBS})
      endif()

      find_path(CPPCOMMON_BFD_INCLUDE_DIR bfd.h)
      find_library(CPPCOMMON_BFD_LIBRARY NAMES bfd)
      if(CPPCOMMON_BFD_INCLUDE_DIR AND CPPCOMMON_BFD_LIBRARY)
        target_compile_definitions(${target} PRIVATE LIBBFD_SUPPORT)
        target_include_directories(${target} PRIVATE ${CPPCOMMON_BFD_INCLUDE_DIR})
        target_link_libraries(${target} PRIVATE ${CPPCOMMON_BFD_LIBRARY})
      endif()
    endif()
  else()
    target_compile_definitions(${target} PRIVATE
      WIN32
      WIN32_LEAN_AND_MEAN
      _CRT_SECURE_NO_DEPRECATE
      _SILENCE_ALL_CXX17_DEPRECATION_WARNINGS
      _WIN32_WINNT=0x0A00
    )
  endif()

  if(MSVC)
    target_compile_options(${target} PRIVATE /bigobj /utf-8 /Zc:__cplusplus)
  elseif(MINGW OR MSYS)
    target_compile_options(${target} PRIVATE -Wa,-mbig-obj)
    target_link_options(${target} INTERFACE -static-libgcc -static-libstdc++)
  endif()

  # UUID generation on Windows is provided by the RPC runtime.
  find_library(CPPCOMMON_RPC_LIBRARY NAMES rpcrt4 rpcrt4.lib)
  if(NOT CPPCOMMON_RPC_LIBRARY)
    message(FATAL_ERROR "CppCommon requires the Windows RPC runtime library (rpcrt4).")
  endif()
  target_link_libraries(${target} PRIVATE ${CPPCOMMON_RPC_LIBRARY})

  # Symbol and source-line information in stack traces is optional on native Windows.
  if(NOT CYGWIN)
    find_library(CPPCOMMON_DBGHELP_LIBRARY NAMES dbghelp dbghelp.lib)
    if(CPPCOMMON_DBGHELP_LIBRARY)
      target_compile_definitions(${target} PRIVATE DBGHELP_SUPPORT)
      target_link_libraries(${target} PRIVATE ${CPPCOMMON_DBGHELP_LIBRARY})
    endif()
  endif()
endfunction()
