#include "ring_buffer.hpp"
#include <cstdint>


auto main() -> int {
    RingBuffer<int, 7> buffer{};
    buffer.test();

#ifndef NDEBUG
    printf("DEBUG\n");
#else
    printf("RELEASE\n");
#endif
    
    return 0;
}
