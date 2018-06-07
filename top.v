module top(	input ADC_DOUT,
				input CLOCK_50,
				input acdc_switch,
				input auto_button,
				input time_button,
				input volt_button,
				output reg ADC_DIN,
				output reg ADC_SCLK,
				output reg ADC_CS_N,
				output wire [7:0] VGA_G,
				output wire VGA_HS,
				output wire VGA_VS,
				output wire VGA_CLK);


	wire ADC_DIN_2;
	wire ADC_SCLK_2;
	
	//adc output
	wire [11:0] d_out;
	wire ADC_CS_N_2;
	
	//ram outputs
	wire [11:0] q;
	wire fast_reading;
	
	//computation outputs
	wire mean_addr_found;
	wire [15:0] mean_addr;
	wire [1:0] time_div;
	wire [1:0] volt_div;
	wire [15:0] vga_data;
	
	//vga outputs
	wire [15:0] read_addr;
	
	//vga640x480 outputs
	wire [9:0] o_x;
	wire [8:0] o_y;
	
	//ram inputs
	reg [11:0] data;
	reg [15:0] read_addr_2;
	reg adc_write_clock;
	
	//computation inputs
	reg [11:0] q_2;
	reg fast_reading_2;
	reg adc_write_clock_2;
	
	//vga inputs
	reg [1:0] time_div_2;
	reg [1:0] volt_div_2;
	reg [15:0] vga_data_2;
	reg mean_addr_found_2;
	reg [15:0] mean_addr_2;
	reg [9:0] x;
	reg [8:0] y;
	
	
	adc myadc( CLOCK_50, ADC_DOUT, d_out, ADC_CS_N_2, ADC_SCLK_2, ADC_DIN_2);
	ram myram( data, read_addr_2, adc_write_clock, q, fast_reading, CLOCK_50, VGA_CLK);
	computation mycomp( adc_write_clock_2, CLOCK_50, q_2, fast_reading_2,
							  acdc_switch, time_div, volt_div, mean_addr, mean_addr_found,
							  vga_data, auto_button, time_button, volt_button );
								
	vga myvga( CLOCK_50, VGA_G, time_div_2, volt_div_2, read_addr, vga_data_2,   
				  mean_addr_2, mean_addr_found_2, x, y, VGA_CLK);
				  
	vga640x480 myvga2( CLOCK_50, VGA_HS, VGA_VS, o_x, o_y);
	
					
	
	
	always begin
	//main inputs
		ADC_DIN <= ADC_DIN_2;
		ADC_SCLK <= ADC_SCLK_2;
		ADC_CS_N <= ADC_CS_N_2;
		
	//internal connections
		data <= d_out;
		read_addr_2 <= read_addr;
		adc_write_clock <= ADC_CS_N_2;
		adc_write_clock_2 <= ADC_CS_N_2;
		q_2 <= q;
		fast_reading_2 <= fast_reading;
		time_div_2 <= time_div;
	   volt_div_2 <= volt_div;
	   vga_data_2 <= vga_data;
	   mean_addr_found_2 <= mean_addr_found;
	   mean_addr_2 <= mean_addr;
	   x <= o_x;
	   y <= o_y;
	end
	
endmodule
