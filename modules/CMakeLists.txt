# Core dependency
include("fmt.cmake")

# Optional dependencies
if(BUILD_TESTING)
    include("Catch2.cmake")
endif()

if(CPPCOMMON_BUILD_BENCHMARKS)
    include("CppBenchmark.cmake")
endif()
