module vga640x480(
    input CLOCK_50,       // FPGA base clock
    input VGA_CLK,   // standard VGA clock
    output wire hsync,       // horizontal sync
    output wire vsync,       // vertical sync
    output wire [9:0] x,  // current pixel x position: 10-bit value: 0-1023
    output wire [8:0] y   // current pixel y position:  10-bit value: 0-511
    );

	 //HORIZONTAL
    localparam Hsync_start = 640 + 16;          
    localparam Hsync_end = 640 + 16 + 96;        
    localparam Hactive_start = 0;    
    localparam Hactive_end = 640; 
	 
	 //VERTICAL
    localparam Vsync_start = 480 + 10;        		 
    localparam Vsync_end = 480 + 10 + 2;    		   
	 localparam Vactive_start = 0 ;        
    localparam Vactive_end = 480;   
	 
    localparam LINE   = 800;               // complete line (pixels)
    localparam SCREEN = 525;               // complete screen (lines)

    reg [9:0] h_count = 0;  // line position:   10-bit value: 0-1023
    reg [9:0] v_count = 0;  // screen position: 10-bit value: 0-1023


    // generate horizontal and vertical sync signals (both active low for 640x480)
    assign hsync = ~((h_count >= Hsync_start) & (h_count < Hsync_end));
    assign vsync = ~((v_count >= Vsync_start) & (v_count < Vsync_end));

	 // If x and y are outside active pixel region, they should be 0 to work properly
	 assign x = (h_count < Hactive_start || h_count > Hactive_end) ? 0 : (h_count - Hactive_start); 
	 assign y = (v_count < Vactive_start || v_count > Vactive_end) ? 0 : (v_count - Vactive_start); 
	 
    always @ (posedge CLOCK_50)
    begin
			if (VGA_CLK) begin  // once per pixel

				if (h_count == LINE) begin // end of line
					h_count <= 0;
					if (v_count == SCREEN)  v_count <= 0;  // end of screen
					else v_count <= v_count + 1;
				end else h_count <= h_count + 1;
			end
    end
endmodule