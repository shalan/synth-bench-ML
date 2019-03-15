//include bsg_popcount.v in this file

module decoder(
				input [9:0] data_i,
				input enable_i,
  				output [7:0] out8b_o,
				output [2:0] pop_h,
				output [2:0] pop_l
				);

//reg [2:0] pop_h, pop_l;

reg [3:0] h3_msb;
reg [3:0] h3_lsb;
reg [3:0] h2_msb;
reg [3:0] h2_lsb;
reg [2:0] h4_msb;
reg [2:0] h4_lsb;
reg [2:0] h1_msb;
reg [2:0] h1_lsb;
reg [7:0] out8b;

h3_decode h3_upper (.in5_i(data_i[9:5]),
					.out_o(h3_msb));

h3_decode h3_lower (.in5_i(data_i[4:0]),
					.out_o(h3_lsb));

h2_decode h2_upper (.in5_i(data_i[9:5]),
					.out_o(h2_msb));

h2_decode h2_lower (.in5_i(data_i[4:0]),
					.out_o(h2_lsb));

h4_decode h4_upper (.in5_i(data_i[9:5]),
					.out_o(h4_msb));

h4_decode h4_lower (.in5_i(data_i[4:0]),
					.out_o(h4_lsb));

h1_decode h1_upper (.in5_i(data_i[9:5]),
					.out_o(h1_msb));

h1_decode h1_lower (.in5_i(data_i[4:0]),
					.out_o(h1_lsb));


bsg_popcount #(.width_p(5)) high ( .i(data_i[9:5]),
								   .o(pop_h));

bsg_popcount #(.width_p(5)) low ( .i(data_i[4:0]),
								   .o(pop_l));

assign out8b_o = out8b;

