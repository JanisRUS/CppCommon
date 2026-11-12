# Build the shared libraries used by the DLL tests and example.
foreach(PLUGIN_NAME IN ITEMS function interface)
    file(GLOB PLUGIN_HEADER_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/${PLUGIN_NAME}/*.h"
    )
    file(GLOB PLUGIN_INLINE_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/${PLUGIN_NAME}/*.inl"
    )
    file(GLOB PLUGIN_SOURCE_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/${PLUGIN_NAME}/*.cpp"
    )

    set(PLUGIN_TARGET "plugin-${PLUGIN_NAME}")

    add_library(${PLUGIN_TARGET} SHARED
        ${PLUGIN_HEADER_FILES}
        ${PLUGIN_INLINE_FILES}
        ${PLUGIN_SOURCE_FILES}
    )

    target_include_directories(${PLUGIN_TARGET}
        PRIVATE "${CMAKE_CURRENT_LIST_DIR}/../include"
    )

    target_compile_definitions(${PLUGIN_TARGET}
        PRIVATE EXPORTS
    )

    set_target_properties(${PLUGIN_TARGET} PROPERTIES
        FOLDER "plugins"
    )
endforeach()
