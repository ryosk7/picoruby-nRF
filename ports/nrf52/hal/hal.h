#ifndef MRBC_SRC_HAL_H_
#define MRBC_SRC_HAL_H_

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void mrbc_tick(void);

void hal_init(void);
void hal_enable_irq(void);
void hal_disable_irq(void);
void hal_idle_cpu(void);
int hal_write(int fd, const void *buf, int nbytes);
int hal_flush(int fd);
void hal_abort(const char *s);

#ifdef __cplusplus
}
#endif

#endif
