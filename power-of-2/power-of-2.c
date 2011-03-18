
#include <stdint.h>

int64_t isPowerOfTwo (int64_t x)
{
    return ((x > 0) && ((x & (x - 1)) == 0));
}

