find_package(CppBenchmark CONFIG REQUIRED)

if(NOT TARGET CppBenchmark::cppbenchmark)
    message(FATAL_ERROR
        "Пакет CppBenchmark найден, но target CppBenchmark::cppbenchmark отсутствует."
    )
endif()

file(GLOB BENCHMARK_HEADER_FILES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.h"
)
file(GLOB BENCHMARK_INLINE_FILES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.inl"
)
file(GLOB BENCHMARK_SOURCE_FILES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
)

foreach(BENCHMARK_SOURCE_FILE IN LISTS BENCHMARK_SOURCE_FILES)
    get_filename_component(BENCHMARK_NAME "${BENCHMARK_SOURCE_FILE}" NAME_WE)
    set(BENCHMARK_TARGET "cppcommon-performance-${BENCHMARK_NAME}")

    add_executable(${BENCHMARK_TARGET}
        ${BENCHMARK_HEADER_FILES}
        ${BENCHMARK_INLINE_FILES}
        "${BENCHMARK_SOURCE_FILE}"
    )

    target_link_libraries(${BENCHMARK_TARGET}
        PRIVATE
            cppcommon
            CppBenchmark::cppbenchmark
            cppcommon_build_options
    )

    set_target_properties(${BENCHMARK_TARGET} PROPERTIES FOLDER "performance")

    install(TARGETS ${BENCHMARK_TARGET}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
endforeach()
