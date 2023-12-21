# Create a library target for the ring buffer
add_library(ring_buffer ring_buffer.cpp)

# Link libraries (if any)
# target_link_libraries(ring_buffer some_other_library)

# If you want to create an executable
add_executable(RingBufferExecutable main.cpp)

# Link the executable with the ring buffer library
target_link_libraries(RingBufferExecutable PRIVATE ring_buffer
                                           RingBuffer::RingBuffer_options
                                           RingBuffer::RingBuffer_warnings)
