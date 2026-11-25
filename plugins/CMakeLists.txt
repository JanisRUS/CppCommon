set(CPPCOMMON_PLUGINS_TARGET_PREFIX "cppcommon-plugin-")
set(CPPCOMMON_PLUGINS_OUTPUT_PREFIX "plugin-")

#
# Modules initialization
#

add_library(cppcommon-plugins-target-settings INTERFACE)

set_property(GLOBAL PROPERTY CPPCOMMON_PLUGINS_TARGETS "")

#
# Settings configuration
#

target_include_directories(cppcommon-plugins-target-settings
    INTERFACE
        "${CMAKE_CURRENT_SOURCE_DIR}"
)

#
# Targets creation
#
file(GLOB CPPCOMMON_PLUGINS_DIRECTORIES
    LIST_DIRECTORIES true
    RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/*"
)

foreach(CPPCOMMON_PLUGINS_NAME IN LISTS CPPCOMMON_PLUGINS_DIRECTORIES)
    if(NOT IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/${CPPCOMMON_PLUGINS_NAME}")
        continue()
    endif()

    file(GLOB CPPCOMMON_PLUGINS_HEADER_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/${CPPCOMMON_PLUGINS_NAME}/*.h"
    )
    file(GLOB CPPCOMMON_PLUGINS_INLINE_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/${CPPCOMMON_PLUGINS_NAME}/*.inl"
    )
    file(GLOB CPPCOMMON_PLUGINS_SOURCE_FILES
        "${CMAKE_CURRENT_SOURCE_DIR}/${CPPCOMMON_PLUGINS_NAME}/*.cpp"
    )

    set(CPPCOMMON_PLUGINS_TARGET "${CPPCOMMON_PLUGINS_TARGET_PREFIX}${CPPCOMMON_PLUGINS_NAME}")

    add_library(${CPPCOMMON_PLUGINS_TARGET} SHARED
        ${CPPCOMMON_PLUGINS_HEADER_FILES}
        ${CPPCOMMON_PLUGINS_INLINE_FILES}
        ${CPPCOMMON_PLUGINS_SOURCE_FILES}
    )

    set_property(GLOBAL APPEND PROPERTY CPPCOMMON_PLUGINS_TARGETS ${CPPCOMMON_PLUGINS_TARGET})

    target_include_directories(${CPPCOMMON_PLUGINS_TARGET}
        PRIVATE
            "${CMAKE_CURRENT_LIST_DIR}/../include"
    )

    target_compile_definitions(${CPPCOMMON_PLUGINS_TARGET}
        PRIVATE
            EXPORTS
    )

    target_link_libraries(${CPPCOMMON_PLUGINS_TARGET}
        PRIVATE
            cppcommon-global-settings
    )

    set_target_properties(${CPPCOMMON_PLUGINS_TARGET} PROPERTIES
        FOLDER "plugins"
        OUTPUT_NAME "${CPPCOMMON_PLUGINS_OUTPUT_PREFIX}${CPPCOMMON_PLUGINS_NAME}"
    )
endforeach()

#
# Install rule configuration
#

get_property(CPPCOMMON_PLUGINS_TARGETS GLOBAL PROPERTY CPPCOMMON_PLUGINS_TARGETS)

# Install the plugin fixtures together with Core whenever they are built.
if(CPPCOMMON_PLUGINS_TARGETS)
    install(TARGETS ${CPPCOMMON_PLUGINS_TARGETS}
        RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
        LIBRARY DESTINATION "${CMAKE_INSTALL_BINDIR}"
        COMPONENT Core
    )
endif()
