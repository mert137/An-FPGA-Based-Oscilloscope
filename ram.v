module ram (   input [11:0] data,
					input [15:0] read_addr,
					input adc_write_clock,
					output reg [11:0] q,
					output reg fast_reading,
					input CLOCK_50,
					input pix_stb
					);
					
					
	// Connections which must be in top module:
	// adc_write_clock with ADC_CS_N in adc
	// read_addr with read_addr in vga
	// q with 

	parameter number_sample = 16'd40000;
	
	reg [11:0] ram[15:0];
	reg [15:0] addr;
	integer counter_clk;
	reg checked;
	reg checked2;
	
	initial begin
		addr <= 0;
		fast_reading <= 0;
		counter_clk <= 0;
		checked <= 0;
		checked2 <= 0;
	end
	

	// ADC_SCLK = 4 X CLOCK_50
	// read = 16 x ADC_SCLK = 64 CLOCK_50
	// idle = 16 x ADC_SCLK = 64 CLOCK_50
	
	always @ (posedge CLOCK_50)
	begin
		// Writing ADC data to RAM 
		// In every 128 x CLOCK_50, adc_write_clk goes posedge
		// When adc_write_clk goes posedge, adc created an 12 bit data
		if(adc_write_clock == 1 && checked == 0) begin
			if(fast_reading == 0) begin
				ram[addr] <= data; // Write
				q <= data;  // Instantaneous read
				if (addr < number_sample) addr <= addr + 1;
				else fast_reading <= 1;
			end
			checked <= 1;
		end
		
		if(adc_write_clock == 0) checked <= 0;
		if(pix_stb == 0) checked2 <= 0;
		
		// Fast Read after RAM is full-loaded 
		if(fast_reading == 1) begin
			if(pix_stb == 1 && checked2 == 0) q <= ram[read_addr];
			checked2 <= 1;
		end
		
		
		if(counter_clk == 'd51200000) begin
			counter_clk <= 'd0;
			fast_reading <= 0;
			addr <= 0;
		end else begin
			counter_clk <= counter_clk +1;
		end
		
	end
	
endmodule
