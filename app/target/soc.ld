/* TODO: replace this with the linker script for your target. Take note of the placement of the ".header" section. */

ENTRY(Reset_Handler)

STACK_SIZE = 0x800;
M_VECTOR_RAM_SIZE = 0x0400;

/* Specify the memory areas */
MEMORY
{
  /* Flash */
  m_header              (RX)  : ORIGIN = 0x00010000, LENGTH = 0x00000028
  m_interrupts          (RX)  : ORIGIN = 0x00010028, LENGTH = 0x0006FFD8
  m_text                (RX)  : ORIGIN = 0x00010428, LENGTH = 0x0006FBD8

  /* SRAM_L */
  m_data                (RW)  : ORIGIN = 0x1FFE0000, LENGTH = 0x00020000

  /* SRAM_U */
  m_data_2              (RW)  : ORIGIN = 0x20000000, LENGTH = 0x0001F000
}

/* Define output sections */
SECTIONS
{
  .header : {
    KEEP(*(.app_crc))
    KEEP(*(.app_main))
    KEEP(*(.app_header))
    . = ALIGN(4);
  } > m_header

  /* The startup code goes first into internal flash */
  .interrupts :
  {
    __VECTOR_TABLE = .;
    __interrupts_start__ = .;
    . = ALIGN(4);
    KEEP(*(.isr_vector))     /* Startup code */
    __interrupts_end__ = .;
    . = ALIGN(4);
  } > m_interrupts

  .text :
  {
    . = ALIGN(4);
    *(.text)
    *(.text*)
    *(.rodata)
    *(.rodata*)
    *(code)
    KEEP(*(.target_test))
    . = ALIGN(4);
  } > m_text

  /DISCARD/ : {
    *(.ARM.exidx)
  }

  . = ALIGN(4);

  __etext = .;    /* Define a global symbol at end of code. */
  __DATA_ROM = .; /* Symbol is used by startup for data initialization. */
  .interrupts_ram :
  {
    . = ALIGN(4);
    __VECTOR_RAM__ = .;
    __RAM_START = .;
    __interrupts_ram_start__ = .; /* Create a global symbol at data start. */
    *(.m_interrupts_ram)          /* This is a user defined section. */
    . += M_VECTOR_RAM_SIZE;
    . = ALIGN(4);
    __interrupts_ram_end__ = .;   /* Define a global symbol at data end. */
  } > m_data

  __VECTOR_RAM = __VECTOR_RAM__ ;
  __RAM_VECTOR_TABLE_SIZE = __interrupts_ram_end__ - __interrupts_ram_start__;

  .data : AT(__DATA_ROM)
  {
    . = ALIGN(4);
    __DATA_RAM = .;
    __data_start__ = .;      /* Create a global symbol at data start. */
    *(.data)                 /* .data sections */
    *(.data*)                /* .data* sections */
    KEEP(*(.jcr*))
    . = ALIGN(4);
    __data_end__ = .;        /* Define a global symbol at data end. */
  } > m_data

  __DATA_END = __DATA_ROM + (__data_end__ - __data_start__);
  __CODE_ROM = __DATA_END; /* Symbol is used by code initialization. */
  .code : AT(__CODE_ROM)
  {
    . = ALIGN(4);
    __CODE_RAM = .;
    __code_start__ = .;      /* Create a global symbol at code start. */
    __code_ram_start__ = .;
    *(.code_ram)             /* Custom section for storing code in RAM */
    . = ALIGN(4);
    __code_end__ = .;        /* Define a global symbol at code end. */
    __code_ram_end__ = .;
  } > m_data

  __CODE_END = __CODE_ROM + (__code_end__ - __code_start__);

  /* Uninitialized data section. */
  .bss :
  {
    /* This is used by the startup in order to initialize the .bss section. */
    . = ALIGN(4);
    __BSS_START = .;
    *(.bss)
    *(.bss*)
    . = ALIGN(4);
    __BSS_END = .;
  } > m_data_2

  end = .;
  __StackEnd = .;

  /* Initializes stack on the end of block */
  __StackTop   = ORIGIN(m_data_2) + LENGTH(m_data_2);
  __StackLimit = __StackTop - __StackEnd;
  PROVIDE(__stack = __StackTop);
  __RAM_END = __StackTop;
}

