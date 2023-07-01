`timescale 1ns / 1ns
`default_nettype wire

//    This file is part of the UnoXT Dev Board Project. 
//    (copyleft)2022 emax73.
//    UnoXT official repository: https://gitlab.com/emax73g/unoxt-hardware
//
//    UnoXT core is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    UnoXT core is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with the UnoXT core.  If not, see <https://www.gnu.org/licenses/>.
//
//    Any distributed copy of this file must keep this notice intact.

//UnoXT Generation Selector
//`define unoxt
`define unoxt2

`ifdef unoxt
	module unoxt_top (
`elsif unoxt2
	module unoxt2_top (
`else
	module unoxt_top (
`endif

   input wire clock_50_i,
	
   output wire [4:0] rgb_r_o,
   output wire [4:0] rgb_g_o,
   output wire [4:0] rgb_b_o,
   output wire hsync_o,
   output wire vsync_o,
   input wire ear_port_i,
   output wire mic_port_o,
   inout wire ps2_clk_io,
   inout wire ps2_data_io,
   inout wire ps2_pin6_io,
   inout wire ps2_pin2_io,
   output wire audioext_l_o,
   output wire audioext_r_o,

   inout wire esp_gpio0_io,
   inout wire esp_gpio2_io,
   output wire esp_tx_o,
   input wire esp_rx_i,
 
   output wire [20:0] ram_addr_o,
   output wire ram_lb_n_o,
   output wire ram_ub_n_o,
   inout wire [15:0] ram_data_io,
   output wire ram_oe_n_o,
   output wire ram_we_n_o,
   output wire ram_ce_n_o,
   
   output wire flash_cs_n_o,
   output wire flash_sclk_o,
   output wire flash_mosi_o,
   input wire flash_miso_i,
   output wire flash_wp_o,
   output wire flash_hold_o,
   
   input wire joyp1_i,
   input wire joyp2_i,
   input wire joyp3_i,
   input wire joyp4_i,
   input wire joyp6_i,
   output wire joyp7_o,
   input wire joyp9_i,
	
   input wire btn_divmmc_n_i,
   input wire btn_multiface_n_i,

   output wire sd_cs0_n_o,    
   output wire sd_sclk_o,     
   output wire sd_mosi_o,    
   input wire sd_miso_i,
`ifdef unoxt2
   input wire sd_d1_i,
   input wire sd_d2_i,
`endif	

   output wire led_red_o,
   output wire led_yellow_o,
   output wire led_green_o,
   output wire led_blue_o,
	
`ifdef unoxt2	
	
   output wire [12:0] sdram_addr,
   output wire [1:0] sdram_ba,
	output wire sdram_cke,
 	output wire sdram_we_n,
 	output wire sdram_cas_n,
 	output wire sdram_ras_n,
 	output wire sdram_cs_n,
   inout wire [15:0] sdram_data,
 	output wire sdram_ldqm,
 	output wire sdram_udqm,
 	output wire sdram_clk

`endif

   //output wire [8:0] test

   );
   
	`define DEFAULT_100_LEDS;
	
	`ifdef ROUND_DIF_LEDS
		//3mm round diffused LEDs
		localparam ledRedK = 16'd20;
		localparam ledYellowK = 16'd50;
		localparam ledGreenK = 16'd12;
		localparam ledBlueK = 16'd50;
	`elsif SQUARE_LEDS
		//square color LEDs
		localparam ledRedK = 16'd20;
		localparam ledYellowK = 16'd33;
		localparam ledGreenK = 16'd100;
		localparam ledBlueK = 16'd20;
	`else
		//default 100% LEDs
		localparam ledRedK = 16'd100;
		localparam ledYellowK = 16'd100;
		localparam ledGreenK = 16'd100;
		localparam ledBlueK = 16'd100;
	`endif
	
	wire sysclk;
	wire [1:0] turbo;
	wire [15:0] turbo100;
	wire [11:0] joyA;
	wire [4:0] joy1;
	wire [5:0] rgb_r, rgb_g, rgb_b;
	wire ram_ce_oe_n_o;
	wire [5:0] joystick;
	
	wire [7:0] dips;
	wire [7:0] leds;
	wire powerLed;
	wire redLed, yellowLed, greenLed, blueLed;
	
	emsx_top	#(.use_midi_g(1'b0))
	msxpp
	(
      //Clock, Reset ports
		//to Do
		.pClk21m(clock_50_i),
		.pSysClk(sysclk),
		
		//MSX cartridge slot ports
      .pSltRst_n(btn_divmmc_n_i),
	
		/*.SRAM_DQ(ram_data_io[7:0]),
		.SRAM_ADDR(ram_addr_o[18:0]),
		.SRAM_WE_N(ram_we_n_o),
		*/
      //SDRAM ports
      .pMemClk(sdram_clk),
      .pMemCke(sdram_cke),
      .pMemCs_n(sdram_cs_n),
      .pMemRas_n(sdram_ras_n),
      .pMemCas_n(sdram_cas_n),
      .pMemWe_n(sdram_we_n),
      .pMemUdq(sdram_udqm),
      .pMemLdq(sdram_ldqm),
      .pMemBa1(sdram_ba[1]),
      .pMemBa0(sdram_ba[0]),
      .pMemAdr(sdram_addr),
      .pMemDat(sdram_data),
		
		//PS/2 keyboard ports
      .pPs2Clk(ps2_clk_io),
      .pPs2Dat(ps2_data_io),
		
		//Joy To Do
		
		//SD/MMC slot ports
      //Max
		/*.pSd_Ck(sd_sclk_o),		// pin 5
      .pSd_Cm(sd_mosi_o),		// pin 2
      .pSd_Dt({sd_cs0_n_o, sd_d2_i, sd_d1_i, sd_miso_i }), //pin 1(D3), 9(D2), 8(D1), 7(D0)
		*/
		.pSd_cs(sd_cs0_n_o),	
		.pSd_sclk(sd_sclk_o),	
		.pSd_mosi(sd_mosi_o),	
		.pSd_miso(sd_miso_i),
	
	   //DIP switch, Lamp ports
      .pDip(dips),
      .pLed(leds),
      .pLedPwr(powerLed),
		
		//Video, Audio/CMT ports
      .pDac_VR(rgb_r),
      .pDac_VG(rgb_g),
      .pDac_VB(rgb_b),
      //Sound to Do
		//.pDac_SL         : out   std_logic_vector(  5 downto 0 ) := "ZZZZZZ";    -- Sound-L
      //.pDac_SR         : inout std_logic_vector(  5 downto 0 ) := "ZZZZZZ";    -- Sound-R / CMT

      .pVideoHS_n(hsync_o),		// Csync(RGB15K), HSync(VGA31K)
      .pVideoVS_n(vsync_o)			// Audio(RGB15K), VSync(VGA31K)
);

	assign dips = {1'b0,1'b1,2'b01,1'b0,2'b10,1'b0};            // 8=Mega_Sd / 7=Interal_Mapper / 6:5=Slot2 / 4=Slot1 / 
	assign redLed = 1'b1;
	assign yellowLed = leds[2];
	//assign greenLed = leds[1];
	assign blueLed = leds[0];

	assign rgb_r_o = rgb_r[5:1];
	assign rgb_g_o = rgb_g[5:1];
	assign rgb_b_o = rgb_b[5:1];

 	assign joyp7_o = 1'b1;
	assign joy1 = {joyp6_i, joyp1_i, joyp2_i, joyp3_i, joyp4_i};
	
	assign ram_oe_n_o = 1'b1;
	assign ram_ce_n_o = 1'b1;
	assign ram_we_n_o = 1'b1;
	assign ram_lb_n_o = 1'b1;
	assign ram_ub_n_o = 1'b1;
	assign ram_data_io[15:0] = 16'bz;
	assign ram_addr_o[20:0] = 21'b0;
	
	assign audioext_l_o = 1'b1;
   assign audioext_r_o = 1'b1;
	
	assign mic_port_o = 1'b1;
 
	assign esp_gpio0_io = 1'b1;
	assign esp_gpio2_io = 1'b1;
	assign esp_tx_o = 1'b1;
	
	assign flash_cs_n_o = 1'b1;
	assign flash_sclk_o = 1'b1;
	assign flash_mosi_o = 1'b1;
	assign flash_wp_o = 1'b1;
	assign flash_hold_o = 1'b1;
	
	
	assign greenLed = !sd_cs0_n_o;
	/*flashCnt #(.CLK_MHZ(16'd50)) cnt(
		.clk(sysclk),
		.signal(sd_sclk_o),
		.msec(16'd20),
		.flash(greenLed)
	);*/
	
	/*assign turbo100 = (turbo == 2'b00) ? 16'd0 :
							(turbo == 2'b01) ? 16'd33 :
							(turbo == 2'b10) ? 16'd66 :
							(turbo == 2'b11) ? 16'd100 :
							16'd0;
	
	
  joystick #(.CLK_MHZ(16'd50)) joy 
  (
 		.clk(sysclk),
		.joyp1_i(joyp1_i),
		.joyp2_i(joyp2_i),
		.joyp3_i(joyp3_i),
		.joyp4_i(joyp4_i),
		.joyp6_i(joyp6_i),
		.joyp7_o(joyp7_o),
		.joyp9_i(joyp9_i),
		.joyOut(joyA)		// MXYZ SACB UDLR  1- On 0 - off
		//.test(test)
  );*/


 	ledPWM ledRed(
		.nReset(1'b1),
		.clock(sysclk),
		.enable(redLed),
		.y1(16'd100),
		.y2(ledRedK),	
		.led(led_red_o)
    );

	ledPWM ledYellow(
		.nReset(1'b1),
		.clock(sysclk),
		.enable(yellowLed),
		.y1(16'd100),
		.y2(ledYellowK),	
		.led(led_yellow_o)
    );

	ledPWM ledGreen(
		.nReset(1'b1),
		.clock(sysclk),
		.enable(greenLed),
		.y1(16'd100),
		.y2(ledGreenK),	
		.led(led_green_o)
    );

	ledPWM ledBlue(
		.nReset(1'b1),
		.clock(sysclk),
		.enable(blueLed),
		.y1(16'd100),
		.y2(ledBlueK),	
		.led(led_blue_o)
    );
	 
	 /*assign test[0] = sd_cs0_n_o;
	 assign test[1] = sd_sclk_o;
	 assign test[2] = sd_mosi_o;
	 assign test[3] = sd_miso_i;
	 assign test[4] = 1'b1;
	 assign test[5] = test5;
	 assign test[6] = 1'b1;
	 assign test[7] = 1'b1;
	 assign test[8] = 1'b1;
	 */
  
endmodule
