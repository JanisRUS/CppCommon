file(GLOB EXAMPLE_HEADER_FILES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.h"
)
file(GLOB EXAMPLE_INLINE_FILES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.inl"
)
file(GLOB EXAMPLE_SOURCE_FILES CONFIGURE_DEPENDS
    "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
)

foreach(EXAMPLE_SOURCE_FILE IN LISTS EXAMPLE_SOURCE_FILES)
    get_filename_component(EXAMPLE_NAME "${EXAMPLE_SOURCE_FILE}" NAME_WE)
    set(EXAMPLE_TARGET "cppcommon-example-${EXAMPLE_NAME}")

    add_executable(${EXAMPLE_TARGET}
        ${EXAMPLE_HEADER_FILES}
        ${EXAMPLE_INLINE_FILES}
        "${EXAMPLE_SOURCE_FILE}"
    )

    target_include_directories(${EXAMPLE_TARGET}
        PRIVATE
            "${PROJECT_SOURCE_DIR}/plugins"
    )

    target_link_libraries(${EXAMPLE_TARGET}
        PRIVATE
            cppcommon
            cppcommon_build_options
    )

    if(CPPCOMMON_PLUGIN_TARGETS)
        add_dependencies(${EXAMPLE_TARGET} ${CPPCOMMON_PLUGIN_TARGETS})
    endif()

    set_target_properties(${EXAMPLE_TARGET} PROPERTIES FOLDER "examples")

    install(TARGETS ${EXAMPLE_TARGET}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
endforeach()
