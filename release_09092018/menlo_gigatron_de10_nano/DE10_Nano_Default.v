
//
// Menlo: 08/24/2018
//
// Modified to create a shell for hosting the Menlo Gigatron.
//

// This produces a VGA test pattern instead of the Gigatron instance
//`define VGA_TEST_PATTERN 1

// Use the RAW, not debounce logic switches
`define RAW_SWITCHES 1

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
   // FPGA Clock.
   //

   wire clock;
   assign clock = FPGA_CLK1_50;

  //
  // PLL generated clocks.
  //

  // 25Mhz display clock from PLL
  wire    disp_clk;

  // Menlo: Gigatron Main Clock from Altera PLL outclk_2 generated by IP wizard.
  wire    clock_6_25Mhz;

  // HDMI Audio I2S clock 1.536 Mhz from PLL
  wire pll_1536k;

  sys_pll u_sys_pll (
    .refclk(FPGA_CLK1_50),
    .rst(1'b0),
    .outclk_0(pll_1536k), // 1.536 Mhz
    .outclk_1(disp_clk),  // vga_clock 25 Mhz
    .outclk_2(clock_6_25Mhz) // Menlo: 6.25 Mhz Gigatron main clock
    );

  //
  // Reset Generator.
  //
  Reset_Delay reset_generator(
    .iCLK(FPGA_CLK1_50),
    .oRESET(reset_n) // output
    );

  // Unused. Set to known value to prevent warnings.
  assign ADC_CONVST = 1'b0;
  assign ADC_SCK = 1'b0;
  assign ADC_SDI = 1'b0;

  //
  // Top 4 LED's are used for user interface for settings along
  // with the pushbuttons and switches.
  //
  reg reg_led4;
  reg reg_led5;
  reg reg_led6;
  reg reg_led7;
   
  assign LED[4:4] = reg_led4;
  assign LED[5:5] = reg_led5;
  assign LED[6:6] = reg_led6;
  assign LED[7:7] = reg_led7;
   
  //
  // Handle switch and push button user interface
  //
  // It uses the (4) switches for the user interface modes,
  // and the (2) push buttons for mode specific user interface
  // select functions.
  //

  //
  // SW [3:0] are available for user interface modes.
  //
  // SW[0:0] is on the right.
  //   - Used for hsync adjust. 
  //   - Left button KEY[1:1] is move frame left.
  //   - Right button KEY[0:0] is move frame right.
  //
  // SW[1:1] is second from right.
  //   - Used for vsync adjust. 
  //   - Left button KEY[1:1] is move frame up.
  //   - Right button KEY[0:0] is move frame down.
  //
  // SW[2:2] is second from left.
  //   - Unassigned.
  //   - Could simulate game port selections.
  //
  // SW[3:3] is on the left.
  //   - Used for Audio Test Mode.
  //   - KEY[1:1] pressed is audio test.
  //   - KEY[0:0] is not used.
  //

  wire switch0_state;
  wire switch1_state;
  wire switch2_state;
  wire switch3_state;

  user_switch switch0(
    .raw_switch(SW[0:0]),
    .clock(clock),
    .reset_n(reset_n),
    .switch_state(switch0_state)
  );

  user_switch switch1(
    .raw_switch(SW[1:1]),
    .clock(clock),
    .reset_n(reset_n),
    .switch_state(switch1_state)
  );

  user_switch switch2(
    .raw_switch(SW[2:2]),
    .clock(clock),
    .reset_n(reset_n),
    .switch_state(switch2_state)
  );

  user_switch switch3(
    .raw_switch(SW[3:3]),
    .clock(clock),
    .reset_n(reset_n),
    .switch_state(switch3_state)
  );

  //
  // KEY[0:0] is on the right.
  // KEY[1:1] is on the left.
  //

  wire key0_pressed;
  reg key0_pressed_ack;
   
  wire key1_pressed;
  reg key1_pressed_ack;

  user_push_button key0(
    .raw_button_n(KEY[0:0]),
    .clock(clock),
    .reset_n(reset_n),
    .press_accepted(key0_pressed_ack),
    .press_activated(key0_pressed)
  );

  user_push_button key1(
    .raw_button_n(KEY[1:1]),
    .clock(clock),
    .reset_n(reset_n),
    .press_accepted(key1_pressed_ack),
    .press_activated(key1_pressed)
  );

  // Audio test setting
  reg 	      hdmi_audio_test;

  always@ (posedge clock) begin
    if (reset_n == 1'b0) begin
       key0_pressed_ack <= 0;
       key1_pressed_ack <= 0;
       reg_led4 <= 0;
       reg_led5 <= 0;
       reg_led6 <= 0;
       reg_led7 <= 0;
       hdmi_audio_test <= 0;
    end
    else begin

      //
      // Not reset.
      //

      //
      // Drive the user interface state machine
      //

      //
      // Keys handler
      //

      //
      // Test: Show push button states on the LED's
      //
      //reg reg_led6; // KEY0
      //reg reg_led7; // KEY1
      //

`ifdef RAW_SWITCHES

      if (KEY[0:0] == 1'b0) begin
        reg_led6 <= 1'b1;
      end // key0
      else begin
        reg_led6 <= 1'b0;
      end

      if (KEY[1:1] == 1'b0) begin
        reg_led7 <= 1'b1;
      end // key1
      else begin
        reg_led7 <= 1'b0;
      end

      //
      // Switches handler
      //
      // Test: Show switch states on the LED's
      //
      // reg reg_led5; // SW[0:0]
      // reg reg_led4; // SW[1:1]
      //
      if (SW[0:0] == 1'b1) begin
        reg_led5 <= 1'b1;
        hdmi_audio_test <= 1'b1;
      end
      else begin
        reg_led5 <= 1'b0;
        hdmi_audio_test <= 1'b0;
      end

      if (SW[1:1] == 1'b1) begin
        reg_led4 <= 1'b1;
      end
      else begin
        reg_led4 <= 1'b0;
      end

`else

      if (key0_pressed_ack == 1'b1) begin
        // Cancel ack
        key0_pressed_ack <= 1'b0;
      end
      else begin
        if (key0_pressed == 1'b1) begin
          // Ack it
          key0_pressed_ack <= 1'b1;

          // toggle LED
          reg_led6 <= ~reg_led6;
        end
      end // key0

      if (key1_pressed_ack == 1'b1) begin
        // Cancel ack
        key1_pressed_ack <= 1'b0;
      end
      else begin
        if (key1_pressed == 1'b1) begin
          // Ack it
          key1_pressed_ack <= 1'b1;

          // toggle LED
          reg_led7 <= ~reg_led7;
        end
      end // key1

      //
      // Switches handler
      //
      // Test: Show switch states on the LED's
      //
      // reg reg_led5; // SW[0:0]
      // reg reg_led4; // SW[1:1]
      //
      if (switch0_state == 1'b1) begin
        reg_led5 <= 1'b1;
        hdmi_audio_test <= 1'b1;
      end
      else begin
        reg_led5 <= 1'b0;
        hdmi_audio_test <= 1'b0;
      end

      if (switch1_state == 1'b1) begin
        reg_led4 <= 1'b1;
      end
      else begin
        reg_led4 <= 1'b0;
      end

`endif // RAW_SWITCHES

    end // not reset

  end // always user interface state machine

  //
  // HDMI I2C	
  //
  I2C_HDMI_Config u_I2C_HDMI_Config (
    .iCLK(FPGA_CLK1_50),
    .iRST_N(reset_n),
    .I2C_SCLK(HDMI_I2C_SCL),
    .I2C_SDAT(HDMI_I2C_SDA),
    .HDMI_TX_INT(HDMI_TX_INT)
  );
   
  //
  // VGA controller implements a 640x480 8 bit true color dual ported frame buffer.
  //
  // It can optionally implement a customized palette as well.
  //

  //
  // VGA Frame buffer write variables
  //
  wire        vga_write_clock;
  wire        vga_write_signal;
  wire [18:0] vga_write_address;
  wire  [7:0] vga_write_data;

  // hdmi support
  wire [7:0] hdmi_b;
  wire [7:0] hdmi_g;
  wire [7:0] hdmi_r;
  wire       disp_de;
  wire       disp_hs;
  wire       disp_vs;
  wire       reset_n; // active low reset

  vga_controller hdmi_ins(
    .iRST_n(reset_n),
    .iVGA_CLK(disp_clk),
    .fpga_clock(FPGA_CLK1_50),
    .oBLANK_n(disp_de),
    .oHS(disp_hs),
    .oVS(disp_vs),
    .b_data(hdmi_b),
    .g_data(hdmi_g),
    .r_data(hdmi_r),
    .input_framebuffer_write_clock(vga_write_clock),
    .input_framebuffer_write_signal(vga_write_signal),
    .input_framebuffer_write_address(vga_write_address),
    .input_framebuffer_write_data(vga_write_data)
    );	
							 
  // These are the output generated signals to the HDMI display driver chip.
  assign HDMI_TX_CLK	= disp_clk;
  assign HDMI_TX_D	= {hdmi_r,hdmi_g,hdmi_b};
  assign HDMI_TX_DE	= disp_de;
  assign HDMI_TX_HS	= disp_hs;
  assign HDMI_TX_VS	= disp_vs;
	
  //
  // HDMI I2S audio support.
  //

  // Gigatron audio output DAC
  wire [3:0]  gigatron_audio_output_dac;

  wire [15:0] hdmi_audio_input;
   
  // I2S audio standard sets the MSB bits first.
  assign hdmi_audio_input[15:12] = gigatron_audio_output_dac;

  // I2S audio standard sets the low bits to 0 when not supplied.
  assign hdmi_audio_input[11:0] = 12'h000;

  menlo_hdmi_audio hdmi_audio(
	.reset_n(reset_n),         // input
	.sclk(HDMI_SCLK),          // output to HDMI (passed through from .clk)
	.lrclk(HDMI_LRCLK),        // output to HDMI
	.i2s(HDMI_I2S),            // output [3:0] four serialized HDMI I2S audio channels
	.clk(pll_1536k),           // input
        .audio_in(hdmi_audio_input), // input audio DAC audio signal
        .audio_test(hdmi_audio_test) // input, true if use internal test sample.
  );
	
  //
  // Menlo Gigatron Project invoked by this shell.
  //

  wire reset;
  assign reset = ~reset_n;

  wire [7:0] gigatron_output_port;
  wire [7:0] gigatron_extended_output_port;

  //
  // RAW VGA signals from the Gigatron
  //
  wire hsync_n;
  wire vsync_n;
  wire [1:0] red;
  wire [1:0] green;
  wire [1:0] blue;

  //
  // BlinkenLights
  //
  wire led5;
  wire led6;
  wire led7;
  wire led8;

  assign LED[0:0] = led5;
  assign LED[1:1] = led6;
  assign LED[2:2] = led7;
  assign LED[3:3] = led8;

  //
  // Serial game controller
  //
  wire famicom_pulse;
  wire famicom_latch;
  wire famicom_data;

  //
  // inout [15:0] ARDUINO_IO
  //
  // Handle Arduino I/O to the game port.
  //
  // ARDUINO_IO[2:2] - famicom_data  (input),  Pin 2 of the DB9, 2.2K pull up to VCC
  // ARDUINO_IO[3:3] - famicom_pulse (output), Pin 4 of the DB9, series 68 ohm
  // ARDUINO_IO[4:4] - famicom_latch (output), Pin 3 of the DB9, series 68 ohm
  //
  // VCC +5V to DB9 Pin 6, Red
  // GND     to DB9 Pin 8, Black
  //

  // Assign ARDUINO_IO[2:2] output to hiZ as its only an input.
  assign ARDUINO_IO[2:2] = 1'bz;

  assign famicom_data = ARDUINO_IO[2:2]; // input signal, DB9 Pin 2, Green
  assign ARDUINO_IO[3:3] = famicom_pulse; // output signal, DB9 Pin 4, Yellow
  assign ARDUINO_IO[4:4] = famicom_latch; // output signal, DB9 Pin 3, White

  // Gigatron VGA output signals
  wire gigatron_framebuffer_write_clock;
  wire gigatron_framebuffer_write_signal;
  wire [18:0] gigatron_framebuffer_write_address;
  wire [7:0] gigatron_framebuffer_write_data;

`ifdef VGA_TEST_PATTERN

  //
  // Create a VGA color test pattern sequencing through the
  // 8 bit true color palette.
  //
  vga_test_pattern_generator test_pattern(
    .vga_clock(disp_clk), // 25Mhz VGA display clock
    .fpga_clock(FPGA_CLK1_50),
    .gigatron_clock(clock_6_25Mhz), // 6.25Mhz Gigatron Clock
    .reset_n(reset_n),    // Active low reset
    .write_clock(vga_write_clock),
    .write_signal(vga_write_signal),
    .write_address(vga_write_address),
    .write_data(vga_write_data)
  );

`else

  //
  // Testing: replace Gigatron framebuffer generator with local test one
  // by setting VGA_TEST_PATTERN.
  //
  // Ok, there appears to be a problem with the Gigatrons VGA framebuffer
  // paths causing a massive latch inferall.
  //
  // But driving the VGA with the test pattern generator and dead ending
  // the Gigatrons signals the design compiles as expected.
  //   
  // In this case this is likely not driving the outputs from the Gigatron VGA
  // with a registered signal.
  //

  assign vga_write_clock = gigatron_framebuffer_write_clock;
  assign vga_write_signal = gigatron_framebuffer_write_signal;
  assign vga_write_address = gigatron_framebuffer_write_address;
  assign vga_write_data = gigatron_framebuffer_write_data;

`endif // VGA_TEST_PATTERN

  Gigatron gigatron(
    .fpga_clock(FPGA_CLK1_50), // 50Mhz FPGA clock
    .vga_clock(disp_clk),      // 25Mhz VGA clock from the PLL
    .clock(clock_6_25Mhz),     // 6.25Mhz Gigatron clock from the PLL
    .reset(reset),
    .run(1'b1),

    .gigatron_output_port(gigatron_output_port),
    .gigatron_extended_output_port(gigatron_extended_output_port),

    // Serial game controller
    .famicom_pulse(famicom_pulse), // output
    .famicom_latch(famicom_latch), // output
    .famicom_data(famicom_data),   // input

    // Raw VGA signals from the Gigatron
    .hsync_n(hsync_n),
    .vsync_n(vsync_n),
    .red(red),
    .green(green),
    .blue(blue),

    //
    // Write output to external framebuffer
    //
    // Note: Gigatron outputs its 6.25Mhz clock as VGA clock in this case.
    //
    .framebuffer_write_clock(gigatron_framebuffer_write_clock),
    .framebuffer_write_signal(gigatron_framebuffer_write_signal),
    .framebuffer_write_address(gigatron_framebuffer_write_address),
    .framebuffer_write_data(gigatron_framebuffer_write_data),

    // BlinkenLights
    .led5(led5),
    .led6(led6),
    .led7(led7),
    .led8(led8),

    // 4 bit Audio DAC output from the Gigatron as a two's complement signal range.
    .audio_dac(gigatron_audio_output_dac) // extended_output_port bits 7-4
  );

endmodule // DE10_Nano_Default

//
// VGA test pattern generator
//
module vga_test_pattern_generator(
    input         vga_clock,
    input         fpga_clock,
    input         gigatron_clock,
    input         reset_n,
    output        write_clock,
    output        write_signal,
    output [18:0] write_address,
    output [7:0]  write_data
    );
   
   // VGA clock is the write clock
   assign write_clock = vga_clock;

   // Test Gigatron clock timings
   //assign write_clock = gigatron_clock;

  //
  // Assignments in the always process must be variables (registers)
  // so registers are declared locally, and continuous assigns are used
  // to set the output signals.
  //
  reg [18:0] reg_write_address;
  reg [7:0]  reg_write_data;
  reg        reg_write_signal;

  assign write_address = reg_write_address;
  assign write_data = reg_write_data;
  assign write_signal = reg_write_signal;

  //
  // For test pattern
  //
  reg [31:0] reg_vga_test_counter;
  reg        reg_vga_writing_framebuffer;
   
  //
  // Test pattern loop to verify VGA + framebuffer.
  //
  // Uses the VGA clock.
  //
  // Writes an incrementing 8 bit color pattern in the frame buffer
  // per clock period.
  //
  always@(posedge vga_clock) begin

    if (reset_n == 1'b0) begin
      reg_write_address <= 0;
      reg_write_data <= 0;
      reg_write_signal <= 0;

      reg_vga_test_counter <= 0;
      reg_vga_writing_framebuffer <= 0;
    end
    else begin

      //
      // Not Reset
      //

      //
      // Process sequential write of the current VGA 8 bit value through the frame buffer.
      //
      if (reg_vga_writing_framebuffer != 1'b0) begin

          if (reg_write_signal == 1'b1) begin
              // done with this framebuffer location.
              reg_write_signal <= 1'b0;
              reg_write_address <= reg_write_address + 18'd1;
          end
          else begin

              // Write not asserted, see if we are still writing the framebuffer
              if (reg_write_address == 0) begin
                  reg_vga_writing_framebuffer <= 1'b0; // Done
              end
              else begin
                  reg_write_signal <= 1'b1; // Write current address
              end
          end
      end

      //
      // 25Mhz clock, 8 million clocks == ~1/4 sec
      //
      if (reg_vga_test_counter < 32'h007FFFFF) begin
          reg_vga_test_counter <= reg_vga_test_counter + 1;
      end
      else begin

          //
          // New cycle, increment the color value.
          //
          reg_vga_test_counter <= 0; // reset counter

          // 8 bit wrap around
          reg_write_data <= reg_write_data + 8'd1;
       
          // Indicate we are writing the framebuffer
          reg_vga_writing_framebuffer <= 1;
          reg_write_address <= 0;
          reg_write_signal <= 1;
      end
    end
  end

endmodule // vga_test_pattern_generator
