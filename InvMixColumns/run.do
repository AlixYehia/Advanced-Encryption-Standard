vlib work
vlog *.*v
vsim -voptargs=+acc work.InvMixColumns_tb
do wave.do
run -all