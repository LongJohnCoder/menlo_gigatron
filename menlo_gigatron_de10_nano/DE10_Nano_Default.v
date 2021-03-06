
//
//   Menlo Silicon Shell DE10-Nano SoC board support.
//
//   Created from Terasic Default project for support of DE10-Nano SoC.
//
//   Copyright (C) 2018 Menlo Park Innovation LLC
//
//   menloparkinnovation.com
//   menloparkinnovation@gmail.com
//
//   Snapshot License
//
//   This license is for a specific snapshot of a base work of
//   Menlo Park Innovation LLC on a non-exclusive basis with no warranty
//   or obligation for future updates. This work, any portion, or derivative
//   of it may be made available under other license terms by
//   Menlo Park Innovation LLC without notice or obligation to this license.
//
//   There is no warranty, statement of fitness, statement of
//   fitness for any purpose, and no statements as to infringements
//   on any patents.
//
//   Menlo Park Innovation has no obligation to offer support, updates,
//   future revisions and improvements, source code, source code downloads,
//   media, etc.
//
//   This specific snapshot is made available under the following license:
//
//   Licensed under the MIT License (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://opensource.org/licenses/MIT
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module DE10_Nano_Default(

	//////////// ADC //////////
	output		          		ADC_CONVST,
	output		          		ADC_SCK,
	output		          		ADC_SDI,
	input 		          		ADC_SDO,

	//////////// ARDUINO //////////
	inout 		    [15:0]		ARDUINO_IO,
	inout 		          		ARDUINO_RESET_N,

	//////////// CLOCK //////////
	input 		          		FPGA_CLK1_50,
	input 		          		FPGA_CLK2_50,
	input 		          		FPGA_CLK3_50,

	//////////// HDMI //////////
	inout 		          		HDMI_I2C_SCL,
	inout 		          		HDMI_I2C_SDA,
	inout 		          		HDMI_I2S,
	inout 		          		HDMI_LRCLK,
	inout 		          		HDMI_MCLK,
	inout 		          		HDMI_SCLK,
	output		          		HDMI_TX_CLK,
	output		          		HDMI_TX_DE,
	output		    [23:0]		HDMI_TX_D,
	output		          		HDMI_TX_HS,
	input 		          		HDMI_TX_INT,
	output		          		HDMI_TX_VS,

	//////////// KEY //////////
	input 		     [1:0]		KEY,

	//////////// LED //////////
	output		     [7:0]		LED,

	//////////// SW //////////
	input 		     [3:0]		SW
);

  //
  // PLL generated clocks.
  //

  // 25Mhz display clock from PLL
  wire    vga_clock;

  // Application main Clock from Altera PLL outclk_2 generated by IP wizard.
  wire    application_clock_6_25Mhz;

  // HDMI Audio I2S clock 1.536 Mhz from PLL
  wire audio_clock;

  //
  // Closely tied hardware modules are in this board support top level
  // module. Typically its created from the board suppliers default
  // project template, with any board/FPGA specific core IP modules
  // integrated.
  //
  // Generic hardware is specialized in the <board_name>_top.sv project
  // for the particular board.
  //
  // Application logic goes into the application_shell.sv.
  //

  sys_pll u_sys_pll (
    .refclk(FPGA_CLK1_50),
    .rst(1'b0),
    .outclk_0(audio_clock), // 1.536 Mhz
    .outclk_1(vga_clock),   // vga_clock 25 Mhz
    .outclk_2(application_clock_6_25Mhz) // 6.25Mhz application clock
    );

  //
  // Invoke the board specific customization shell.
  //
  // This shell creates an environment for the application out
  // of generic resources, so is separate from this per board
  // customized file.
  //

  DE10_Nano_Shell_Top de10_nano_shell_top (
    .ADC_CONVST(ADC_CONVST),
    .ADC_SCK(ADC_SCK),
    .ADC_SDI(ADC_SDI),
    .ADC_SDO(ADC_SDO),

    .ARDUINO_IO(ARDUINO_IO),
    .ARDUINO_RESET_N(ARDUINO_RESET_N),

    .FPGA_CLK1_50(FPGA_CLK1_50),
    .FPGA_CLK2_50(FPGA_CLK2_50),
    .FPGA_CLK3_50(FPGA_CLK3_50),

    .HDMI_I2C_SCL(HDMI_I2C_SCL),
    .HDMI_I2C_SDA(HDMI_I2C_SDA),
    .HDMI_I2S(HDMI_I2S),
    .HDMI_LRCLK(HDMI_LRCLK),
    .HDMI_MCLK(HDMI_MCLK),
    .HDMI_SCLK(HDMI_SCLK),
    .HDMI_TX_CLK(HDMI_TX_CLK),
    .HDMI_TX_DE(HDMI_TX_DE),
    .HDMI_TX_D(HDMI_TX_D),
    .HDMI_TX_HS(HDMI_TX_HS),
    .HDMI_TX_INT(HDMI_TX_INT),
    .HDMI_TX_VS(HDMI_TX_VS),

    .KEY(KEY),
    .LED(LED),
    .SW(SW),

    .application_clock(application_clock_6_25Mhz),
    .vga_clock(vga_clock),
    .audio_clock(audio_clock)
  );

endmodule // DE10_Nano_Default
