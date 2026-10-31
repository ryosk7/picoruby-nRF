SEARCH_DIR(.)
GROUP(-lgcc -lc -lnosys)

MEMORY
{
  FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 0x100000
  FLASH_MBR (rx) : ORIGIN = 0x00000000, LENGTH = 0x1000
  FLASH_SD (rx) : ORIGIN = 0x00001000, LENGTH = 0x25000
  FLASH_ISR (rx) : ORIGIN = 0x00026000, LENGTH = 0x1000
  FLASH_FIRMWARE (rx) : ORIGIN = 0x00027000, LENGTH = 0x95000
  FLASH_MSC (r) : ORIGIN = 0x000BC000, LENGTH = 0x8000
  FLASH_LFS (r) : ORIGIN = 0x000C4000, LENGTH = 0x30000
  FLASH_BOOTLOADER (rx) : ORIGIN = 0x000F4000, LENGTH = 0xA000
  FLASH_BOOTLOADER_SETTINGS (r) : ORIGIN = 0x000FF000, LENGTH = 0x1000

  RAM (xrw) : ORIGIN = 0x20000000, LENGTH = 0x40000
  SD_RAM (rw) : ORIGIN = 0x20000000, LENGTH = 0xE000
  /* The 8 KB at 0x2000E000 used to be reserved for the anomaly 198
     workaround. picoruby-spi deliberately offers SPIM0/1/2 only and
     nrfx_spim is not built at all, so nothing ever used it, and no
     output section was ever assigned to it. Folded into APP_RAM.
     Note ld diagnoses overlap between placed sections but not between
     MEMORY regions, so a stale region is a silent trap the next time
     APP_RAM grows. */
  APP_RAM (xrw) : ORIGIN = 0x2000E000, LENGTH = 0x32000
}

_stack_size = 24 * 1024;
/* Reserve room for the C heap rather than leaving it at zero, so the link
   fails when .data and .bss leave too little. R2P2-nRF sizes its mruby/c
   pool at boot from what the linker left and keeps the top of it for
   newlib, bounded by its own _sbrk, so this section's position is not
   where the heap ends up: it is the guarantee that one fits. */
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

  /DISCARD/ :
  {
    *(.ARM.extab* .gnu.linkonce.armextab.*)
    *(.ARM.exidx*)
  }

  .ARM.attributes 0 : { *(.ARM.attributes) }
}
