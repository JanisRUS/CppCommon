include(CheckIncludeFileCXX)

function(platform_find_libraries)
    # Поддержка загрузчика динамических библиотек и POSIX stack trace.
    check_include_file_cxx("dlfcn.h" CPPCOMMON_HAVE_DLFCN_H)
    if(CPPCOMMON_HAVE_DLFCN_H)
        list(APPEND PLATFORM_COMPILE_DEFINITIONS LIBDL_SUPPORT)
        if(CMAKE_DL_LIBS)
            list(APPEND PLATFORM_LIBS ${CMAKE_DL_LIBS})
        endif()
    endif()

    # BFD используется только для расширенной информации о stack trace.
    if(CPPCOMMON_HAVE_DLFCN_H)
        find_path(CPPCOMMON_BFD_INCLUDE_DIR NAMES bfd.h)
        find_library(CPPCOMMON_BFD_LIBRARY NAMES bfd)

        if(CPPCOMMON_BFD_INCLUDE_DIR AND CPPCOMMON_BFD_LIBRARY)
            list(APPEND PLATFORM_COMPILE_DEFINITIONS LIBBFD_SUPPORT)
            list(APPEND PLATFORM_INCLUDE_DIRS "${CPPCOMMON_BFD_INCLUDE_DIR}")
            list(APPEND PLATFORM_LIBS "${CPPCOMMON_BFD_LIBRARY}")
        endif()
    endif()

    # librt требуется некоторым старым Linux-системам.
    find_library(CPPCOMMON_RT_LIBRARY NAMES rt)
    if(CPPCOMMON_RT_LIBRARY)
        list(APPEND PLATFORM_LIBS "${CPPCOMMON_RT_LIBRARY}")
    endif()

    # UUID — обязательная зависимость Linux-реализации uuid.cpp.
    find_path(CPPCOMMON_UUID_INCLUDE_DIR NAMES uuid/uuid.h)
    find_library(CPPCOMMON_UUID_LIBRARY NAMES uuid)

    if(NOT CPPCOMMON_UUID_INCLUDE_DIR OR NOT CPPCOMMON_UUID_LIBRARY)
        message(FATAL_ERROR
            "Для CppCommon необходимы заголовки uuid/uuid.h и библиотека libuuid. "
            "Укажите CPPCOMMON_UUID_INCLUDE_DIR и CPPCOMMON_UUID_LIBRARY, "
            "если они установлены в нестандартном месте."
        )
    endif()

    list(APPEND PLATFORM_INCLUDE_DIRS "${CPPCOMMON_UUID_INCLUDE_DIR}")
    list(APPEND PLATFORM_LIBS "${CPPCOMMON_UUID_LIBRARY}")

    set(PLATFORM_LIBS "${PLATFORM_LIBS}" PARENT_SCOPE)
    set(PLATFORM_INCLUDE_DIRS "${PLATFORM_INCLUDE_DIRS}" PARENT_SCOPE)
    set(PLATFORM_COMPILE_DEFINITIONS "${PLATFORM_COMPILE_DEFINITIONS}" PARENT_SCOPE)
    set(PLATFORM_COMPILE_OPTIONS "${PLATFORM_COMPILE_OPTIONS}" PARENT_SCOPE)
    set(PLATFORM_LINK_OPTIONS "${PLATFORM_LINK_OPTIONS}" PARENT_SCOPE)
endfunction()

function(platform_configure_compiler)
    # Дополнительные параметры компилятора Linux не требуются.
endfunction()

function(platform_configure_install)
    # Зарезервировано для платформенно-зависимой настройки установки.
endfunction()

function(platform_configure_uninstall)
    # Зарезервировано для платформенно-зависимой настройки удаления.
endfunction()
