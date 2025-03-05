##Clock signal
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { i_Clk }]; #IO_L11P_T1_SRCC_35 Sch=sysclk
create_clock -add -name sys_clk_pin -period 8.00 [get_ports { i_Clk }];

##Switches
set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { i_Switches[0] }]; #IO_L19N_T3_VREF_35 Sch=SW0
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { i_Switches[1] }]; #IO_L24P_T3_34 Sch=SW1
set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports { i_Switches[2] }]; #IO_L4N_T0_34 Sch=SW2
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { i_Switches[3] }]; #IO_L9P_T1_DQS_34 Sch=SW3

##Buttons
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports i_Rst]; #IO_L20N_T3_34 Sch=BTN0
set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 } [get_ports i_Soft_Rst]; #IO_L24N_T3_34 Sch=BTN1

##LEDs
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { o_Leds[0] }]; #IO_L23P_T3_35 Sch=LED0
set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports { o_Leds[1] }]; #IO_L23N_T3_35 Sch=LED1
set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS33 } [get_ports { o_Leds[2] }]; #IO_0_35=Sch=LED2
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { o_Leds[3] }]; #IO_L3N_T0_DQS_AD1N_35 Sch=LED3

##Pmod Header JB
set_property -dict { PACKAGE_PIN T20   IOSTANDARD LVCMOS33 } [get_ports { io_Pin_Port[0] }]; #IO_L15P_T2_DQS_34 Sch=JB1_p
set_property -dict { PACKAGE_PIN U20   IOSTANDARD LVCMOS33 } [get_ports { io_Pin_Port[1] }]; #IO_L15N_T2_DQS_34 Sch=JB1_N
set_property -dict { PACKAGE_PIN V20   IOSTANDARD LVCMOS33 } [get_ports { io_Pin_Port[2] }]; #IO_L16P_T2_34 Sch=JB2_P
set_property -dict { PACKAGE_PIN W20   IOSTANDARD LVCMOS33 } [get_ports { io_Pin_Port[3] }]; #IO_L16N_T2_34 Sch=JB2_N
set_property -dict { PACKAGE_PIN Y18   IOSTANDARD LVCMOS33 } [get_ports { io_Pin_Port[4] }]; #IO_L17P_T2_34 Sch=JB3_P
set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33 } [get_ports { io_Pin_Port[5] }]; #IO_L17N_T2_34 Sch=JB3_N
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports { io_Pin_Port[6] }]; #IO_L22P_T3_34 Sch=JB4_P
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports { io_Pin_Port[7] }]; #IO_L22N_T3_34 Sch=JB4_N
set_property PULLDOWN TRUE [get_ports io_Pin_Port[0]]
set_property PULLDOWN TRUE [get_ports io_Pin_Port[1]]
set_property PULLDOWN TRUE [get_ports io_Pin_Port[2]]
set_property PULLDOWN TRUE [get_ports io_Pin_Port[3]]
set_property PULLDOWN TRUE [get_ports io_Pin_Port[4]]
set_property PULLDOWN TRUE [get_ports io_Pin_Port[5]]
set_property PULLDOWN TRUE [get_ports io_Pin_Port[6]]
set_property PULLDOWN TRUE [get_ports io_Pin_Port[7]]

##Pmod Header JC
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { io_Pin_Port[8] }]; #IO_L10P_T1_34 Sch=JC1_P
set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33 } [get_ports { io_Pin_Port[9] }]; #IO_L10N_T1_34 Sch=JC1_N
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33 } [get_ports { io_Pin_Port[10] }]; #IO_L1P_T0_34 Sch=JC2_P
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { io_Pin_Port[11] }]; #IO_L1N_T0_34 Sch=JC2_N
set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33 } [get_ports { io_Pin_Port[12] }]; #IO_L8P_T1_34 Sch=JC3_P
set_property -dict { PACKAGE_PIN Y14   IOSTANDARD LVCMOS33 } [get_ports { io_Pin_Port[13] }]; #IO_L8N_T1_34 Sch=JC3_N
set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33 } [get_ports { io_Pin_Port[14] }]; #IO_L2P_T0_34 Sch=JC4_P
set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { io_Pin_Port[15] }]; #IO_L2N_T0_34 Sch=JC4_N
set_property PULLDOWN TRUE [get_ports io_Pin_Port[8]]
set_property PULLDOWN TRUE [get_ports io_Pin_Port[9]]
set_property PULLDOWN TRUE [get_ports io_Pin_Port[10]]
set_property PULLDOWN TRUE [get_ports io_Pin_Port[11]]
set_property PULLDOWN TRUE [get_ports io_Pin_Port[12]]
set_property PULLDOWN TRUE [get_ports io_Pin_Port[13]]
set_property PULLDOWN TRUE [get_ports io_Pin_Port[14]]
set_property PULLDOWN TRUE [get_ports io_Pin_Port[15]]
