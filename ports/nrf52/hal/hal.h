#ifndef MRBC_SRC_HAL_H_
#define MRBC_SRC_HAL_H_

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

void mrbc_tick(void);

void mrbc_hal_init(void);
void mrbc_hal_enable_irq(void);
void mrbc_hal_disable_irq(void);
void mrbc_hal_idle_cpu(void);
int mrbc_hal_write(int fd, const void *buf, int nbytes);
int mrbc_hal_flush(int fd);
void mrbc_hal_abort(const char *s);

#ifdef __cplusplus
}
#endif

#endif
