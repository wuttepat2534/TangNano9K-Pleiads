copy /B ic47.r1 + ic48.r2 + ic47.bin + ic48.bin + ic51.r5 + ic50.bin + ic53.r7 + ic52.bin pleiads_prog.bin

make_vhdl_prom pleiads_prog.bin pleiads_prog.vhd
make_vhdl_prom ic39.bin   prom_ic39.vhd
make_vhdl_prom ic40.bin   prom_ic40.vhd
make_vhdl_prom ic23.bin   prom_ic23.vhd
make_vhdl_prom ic24.bin   prom_ic24.vhd
make_vhdl_prom 7611-5.26  prom_palette_ic40.vhd
make_vhdl_prom 7611-5.33  prom_palette_ic41.vhd

pause