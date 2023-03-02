module LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);

input 				clk;
input 				reset;
input 		[7:0] 	chardata;
output  reg			valid;
output  reg			encode;
output  reg			finish;
output  reg	[4:0] 	offset;
output  reg	[4:0] 	match_len;
output  reg	[7:0] 	char_nxt;


	/*-------------------------------------/
	/		Write your code here~		   /
	/-------------------------------------*/

reg [1:0] st, next_st;
reg [3:0] input_buffer [0:8191];
reg [3:0] search_buffer [29:0];
reg [3:0] match_buffer [0:23];
reg [0:23] compare;
reg [13:0] counter;
reg [4:0] offset_index;
reg [4:0] shift;
integer i, j;

parameter READ = 2'd0,
          ENCODE = 2'd1,
		  OUTPUT = 2'd2,
		  SHIFT = 2'd3;
 
always@(*)begin
	match_buffer[0] = search_buffer[offset_index];
	for(i=1; i<24; i=i+1)begin
		match_buffer[i] = (offset_index >= i)? search_buffer[offset_index - i] : input_buffer[(i-1) - offset_index];
	end
	
	compare[0] = (offset_index <= 29)? ((match_buffer[0]==input_buffer[0])? 1'd1 : 1'd0) : 1'd0;
	for(i=1; i<24; i=i+1)begin
		compare[i] = (offset_index <= 29)? ((match_buffer[i]==input_buffer[i])? compare[i-1] : 1'd0) : 1'd0;
	end
end
 
always@(posedge clk or posedge reset)begin
	if(reset)begin
		st <= READ;
		valid <= 1'd0;
		encode <= 1'd0;
		finish <= 1'd0;
		offset <= 4'd0;
		offset_index <= 5'd29;
		match_len <= 5'd0;
		char_nxt <= 8'd0;
		counter <= 14'd0;
		compare <= 7'd0;
		shift <= 5'd0;
		for(i=0; i<8191; i=i+1)begin
			input_buffer[i] <= 3'd0;
		end
		for(j=0; j<30; j=j+1)begin
			search_buffer[j] <= 3'd0;
		end
	end
	else begin
		st <= next_st;
		case(st)
			READ : begin
				encode <= 1'd1;
				counter <= (counter==14'd8191)? 12'd0 : counter + 12'd1;
				input_buffer[counter] <= chardata[3:0];
			end
			ENCODE : begin
				if(compare[match_len]==1'd1 && offset_index<counter && counter<14'd8191)begin
					match_len <= match_len + 5'd1;
					offset <= offset_index;
				end
				else begin
					offset_index <= (offset_index==5'd31)? 5'd0 : offset_index - 5'd1;
				end
			end
			OUTPUT : begin
				valid <= 1'd1;
				finish <= (counter==14'd8193)? 1'd1 : 1'd0;
				char_nxt <= (counter + match_len + 1 > 14'd8192)? 8'h24 : input_buffer[match_len];
			end
			SHIFT : begin
				valid <= 1'd0;
				counter <= (shift==match_len)? ((counter==14'd8193)? 12'd0 : counter + match_len + 1) : counter;
				shift <= (shift==match_len)? 5'd0 : shift + 5'd1;
				offset_index <= 5'd29;
				offset <= 5'd0;
				match_len <= (shift==match_len)? 5'd0 : match_len;
				for(i=0; i<29; i=i+1)begin
					search_buffer[i+1] <= search_buffer[i];
				end
				search_buffer[0] <= input_buffer[0];
				for(j=0; j<8191; j=j+1)begin
					input_buffer[j] <= input_buffer[j+1];
				end
			end
		endcase
	end
end	

always@(*)begin
	case(st)
		READ : begin
			next_st = (counter==14'd8191)? ENCODE : READ;
		end
		ENCODE : begin
			next_st = (offset_index==5'd31)? OUTPUT : ENCODE;
		end
		OUTPUT : begin
			next_st = SHIFT;
		end
		SHIFT : begin
			next_st = (shift==match_len)? ENCODE : SHIFT;
		end
		default : begin
			next_st = READ;
		end
	endcase
end
	
endmodule
