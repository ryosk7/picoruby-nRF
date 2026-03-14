#include <stdbool.h>
#include <stdint.h>
#include <mrubyc.h>
#include "_build/mrb/main_task.c"

#ifndef HEAP_SIZE
#define HEAP_SIZE (1024 * 64)
#endif

static uint8_t heap_pool[HEAP_SIZE];

int main(void)
{
  hal_init();
  mrbc_init(heap_pool, HEAP_SIZE);
  mrbc_create_task(main_task, 0);
  mrbc_run();

  while (true)
  {
  }
}
