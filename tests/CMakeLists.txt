find_package(Catch2 3 CONFIG REQUIRED)

if(NOT TARGET Catch2::Catch2WithMain)
    message(FATAL_ERROR
        "Пакет Catch2 найден, но цель Catch2::Catch2WithMain отсутствует."
    )
endif()

find_path(CPPCOMMON_CATCH2_INCLUDE_DIR
    NAMES catch_amalgamated.hpp
    PATH_SUFFIXES catch2 extras
)

if(NOT CPPCOMMON_CATCH2_INCLUDE_DIR)
    message(FATAL_ERROR
        "Не найден catch_amalgamated.hpp. Укажите CPPCOMMON_CATCH2_INCLUDE_DIR."
    )
endif()

file(GLOB TEST_HEADER_FILES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.h"
)
file(GLOB TEST_INLINE_FILES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.inl"
)
file(GLOB TEST_SOURCE_FILES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
)

add_executable(cppcommon-tests
    ${TEST_HEADER_FILES}
    ${TEST_INLINE_FILES}
    ${TEST_SOURCE_FILES}
)

target_include_directories(cppcommon-tests
    PRIVATE
        ${CPPCOMMON_CATCH2_INCLUDE_DIR}
)

target_link_libraries(cppcommon-tests
    PRIVATE
        cppcommon
        Catch2::Catch2WithMain
        cppcommon_build_options
)

set_target_properties(cppcommon-tests PROPERTIES FOLDER "tests")

install(TARGETS cppcommon-tests
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

add_test(NAME cppcommon-tests
    COMMAND cppcommon-tests --durations yes --order lex
)
