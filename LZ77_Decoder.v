module LZ77_Decoder(clk,reset,ready,code_pos,code_len,chardata,encode,finish,char_nxt);

input 				clk;
input 				reset;
input				ready;
input 		[4:0] 	code_pos;
input 		[4:0] 	code_len;
input 		[7:0] 	chardata;
output  reg			encode;
output  reg			finish;
output 	reg  [7:0] 	char_nxt;


	/*-------------------------------------/
	/		Write your code here~		   /
	/-------------------------------------*/

reg [3:0] search_buffer [0:29];
reg [4:0] shift_count;
reg [4:0] i;


always@(posedge clk or posedge reset)begin
	if(reset)begin
		shift_count <= 5'd0;
		finish <= 1'd0;
		encode <= 1'd0;
		for(i=0; i<30; i=i+1)begin
			search_buffer[i] <= 3'd0;
		end
	end
	else if(ready)begin
		shift_count <= (shift_count == code_len)? 5'd0 : shift_count + 5'd1;
		if(shift_count < code_len)begin
			char_nxt <= search_buffer[code_pos];
			search_buffer[0] <= search_buffer[code_pos];
			for(i=1; i<30; i=i+1)begin
				search_buffer[i] <= search_buffer[i-1];
			end
			/* search_buffer[1] <= search_buffer[0];
			search_buffer[2] <= search_buffer[1];
			search_buffer[3] <= search_buffer[2];
			search_buffer[4] <= search_buffer[3];
			search_buffer[5] <= search_buffer[4];
			search_buffer[6] <= search_buffer[5];
			search_buffer[7] <= search_buffer[6];
			search_buffer[8] <= search_buffer[7]; */
		end
		else if(shift_count == code_len)begin
			char_nxt <= chardata;
			search_buffer[0] <= chardata;
			for(i=1; i<30; i=i+1)begin
				search_buffer[i] <= search_buffer[i-1];
			end
			/* search_buffer[1] <= search_buffer[0];
			search_buffer[2] <= search_buffer[1];
			search_buffer[3] <= search_buffer[2];
			search_buffer[4] <= search_buffer[3];
			search_buffer[5] <= search_buffer[4];
			search_buffer[6] <= search_buffer[5];
			search_buffer[7] <= search_buffer[6];
			search_buffer[8] <= search_buffer[7]; */
			finish <= (chardata==8'h24)? 1'd1 : 1'd0;
			
		end
	end
end


endmodule
