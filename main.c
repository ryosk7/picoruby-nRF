#include <stdbool.h>
#include <stdint.h>
#include <mrubyc.h>

#ifndef HEAP_SIZE
#define HEAP_SIZE (1024 * 64)
#endif

static uint8_t heap_pool[HEAP_SIZE];

int main(void)
{
  mrbc_init(heap_pool, HEAP_SIZE);

  while (true)
  {
  }
}
