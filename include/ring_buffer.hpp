#pragma once

#include <array>
#include <cstdio>


template <typename T, size_t Size>
class RingBuffer {
public:
    // RingBuffer methods
    RingBuffer() {
        printf("Ring Buffer Construction!\n");
    }

    auto test() -> void {
    printf("Test function.\n");
}
private:
    std::array<T, Size> buffer{};
    // Other member variables
};
