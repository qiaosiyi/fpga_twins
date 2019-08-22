`timescale 1ns / 1ps

module main #(
	parameter TOKEN_WIDTH = 8,
	parameter DIST_WIDTH = 8,
	parameter LENGTH_WIDTH = 16,
	parameter G_STATE_WIDTH = 8,
	parameter R_BUF_DEPTH = 32
)(
	input clk,
	input reset_n,
	
	input							in_data_valid,
	input	[TOKEN_WIDTH - 1 : 0]	in_token,
	input	[DIST_WIDTH - 1 : 0]	in_dist,
	input	[LENGTH_WIDTH - 1 : 0]	in_length
);
	
	reg fifo_data_in_read_valid;
	wire fifo_data_in_empty;
	
	wire [TOKEN_WIDTH - 1 : 0]		out_token_fifo;
	wire [DIST_WIDTH - 1 : 0]		out_dist_fifo;
	wire [LENGTH_WIDTH - 1 : 0]		out_length_fifo;
	
	reg [G_STATE_WIDTH - 1 : 0]		g_state;
	reg [G_STATE_WIDTH - 1 : 0]		b_state;
	
	reg [(TOKEN_WIDTH + G_STATE_WIDTH - 1):0]	ring_buffer	[0 : R_BUF_DEPTH - 1];
	reg [15 - 1:0]					ring_buffer_pointer;	// 2^15 = 32768 default = 0.
	
	reg [G_STATE_WIDTH - 1 : 0]		offset_state;
	reg [G_STATE_WIDTH - 1 : 0]		offset_state_m1;
	reg [15 - 1:0]					offset;					// 2^15 = 32768 default = 0.
	
	
	always@(*)begin // calculate offset
		offset = ring_buffer_pointer - out_dist_fifo - 2;
		offset_state = ring_buffer[offset][G_STATE_WIDTH - 1 : 0];
		offset_state_m1 = ring_buffer[offset - 2][G_STATE_WIDTH - 1 : 0];
	end
	
	
	fifofall #(	.C_WIDTH(TOKEN_WIDTH + DIST_WIDTH + LENGTH_WIDTH),// data_input FIFO
				.C_MAX_DEPTH_BITS(4)) 
				
		fifo_data_in(
			.din({in_token, in_dist, in_length}),  
			.wr_en(in_data_valid),
			
			.rd_en(fifo_data_in_read_valid),
			.dout({out_token_fifo, out_dist_fifo, out_length_fifo}),   
			
			.full(),
			.nearly_full(),
			.empty(fifo_data_in_empty),
			
			.rst(~reset_n),
			.clk(clk)
		);

		
	always@(out_token_fifo or negedge reset_n)begin// state lookup for g_state
		if(!reset_n)begin
			g_state <= 0;
		end else begin
			if(out_length_fifo == 0)begin
				if(g_state == 0)begin
					if(out_token_fifo == 97)begin // a
						g_state <= 1;
					end else if(out_token_fifo == 98)begin  //b
						g_state <= 2;
					end else begin
						g_state <= 0;
					end
				end else if(g_state == 1)begin
					if(out_token_fifo == 97)begin // a
						g_state <= 1;
					end else if(out_token_fifo == 98)begin  //b
						g_state <= 2;
					end else begin
						g_state <= 0;
					end
				end else if(g_state == 2)begin
					if(out_token_fifo == 99)begin
						g_state <= 3;
					end else begin
						g_state <= 0;
					end
				end else if(g_state == 3)begin
					if(out_token_fifo == 99)begin
						g_state <= 5;
					end else if(out_token_fifo == 100)begin
						g_state <= 6;
					end else begin
						g_state <= 1;
					end
				end else if(g_state == 4)begin
					if(out_token_fifo == 100)begin
						g_state <= 6;
					end else begin
						g_state <= 2;
					end
				end else if(g_state == 5)begin
					g_state <= 6;
				end else if(g_state == 6)begin
					g_state <= 0;
				end
			end
		end
	end
	
	always@(posedge clk or negedge reset_n)begin
		if(!reset_n)begin
			ring_buffer_pointer <= 0;
			fifo_data_in_read_valid <= 0;
		end else begin
			if(fifo_data_in_empty == 0)begin
				if(out_length_fifo == 0)begin //normal string
					ring_buffer[ring_buffer_pointer - 1] <= {out_token_fifo, g_state};
					ring_buffer_pointer <= ring_buffer_pointer + 1;
					fifo_data_in_read_valid <= 1; //to read fifo
				end else if(out_length_fifo == 3) begin //compression tag
					if(g_state == offset_state)begin
						ring_buffer[ring_buffer_pointer - 1] <= ring_buffer[offset + 1];
						ring_buffer[ring_buffer_pointer + 0] <= ring_buffer[offset + 2];
						ring_buffer[ring_buffer_pointer + 1] <= ring_buffer[offset + 3];
						ring_buffer_pointer <= ring_buffer_pointer + 3;
						g_state <= ring_buffer[offset + 3][G_STATE_WIDTH - 1 : 0];
						//fifo_data_in_read_valid <= 0;
					end else if(g_state == offset_state_m1)begin
						ring_buffer_pointer <= ring_buffer_pointer + 2;
						ring_buffer[ring_buffer_pointer - 1] <= ring_buffer[offset_state_m1 + 2];
						ring_buffer[ring_buffer_pointer + 0] <= ring_buffer[offset_state_m1 + 3];
					end else begin
						ring_buffer[ring_buffer_pointer - 1] <= {out_token_fifo, g_state};
						ring_buffer_pointer <= ring_buffer_pointer + 1;
						fifo_data_in_read_valid <= 0; //to read fifo
					end
				end else if(out_length_fifo == 4)begin
					//to do if length =4,5,6,,,,,
				end
			end else begin
				fifo_data_in_read_valid <= 0; //stop reading fifo
			end
		end
	end
	
endmodule
