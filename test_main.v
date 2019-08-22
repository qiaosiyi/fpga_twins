`timescale 1ns / 1ps

module test_main#(
	parameter TOKEN_WIDTH = 8,
	parameter DIST_WIDTH = 8,
	parameter LENGTH_WIDTH = 32
);

	reg								in_data_valid = 0;
	reg		[TOKEN_WIDTH - 1 : 0]	in_token = 0;
	reg		[DIST_WIDTH - 1 : 0]	in_dist = 0;
	reg		[LENGTH_WIDTH - 1 : 0]	in_length = 0;
	
	reg								clk = 1;
	reg								reset_n = 0;
	
	
	always begin
		#2.5 clk = 0;
		#2.5 clk = 1;
	end

	initial begin
		#40		reset_n = 1;
		
		#40		in_data_valid = 1;in_token = 120;	//x
				in_dist = 0;in_length = 0;
				
		#5		in_data_valid = 1;in_token = 120;	//x
				in_dist = 0;in_length = 0;
				
		#5		in_data_valid = 1;in_token = 97;	//a
				in_dist = 0;in_length = 0;
				
		#5		in_data_valid = 1;in_token = 99;	//c
				in_dist = 0;in_length = 0;
				
		#5		in_data_valid = 1;in_token = 99;	//c
		        in_dist = 0;in_length = 0;
				
		#5		in_data_valid = 1;in_token = 97;	//a
				in_dist = 0;in_length = 0;
				
		#5		in_data_valid = 1;in_token = 98;	//b
				in_dist = 0;in_length = 0;
				
		#5		in_data_valid = 1;in_token = 99;	//c
		        in_dist = 0;in_length = 0;
		
		#5		in_data_valid = 1;in_token = 100;	//d
		        in_dist = 0;in_length = 0;
		
		#5		in_data_valid = 1;in_token = 121;	//y
		        in_dist = 0;in_length = 0;
				
		#5		in_data_valid = 1;in_token = 121;	//y
		        in_dist = 0;in_length = 0;
				
				
		#5		in_data_valid = 1;in_token = 0;		//<3, 9>
		        in_dist = 9;in_length = 3;
				
		#5		in_data_valid = 1;in_token = 122;	//z
		        in_dist = 0;in_length = 0;
				
		#5		in_data_valid = 1;in_token = 122;	//z
		        in_dist = 0;in_length = 0;
				
		#5		in_data_valid = 1;in_token = 97;	//a
		        in_dist = 0;in_length = 0;
				
		#5		in_data_valid = 1;in_token = 0;		//<3, 12>
		        in_dist = 12;in_length = 3;
				
		#5		in_data_valid = 1;in_token = 99;	//c
		        in_dist = 0;in_length = 0;
				
		#5		in_data_valid = 1;in_token = 100;	//d
		        in_dist = 0;in_length = 0;
				
		#5		in_data_valid = 0;in_token = 0;		//end input
		        in_dist = 0;in_length = 0;		
	end
	
	main main_inst(
		.clk(clk),
		.reset_n(reset_n),
		
		.in_data_valid(in_data_valid),
		.in_token(in_token),
		.in_dist(in_dist),
		.in_length(in_length)
	);
	
	
endmodule
