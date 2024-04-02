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
add wave -noupdate -expand -group {MIDI Controller} /synthi_top_tb/DUT/note_on_sig
add wave -noupdate -expand -group {MIDI Controller} /synthi_top_tb/DUT/note_sig
add wave -noupdate -expand -group {MIDI Controller} /synthi_top_tb/DUT/velocity_sig
add wave -noupdate -expand -group {Source Select} -radix decimal /synthi_top_tb/DUT/midi_uart_1/baud_rate_i
add wave -noupdate -expand -group {Source Select} /synthi_top_tb/DUT/midi_sync_sig
add wave -noupdate -expand -group {Source Select} /synthi_top_tb/DUT/midi_uart_1/serial_in
add wave -noupdate -expand -group {Source Select} /synthi_top_tb/DUT/midi_uart_1/falling_pulse
add wave -noupdate -expand -group {Source Select} /synthi_top_tb/DUT/midi_uart_1/start_pulse
add wave -noupdate -expand -group {Source Select} /synthi_top_tb/DUT/midi_uart_1/bit_count
add wave -noupdate -expand -group {Source Select} -radix decimal /synthi_top_tb/DUT/midi_uart_1/baud_tick_inst1/count
add wave -noupdate -expand -group {Source Select} /synthi_top_tb/DUT/midi_uart_1/tick
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4408273 ns} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {2263430 ns} {2266583 ns}
