# TRISC-16 Microcontroller

## A 16-bit microcontroller, containing a RISC processor, named TRISC (Training RISC), made as part of my final monograph for the Computer Engineering course: "Implementation of a FPGA Microcontroller for Teacing Computer Engineering: From Theory to Experimentation".

The main part if the RISC core, the TRISC CPU, having a microcontroller encapsulation made for it's use, the TRISC-16 MCU, with up to 64 KB address space, unified instruction and data memories, as well as various peripherals and 16 general purpose I/O pins.

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
