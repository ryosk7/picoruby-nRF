/*
 * Thread variant of nrf52840.ld.
 *
 * Differences from the default map, both consequences of the same
 * decision -- BLE and Thread are mutually exclusive builds here, and this
 * one has no SoftDevice:
 *
 *  - FLASH_SD (0x1000..0x26000) and SD_RAM (0x20000000..0x2000E000) are
 *    reclaimed. Nothing referenced them already: the firmware links
 *    nrf_soc_nosd, so the SoftDevice was reserved but never called.
 *    The Adafruit bootloader supports this: is_sd_existed() checks for
 *    the magic at 0x3004 and starts the app at MBR_SIZE when it is
 *    absent, and the UF2 path (uf2cfg.h USER_FLASH_START = MBR_SIZE)
 *    accepts an image at 0x1000 either way.
 *
 *  - FLASH_OT_SETTINGS is carved off the end of FLASH_FIRMWARE for
 *    OpenThread's settings storage.
 *
 * WARNING: flashing this image erases the SoftDevice as a side effect --
 * the image spans 0x3004. That is one-way. BLE OTA DFU stops working
 * (bootloader src/main.c:328 initialises the SoftDevice unguarded on the
 * OTA path), and to go back to a 0x26000-layout firmware you must first
 * flash an S140-only UF2 built from the bootloader release hex. UF2 over
 * USB and normal app start are unaffected.
 */
SEARCH_DIR(.)
GROUP(-lgcc -lc -lnosys)

MEMORY
{
  FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 0x100000
  FLASH_MBR (rx) : ORIGIN = 0x00000000, LENGTH = 0x1000
  FLASH_ISR (rx) : ORIGIN = 0x00001000, LENGTH = 0x1000
  FLASH_FIRMWARE (rx) : ORIGIN = 0x00002000, LENGTH = 0xAE000
  FLASH_OT_SETTINGS (r) : ORIGIN = 0x000B0000, LENGTH = 0x4000
  FLASH_MSC (r) : ORIGIN = 0x000B4000, LENGTH = 0x8000
  FLASH_LFS (r) : ORIGIN = 0x000BC000, LENGTH = 0x38000
  FLASH_BOOTLOADER (rx) : ORIGIN = 0x000F4000, LENGTH = 0xA000
  FLASH_BOOTLOADER_SETTINGS (r) : ORIGIN = 0x000FF000, LENGTH = 0x1000

  RAM (xrw) : ORIGIN = 0x20000000, LENGTH = 0x40000
  /* The 8 KB at 0x2000E000 used to be reserved for the anomaly 198
     workaround. picoruby-spi deliberately offers SPIM0/1/2 only and
     nrfx_spim is not built at all, so nothing ever used it, and no
     output section was ever assigned to it. Folded into APP_RAM.
     Note ld diagnoses overlap between placed sections but not between
     MEMORY regions, so a stale region is a silent trap the next time
     APP_RAM grows. */
  /*
   * Started above the bootloader's double-reset cell.
   *
   * Adafruit's bootloader keeps dbl_reset_mem at 0x20007F7C (its
   * src/main.c). On the default map that address falls inside the unused
   * SD_RAM reservation, so nothing could touch it. Reclaiming the
   * SoftDevice RAM moved APP_RAM over it, and RAM survives a pin reset on
   * nRF52840 -- so an application that happened to leave 0x5A1AD5 there
   * would send the next single RESET press into DFU instead of into the
   * app. Starting above the cell rather than splitting the region keeps
   * every output section in one place; it gives back 28 KB of the 57 KB
   * the SoftDevice reservation freed, which still leaves 24 KB more than
   * the default map had.
   */
  APP_RAM (xrw) : ORIGIN = 0x20008000, LENGTH = 0x38000
}

_stack_size = 24 * 1024;
/* Reserve the C heap rather than leaving it at zero. mruby/c runs from
   its own static pool, so libc malloc is newlib's own use today -- but
   that changes as soon as a stack such as OpenThread or mbedTLS is
   linked in, and with a reservation of 0 the link succeeds no matter
   how little room is left. */
