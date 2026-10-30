# Zet x86-16 SoC on Zynq-7010 PL — 8086/80286-class PC

The [Zet](https://github.com/marmolejo/zet) x86-16 processor core (8086/80186
compatible, Wishbone) instantiated in the programmable logic of a Zynq-7010
(xc7z010clg400-1), using the PS DDR through the S_AXI_HP0 port as main memory.
Goal: boot a minimal BIOS + a DOS-class operating system.

## Layout

- `rtl/zet*.v` – the Zet core (fetched from the Zet repo) plus `zet_signmul17.v`
  (Altera multiplier dependency).
- `rtl/zet_micro_rom.v`, `rtl/rom_def.v`, `rtl/micro_rom.dat` – the CPU
  microcode ROM. `micro_rom.dat` is generated from Zet's `microcode.txt` by
  `tools/micro2rom.py`.
- `rtl/zet_soc_top.v` – top level: Zet + 8 KB BIOS ROM (@0xFE000) + `wb2axi`
  bridge. Wishbone memory accesses map to `0x10000000|addr` (PS DDR via HP0);
  I/O accesses map to `0x8000_0000|port` (an AXI-Lite IO window).
- `rtl/wb2axi.v` – Wishbone -> AXI(-Lite) bridge.
- `bios/bios.asm` -> `bios.bin` -> `rtl/bios.hex` – a minimal 8086 BIOS:
  IVT, int 10h teletype (IO port 0x60), int 13h disk (IO ports 0x170-0x176),
  int 19h bootstrap (load sector 1 -> 0x7C00, far jump), reset vector @0xFFFF0.
- `vivado/build.tcl` – Vivado build (BD = PS7 + `zet_soc_top` module +
  AXI interconnects for protocol/width conversion to HP0).
- `sw/dos/` – DOS disk images (FreeDOS 1.2 CD).

## Memory map (Zet view)

| Region   | Zet address | Maps to                               |
|----------|-------------|----------------------------------------|
| RAM      | 0x00000-... | PS DDR @0x10000000 via HP0             |
| BIOS ROM | 0xFE000     | 8 KB BRAM ($readmemh bios.hex)         |
| Reset    | 0xFFFF0     | -> BIOS                                |

| IO port (Zet) | AXI-Lite address | Purpose            |
|---------------|------------------|--------------------|
| 0x60          | 0x8000_0060      | console data       |
| 0x170-0x176   | 0x8000_0170-176  | disk (LBA/CHS)     |

The PS runs a small IO-window server that backs the console port and the
disk ports so the CPU can read sectors and print characters.

## Status

Bitstream builds clean (`vivado/build.tcl` -> `zynq286_bd_wrapper.bit`).
PS-side IO-window server and DOS boot are bring-up work in progress.
