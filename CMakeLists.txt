cmake_minimum_required(VERSION 3.20)

project(cppcommon LANGUAGES CXX)

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

# Параметры дополнительных компонентов.
option(CPPCOMMON_BUILD_PLUGINS "Собирать плагины" OFF)
option(CPPCOMMON_BUILD_EXAMPLES "Собирать примеры" OFF)
option(CPPCOMMON_BUILD_BENCHMARKS "Собирать benchmarks" OFF)
option(CPPCOMMON_BUILD_TESTS "Собирать тесты" OFF)
option(CPPCOMMON_BUILD_DOCUMENTATION "Собирать документацию" OFF)

# Определение платформы и подключение её конфигурации.
if(CYGWIN OR MSYS OR WIN32)
    include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/windows.cmake")
elseif(APPLE)
    include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/macos.cmake")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/linux.cmake")
else()
    message(FATAL_ERROR
        "Платформа ${CMAKE_SYSTEM_NAME} не поддерживается CppCommon."
    )
endif()

# Инициализация интерфейса платформенной конфигурации.
set(PLATFORM_LIBS "")
set(PLATFORM_INCLUDE_DIRS "")
set(PLATFORM_COMPILE_DEFINITIONS "")
set(PLATFORM_COMPILE_OPTIONS "")
set(PLATFORM_LINK_OPTIONS "")

platform_configure_compiler()
platform_find_libraries()

# Общие настройки компилятора.
set(COMMON_COMPILE_OPTIONS "")

if(MSVC)
    list(APPEND COMMON_COMPILE_OPTIONS
        /W4
        /WX
        /wd4100
        /wd4250
    )
else()
    list(APPEND COMMON_COMPILE_OPTIONS
        -Wall
        -Werror
        -Wshadow
        -pedantic
    )

    if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        list(APPEND COMMON_COMPILE_OPTIONS
            -Wno-maybe-uninitialized
            -Wno-overflow
            -Wno-restrict
            -Wno-stringop-overflow
        )
    endif()
endif()

# Общий интерфейс параметров компиляции для целей проекта.
add_library(cppcommon_build_options INTERFACE)

target_compile_options(cppcommon_build_options
    INTERFACE
        ${COMMON_COMPILE_OPTIONS}
)

# Поиск общих зависимостей основной библиотеки.
find_package(Threads REQUIRED)
find_package(fmt CONFIG REQUIRED)

if(NOT TARGET fmt::fmt)
    message(FATAL_ERROR
        "Пакет fmt найден, но target fmt::fmt отсутствует. "
        "Проверьте установленный CMake package fmt."
    )
endif()

# Основная библиотека.
file(GLOB_RECURSE CPPCOMMON_HEADER_FILES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/include/*.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/source/*.h"
)
file(GLOB_RECURSE CPPCOMMON_INLINE_FILES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/include/*.inl"
    "${CMAKE_CURRENT_SOURCE_DIR}/source/*.inl"
)
file(GLOB_RECURSE CPPCOMMON_SOURCE_FILES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/include/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/source/*.cpp"
)

add_library(cppcommon
    ${CPPCOMMON_HEADER_FILES}
    ${CPPCOMMON_INLINE_FILES}
    ${CPPCOMMON_SOURCE_FILES}
)

set_target_properties(cppcommon PROPERTIES
    CXX_EXTENSIONS ON
    FOLDER "libraries"
)

target_compile_features(cppcommon PUBLIC cxx_std_23)

target_include_directories(cppcommon
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

if(PLATFORM_INCLUDE_DIRS)
    target_include_directories(cppcommon PRIVATE ${PLATFORM_INCLUDE_DIRS})
endif()

if(PLATFORM_COMPILE_DEFINITIONS)
    target_compile_definitions(cppcommon PRIVATE ${PLATFORM_COMPILE_DEFINITIONS})
endif()

target_compile_options(cppcommon
    PRIVATE
        ${COMMON_COMPILE_OPTIONS}
)

if(PLATFORM_COMPILE_OPTIONS)
    target_compile_options(cppcommon PRIVATE ${PLATFORM_COMPILE_OPTIONS})
endif()

if(PLATFORM_LINK_OPTIONS)
    target_link_options(cppcommon INTERFACE ${PLATFORM_LINK_OPTIONS})
endif()

if(PLATFORM_LIBS)
    target_link_libraries(cppcommon PRIVATE ${PLATFORM_LIBS})
endif()

target_link_libraries(cppcommon
    PUBLIC
        Threads::Threads
        fmt::fmt
)

# Платформенные точки расширения установки и удаления.
platform_configure_install()
platform_configure_uninstall()

# Дополнительные компоненты конфигурируются только по запросу.
if(CPPCOMMON_BUILD_PLUGINS)
    add_subdirectory(plugins)
endif()

if(CPPCOMMON_BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

if(CPPCOMMON_BUILD_BENCHMARKS)
    add_subdirectory(performance)
endif()

if(CPPCOMMON_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

if(CPPCOMMON_BUILD_DOCUMENTATION)
    find_package(Doxygen REQUIRED)

    add_custom_target(cppcommon-docs
        COMMAND "${DOXYGEN_EXECUTABLE}" "${CMAKE_CURRENT_SOURCE_DIR}/documents/Doxyfile"
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/documents"
        COMMENT "Генерация документации CppCommon"
        VERBATIM
    )
    set_target_properties(cppcommon-docs PROPERTIES FOLDER "documentation")
endif()

# Установка библиотеки и публичных заголовков.
install(TARGETS cppcommon
    EXPORT cppcommonTargets
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(DIRECTORY include/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/CppCommonConfig.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/CppCommonConfig.cmake"
    INSTALL_DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/CppCommon"
)

install(EXPORT cppcommonTargets
    NAMESPACE CppCommon::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/CppCommon"
)

install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/CppCommonConfig.cmake"
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/CppCommon"
)
