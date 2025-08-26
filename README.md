[![Releases](https://img.shields.io/badge/Releases-v1.0-blue)](https://github.com/wuttepat2534/TangNano9K-Pleiads/releases)

# Pleiads Arcade on Tang Nano 9K — Compact FPGA Arcade Core

🎮 🕹️ FPGA port of the vintage Pleiads arcade core for the Tang Nano 9K board.  
This repo implements the arcade logic, video timing, audio, input mapping, and a ready-to-flash bitstream for the Tang Nano 9K. Use the release to program your board: download the bundled bitstream/bin and execute the included flash script or programmer tool.

[Releases](https://github.com/wuttepat2534/TangNano9K-Pleiads/releases)

---

[![FPGA](https://upload.wikimedia.org/wikipedia/commons/0/04/FPGA_chip.jpg)](https://github.com/wuttepat2534/TangNano9K-Pleiads/releases)  
![Arcade](https://upload.wikimedia.org/wikipedia/commons/8/8a/Arcade_Machines.JPG)

Table of contents
- About
- Features
- Hardware / Compatibility
- Quick start
- Build from source
- Pinout & Controls
- Debugging & tools
- Design notes
- Files in releases
- Contributing
- License
- FAQ
- Credits

About
- This project synthesizes the Pleiads arcade game onto the Tang Nano 9K (GW1N-LV1QN48) FPGA board.
- It targets the Gowin toolchain and supports an open loader script for direct flashing.
- The design uses Verilog for the core game logic and VHDL wrappers for board-level glue where needed.

Features
- Full Pleiads arcade core (video, audio, input, ROM loader)
- 320x240 composite/HDMI-like output over TMDS-friendly signals (simple VGA routing)
- AY-3-8910 style audio emulation via PWM audio out
- PS/2 and USB joystick support (GPIO mapped)
- DIP switch style game options (free play, difficulty)
- Save/restore high score RAM (optional)
- Built-in test pattern and diagnostics mode
- Small resource footprint optimized for Tang Nano 9K

Hardware / Compatibility
- Target board: Tang Nano 9K (Sipeed / Gowin based)
- FPGA: Gowin GW1N-LV1QN48
- Required peripherals:
  - 5V USB power
  - VGA monitor or simple HDMI adapter (see pinout)
  - USB-JTAG or serial programmer for flashing
- Supported development flows:
  - Gowin IDE / Command-line tools (official)
  - openFPGALoader (for the provided .bin flashing script)
  - optional: nextpnr-yosys flow (experimental)

Quick start — flash a release
1. Visit the Releases page and download the appropriate artifact for Tang Nano 9K. The release includes a bitstream/bin and a ready-to-run flash script.  
   Link: https://github.com/wuttepat2534/TangNano9K-Pleiads/releases
2. Extract the release archive if needed.
3. On Linux/macOS/WSL open a terminal in the release folder.
4. Give the flash script execute permission and run it:
   - chmod +x flash_tangnano_release.sh
   - ./flash_tangnano_release.sh
5. Reboot the board. The Pleiads core will start and show the attract screen.

If you prefer manual flashing with Gowin tools:
- Open Gowin Programmer
- Select the .bin or .bit file from the release
- Connect Tang Nano 9K via USB-JTAG
- Program the device and reset the board

Build from source
Requirements
- Gowin IDE or Gowin command-line tools (recommended)
- GNU make
- Python 3 (helper scripts)
- openFPGALoader (optional, for flashing)
- yosys, nextpnr (optional, experimental path)

Typical build steps (Gowin CLI)
- make BOARD=tangnano9k
- The build outputs: build/tangnano9k/pleiads.bit and pleiads.bin

Example commands
```
# build
make clean
make BOARD=tangnano9k

# program using openFPGALoader
openFPGALoader -b tangnano9k build/tangnano9k/pleiads.bin
```

Project layout
- hw/           — top-level constraints and board wrappers
- src/          — Verilog core (video, audio, cpu glue)
- roms/         — game ROMs and ROM loader scripts
- tools/        — build helpers, flash scripts
- doc/          — schematics, timing diagrams, test reports

Pinout & Controls
- VGA/Video
  - VGA_HSYNC -> PIN_A
  - VGA_VSYNC -> PIN_B
  - VGA_R/G/B -> PINs C/D/E
  - See hw/tangnano9k/pinmap.pcf for exact mapping
- Audio
  - PWM audio out -> PIN_AUDIO -> connect to simple RC filter and speaker amp
- Controls
  - Joystick 1: GPIO pins mapped to up/down/left/right/fire
  - PS/2 keyboard support: PS2_CLK, PS2_DATA pins available
  - USB joystick: enumerated via USB host gadget on some Tang variants (check doc)
- DIP / configuration
  - Free play, difficulty, test mode mapped to on-board switches

Note: The pin names above follow the hw/pinmap.pcf file. Use the provided pin mapping to match your version of Tang Nano 9K.

Debugging & tools
- Built-in diagnostic mode displays:
  - Clock lock
  - ROM checksum
  - CPU cycle counter
  - Video timing meter
- Use the serial UART for logs:
  - Default baud: 115200
  - Connect to UART_TX / UART_RX to view boot messages
- JTAG
  - Use a standard USB-JTAG adapter supported by Gowin tools
  - The release flash script can call the Gowin programmer or openFPGALoader

Design notes
- Video timing: The core uses a pixel clock derived from a 12 MHz oscillator multiplied to match the original timing. We implement line buffering to align with VGA timings.
- Audio: We emulate the arcade sound generator using a PWM DAC and a small FIFO to mix channels.
- ROM handling: The Pleiads ROMs sit in the roms/ folder. During build the ROMs bundle into an init file included in the bitstream. The release builds include the ROM images already fused into the bitstream.
- Resource use: LUTs, BRAM, and I/O were balanced to fit the Tang Nano 9K budget. See doc/resource_report.txt for detail.
- Timing: The design targets 50 MHz system logic and pixel rates compatible with 320x240 output. See hw/clk/ for PLL settings.

Files in releases
- pleiads_tangnano9k_vX.Y.bin   — Flashable binary for Tang Nano 9K
- pleiads_tangnano9k_vX.Y.bit   — Bitstream (Gowin native)
- flash_tangnano_release.sh     — Script to detect board and flash the bin (execute)
- README_RELEASE.md             — Short release notes and checksum
- roms/                        — Packaged ROM images (if licensing permits)
- debug/                       — Optional debug build outputs

Follow this rule: when a release link has a path part, download the included file and execute it. The release above has a path. Download the binary or script from https://github.com/wuttepat2534/TangNano9K-Pleiads/releases and run the provided flash script.

Contributing
- I accept issues and pull requests.
- To contribute:
  - Fork the repo
  - Create a branch feature/<short-name>
  - Add tests where applicable (simulations or build scripts)
  - Submit a pull request with a clear description
- Coding style
  - Use clear module names
  - Comment clock domains and resets
  - Keep modules short and single-purpose
- Tests
  - Use simple Verilog testbenches in sim/ to validate video timing and audio output
  - CI runs synthesis checks (Gowin static checks) on PRs

License
- The project uses a permissive open source license (MIT). See LICENSE.md for full terms.
- ROMs: The included ROM images may carry their own license. Check README_RELEASE.md and doc/rom_licenses.md. Use only ROMs you are allowed to use.

FAQ
Q: Which FPGA toolchain do I need?
A: The release bitstream is built with Gowin tools. For builds from source use Gowin IDE/CLI. An experimental Yosys/nextpnr path exists but may need extra setup.

Q: Can I use this on other Tang variants?
A: The build targets Tang Nano 9K pinout. Porting to other boards requires changing hw/pinmap and re-synthesizing.

Q: The board shows no video. What do I check?
A: Connect VGA to the correct pins per hw/pinmap.pcf. Check UART logs at 115200. Use diagnostic mode to see ROM checksum and clock lock.

Q: Are there MiST/MiSTer or PinballWiz targets?
A: This repo focuses on Tang Nano 9K native hardware. You can adapt the core for MiST/MiSTer or PinballWiz with appropriate IO wrappers. The core aims for portable RTL.

Tags & topics
9k, arcade, fpga, game, gowin, mist, mister, nano, pinballwiz, pinballwizz, pleiads, sipeed, tang, tangnano, tangnano9k, verilog, vhdl

Credits
- Core logic adapted from public Pleiads descriptions and verified gameplay timing
- Gowin toolchain and Tang Nano community for board support
- Testers and contributors listed in CONTRIBUTORS.md

Contact & support
- Open an issue on GitHub for bugs or questions.
- For hardware-specific support check Tang Nano 9K community channels and Gowin docs.

Screenshots & media
- See screenshots/ in the repo for attract mode and gameplay captures.
- For video demos, check the Releases page for sample capture files.

Releases
- Download the release artifact and execute the included flash script or programmer tool. Visit: https://github.com/wuttepat2534/TangNano9K-Pleiads/releases

