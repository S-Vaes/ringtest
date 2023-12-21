include(CMakeDependentOption)
include(CheckCXXCompilerFlag)


macro(RingBuffer_supports_sanitizers)
  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)
    set(SUPPORTS_UBSAN ON)
  else()
    set(SUPPORTS_UBSAN OFF)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else()
    set(SUPPORTS_ASAN ON)
  endif()
endmacro()

macro(RingBuffer_setup_options)
  option(RingBuffer_ENABLE_HARDENING "Enable hardening" ON)
  option(RingBuffer_ENABLE_COVERAGE "Enable coverage reporting" OFF)
  cmake_dependent_option(
    RingBuffer_ENABLE_GLOBAL_HARDENING
    "Attempt to push hardening options to built dependencies"
    ON
    RingBuffer_ENABLE_HARDENING
    OFF)

  RingBuffer_supports_sanitizers()

  if(NOT PROJECT_IS_TOP_LEVEL OR RingBuffer_PACKAGING_MAINTAINER_MODE)
    option(RingBuffer_ENABLE_IPO "Enable IPO/LTO" OFF)
    option(RingBuffer_WARNINGS_AS_ERRORS "Treat Warnings As Errors" OFF)
    option(RingBuffer_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(RingBuffer_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" OFF)
    option(RingBuffer_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(RingBuffer_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" OFF)
    option(RingBuffer_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(RingBuffer_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(RingBuffer_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(RingBuffer_ENABLE_CLANG_TIDY "Enable clang-tidy" OFF)
    option(RingBuffer_ENABLE_CPPCHECK "Enable cpp-check analysis" OFF)
    option(RingBuffer_ENABLE_PCH "Enable precompiled headers" OFF)
    option(RingBuffer_ENABLE_CACHE "Enable ccache" OFF)
  else()
    option(RingBuffer_ENABLE_IPO "Enable IPO/LTO" ON)
    option(RingBuffer_WARNINGS_AS_ERRORS "Treat Warnings As Errors" ON)
    option(RingBuffer_ENABLE_USER_LINKER "Enable user-selected linker" OFF)
    option(RingBuffer_ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" ${SUPPORTS_ASAN})
    option(RingBuffer_ENABLE_SANITIZER_LEAK "Enable leak sanitizer" OFF)
    option(RingBuffer_ENABLE_SANITIZER_UNDEFINED "Enable undefined sanitizer" ${SUPPORTS_UBSAN})
    option(RingBuffer_ENABLE_SANITIZER_THREAD "Enable thread sanitizer" OFF)
    option(RingBuffer_ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" OFF)
    option(RingBuffer_ENABLE_UNITY_BUILD "Enable unity builds" OFF)
    option(RingBuffer_ENABLE_CLANG_TIDY "Enable clang-tidy" ON)
    option(RingBuffer_ENABLE_CPPCHECK "Enable cpp-check analysis" ON)
    option(RingBuffer_ENABLE_PCH "Enable precompiled headers" OFF)
    option(RingBuffer_ENABLE_CACHE "Enable ccache" ON)
  endif()

  if(NOT PROJECT_IS_TOP_LEVEL)
    mark_as_advanced(
      RingBuffer_ENABLE_IPO
      RingBuffer_WARNINGS_AS_ERRORS
      RingBuffer_ENABLE_USER_LINKER
      RingBuffer_ENABLE_SANITIZER_ADDRESS
      RingBuffer_ENABLE_SANITIZER_LEAK
      RingBuffer_ENABLE_SANITIZER_UNDEFINED
      RingBuffer_ENABLE_SANITIZER_THREAD
      RingBuffer_ENABLE_SANITIZER_MEMORY
      RingBuffer_ENABLE_UNITY_BUILD
      RingBuffer_ENABLE_CLANG_TIDY
      RingBuffer_ENABLE_CPPCHECK
      RingBuffer_ENABLE_COVERAGE
      RingBuffer_ENABLE_PCH
      RingBuffer_ENABLE_CACHE)
  endif()

endmacro()

macro(RingBuffer_global_options)
  RingBuffer_supports_sanitizers()

  if(RingBuffer_ENABLE_HARDENING AND RingBuffer_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR RingBuffer_ENABLE_SANITIZER_UNDEFINED
       OR RingBuffer_ENABLE_SANITIZER_ADDRESS
       OR RingBuffer_ENABLE_SANITIZER_THREAD
       OR RingBuffer_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    message("${RingBuffer_ENABLE_HARDENING} ${ENABLE_UBSAN_MINIMAL_RUNTIME} ${RingBuffer_ENABLE_SANITIZER_UNDEFINED}")
    RingBuffer_enable_hardening(RingBuffer_options ON ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()
endmacro()

macro(RingBuffer_local_options)
  if(PROJECT_IS_TOP_LEVEL)
    include(cmake/StandardProjectSettings.cmake)
  endif()

  add_library(RingBuffer_warnings INTERFACE)
  add_library(RingBuffer_options INTERFACE)

  include(cmake/CompilerWarnings.cmake)
  RingBuffer_set_project_warnings(
    RingBuffer_warnings
    ${RingBuffer_WARNINGS_AS_ERRORS}
    ""
    ""
    ""
    "")

  if(RingBuffer_ENABLE_USER_LINKER)
    include(cmake/Linker.cmake)
    configure_linker(RingBuffer_options)
  endif()

  include(cmake/Sanitizers.cmake)
  RingBuffer_enable_sanitizers(
    RingBuffer_options
    ${RingBuffer_ENABLE_SANITIZER_ADDRESS}
    ${RingBuffer_ENABLE_SANITIZER_LEAK}
    ${RingBuffer_ENABLE_SANITIZER_UNDEFINED}
    ${RingBuffer_ENABLE_SANITIZER_THREAD}
    ${RingBuffer_ENABLE_SANITIZER_MEMORY})

  set_target_properties(RingBuffer_options PROPERTIES UNITY_BUILD ${RingBuffer_ENABLE_UNITY_BUILD})

  if(RingBuffer_ENABLE_PCH)
    target_precompile_headers(
      RingBuffer_options
      INTERFACE
      <vector>
      <string>
      <utility>)
  endif()

  if(RingBuffer_ENABLE_COVERAGE)
    include(cmake/Tests.cmake)
    RingBuffer_enable_coverage(RingBuffer_options)
  endif()

  if(RingBuffer_WARNINGS_AS_ERRORS)
    check_cxx_compiler_flag("-Wl,--fatal-warnings" LINKER_FATAL_WARNINGS)
    if(LINKER_FATAL_WARNINGS)
      # This is not working consistently, so disabling for now
      # target_link_options(RingBuffer_options INTERFACE -Wl,--fatal-warnings)
    endif()
  endif()

  if(RingBuffer_ENABLE_HARDENING AND NOT RingBuffer_ENABLE_GLOBAL_HARDENING)
    include(cmake/Hardening.cmake)
    if(NOT SUPPORTS_UBSAN 
       OR RingBuffer_ENABLE_SANITIZER_UNDEFINED
       OR RingBuffer_ENABLE_SANITIZER_ADDRESS
       OR RingBuffer_ENABLE_SANITIZER_THREAD
       OR RingBuffer_ENABLE_SANITIZER_LEAK)
      set(ENABLE_UBSAN_MINIMAL_RUNTIME FALSE)
    else()
      set(ENABLE_UBSAN_MINIMAL_RUNTIME TRUE)
    endif()
    RingBuffer_enable_hardening(RingBuffer_options OFF ${ENABLE_UBSAN_MINIMAL_RUNTIME})
  endif()

endmacro()