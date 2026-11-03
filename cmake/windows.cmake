function(platform_find_libraries)
    # UUID на Windows предоставляется RPC runtime.
    find_library(CPPCOMMON_RPC_LIBRARY NAMES rpcrt4 rpcrt4.lib)

    if(NOT CPPCOMMON_RPC_LIBRARY)
        message(FATAL_ERROR
            "Для CppCommon необходима библиотека Windows RPC (rpcrt4). "
            "Укажите CPPCOMMON_RPC_LIBRARY, если она находится в нестандартном месте."
        )
    endif()

    list(APPEND PLATFORM_LIBS "${CPPCOMMON_RPC_LIBRARY}")

    # DbgHelp необязателен: без него stack trace остаётся доступен без символов.
    if(NOT CYGWIN)
        find_library(CPPCOMMON_DBGHELP_LIBRARY NAMES dbghelp dbghelp.lib)
        if(CPPCOMMON_DBGHELP_LIBRARY)
            list(APPEND PLATFORM_COMPILE_DEFINITIONS DBGHELP_SUPPORT)
            list(APPEND PLATFORM_LIBS "${CPPCOMMON_DBGHELP_LIBRARY}")
        endif()
    endif()

    set(PLATFORM_LIBS "${PLATFORM_LIBS}" PARENT_SCOPE)
    set(PLATFORM_INCLUDE_DIRS "${PLATFORM_INCLUDE_DIRS}" PARENT_SCOPE)
    set(PLATFORM_COMPILE_DEFINITIONS "${PLATFORM_COMPILE_DEFINITIONS}" PARENT_SCOPE)
    set(PLATFORM_COMPILE_OPTIONS "${PLATFORM_COMPILE_OPTIONS}" PARENT_SCOPE)
    set(PLATFORM_LINK_OPTIONS "${PLATFORM_LINK_OPTIONS}" PARENT_SCOPE)
endfunction()

function(platform_configure_compiler)
    if(CYGWIN)
        list(APPEND PLATFORM_COMPILE_DEFINITIONS
            WIN32
            WIN32_LEAN_AND_MEAN
            _WIN32_WINNT=0x0A00
        )
    else()
        list(APPEND PLATFORM_COMPILE_DEFINITIONS
            WIN32
            WIN32_LEAN_AND_MEAN
            _CRT_SECURE_NO_DEPRECATE
            _SILENCE_ALL_CXX17_DEPRECATION_WARNINGS
            _WIN32_WINNT=0x0A00
        )
    endif()

    if(MSVC)
        list(APPEND PLATFORM_COMPILE_OPTIONS
            /bigobj
            /utf-8
            /Zc:__cplusplus
        )
    elseif(MINGW OR MSYS)
        list(APPEND PLATFORM_COMPILE_OPTIONS -Wa,-mbig-obj)
        list(APPEND PLATFORM_LINK_OPTIONS
            -static-libgcc
            -static-libstdc++
        )
    endif()

    set(PLATFORM_COMPILE_DEFINITIONS "${PLATFORM_COMPILE_DEFINITIONS}" PARENT_SCOPE)
    set(PLATFORM_COMPILE_OPTIONS "${PLATFORM_COMPILE_OPTIONS}" PARENT_SCOPE)
    set(PLATFORM_LINK_OPTIONS "${PLATFORM_LINK_OPTIONS}" PARENT_SCOPE)
endfunction()

function(platform_configure_install)
    # Зарезервировано для платформенно-зависимой настройки установки.
endfunction()

function(platform_configure_uninstall)
    # Зарезервировано для платформенно-зависимой настройки удаления.
endfunction()
