onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /synthi_top_tb/CLOCK_50
add wave -noupdate /synthi_top_tb/KEY_0
add wave -noupdate /synthi_top_tb/USB_TXD
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/baud_tick_inst1/tick
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/baud_tick_inst1/start_pulse
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/shiftreg_uart_inst1/parallel_out
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/clk_6m
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/reset_n
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/serial_in
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/rx_data_rdy
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/rx_data
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/hex0
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/hex1
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/tick
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/start_pulse
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/falling_pulse
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/data_valid
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/shift_enable
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/bit_count
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/hex_lsb_out
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/hex_msb_out
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/parallel_data
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/rx_data_rdy
add wave -noupdate /synthi_top_tb/DUT/uart_top_1/baud_tick_inst1/count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {513712 ns} 0}
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
WaveRestoreZoom {0 ns} {481487 ns}
