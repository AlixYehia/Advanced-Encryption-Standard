vlib work
vlog *.*v
vsim -voptargs=+acc work.MixColumns_tb
do wave.do
run -all