always @(*)
	begin
	case({pop_h,pop_l})
		{3'd3,3'd2}: begin
		  			case (h3_msb)
		  				4'b1000: begin
		  							if(h2_lsb == 4'b1000)
		  								out8b = {6'b11_11_00,1'b0,1'b0};
		  							else if (h2_lsb == 4'b1001)
		  								out8b = {6'b11_11_00,1'b0,1'b1};
		  							else
		  								out8b = {4'b10_00,1'b0,h2_lsb[2:0]};
		  						 end
		  				4'b1001: begin
		  							if(h2_lsb == 4'b1000)
		  								out8b = {6'b11_11_00,1'b1,1'b0};
		  							else if(h2_lsb == 4'b1001)
		  								out8b = {6'b11_11_00,1'b1,1'b1};
		  							else
		  								out8b = {4'b10_00,1'b1,h2_lsb[2:0]};
		  						 end
		  				default: begin
		  							if (h2_lsb == 4'b1000)
		  								out8b = {4'b10_10,1'b0,h3_msb[2:0]};
		  							else if (h2_lsb == 4'b1001)
		  								out8b = {4'b10_10,1'b1,h3_msb[2:0]};
		  							else
		  								out8b = {2'b00,h3_msb[2:0],h2_lsb[2:0]};
		  						end
		  			endcase
					$display("pop_h has 3 1s");
					end
		{3'd2,3'd3}: begin
						case (h2_msb)
							4'b1000: begin
		  								if(h3_lsb == 4'b1000)
		  									out8b = {8'b10_00_00_00}; //no data code
		  								else if (h3_lsb == 4'b1001)
		  									out8b = 8'b?; //decodes to some commonly used code
			  							else
			  								out8b = {4'b10_01,1'b0,h3_lsb[2:0]};
			  						 end
		  					4'b1001: begin
		  								if(h3_lsb == 4'b1000)
		  									out8b = {6'b11_11_01,1'b0,1'b0};
		  								else if(h3_lsb == 4'b1001)
		  									out8b = {6'b11_11_01,1'b0,1'b1};
		  								else
		  									out8b = {4'b10_01,1'b1,h3_lsb[2:0]};
		  						 	 end
		  					default: begin
		  								if (h3_lsb == 4'b1000)
		  									out8b = {4'b10_11,1'b0,h2_msb[2:0]};
			  							else if (h3_lsb == 4'b1001)
			  								out8b = {4'b10_11,1'b1,h2_msb[2:0]};
			  							else
		  									out8b = {2'b01,h2_msb[2:0],h3_lsb[2:0]};
		  							 end
		  				endcase
						$display("pop_h has 2 1s");
					 end
		{3'd4,3'd1}: begin
						case (h4_msb)
							3'b100: begin
										if(h1_lsb == 3'b100)
											out8b = {8'b11_11_01_10};
										else
											out8b = {6'b11_10_00,h1_lsb[1:0]};
									end
							default: begin
										if(h1_lsb == 3'b100)
											out8b = {6'b11_10_10,h4_msb[1:0]};
										else
											out8b = {4'b11_00,h4_msb[1:0],h1_lsb[1:0]};

									 end
						endcase
						$display("pop_h has 4 1s");
					 end

		{3'd1,3'd4}: begin
						case (h1_msb)
							3'b100: begin
										if(h4_lsb == 3'b100)
											out8b = {8'b11_11_01_11};
										else
											out8b = {6'b11_10_01,h4_lsb[1:0]};
									end
							default: begin
										if(h4_lsb == 3'b100)
											out8b = {6'b11_10_11,h1_msb[1:0]};
										else
											out8b = {4'b11_01,h1_msb[1:0],h4_lsb[1:0]};

									 end
						endcase
						$display("pop_h has 1 1s");
					 end
		//unbalanced cases
		{3'd3,3'd3}: begin
						if(h3_msb == 4'b1000)
							//unbalanced data codes
							out8b = {5'b11_11_1,h3_lsb[2:0]};
						else
							//Can also be h2_msb,h2_lsb for balance across channels
							out8b = {3'b000,h3_msb[2:0],h3_lsb[2:0]};
					end
		{3'd2,3'd2}: $display("Possible bit flip error");


		default:$display("error. decode match not found ");

	endcase //main case


	end

endmodule

module h3_decode (
					input [4:0] in5_i,
 					output [3:0] out_o
					);
  reg [3:0] out;
		always @(*)
		begin
			case (in5_i)
				5'b00111: out = 4'b0000;
				5'b01011: out = 4'b0001;
				5'b01101: out = 4'b0010;
				5'b01110: out = 4'b0011;
				5'b10011: out = 4'b0100;
				5'b10101: out = 4'b0101;
				5'b10110: out = 4'b0110;
				5'b11001: out = 4'b0111;
				5'b11010: out = 4'b1000;
				5'b11100: out = 4'b1001;
				default: $display("Unmatched h3 input");

			endcase

		end //end always
  assign out_o = out;
endmodule

module h2_decode (
					input [4:0] in5_i,
  					output [3:0] out_o
					);
  reg [3:0] out;
		always @(*)
		begin
			case (in5_i)
				5'b00011: out = 4'b0000;
				5'b00101: out = 4'b0001;
				5'b00110: out = 4'b0010;
				5'b01010: out = 4'b0011;
				5'b01100: out = 4'b0100;
				5'b01001: out = 4'b0101;
				5'b10001: out = 4'b0110;
				5'b10010: out = 4'b0111;
				5'b10100: out = 4'b1000;
				5'b11000: out = 4'b1001;
				default: $display("Unmatched h2 input");

			endcase

		end //end always
  assign out_o = out;
endmodule

module h4_decode (
					input [4:0] in5_i,
  					output [2:0] out_o
					);
  reg [2:0] out;
		always @(*)
		begin
			case (in5_i)
				5'b11110: out = 3'b000;
				5'b11101: out = 3'b001;
				5'b11011: out = 3'b010;
				5'b10111: out = 3'b011;
				5'b01111: out = 3'b100;
				default: $display("Unmatched h4 input");

			endcase

		end //end always
  assign out_o = out;
endmodule

module h1_decode (
					input [4:0] in5_i,
  					output [2:0] out_o
					);
  reg [2:0] out;
		always @(*)
		begin
			case (in5_i)
				5'b00001: out = 3'b000;
				5'b00010: out = 3'b001;
				5'b00100: out = 3'b010;
				5'b01000: out = 3'b011;
				5'b10000: out = 3'b100;
				default: $display("Unmatched h1 input");

			endcase

		end //end always
  assign out_o = out;
endmodule


//`include "bsg_defines.v"

// MBT popcount
//
// 10-24-14
//

module bsg_popcount #(parameter width_p="inv")
   (input [width_p-1:0] i
    , output [$clog2(width_p+1)-1:0] o
    );

   // perf fixme: better to round up to nearest power of two and then
   // recurse with side full and one side minimal
   //
   // e.g-> 80 -> 128/2 = 64 --> (64,16)
   //
   // possibly slightly better is to use 2^N-1:
   //
   // for items that are 5..7 bits wide, we make sure to
   // split into a 4 and a 1/2/3; since the four is relatively optimized.
   //

   localparam first_half_lp  = 4;
   localparam second_half_lp = 1;

   if (width_p <= 3)
     begin : lt3
        assign o[0] = ^i;

        if (width_p == 2)
          assign o[1] = & i;
        else
          if (width_p == 3)
            assign o[1] = (&i[1:0]) | (&i[2:1]) | (i[0]&i[2]);
     end
   else
     // http://www.wseas.us/e-library/conferences/2006hangzhou/papers/531-262.pdf

     if (width_p == 4)
       begin : four
          // half adders
          wire [1:0] s0 = { ^i[3:2], ^i[1:0]};
          wire [1:0] c0 = { &i[3:2], &i[1:0]};

          // low bit is xor of all bits
          assign o[0] =  ^s0;

          // middle bit is: ab ^ cd
          //            or  (a^b) & (c^d)

          assign o[1] =  (^c0) | (&s0);

          // high bit is and of all bits

          assign o[2] =  &c0;
       end
     else
       begin : recurse
          wire [$clog2(first_half_lp+1)-1:0]  lo;
          wire [$clog2(second_half_lp+1)-1:0] hi;

          bsg_popcount #(.width_p(first_half_lp))
             left(.i(i[0+:first_half_lp])
                  ,.o(lo)
                  );

          bsg_popcount #(.width_p(second_half_lp))
          right(.i(i[first_half_lp+:second_half_lp])
                ,.o(hi)
                );

          assign o = lo+hi;
       end

endmodule // bsg_popcount
