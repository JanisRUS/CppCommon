function(platform_find_libraries)
    # Дополнительные платформенные библиотеки не требуются.
endfunction()

function(platform_configure_compiler)
    list(APPEND PLATFORM_LINK_OPTIONS "LINKER:-no_warn_duplicate_libraries")

    set(PLATFORM_LINK_OPTIONS "${PLATFORM_LINK_OPTIONS}" PARENT_SCOPE)
endfunction()

function(platform_configure_install)
    # Зарезервировано для платформенно-зависимой настройки установки.
endfunction()

function(platform_configure_uninstall)
    # Зарезервировано для платформенно-зависимой настройки удаления.
endfunction()
