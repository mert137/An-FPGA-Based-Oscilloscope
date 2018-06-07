module adc(    input CLOCK_50,
					input ADC_DOUT,
					output reg [11:0] d_out,
					output reg ADC_CS_N,
					output reg ADC_SCLK,
					output reg ADC_DIN,
					input reset);
	
	reg [2:0] state;   
	reg [2:0] addr;    
	reg [3:0] count;   
	reg [14:0] buffer; 
	integer counter_clk;
	reg clk_en;
	wire [3:0] count2;    
	reg control;     


	parameter QUIET0 = 3'b000, QUIET1 = 3'b001, QUIET2 = 3'b010;
	parameter CYCLE0 = 3'b100, CYCLE1 = 3'b101, CYCLE2 = 3'b110, CYCLE3 = 3'b111;
	
	initial begin
		ADC_CS_N <= 1;
		ADC_DIN <= 0;
		ADC_SCLK <= 1;
		state <= QUIET0;
		buffer <= 0;
		addr <= 0;
		counter_clk <= 0;
		clk_en <= 0;
		count <= 0;
		d_out <= 0;
	end

	
	// Create 12.5 MHz clock for ADC 
	always @(posedge CLOCK_50) begin
	
		if(counter_clk == 3) begin
			counter_clk <= 0;
			clk_en = 1;
		end else begin
			counter_clk <= counter_clk + 1;
			clk_en <= 0;
		end
		
	end
	
	assign count2 = count + 1;
	
	// determine control
	always @(*)
		case (count)
			4'b0000: control = 1; //write
			4'b0001: control = 0;  //seq
			4'b0010: control = 1'bx;  //dont care
			4'b0011: control = 0; //addr[2]
			4'b0100: control = 0; //addr[1]
			4'b0101: control = 0; //addr[0]
			4'b0110: control = 1; //pm1 (normal mode)
			4'b0111: control = 1; //pm0 (normal mode)
			4'b1000: control = 0; //shadow
			4'b1001: control = 1'bx; //dont care
			4'b1010: control = 0; // range (0-5V)
			4'b1011: control = 1; //coding (straight binary)
			default: control = 1'bx;
		endcase
	
	
	// transitions for state holding elements
	always @(posedge clk_en)
		if (reset)
			begin
				ADC_CS_N <= 1;
				ADC_DIN <= 0;
				ADC_SCLK <= 1;
				state <= QUIET0;
				addr <= 0;
				count <= 0;
				buffer <= 0;
				d_out <= 0;
			end
		else
			begin
				case (state)
					QUIET0: // first CLOCK_50 cycle of quiet period, xfer buffer to d_out
						begin
							state <= QUIET1;
							d_out <= buffer[11:0];
						end
					QUIET1:
						begin
							state <= QUIET2;
						end
					QUIET2: // end the quiet period by bringing CS low and setting up first d_out bit
						begin
							state <= CYCLE0;
							ADC_CS_N <= 0;
							ADC_DIN <= control;
							count <= count2;
						end
					CYCLE0: // first CLOCK_50 cycle of serial d_out xfer cycle, bring SCLK low
						begin
							state <= CYCLE1;
							ADC_SCLK <= 0;
						end
					CYCLE1:
						begin
							state <= CYCLE2;
						end
					CYCLE2: // bring SCLK high
						begin
							state <= CYCLE3;
							ADC_SCLK <= 1;
						end
					CYCLE3: // get d_out in and prepare for next cycle or transition back to quiet
						begin
							if (count == 4'b1111) // back to quiet
								begin
									state <= QUIET0;
									ADC_CS_N <= 1;
									addr <= addr + 1;
								end
							else
								begin
									state <= CYCLE0;
								end
							ADC_DIN <= control;
							buffer <= {buffer[13:0], ADC_DOUT};
							count <= count2;
						end
				endcase
			end
endmodule