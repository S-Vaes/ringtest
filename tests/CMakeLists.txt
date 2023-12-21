# Enable testing
enable_testing()

# Add test executable
add_executable(test_ring_buffer test_ring_buffer.cpp)

# Link the test executable with the ring buffer library
target_link_libraries(test_ring_buffer ring_buffer)

# Add the test
add_test(NAME TestRingBuffer COMMAND test_ring_buffer)