_minimum_heap_size = 8 * 1024;
_estack = ORIGIN(APP_RAM) + LENGTH(APP_RAM);
_ram_end = ORIGIN(APP_RAM) + LENGTH(APP_RAM);
/* Was hardcoded to 0x20020000, which sits below _heap_start and so
   describes a heap of negative size. It went unnoticed because _sbrk
   never reads it; state the real ceiling so a _sbrk that does honour it
   is correct. */
_heap_end = ORIGIN(APP_RAM) + LENGTH(APP_RAM) - _stack_size;

SECTIONS
{
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector))
    . = ALIGN(4);
  } > FLASH_ISR

  .text :
  {
    . = ALIGN(4);
    *(SORT_BY_ALIGNMENT(SORT_BY_NAME(.text)))
    *(SORT_BY_ALIGNMENT(SORT_BY_NAME(.text*)))
    *(.rodata)
    *(.rodata*)
    . = ALIGN(4);
    _etext = .;
  } > FLASH_FIRMWARE

  .data :
  {
    . = ALIGN(4);
    _sdata = .;
    _ram_start = .;
    PROVIDE(__start_fs_data = .);
    KEEP(*(.fs_data))
    KEEP(*(.fs_data*))
    PROVIDE(__stop_fs_data = .);
    *(SORT_BY_ALIGNMENT(SORT_BY_NAME(.data)))
    *(SORT_BY_ALIGNMENT(SORT_BY_NAME(.data*)))
    . = ALIGN(4);
    _edata = .;
  } > APP_RAM AT > FLASH_FIRMWARE

  _sidata = LOADADDR(.data);

  .bss :
  {
    . = ALIGN(4);
    _sbss = .;
    *(SORT_BY_ALIGNMENT(SORT_BY_NAME(.bss)))
    *(SORT_BY_ALIGNMENT(SORT_BY_NAME(.bss*)))
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;
  } > APP_RAM

  .uninitialized (NOLOAD) :
  {
    . = ALIGN(4);
    _suninitialized = .;
    *(.uninitialized)
    *(.uninitialized*)
    . = ALIGN(4);
    _euninitialized = .;
  } > APP_RAM

  .heap :
  {
    . = ALIGN(4);
    PROVIDE(end = .);
    PROVIDE(_end = .);
    _heap_start = .;
    . = . + _minimum_heap_size;
  } > APP_RAM

  .stack :
  {
    . = ALIGN(4);
    . = . + _stack_size;
    . = ALIGN(4);
  } > APP_RAM

  /*
   * OpenThread's flash driver (ot-nrf528xx src/src/flash.c) locates its
   * settings storage from __start_ot_flash_data / __stop_ot_flash_data on
   * GCC -- the UICR-derived path is the __CC_ARM branch -- so the region
   * has to be declared or the link fails on two undefined symbols.
   *
   * Taken off the end of FLASH_FIRMWARE rather than out of FLASH_LFS:
   * picoruby-littlefs hardcodes LFS_FLASH_BLOCK_COUNT 56 with no override,
   * so shrinking the filesystem would mean editing picoruby core, and
   * lfs.c refuses to mount an existing image whose block count disagrees.
   *
   * The driver halves the region into two banks, so with 0x4000 here the
   * usable settings space is 8 KB, two pages per bank (sSwapSize).
   */
  .ot_flash_data (NOLOAD) :
  {
    __start_ot_flash_data = .;
    . = . + LENGTH(FLASH_OT_SETTINGS);
    __stop_ot_flash_data = .;
  } > FLASH_OT_SETTINGS

  /DISCARD/ :
  {
    *(.ARM.extab* .gnu.linkonce.armextab.*)
    *(.ARM.exidx*)
  }

  .ARM.attributes 0 : { *(.ARM.attributes) }
}
