function(cppcommon_configure_platform target)
  # Apple ld supports this option to suppress duplicate-library warnings.
  target_link_options(${target} INTERFACE "LINKER:-no_warn_duplicate_libraries")
endfunction()
