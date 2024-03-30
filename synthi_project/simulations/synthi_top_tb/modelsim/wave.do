onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /synthi_top_tb/DUT/codec_controller_1/fsm_state
add wave -noupdate /synthi_top_tb/DUT/codec_controller_1/write_o
add wave -noupdate /synthi_top_tb/DUT/codec_controller_1/write_done_i
add wave -noupdate /synthi_top_tb/DUT/codec_controller_1/count
add wave -noupdate /synthi_top_tb/DUT/codec_controller_1/write_data_o
add wave -noupdate /synthi_top_tb/i2c_slave_bfm_1/I2C_SDAT
add wave -noupdate /synthi_top_tb/i2c_slave_bfm_1/I2C_SCLK
add wave -noupdate /synthi_top_tb/i2c_slave_bfm_1/reg_data0
add wave -noupdate /synthi_top_tb/i2c_slave_bfm_1/reg_data1
add wave -noupdate /synthi_top_tb/i2c_slave_bfm_1/reg_data2
add wave -noupdate /synthi_top_tb/i2c_slave_bfm_1/reg_data3
add wave -noupdate /synthi_top_tb/i2c_slave_bfm_1/reg_data4
add wave -noupdate /synthi_top_tb/i2c_slave_bfm_1/reg_data5
add wave -noupdate /synthi_top_tb/i2c_slave_bfm_1/reg_data6
add wave -noupdate /synthi_top_tb/i2c_slave_bfm_1/reg_data7
add wave -noupdate /synthi_top_tb/i2c_slave_bfm_1/reg_data8
add wave -noupdate /synthi_top_tb/i2c_slave_bfm_1/reg_data9
add wave -noupdate /synthi_top_tb/SW
add wave -noupdate /synthi_top_tb/DUT/adcdat_pl
add wave -noupdate /synthi_top_tb/DUT/adcdat_pr
add wave -noupdate /synthi_top_tb/DUT/dacdat_pl
add wave -noupdate /synthi_top_tb/DUT/dacdat_pr
add wave -noupdate /synthi_top_tb/DUT/AUD_DACDAT
add wave -noupdate /synthi_top_tb/DUT/AUD_BCLK
add wave -noupdate /synthi_top_tb/dacdat_check
add wave -noupdate /synthi_top_tb/DUT/AUD_ADCDAT
add wave -noupdate -format Analog-Step -height 74 -max 2106.0 -radix decimal /synthi_top_tb/DUT/tone_generator_1/dds_o_LR
add wave -noupdate -radix decimal /synthi_top_tb/DUT/tone_generator_1/dds_1/count
add wave -noupdate /synthi_top_tb/DUT/tone_generator_1/dds_1/step_i
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {25541027 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 311
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
WaveRestoreZoom {4306732 ns} {33318329 ns}
