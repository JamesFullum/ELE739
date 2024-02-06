transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vmap -link {C:/Users/james/ETS/Hiver_2024/ELE739/ELE739-Projet_1/Projet_1/Projet_1.cache/compile_simlib/activehdl}
vlib activehdl/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 "+incdir+../../../../Projet_1.gen/sources_1/ip/ila_0/hdl/verilog" -l xil_defaultlib \
"../../../../Projet_1.gen/sources_1/ip/ila_0/sim/ila_0.v" \


vlog -work xil_defaultlib \
"glbl.v"

