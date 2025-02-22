# TRISC-16 Processor

## A 16-bit RISC processor made for the monograph of the Computer Engineering course, using VHDL-2008.

A microcontroller encapsulation was made for the TRISC-16 CPU, with a 64 KB address space, unified instruction and data memories, as well as various peripherals and 16 general purpose I/O pins.

## Revisions

The TRISC architecture is currenctly in the TRISCv3 revision.

- TRISCv1: 14 simple instructions, including: Movimentation, load, store, logical and arithmetical.
- TRISCv2: 14 instructions added, including: Branch, Comparing, Shift, Rotate, Input, Output and Stack. GPIO and Counter peripherals added, as well as 16 I/O pins.
- TRISCv3: Instruction set and internal organization improved. Added 6 instructions. UART, PWM, HDMI, LED and Switch peripherals added (Counter renamed to Timer). Memory changed to unified memory. Added bootloader to flash the internal memory.

## Features

For more informations, see the latest revision [datasheet](https://github.com/boltragons/TRISC-16/blob/main/docs/trisc_16_datasheet_rev_2.pdf).

- [X] 16-bit RISC CPU in a 16 I/O pin MCU
- [X] 34 Instructions
- [X] Bootloader
- [X] 4 LEDs & 4 Switches
- [X] GPIO
- [X] Timer
- [X] UART
- [X] PWM
- [X] HDMI
