onerror {resume}
quietly virtual signal -install /synthi_top_tb { (context /synthi_top_tb )(DUT/adcdat_pl &DUT/adcdat_pr &DUT/dacdat_pl &DUT/dacdat_pr & DUT/AUD_DACDAT & DUT/AUD_BCLK &dacdat_check & DUT/AUD_ADCDAT )} I2S
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group Allgemein /synthi_top_tb/SW
add wave -noupdate -expand -group Allgemein /synthi_top_tb/DUT/clk_6m_sig
add wave -noupdate -expand -group Allgemein /synthi_top_tb/DUT/reset_n_sig
add wave -noupdate -group {Codec Controller and I2C} /synthi_top_tb/DUT/codec_controller_1/fsm_state
add wave -noupdate -group {Codec Controller and I2C} /synthi_top_tb/DUT/codec_controller_1/write_o
add wave -noupdate -group {Codec Controller and I2C} /synthi_top_tb/DUT/codec_controller_1/write_done_i
add wave -noupdate -group {Codec Controller and I2C} /synthi_top_tb/DUT/codec_controller_1/count
add wave -noupdate -group {Codec Controller and I2C} /synthi_top_tb/DUT/codec_controller_1/write_data_o
add wave -noupdate -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/I2C_SDAT
add wave -noupdate -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/I2C_SCLK
add wave -noupdate -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data0
add wave -noupdate -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data1
add wave -noupdate -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data2
add wave -noupdate -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data3
add wave -noupdate -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data4
add wave -noupdate -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data5
add wave -noupdate -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data6
add wave -noupdate -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data7
add wave -noupdate -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data8
add wave -noupdate -group {Codec Controller and I2C} /synthi_top_tb/i2c_slave_bfm_1/reg_data9
add wave -noupdate -group I2S /synthi_top_tb/DUT/adcdat_pl
add wave -noupdate -group I2S /synthi_top_tb/DUT/adcdat_pr
add wave -noupdate -group I2S /synthi_top_tb/DUT/dacdat_pl
add wave -noupdate -group I2S /synthi_top_tb/DUT/dacdat_pr
add wave -noupdate -group I2S /synthi_top_tb/DUT/AUD_DACDAT
add wave -noupdate -group I2S /synthi_top_tb/DUT/AUD_BCLK
add wave -noupdate -group I2S /synthi_top_tb/dacdat_check
add wave -noupdate -group I2S /synthi_top_tb/DUT/AUD_ADCDAT
add wave -noupdate -group {MIDI Controller} /synthi_top_tb/DUT/usb_txd_sync_sig
add wave -noupdate -group {MIDI Controller} /synthi_top_tb/DUT/rx_data_sig
add wave -noupdate -group {MIDI Controller} /synthi_top_tb/DUT/rx_data_rdy_sig
add wave -noupdate -group {MIDI Controller} /synthi_top_tb/DUT/midi_controller_1/fsm_state
add wave -noupdate -group {MIDI Controller} /synthi_top_tb/DUT/midi_controller_1/status_reg
add wave -noupdate -group {MIDI Controller} /synthi_top_tb/DUT/midi_controller_1/data1_reg
add wave -noupdate -group {MIDI Controller} /synthi_top_tb/DUT/midi_controller_1/data2_reg
add wave -noupdate -group {MIDI Controller} /synthi_top_tb/DUT/LEDR_1
add wave -noupdate -group {Source Select} -radix decimal /synthi_top_tb/DUT/midi_uart_1/baud_rate_i
add wave -noupdate -group {Source Select} /synthi_top_tb/DUT/midi_sync_sig
add wave -noupdate -group {Source Select} /synthi_top_tb/DUT/midi_uart_1/serial_in
add wave -noupdate -group {Source Select} /synthi_top_tb/DUT/midi_uart_1/falling_pulse
add wave -noupdate -group {Source Select} /synthi_top_tb/DUT/midi_uart_1/start_pulse
add wave -noupdate -group {Source Select} /synthi_top_tb/DUT/midi_uart_1/bit_count
add wave -noupdate -group {Source Select} /synthi_top_tb/DUT/midi_uart_1/tick
add wave -noupdate -group {MIDI poly} /synthi_top_tb/DUT/midi_controller_1/new_data_flag
add wave -noupdate -group {MIDI poly} /synthi_top_tb/DUT/note_on_sig
add wave -noupdate -group {MIDI poly} /synthi_top_tb/DUT/note_valid_sig
add wave -noupdate -group {MIDI poly} /synthi_top_tb/DUT/note_sig
add wave -noupdate -group {MIDI poly} /synthi_top_tb/DUT/velocity_sig
add wave -noupdate -group {MIDI poly} /synthi_top_tb/DUT/midi_controller_1/vol_reg
add wave -noupdate -group {MIDI poly} /synthi_top_tb/DUT/midi_controller_1/pitch_reg
add wave -noupdate -group {MIDI poly} /synthi_top_tb/DUT/midi_controller_1/ctrl_reg
add wave -noupdate -expand -group {tone generator (DDS)} -format Analog-Step -height 80 -max 4095.0000000000005 -min -4096.0 -radix sfixed /synthi_top_tb/DUT/tone_generator_1/dds_r_o
add wave -noupdate -expand -group {tone generator (DDS)} /synthi_top_tb/DUT/tone_generator_1/note_valid_o
add wave -noupdate -expand -group {tone generator (DDS)} -radix decimal -childformat {{/synthi_top_tb/DUT/tone_generator_1/final_sum_reg(15) -radix decimal} {/synthi_top_tb/DUT/tone_generator_1/final_sum_reg(14) -radix decimal} {/synthi_top_tb/DUT/tone_generator_1/final_sum_reg(13) -radix decimal} {/synthi_top_tb/DUT/tone_generator_1/final_sum_reg(12) -radix decimal} {/synthi_top_tb/DUT/tone_generator_1/final_sum_reg(11) -radix decimal} {/synthi_top_tb/DUT/tone_generator_1/final_sum_reg(10) -radix decimal} {/synthi_top_tb/DUT/tone_generator_1/final_sum_reg(9) -radix decimal} {/synthi_top_tb/DUT/tone_generator_1/final_sum_reg(8) -radix decimal} {/synthi_top_tb/DUT/tone_generator_1/final_sum_reg(7) -radix decimal} {/synthi_top_tb/DUT/tone_generator_1/final_sum_reg(6) -radix decimal} {/synthi_top_tb/DUT/tone_generator_1/final_sum_reg(5) -radix decimal} {/synthi_top_tb/DUT/tone_generator_1/final_sum_reg(4) -radix decimal} {/synthi_top_tb/DUT/tone_generator_1/final_sum_reg(3) -radix decimal} {/synthi_top_tb/DUT/tone_generator_1/final_sum_reg(2) -radix decimal} {/synthi_top_tb/DUT/tone_generator_1/final_sum_reg(1) -radix decimal} {/synthi_top_tb/DUT/tone_generator_1/final_sum_reg(0) -radix decimal}} -subitemconfig {/synthi_top_tb/DUT/tone_generator_1/final_sum_reg(15) {-height 15 -radix decimal} /synthi_top_tb/DUT/tone_generator_1/final_sum_reg(14) {-height 15 -radix decimal} /synthi_top_tb/DUT/tone_generator_1/final_sum_reg(13) {-height 15 -radix decimal} /synthi_top_tb/DUT/tone_generator_1/final_sum_reg(12) {-height 15 -radix decimal} /synthi_top_tb/DUT/tone_generator_1/final_sum_reg(11) {-height 15 -radix decimal} /synthi_top_tb/DUT/tone_generator_1/final_sum_reg(10) {-height 15 -radix decimal} /synthi_top_tb/DUT/tone_generator_1/final_sum_reg(9) {-height 15 -radix decimal} /synthi_top_tb/DUT/tone_generator_1/final_sum_reg(8) {-height 15 -radix decimal} /synthi_top_tb/DUT/tone_generator_1/final_sum_reg(7) {-height 15 -radix decimal} /synthi_top_tb/DUT/tone_generator_1/final_sum_reg(6) {-height 15 -radix decimal} /synthi_top_tb/DUT/tone_generator_1/final_sum_reg(5) {-height 15 -radix decimal} /synthi_top_tb/DUT/tone_generator_1/final_sum_reg(4) {-height 15 -radix decimal} /synthi_top_tb/DUT/tone_generator_1/final_sum_reg(3) {-height 15 -radix decimal} /synthi_top_tb/DUT/tone_generator_1/final_sum_reg(2) {-height 15 -radix decimal} /synthi_top_tb/DUT/tone_generator_1/final_sum_reg(1) {-height 15 -radix decimal} /synthi_top_tb/DUT/tone_generator_1/final_sum_reg(0) {-height 15 -radix decimal}} /synthi_top_tb/DUT/tone_generator_1/final_sum_reg
add wave -noupdate -expand -group {tone generator (DDS)} /synthi_top_tb/DUT/tone_generator_1/next_final_sum_reg
add wave -noupdate -group FM -expand -group {preset values} /synthi_top_tb/DUT/tone_generator_1/fm_attack
add wave -noupdate -group FM -expand -group {preset values} /synthi_top_tb/DUT/tone_generator_1/fm_decay
add wave -noupdate -group FM -expand -group {preset values} /synthi_top_tb/DUT/tone_generator_1/fm_sustain
add wave -noupdate -group FM -expand -group {preset values} /synthi_top_tb/DUT/tone_generator_1/fm_release
add wave -noupdate -group FM -expand -group {preset values} /synthi_top_tb/DUT/tone_generator_1/fm_freq
add wave -noupdate -group FM -expand -group {preset values} /synthi_top_tb/DUT/tone_generator_1/fm_amp
add wave -noupdate -group FM -expand -group {preset values} /synthi_top_tb/DUT/tone_generator_1/fm_mode
add wave -noupdate -group FM -expand -group {control signals} -radix sfixed -childformat {{/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/phi_incr_sig(0) -radix sfixed} {/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/phi_incr_sig(1) -radix sfixed} {/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/phi_incr_sig(2) -radix sfixed}} -subitemconfig {/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/phi_incr_sig(0) {-height 15 -radix sfixed} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/phi_incr_sig(1) {-height 15 -radix sfixed} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/phi_incr_sig(2) {-height 15 -radix sfixed}} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/phi_incr_sig
add wave -noupdate -group FM -expand -group {control signals} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/tone_on_sig
add wave -noupdate -group FM -expand -group {control signals} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/velocity_adsr_sig
add wave -noupdate -group FM -expand -group {control signals} -radix hexadecimal /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/note_valid_adsr_sig
add wave -noupdate -group FM -group {FM test tone 1} -format Analog-Step -height 50 -max 4095.0000000000005 -min -4096.0 -radix sfixed /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/dds_o
add wave -noupdate -group FM -group {FM test tone 1} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/note_valid_o
add wave -noupdate -group FM -group {FM test tone 1} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(0)/inst_adsr/fsm_state
add wave -noupdate -group FM -group {FM test tone 1} -format Analog-Step -height 50 -max 4095.0000000000005 -min -4096.0 -radix sfixed /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(0)/inst_adsr/dds_o
add wave -noupdate -group FM -group {FM test tone 1} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(1)/inst_adsr/fsm_state
add wave -noupdate -group FM -group {FM test tone 1} -format Analog-Step -height 50 -max 4095.0000000000005 -min -4096.0 -radix sfixed /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(1)/inst_adsr/dds_o
add wave -noupdate -group FM -group {FM test tone 1} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/fsm_state
add wave -noupdate -group FM -group {FM test tone 1} -format Analog-Step -height 50 -max 4095.0000000000005 -min -4096.0 -radix sfixed -childformat {{/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(15) -radix sfixed} {/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(14) -radix sfixed} {/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(13) -radix sfixed} {/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(12) -radix sfixed} {/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(11) -radix sfixed} {/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(10) -radix sfixed} {/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(9) -radix sfixed} {/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(8) -radix sfixed} {/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(7) -radix sfixed} {/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(6) -radix sfixed} {/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(5) -radix sfixed} {/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(4) -radix sfixed} {/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(3) -radix sfixed} {/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(2) -radix sfixed} {/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(1) -radix sfixed} {/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(0) -radix sfixed}} -subitemconfig {/synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(15) {-height 15 -radix sfixed} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(14) {-height 15 -radix sfixed} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(13) {-height 15 -radix sfixed} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(12) {-height 15 -radix sfixed} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(11) {-height 15 -radix sfixed} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(10) {-height 15 -radix sfixed} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(9) {-height 15 -radix sfixed} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(8) {-height 15 -radix sfixed} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(7) {-height 15 -radix sfixed} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(6) {-height 15 -radix sfixed} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(5) {-height 15 -radix sfixed} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(4) {-height 15 -radix sfixed} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(3) {-height 15 -radix sfixed} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(2) {-height 15 -radix sfixed} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(1) {-height 15 -radix sfixed} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o(0) {-height 15 -radix sfixed}} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o
add wave -noupdate -group FM -group {FM test tone 2} -format Analog-Step -height 50 -max 4095.0000000000005 -min -4096.0 -radix sfixed /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(1)/inst_fm/dds_o
add wave -noupdate -group FM -group {FM test tone 2} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(1)/inst_fm/note_valid_o
add wave -noupdate -group FM -group {FM test tone 2} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(1)/inst_fm/ADSR_inst_gen(0)/inst_adsr/fsm_state
add wave -noupdate -group FM -group {FM test tone 2} -format Analog-Step -height 50 -max 4095.0000000000005 -min -4096.0 -radix sfixed /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(1)/inst_fm/ADSR_inst_gen(0)/inst_adsr/dds_o
add wave -noupdate -group FM -group {FM test tone 2} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(1)/inst_fm/ADSR_inst_gen(1)/inst_adsr/fsm_state
add wave -noupdate -group FM -group {FM test tone 2} -format Analog-Step -height 50 -max 4095.0000000000005 -min -4096.0 -radix sfixed /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(1)/inst_fm/ADSR_inst_gen(1)/inst_adsr/dds_o
add wave -noupdate -group FM -group {FM test tone 2} /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(1)/inst_fm/ADSR_inst_gen(2)/inst_adsr/fsm_state
add wave -noupdate -group FM -group {FM test tone 2} -format Analog-Step -height 50 -max 4095.0000000000005 -min -4096.0 -radix sfixed /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(1)/inst_fm/ADSR_inst_gen(2)/inst_adsr/dds_o
add wave -noupdate -group {Lowpass Filter} /synthi_top_tb/DUT/tone_generator_1/low_pass_enable_i
add wave -noupdate -group {Lowpass Filter} -format Analog-Step -height 74 -max 4095.0 -min -4096.0 -radix decimal /synthi_top_tb/DUT/tone_generator_1/sum_reg
add wave -noupdate -group {Lowpass Filter} -format Analog-Step -height 74 -max 4095.0 -min -4096.0 -radix decimal /synthi_top_tb/DUT/tone_generator_1/next_final_sum_reg
add wave -noupdate -group Wavetable -format Analog-Step -height 74 -max 4095.0 -min -4096.0 -radix decimal /synthi_top_tb/DUT/tone_generator_1/dds_l_o
add wave -noupdate -group Wavetable /synthi_top_tb/DUT/tone_generator_1/ctrl_reg_i
add wave -noupdate -expand -group ADSR -format Analog-Step -height 74 -max 4095.0 -min -4096.0 -radix decimal /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(0)/inst_adsr/dds_o
add wave -noupdate -expand -group ADSR -format Analog-Step -max 100.0 -radix decimal /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(0)/inst_adsr/volume
add wave -noupdate /synthi_top_tb/DUT/tone_generator_1/fm_inst_gen(0)/inst_fm/ADSR_inst_gen(0)/inst_adsr/fsm_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {20340230 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 572
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
WaveRestoreZoom {0 ns} {226945342 ns}
