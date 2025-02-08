onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -color Cyan /InvMixColumns_tb/DUT/MixColumns_Matrix
add wave -noupdate -color Magenta /InvMixColumns_tb/DUT/InvMixColumns_Matrix
add wave -noupdate /InvMixColumns_tb/DUT/state
add wave -noupdate /InvMixColumns_tb/DUT/new_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {29266 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {29050 ps} {30050 ps}
