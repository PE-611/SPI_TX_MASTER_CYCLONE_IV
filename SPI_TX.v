///////////////////////////////////////////////////////////
// Name File : SPI_TX.v 											//
// Autor : Dyomkin Pavel Mikhailovich 							//
// Company : FLEXLAB													//
// Description : SPI master module							  	//
// Start design : 12.10.2021 										//
// Last revision: 02.08.2022										//
///////////////////////////////////////////////////////////

module SPI_TX (input clk, start_transmit, reset,
					//input [9:0] data,
					output reg sdi, cs, out_spi_clk
					);

parameter divider_clk = 100;
parameter quantity_bits = 12;
					
reg [quantity_bits:0] data;					
reg transmit_flg;					
reg [12:0] transmit_flg_cnt;					
reg [12:0] cnt;					

reg [7:0] state;	
reg [7:0] next_state;
reg [7:0] bit_cnt;
//reg [7:0] state_cnt;


localparam IDLE 							= 8'd0;
localparam STARTING_TRANSMITTING		= 8'd1;	
localparam SET_BIT_TO_TRANSMITTING  = 8'd2;
localparam SET_HIGH_CLK_SPI			= 8'd3;
localparam SET_LOW_CLK_SPI				= 8'd4;
localparam DEC_BIT_CNT 					= 8'd5;
localparam STOP_TRANSMIT				= 8'd6;




	
initial begin					
	sdi 					<= 1'b0;
	cs 					<= 1'b1;
	out_spi_clk  		<= 1'b0;					

	data 					<= 12'b110011001100; 
	transmit_flg 		<= 1'b0;
	transmit_flg_cnt 	<= 1'b0;
	cnt 					<= 1'b0;	
	bit_cnt 				<= quantity_bits - 1;
end
			
			
always @* 	
		
		case (state)
			
			IDLE:
						
				
				if (start_transmit == 1'b1 && transmit_flg == 1'b1) begin
					next_state <= STARTING_TRANSMITTING;
				end
				
				else begin
					next_state <= IDLE;
				end
				
				
			STARTING_TRANSMITTING:
				
				if (cnt == divider_clk) begin
					next_state <= SET_BIT_TO_TRANSMITTING;
				end
				
				else begin
					next_state <= STARTING_TRANSMITTING;
				end
				
			SET_BIT_TO_TRANSMITTING:
				
				if (cnt == divider_clk * 2) begin
					next_state <= SET_HIGH_CLK_SPI;
				end
				
				else begin
					next_state <= SET_BIT_TO_TRANSMITTING;
				end
				
			SET_HIGH_CLK_SPI:
				
				if (cnt == divider_clk * 3) begin
					next_state <= SET_LOW_CLK_SPI;
				end
				
				else begin
					next_state <= SET_HIGH_CLK_SPI;
				end
				
			SET_LOW_CLK_SPI: 
				
				if (cnt == divider_clk * 4) begin
					next_state <= DEC_BIT_CNT;
				end
				
				else begin
					next_state <= SET_LOW_CLK_SPI;
				end
				
			DEC_BIT_CNT: 
				
				if (bit_cnt == 1'b0) begin
					next_state <= STOP_TRANSMIT;
				end
				
				else begin
					next_state <= SET_BIT_TO_TRANSMITTING;
				end

			STOP_TRANSMIT:
				
				if (cnt >= divider_clk * 5) begin
					next_state <= IDLE;
				end
				
				else begin
					next_state <= STOP_TRANSMIT;
				end
				
				
				
			default:
				next_state <= IDLE;
		
		endcase
		
		
always @(posedge clk) begin
	
	if (start_transmit == 1'b0) begin
		transmit_flg_cnt <= 1'b0;
	end

	if (start_transmit == 1'b1 && transmit_flg_cnt == 1'b0) begin
		transmit_flg <= 1'b1;	
	end

	if (transmit_flg == 1'b1) begin
		transmit_flg_cnt <= transmit_flg_cnt + 1'b1;
	end

	if (transmit_flg_cnt >= divider_clk * 5) begin
		transmit_flg <= 1'b0;
	end

	if (state == IDLE) begin
		cnt <= 1'b0;
		bit_cnt <= quantity_bits - 1;
		cs <= 1'b1; 
		sdi <= 1'b0;
		out_spi_clk <= 1'b0;
	end
	
	if (state == STARTING_TRANSMITTING) begin
		cnt <= cnt + 1'b1;
		out_spi_clk <= 1'b0;
		sdi <= 1'b0;
		cs <= 1'b0;
	end
	
	if (state == SET_BIT_TO_TRANSMITTING) begin
		cnt <= cnt + 1'b1;
		out_spi_clk <= 1'b0;
		sdi <= data[bit_cnt];
		cs <= 1'b0;
	end
	
	if (state == SET_HIGH_CLK_SPI) begin
		cnt <= cnt + 1'b1;
		out_spi_clk <= 1'b1;
		cs <= 1'b0;
	end
	
	if (state == SET_LOW_CLK_SPI) begin
		cnt <= cnt + 1'b1;
		out_spi_clk <= 1'b0;
	end
	
	if (state == DEC_BIT_CNT) begin
		bit_cnt <= bit_cnt - 1'b1;
		cnt <= divider_clk;
	end
	
	if (state == STOP_TRANSMIT) begin
		cs <= 1'b1;
		cnt <= cnt + 1'b1;
		sdi <= 1'b0;
		bit_cnt <= 1'b0;
	end 
	
	

end	




always @(posedge clk or negedge reset) begin 
	
	
	if(!reset) begin
		state <= IDLE;
	end
	
	else begin
		state <= next_state;
	end
end		









		
endmodule

