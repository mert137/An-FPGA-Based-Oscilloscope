module vga(
    input CLOCK_50,        	   // FPGA clock: 50 MHz
    output wire [7:0] VGA_G,      // 8-bit VGA green output
	 input [1:0] time_div,        // Bunun büyüklüğü computationdaki ile aynı olmalı.
	 input [1:0] volt_div,		   // Aynı şekilde	
	 output reg [15:0] read_addr, // connect read_addr of ram
	 input [11:0] vga_data,   
	 input [15:0] mean_addr,
	 input mean_addr_found,
	 input [9:0] x,     // current pixel x position: 10-bit value: 0-1023
	 input [8:0] y,     // current pixel y position:  9-bit value: 0-511
	 output reg VGA_CLK );   


   // generate a 25 MHz pixel strobe (from our 50MHz fpga clock) 
	always @(posedge CLOCK_50)
	if (VGA_CLK == 0)
		VGA_CLK <= 1;
	else
		VGA_CLK <= 0;
		
	// volt/div :
	// 8 div   =>   1div = 50pixel
	// 1pixel 10mv  500mV/div
	// 1pixel 20mV  1V
	// 1pixel 40mv  2V
	// 1pixel 80mV  4V
	
	// 40 - 640 (600)
	// 80 - 480 (400)
	
	// set time/div and volt/div	
	// 640 addresses in RAM are read in each line
	// that is, 640 addresses are read 480 times for each frame
	// For each frame, (640x480xT(25MHz)) = 0.0123 sec. passed 
	
	
	reg current_pixel;
	assign VGA_G[7] = current_pixel;
	
	always @(posedge VGA_CLK) begin
		if (mean_addr_found == 1) begin
			if(	  time_div == 0) read_addr <= x + mean_addr;
			else if(time_div == 1) read_addr <= 2*x + mean_addr;
			else if(time_div == 2) read_addr <= 4*x + mean_addr;
			else if(time_div == 3) read_addr <= 8*x + mean_addr;

			if(	  volt_div == 0 & (400 - vga_data/10 + 80) == y) current_pixel <= 1;
			else if(volt_div == 1 & (400 - vga_data/20 + 80) == y) current_pixel <= 1;
			else if(volt_div == 2 & (400 - vga_data/40 + 80) == y) current_pixel <= 1;
			else if(volt_div == 3 & (400 - vga_data/80 + 80) == y) current_pixel <= 1;	
			else current_pixel <= 0;
		end		
	end
	
endmodule