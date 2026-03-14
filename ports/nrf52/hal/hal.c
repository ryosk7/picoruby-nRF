#include "hal.h"

#include <stdbool.h>
#include <stdint.h>

#include "nrf_drv_uart.h"

#include "app_util_platform.h"
#include "boards.h"
#include "nrf_drv_uart.h"

static const nrf_drv_uart_t uart = NRF_DRV_UART_INSTANCE(0);
static volatile bool uart_tx_done;

static void uart_event_handler(nrf_drv_uart_event_t *event, void *context)
{
  (void)context;

  if (event->type == NRF_DRV_UART_EVT_TX_DONE) {
    uart_tx_done = true;
  }
}

void hal_init(void)
{
  const nrf_drv_uart_config_t config = {
    .pseltxd = TX_PIN_NUMBER,
    .pselrxd = RX_PIN_NUMBER,
    .pselcts = NRF_UART_PSEL_DISCONNECTED,
    .pselrts = NRF_UART_PSEL_DISCONNECTED,
    .p_context = NULL,
    .hwfc = NRF_UART_HWFC_DISABLED,
    .parity = NRF_UART_PARITY_EXCLUDED,
    .baudrate = NRF_UART_BAUDRATE_115200,
    .interrupt_priority = APP_IRQ_PRIORITY_LOWEST
  };

  uart_tx_done = false;
  nrf_drv_uart_init(&uart, &config, uart_event_handler);
}

void hal_enable_irq(void) {}
void hal_disable_irq(void) {}
void hal_idle_cpu(void) {}
int hal_write(int fd, const void *buf, int nbytes)
{
  const uint8_t *p = (const uint8_t *)buf;
  (void)fd;

  for (int i = 0; i < nbytes; i++) {
    uart_tx_done = false;
    nrf_drv_uart_tx(&uart, &p[i], 1);
    while (!uart_tx_done) {
    }
  }

  return nbytes;
}

int hal_flush(int fd)
{
  (void)fd;
  return 0;
}
void hal_abort(const char *s)
{
  (void)s;
  while (1) {
  }
}
