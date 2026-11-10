if(NOT CPPCOMMON_MODULE)
  # Tests
  file(GLOB TESTS_HEADER_FILES "tests/*.h")
  file(GLOB TESTS_INLINE_FILES "tests/*.inl")
  file(GLOB TESTS_SOURCE_FILES "tests/*.cpp")
  add_executable(cppcommon-tests ${TESTS_HEADER_FILES} ${TESTS_INLINE_FILES} ${TESTS_SOURCE_FILES})
  platform_configure_target(cppcommon-tests)
  add_dependencies(cppcommon-tests ${PLUGINS})
  set_target_properties(cppcommon-tests PROPERTIES COMPILE_FLAGS "${PEDANTIC_COMPILE_FLAGS}" FOLDER "tests")
  target_include_directories(cppcommon-tests PRIVATE Catch2)
  target_link_libraries(cppcommon-tests ${LINKLIBS} Catch2)
  list(APPEND INSTALL_TARGETS cppcommon-tests)
  list(APPEND INSTALL_TARGETS_PDB cppcommon-tests)

  # CTest
  include(CTest)
  add_test(cppcommon-tests cppcommon-tests --durations yes --order lex)
endif()
