/*
******************************************************************************
** STM32F746ZGTx linker script (AERIS-10 PR 2)
**
** Memory layout (STM32F746ZGT7, LQFP144, 1 MB flash / 320 KB RAM):
**   ITCM    : 0x00000000, 16 KB  (CPU tightly-coupled instruction RAM)
**   FLASH   : 0x08000000,  1 MB
**   DTCM    : 0x20000000, 64 KB  (CPU tightly-coupled data RAM — stack/heap)
**   RAM     : 0x20010000,256 KB  (SRAM1 240 KB + SRAM2 16 KB contiguous)
**
** Entry: Reset_Handler (from vendor/cmsis_device_f7 startup).
** Heap:  grows up from _end.  Stack: grows down from end of DTCM (_estack).
******************************************************************************
*/

ENTRY(Reset_Handler)

_estack       = ORIGIN(DTCM) + LENGTH(DTCM);   /* top of DTCM for MSP */
_Min_Heap_Size  = 0x200;
_Min_Stack_Size = 0x400;

MEMORY
{
  ITCM (rx)   : ORIGIN = 0x00000000, LENGTH = 16K
  FLASH (rx)  : ORIGIN = 0x08000000, LENGTH = 1024K
  DTCM (rw)   : ORIGIN = 0x20000000, LENGTH = 64K
  RAM (rw)    : ORIGIN = 0x20010000, LENGTH = 256K
}

SECTIONS
{
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector))
    . = ALIGN(4);
  } >FLASH

  .text :
  {
    . = ALIGN(4);
    *(.text)
    *(.text*)
    *(.glue_7)
    *(.glue_7t)
    *(.eh_frame)
    KEEP (*(.init))
    KEEP (*(.fini))
    . = ALIGN(4);
    _etext = .;
  } >FLASH

  .rodata :
  {
    . = ALIGN(4);
    *(.rodata)
    *(.rodata*)
    . = ALIGN(4);
  } >FLASH

  .ARM.extab : { *(.ARM.extab* .gnu.linkonce.armextab.*) } >FLASH
  .ARM       : { __exidx_start = .; *(.ARM.exidx*) __exidx_end = .; } >FLASH

  .preinit_array :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array*))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  } >FLASH

  .init_array :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT(.init_array.*)))
    KEEP (*(.init_array*))
    PROVIDE_HIDDEN (__init_array_end = .);
  } >FLASH

  .fini_array :
  {
    PROVIDE_HIDDEN (__fini_array_start = .);
    KEEP (*(SORT(.fini_array.*)))
    KEEP (*(.fini_array*))
    PROVIDE_HIDDEN (__fini_array_end = .);
  } >FLASH

  _sidata = LOADADDR(.data);

  .data :
  {
    . = ALIGN(4);
    _sdata = .;
    *(.data)
    *(.data*)
    . = ALIGN(4);
    _edata = .;
  } >DTCM AT> FLASH

  .bss (NOLOAD) :
  {
    . = ALIGN(4);
    _sbss = .;
    __bss_start__ = _sbss;
    *(.bss)
    *(.bss*)
    *(COMMON)
    . = ALIGN(4);
    _ebss = .;
    __bss_end__ = _ebss;
  } >DTCM

  ._user_heap_stack (NOLOAD) :
  {
    . = ALIGN(8);
    PROVIDE ( end = . );
    PROVIDE ( _end = . );
    . = . + _Min_Heap_Size;
    . = . + _Min_Stack_Size;
    . = ALIGN(8);
  } >DTCM

  /* Larger buffers can be placed in .sram using __attribute__((section(".sram"))) */
  .sram (NOLOAD) :
  {
    . = ALIGN(4);
    *(.sram)
    *(.sram*)
    . = ALIGN(4);
  } >RAM

  /DISCARD/ : { libc.a ( * ) libm.a ( * ) libgcc.a ( * ) }

  .ARM.attributes 0 : { *(.ARM.attributes) }
}
