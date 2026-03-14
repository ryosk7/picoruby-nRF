#include "hal.h"

void hal_init(void) {}
void hal_enable_irq(void) {}
void hal_disable_irq(void) {}
void hal_idle_cpu(void) {}
int hal_write(int fd, const void *buf, int nbytes) { return 0; }
int hal_flush(int fd) { return 0; }
void hal_abort(const char *s)
{
  (void)s;
  while (1) {
  }
}
