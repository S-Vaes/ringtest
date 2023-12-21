cmake_minimum_required(VERSION 3.21)

# This template attempts to be "fetch_content"-able
# so that it works well with tools like CPM or other
# manual dependency management

# Only set the cxx_standard if it is not set by someone else
if (NOT DEFINED CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 23)
endif()

# strongly encouraged to enable this globally to avoid conflicts between
# -Wpedantic being enabled and -std=c++20 and -std=gnu++20 for example
# when compiling with PCH enabled
set(CMAKE_CXX_EXTENSIONS OFF)

# Set the project name and language
project(
  RingBuffer
  VERSION 0.0.1
  DESCRIPTION ""
  LANGUAGES CXX)

include(cmake/PreventInSourceBuild.cmake)
include(ProjectOptions.cmake)


RingBuffer_setup_options()
RingBuffer_global_options()
RingBuffer_local_options()

target_compile_features(RingBuffer_options INTERFACE cxx_std_${CMAKE_CXX_STANDARD})

add_library(RingBuffer::RingBuffer_options ALIAS RingBuffer_options)
add_library(RingBuffer::RingBuffer_warnings ALIAS RingBuffer_warnings)

# Include directories
include_directories(include)

# Add subdirectories
add_subdirectory(src)

# If you have tests, uncomment the following line
# add_subdirectory(tests)

# Don't even look at tests if we're not top level
if(NOT PROJECT_IS_TOP_LEVEL)
  return()
endif()
