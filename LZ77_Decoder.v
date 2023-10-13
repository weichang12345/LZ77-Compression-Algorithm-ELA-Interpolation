module LZ77_Decoder(clk,reset,code_pos,code_len,chardata,encode,finish,char_nxt);

input 				clk;
input 				reset;
input 		[3:0] 	code_pos;
input 	    [2:0] 	code_len;
input 		[7:0] 	chardata;
output  reg			encode;
output  reg			finish;
output 	reg [7:0] 	char_nxt;


/*
	Write Your Design Here ~
*/


reg [35:0] search_buffer;
reg [31:0] buffer; //複製字串用
reg [2:0] count;

always@(posedge clk or posedge reset)begin
	if(reset)begin
		encode <= 1'd0;
		finish <= 1'd0;
		search_buffer <= 36'd0;
		char_nxt <= 8'd0;
	end
	else begin
		char_nxt <= {4'd0 , buffer[31-((count)<<<2) -: 4]};
		finish <= (chardata==8'h24 && count==code_len)? 1'd1 : 1'd0;
		if(count==code_len)begin
			case(code_len)
				3'd0 : begin
					search_buffer[35:4] <= search_buffer[31:0];
					search_buffer[3:0] <= buffer[31:28];
				end
				3'd1 : begin
					search_buffer[35:8] <= search_buffer[27:0];
					search_buffer[7:0] <= buffer[31:24];
				end
				3'd2 : begin
					search_buffer[35:12] <= search_buffer[23:0];
					search_buffer[11:0] <= buffer[31:20];
				end
				3'd3 : begin
					search_buffer[35:16] <= search_buffer[19:0];
					search_buffer[15:0] <= buffer[31:16];
				end
				3'd4 : begin
					search_buffer[35:20] <= search_buffer[15:0];
					search_buffer[19:0] <= buffer[31:12];
				end
				3'd5 : begin
					search_buffer[35:24] <= search_buffer[11:0];
					search_buffer[23:0] <= buffer[31:8];
				end
				3'd6 : begin
					search_buffer[35:28] <= search_buffer[7:0];
					search_buffer[27:0] <= buffer[31:4];
				end
				3'd7 : begin
					search_buffer[35:32] <= search_buffer[3:0];
					search_buffer[31:0] <= buffer;
				end
			endcase
		end
	end
end

always@(negedge clk)begin
	if(reset)begin
		count <= 3'd7;
	end
	else begin
		count <= (count==code_len)? 3'd0 : count + 3'd1;
	end
end

always@(*)begin
	case(code_pos)
	4'd0 : begin
		buffer = {search_buffer[3:0] , search_buffer[3:0] , search_buffer[3:0] , search_buffer[3:0] , 
		          search_buffer[3:0] , search_buffer[3:0] , search_buffer[3:0] , 4'd0};
		buffer[31 - (code_len<<<2) -: 4] = chardata[3:0];
	end
	4'd1 : begin
		buffer = {search_buffer[7:0] , search_buffer[7:0] , search_buffer[7:0] , search_buffer[7:4] , 4'd0};
		buffer[31 - (code_len<<<2) -: 4] = chardata[3:0];
	end
	4'd2 : begin
		buffer = {search_buffer[11:0] , search_buffer[11:0] , search_buffer[11:8] , 4'd0};
		buffer[31 - (code_len<<<2) -: 4] = chardata[3:0];
	end
	4'd3 : begin
		buffer = {search_buffer[15:0] , search_buffer[15:4] , 4'd0};
		buffer[31 - (code_len<<<2) -: 4] = chardata[3:0];
	end
	4'd4 : begin
		buffer = {search_buffer[19:0] , search_buffer[19:12] , 4'd0};
		buffer[31 - (code_len<<<2) -: 4] = chardata[3:0];
	end
	4'd5 : begin
		buffer = {search_buffer[23:0] , search_buffer[23:20] , 4'd0};
		buffer[31 - (code_len<<<2) -: 4] = chardata[3:0];
	end
	4'd6 : begin
		buffer = {search_buffer[27:0] , 4'd0};
		buffer[31 - (code_len<<<2) -: 4] = chardata[3:0];
	end
	4'd7 : begin
		buffer = {search_buffer[31:4] , 4'd0};
		buffer[31 - (code_len<<<2) -: 4] = chardata[3:0];
	end
	4'd8 : begin
		buffer = {search_buffer[35:8] , 4'd0};
		buffer[31 - (code_len<<<2) -: 4] = chardata[3:0];
	end
	default : begin
		buffer = 28'd0;
	end
	endcase

end

endmodule

