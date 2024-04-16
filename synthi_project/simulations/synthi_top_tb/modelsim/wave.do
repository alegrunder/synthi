onerror {resume}
quietly virtual signal -install /synthi_top_tb { (context /synthi_top_tb )(DUT/adcdat_pl &DUT/adcdat_pr &DUT/dacdat_pl &DUT/dacdat_pr & DUT/AUD_DACDAT & DUT/AUD_BCLK &dacdat_check & DUT/AUD_ADCDAT )} I2S
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group Allgemein /synthi_top_tb/SW
add wave -noupdate -expand -group Allgemein /synthi_top_tb/DUT/clk_6m_sig
add wave -noupdate -expand -group Allgemein /synthi_top_tb/DUT/reset_n_sig
add wave -noupdate -expand -group {Codec Controller and I2C} /synthi_top_tb/DUT/codec_controller_1/fsm_state
add wave -noupdate -expand -group {Codec Controller and I2C} /synthi_top_tb/DUT/codec_controller_1/write_o
add wave -noupdate -expand -group {Codec Controller and I2C} /synthi_top_tb/DUT/codec_controller_1/write_done_i
add wave -noupdate -expand -group {Codec Controller and I2C} /synthi_top_tb/DUT/codec_controller_1/count
add wave -noupdate -expand -group {Codec Controller and I2C} /synthi_top_tb/DUT/codec_controller_1/write_data_o
add wave -noupdate -expand -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/I2C_SDAT
add wave -noupdate -expand -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/I2C_SCLK
add wave -noupdate -expand -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data0
add wave -noupdate -expand -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data1
add wave -noupdate -expand -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data2
add wave -noupdate -expand -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data3
add wave -noupdate -expand -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data4
add wave -noupdate -expand -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data5
add wave -noupdate -expand -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data6
add wave -noupdate -expand -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data7
add wave -noupdate -expand -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data8
add wave -noupdate -expand -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data9
add wave -noupdate -expand -group I2S /synthi_top_tb/DUT/adcdat_pl
add wave -noupdate -expand -group I2S /synthi_top_tb/DUT/adcdat_pr
add wave -noupdate -expand -group I2S /synthi_top_tb/DUT/dacdat_pl
add wave -noupdate -expand -group I2S /synthi_top_tb/DUT/dacdat_pr
add wave -noupdate -expand -group I2S /synthi_top_tb/DUT/AUD_DACDAT
add wave -noupdate -expand -group I2S /synthi_top_tb/DUT/AUD_BCLK
add wave -noupdate -expand -group I2S /synthi_top_tb/dacdat_check
add wave -noupdate -expand -group I2S /synthi_top_tb/DUT/AUD_ADCDAT
add wave -noupdate -expand -group {MIDI Controller} /synthi_top_tb/DUT/usb_txd_sync_sig
add wave -noupdate -expand -group {MIDI Controller} /synthi_top_tb/DUT/rx_data_sig
add wave -noupdate -expand -group {MIDI Controller} /synthi_top_tb/DUT/rx_data_rdy_sig
add wave -noupdate -expand -group {MIDI Controller} /synthi_top_tb/DUT/midi_controller_1/fsm_state
add wave -noupdate -expand -group {MIDI Controller} /synthi_top_tb/DUT/midi_controller_1/status_reg
add wave -noupdate -expand -group {MIDI Controller} /synthi_top_tb/DUT/midi_controller_1/data1_reg
add wave -noupdate -expand -group {MIDI Controller} /synthi_top_tb/DUT/midi_controller_1/data2_reg
add wave -noupdate -expand -group {MIDI Controller} /synthi_top_tb/DUT/LEDR_1
add wave -noupdate -group {Source Select} -radix decimal /synthi_top_tb/DUT/midi_uart_1/baud_rate_i
add wave -noupdate -group {Source Select} /synthi_top_tb/DUT/midi_sync_sig
add wave -noupdate -group {Source Select} /synthi_top_tb/DUT/midi_uart_1/serial_in
add wave -noupdate -group {Source Select} /synthi_top_tb/DUT/midi_uart_1/falling_pulse
add wave -noupdate -group {Source Select} /synthi_top_tb/DUT/midi_uart_1/start_pulse
add wave -noupdate -group {Source Select} /synthi_top_tb/DUT/midi_uart_1/bit_count
add wave -noupdate -group {Source Select} /synthi_top_tb/DUT/midi_uart_1/tick
add wave -noupdate -expand -group {MIDI poly} /synthi_top_tb/DUT/midi_controller_1/new_data_flag
add wave -noupdate -expand -group {MIDI poly} /synthi_top_tb/DUT/note_on_sig
add wave -noupdate -expand -group {MIDI poly} /synthi_top_tb/DUT/note_valid_sig
add wave -noupdate -expand -group {MIDI poly} /synthi_top_tb/DUT/note_sig
add wave -noupdate -expand -group {MIDI poly} /synthi_top_tb/DUT/velocity_sig
add wave -noupdate -expand -group {MIDI poly} /synthi_top_tb/DUT/midi_controller_1/vol_reg
add wave -noupdate -expand -group {MIDI poly} /synthi_top_tb/DUT/midi_controller_1/pitch_reg
add wave -noupdate -expand -group {MIDI poly} /synthi_top_tb/DUT/midi_controller_1/ctrl_reg
add wave -noupdate -expand -group DDS -format Analog-Step -height 74 -max 4095.0 -min -4096.0 -radix sfixed /synthi_top_tb/DUT/tone_generator_1/dds_inst_gen(0)/inst_dds/dds_o
add wave -noupdate -expand -group DDS -format Analog-Step -height 74 -max 4095.0 -min -4096.0 -radix sfixed /synthi_top_tb/DUT/tone_generator_1/dds_inst_gen(1)/inst_dds/dds_o
add wave -noupdate -expand -group DDS -format Analog-Step -height 150 -max 32767.000000000004 -min -32768.0 -radix sfixed /synthi_top_tb/DUT/tone_generator_1/dds_l_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 384
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
WaveRestoreZoom {0 ns} {30169787 ns}
