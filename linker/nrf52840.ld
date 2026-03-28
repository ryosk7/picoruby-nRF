SEARCH_DIR(.)
GROUP(-lgcc -lc -lnosys)

MEMORY
{
  FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 0x100000
  FLASH_MBR (rx) : ORIGIN = 0x00000000, LENGTH = 0x1000
  FLASH_SD (rx) : ORIGIN = 0x00001000, LENGTH = 0x25000
  FLASH_ISR (rx) : ORIGIN = 0x00026000, LENGTH = 0x1000
  FLASH_FIRMWARE (rx) : ORIGIN = 0x00027000, LENGTH = 0x8D000
  FLASH_FATFS (r) : ORIGIN = 0x000B4000, LENGTH = 0x40000
  FLASH_BOOTLOADER (rx) : ORIGIN = 0x000F4000, LENGTH = 0xA000
  FLASH_BOOTLOADER_SETTINGS (r) : ORIGIN = 0x000FF000, LENGTH = 0x1000

  RAM (xrw) : ORIGIN = 0x20000000, LENGTH = 0x40000
  SD_RAM (rw) : ORIGIN = 0x20000000, LENGTH = 0xE000
  SPIM3_RAM (rw) : ORIGIN = 0x2000E000, LENGTH = 0x2000
  APP_RAM (xrw) : ORIGIN = 0x20010000, LENGTH = 0x30000
}

_minimum_heap_size = 0;
_estack = ORIGIN(APP_RAM) + LENGTH(APP_RAM);
_ram_end = ORIGIN(APP_RAM) + LENGTH(APP_RAM);
_heap_end = 0x20020000;
_spim3_ram = ORIGIN(SPIM3_RAM);
_spim3_ram_end = ORIGIN(SPIM3_RAM) + LENGTH(SPIM3_RAM);

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
    . = . + (24 * 1024);
    . = ALIGN(4);
  } > APP_RAM

  /DISCARD/ :
  {
    *(.ARM.extab* .gnu.linkonce.armextab.*)
    *(.ARM.exidx*)
  }

  .ARM.attributes 0 : { *(.ARM.attributes) }
}
