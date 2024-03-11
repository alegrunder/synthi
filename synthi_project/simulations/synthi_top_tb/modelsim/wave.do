onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /synthi_top_tb/DUT/infrastructure_1/modulo_divider_1/clk_12m
add wave -noupdate /synthi_top_tb/DUT/infrastructure_1/reset_n
add wave -noupdate /synthi_top_tb/DUT/codec_controller_1/fsm_state
add wave -noupdate /synthi_top_tb/DUT/codec_controller_1/write_o
add wave -noupdate /synthi_top_tb/DUT/codec_controller_1/write_done_i
add wave -noupdate /synthi_top_tb/DUT/codec_controller_1/count
add wave -noupdate /synthi_top_tb/DUT/codec_controller_1/write_data_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {112457 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 194
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {106890 ns}
