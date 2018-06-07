module computation (	input adc_write_clock,
							input CLOCK_50,
							input [11:0] q,
							input fast_reading,
							input acdc_switch,
							output reg [1:0] time_div,
							output reg [1:0] volt_div,		
							output reg [15:0] mean_addr,
							output reg mean_addr_found,
							output reg [11:0] vga_data,
							input auto_button,
							input time_button,
							input volt_button
							);
							
							
	reg [11:0] max_voltage;
	reg [11:0] min_voltage;			
	reg [11:0] mean_voltage;
	reg [11:0] mean_double;
	reg [11:0] peak_to_peak;
	reg mean_changed;
	reg enable_vga;
	reg [15:0] period;
	reg first_checked;
	reg [1:0] period_found;
	reg [11:0] first_q;
	reg is_checked_smallestness;
	reg is_checked_greatestness;
	integer time_button_counter;
	integer volt_button_counter;
	integer auto_button_counter;
	reg autoscale;
	reg checked;
	reg checked2;
	reg second_checked;
	reg increasing;
	reg maxmin_checked;
	integer counter_clk;
	
	
	
	// generate a 25 MHz pixel strobe (from our 50MHz fpga clock) 
	reg pix_stb;
	always @(posedge CLOCK_50)
	if (pix_stb == 1'b0)
		pix_stb <= 1'b1;
	else
		pix_stb <= 1'b0;
	
			
	initial begin
		max_voltage <= 0;
		min_voltage <= 0;	
		mean_changed <= 0;
		enable_vga <= 0;
		mean_addr <= 0;
		first_checked <= 0;
		period <= 0;
		period_found <= 0;
		peak_to_peak <= 0;
		checked <= 0;
		checked2 <= 0;
		second_checked <= 0;
		increasing <= 0;
		maxmin_checked <= 0;
		counter_clk <= 0;
	end
	
	
	always @ (posedge CLOCK_50)
	begin
	
		if(adc_write_clock == 1 && checked == 0) begin
			if(fast_reading == 0) begin
				
				// finding period for autoscale
				if(first_checked == 0) begin
					first_q <= q;
					first_checked <= 1;
					period <= period + 1;
				end else if (second_checked == 0) begin
					if (q > first_q) increasing <= 1;
					else if (q < first_q) increasing <= 0;
					second_checked <= 1;
					period <= period + 1;
				end else if(period_found < 2) begin
					if (increasing == 1 && q > first_q || increasing == 0 && q < first_q ) period <= period + 1;
					else begin 
						if (period_found == 0) begin
							second_checked <= 0;
							period <= period + 1;
						end
						period_found <= period_found + 1;
					end
				end
				
				// Finding min, max, and peak to peak voltage values
				if(maxmin_checked == 0) begin
					min_voltage <= q;
					max_voltage <= q;
					maxmin_checked <= 1;
				end else if(maxmin_checked == 1) begin
					if (q > max_voltage)	max_voltage <= q;
					else if (q < min_voltage) min_voltage <= q;
					mean_double <= max_voltage + min_voltage;
					peak_to_peak <= max_voltage - min_voltage;
					mean_changed <= 0;
				end
				
			end
			checked <= 1;
		end
		
		if(adc_write_clock == 0) checked <= 0;
		if(pix_stb == 0) checked2 <= 0;
		
		if(fast_reading == 1) begin
			if(pix_stb == 1 && checked2 == 0) begin
				
				//  Finding mean value
				if(mean_changed == 0) begin
					mean_voltage <= {1'b0,mean_double[11:1]};
					mean_changed <= 1;
				end
	
				// Write to VGA after first mean value in RAM found!
				else if(mean_changed == 1) begin
					if (enable_vga != 1) begin
						if( q == mean_voltage) begin
							enable_vga <= 1; 
							mean_addr_found = 1;
						end else if( q < mean_voltage  && is_checked_greatestness) begin 
							enable_vga <= 1; 
							mean_addr_found = 1; 
						end else if( q < mean_voltage  && !is_checked_greatestness) begin
							is_checked_smallestness <= 1;
							mean_addr <= mean_addr + 1;
						end else if( q > mean_voltage  && is_checked_smallestness) begin 
								enable_vga <= 1; 
								mean_addr_found = 1; 
						end else if( q > mean_voltage  && !is_checked_smallestness) begin
							is_checked_greatestness <= 1;
							mean_addr <= mean_addr + 1;
						end
					end
				end
			
			
				// set AC/DC mode 
				if(enable_vga == 1) begin
					if (acdc_switch == 0) vga_data <= q - mean_voltage; 
					else vga_data <= q;
				end
				
			end
			checked2 <= 1;
		end		
		
		
		if(counter_clk == 'd51200000) begin
			counter_clk <= 'd0;
			max_voltage <= 0;
			min_voltage <= 0;	
			mean_changed <= 0;
			enable_vga <= 0;
			mean_addr <= 0;
			first_checked <= 0;
			period <= 0;
			period_found <= 0;
			peak_to_peak <= 0;
			checked <= 0;
			checked2 <= 0;
			second_checked <= 0;
			increasing <= 0;
			maxmin_checked <= 0;
		end else begin
			counter_clk <= counter_clk +1;
		end
		
	end
	
	
	
	
	
	
	//  time button,volt button and autoscale button
	always @(posedge CLOCK_50) begin
	
	//time
		if (time_button == 0 && time_button_counter < 'd100) begin
				time_button_counter <= time_button_counter + 'd1;
		end else if (time_button == 1) begin
				time_button_counter <= 0;
		end
		
		if (time_button_counter == 'd98 && time_div < 'd3) begin
			time_div <= time_div +'d1;
		end else if (time_button_counter == 'd98 && time_div == 'd3) begin
			time_div <= 0;
		end
		
	//volt
		if (volt_button == 0 && volt_button_counter < 'd100) begin
				volt_button_counter <= volt_button_counter + 'd1;
		end else if (volt_button == 1) begin
				volt_button_counter <= 0;
		end	
		
		if (volt_button_counter == 'd98 && volt_div < 'd3) begin
			volt_div <= volt_div +'d1;
		end else if (volt_button_counter == 'd98 && volt_div == 'd3) begin
			volt_div <= 0;
		end
		
	//autoscale
		if (auto_button == 0 && auto_button_counter < 'd100) begin
				auto_button_counter <= auto_button_counter + 'd1;
		end else if (auto_button == 1) begin
				auto_button_counter <= 0;
		end
		
		if (auto_button_counter == 'd98 && autoscale == 0) begin
			autoscale <= 1;
		end
		
	// autoscale triggered
		if (autoscale == 1) begin
			if(     0     < period && period <= 10000) time_div <= 0;
			else if(10000 < period && period <= 20000) time_div <= 1;
			else if(20000 < period && period <= 30000) time_div <= 2;
			else if(30000 < period && period <= 40000) time_div <= 3;
		
			if(     0    < peak_to_peak && peak_to_peak <= 1000) volt_div <= 0;
			else if(1000 < peak_to_peak && peak_to_peak <= 2000) volt_div <= 1;
			else if(2000 < peak_to_peak && peak_to_peak <= 3000) volt_div <= 2;
			else if(3000 < peak_to_peak && peak_to_peak <= 4096) volt_div <= 3;
			
			autoscale <= 0;
		end

	end
	
	endmodule