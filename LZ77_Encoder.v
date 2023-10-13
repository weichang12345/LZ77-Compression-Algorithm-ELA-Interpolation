module LZ77_Encoder(clk,reset,chardata,valid,encode,finish,offset,match_len,char_nxt);


input 				clk;
input 				reset;
input 		[7:0] 	chardata;
output  reg			valid;
output  reg			encode;
output  reg			finish;
output 	reg	[3:0] 	offset;
output 	reg	[2:0] 	match_len;
output 	reg [7:0] 	char_nxt;


/*
	Write Your Delen Here ~
*/

reg [8199:0] overall_input; //全長input的reg
reg [3:0]    st, st_ns;
reg [67:0]   sliding_window;
reg [13:0]   acc; //match_len+1所累積的長度
reg [13:0]   index_count; //輸入overall_input的index
reg [8:0]    compare; //compare[i]offset i 的flag，若有配對到則flag舉起
reg [2:0]    len; //等同match_len，供Next state logic使用
reg [3:0]    temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8, com1, com2, com3, com4, com5, com6;
reg          encode_flag;

parameter READ       = 4'd0,
		  PAUSE      = 4'd1,
		  Find_7bits = 4'd2,
		  Find_6bits = 4'd3,
		  Find_5bits = 4'd4,
		  Find_4bits = 4'd5,
		  Find_3bits = 4'd6,
		  Find_2bits = 4'd7,
		  Find_1bits = 4'd8,
		  ENCODE     = 4'd9,
		  VALID      = 4'd10,
		  FINISH     = 4'd11;


/* State register */
always@(posedge clk or posedge reset)begin
	if(reset)begin
		st <= READ;
		index_count <= 14'd8199;         //reset時將index回歸到最左側   
		sliding_window <= 68'b1100_1100_1100_1100_1100_1100_1100_1100_1100_1100_1100_1100_1100_1100_1100_1100_1100;   //sliding_window初始值
		acc <= 14'd0;              //-----------------------		
		overall_input <= 8200'd0;  //         歸零
		compare <= 9'd0;           //
		char_nxt <= 8'd0;          //-----------------------
	end
	else begin
		st <= st_ns;
		match_len <= (encode_flag)? len : match_len;
		case(st)
			READ : begin
				sliding_window[31:0] <= overall_input[8199:8168];
				if(chardata==8'h24)begin //READ時若遇到"$"則要把八碼全存進去
					overall_input[7:0] <= 8'h24;
				end
				else begin //否則將overall_input從左到右輸入input的右四碼
					overall_input[index_count -: 4] <= chardata[3:0];
					index_count <= index_count - 14'd4; 
				end
			end
			PAUSE : begin
				if(encode_flag)begin
					compare <= compare;
				end
				else begin
					compare[0] <= (sliding_window[31:4]==sliding_window[35:8])? 1'd1 : 1'd0;
					compare[1] <= (sliding_window[31:4]==sliding_window[39:12])? 1'd1 : 1'd0;
					compare[2] <= (sliding_window[31:4]==sliding_window[43:16])? 1'd1 : 1'd0;
					compare[3] <= (sliding_window[31:4]==sliding_window[47:20])? 1'd1 : 1'd0;
					compare[4] <= (sliding_window[31:4]==sliding_window[51:24])? 1'd1 : 1'd0;
					compare[5] <= (sliding_window[31:4]==sliding_window[55:28])? 1'd1 : 1'd0;
					compare[6] <= (sliding_window[31:4]==sliding_window[59:32])? 1'd1 : 1'd0;
					compare[7] <= (sliding_window[31:4]==sliding_window[63:36])? 1'd1 : 1'd0;
					compare[8] <= (sliding_window[31:4]==sliding_window[67:40])? 1'd1 : 1'd0;
				end
			end
			Find_7bits : begin
				if(encode_flag)begin
					compare <= compare;
				end
				else begin
					compare[0] <= (sliding_window[31:8]==sliding_window[35:12])? 1'd1 : 1'd0;
					compare[1] <= (sliding_window[31:8]==sliding_window[39:16])? 1'd1 : 1'd0;
					compare[2] <= (sliding_window[31:8]==sliding_window[43:20])? 1'd1 : 1'd0;
					compare[3] <= (sliding_window[31:8]==sliding_window[47:24])? 1'd1 : 1'd0;
					compare[4] <= (sliding_window[31:8]==sliding_window[51:28])? 1'd1 : 1'd0;
					compare[5] <= (sliding_window[31:8]==sliding_window[55:32])? 1'd1 : 1'd0;
					compare[6] <= (sliding_window[31:8]==sliding_window[59:36])? 1'd1 : 1'd0;
					compare[7] <= (sliding_window[31:8]==sliding_window[63:40])? 1'd1 : 1'd0;
					compare[8] <= (sliding_window[31:8]==sliding_window[67:44])? 1'd1 : 1'd0;
				end
			end
			Find_6bits : begin
				if(encode_flag)begin
					compare <= compare;
				end
				else begin
					compare[0] <= (sliding_window[31:12]==sliding_window[35:16])? 1'd1 : 1'd0;
					compare[1] <= (sliding_window[31:12]==sliding_window[39:20])? 1'd1 : 1'd0;
					compare[2] <= (sliding_window[31:12]==sliding_window[43:24])? 1'd1 : 1'd0;
					compare[3] <= (sliding_window[31:12]==sliding_window[47:28])? 1'd1 : 1'd0;
					compare[4] <= (sliding_window[31:12]==sliding_window[51:32])? 1'd1 : 1'd0;
					compare[5] <= (sliding_window[31:12]==sliding_window[55:36])? 1'd1 : 1'd0;
					compare[6] <= (sliding_window[31:12]==sliding_window[59:40])? 1'd1 : 1'd0;
					compare[7] <= (sliding_window[31:12]==sliding_window[63:44])? 1'd1 : 1'd0;
					compare[8] <= (sliding_window[31:12]==sliding_window[67:48])? 1'd1 : 1'd0;
				end
			end
			Find_5bits : begin
				if(encode_flag)begin
					compare <= compare;
				end
				else begin
					compare[0] <= (sliding_window[31:16]==sliding_window[35:20])? 1'd1 : 1'd0;
					compare[1] <= (sliding_window[31:16]==sliding_window[39:24])? 1'd1 : 1'd0;
					compare[2] <= (sliding_window[31:16]==sliding_window[43:28])? 1'd1 : 1'd0;
					compare[3] <= (sliding_window[31:16]==sliding_window[47:32])? 1'd1 : 1'd0;
					compare[4] <= (sliding_window[31:16]==sliding_window[51:36])? 1'd1 : 1'd0;
					compare[5] <= (sliding_window[31:16]==sliding_window[55:40])? 1'd1 : 1'd0;
					compare[6] <= (sliding_window[31:16]==sliding_window[59:44])? 1'd1 : 1'd0;
					compare[7] <= (sliding_window[31:16]==sliding_window[63:48])? 1'd1 : 1'd0;
					compare[8] <= (sliding_window[31:16]==sliding_window[67:52])? 1'd1 : 1'd0;
				end
			end
			Find_4bits : begin
				if(encode_flag)begin
					compare <= compare;
				end
				else begin
					compare[0] <= (sliding_window[31:20]==sliding_window[35:24])? 1'd1 : 1'd0;
					compare[1] <= (sliding_window[31:20]==sliding_window[39:28])? 1'd1 : 1'd0;
					compare[2] <= (sliding_window[31:20]==sliding_window[43:32])? 1'd1 : 1'd0;
					compare[3] <= (sliding_window[31:20]==sliding_window[47:36])? 1'd1 : 1'd0;
					compare[4] <= (sliding_window[31:20]==sliding_window[51:40])? 1'd1 : 1'd0;
					compare[5] <= (sliding_window[31:20]==sliding_window[55:44])? 1'd1 : 1'd0;
					compare[6] <= (sliding_window[31:20]==sliding_window[59:48])? 1'd1 : 1'd0;
					compare[7] <= (sliding_window[31:20]==sliding_window[63:52])? 1'd1 : 1'd0;
					compare[8] <= (sliding_window[31:20]==sliding_window[67:56])? 1'd1 : 1'd0;
				end
			end
			Find_3bits : begin
				if(encode_flag)begin
					compare <= compare;
				end
				else begin
					compare[0] <= (sliding_window[31:24]==sliding_window[35:28])? 1'd1 : 1'd0;
					compare[1] <= (sliding_window[31:24]==sliding_window[39:32])? 1'd1 : 1'd0;
					compare[2] <= (sliding_window[31:24]==sliding_window[43:36])? 1'd1 : 1'd0;
					compare[3] <= (sliding_window[31:24]==sliding_window[47:40])? 1'd1 : 1'd0;
					compare[4] <= (sliding_window[31:24]==sliding_window[51:44])? 1'd1 : 1'd0;
					compare[5] <= (sliding_window[31:24]==sliding_window[55:48])? 1'd1 : 1'd0;
					compare[6] <= (sliding_window[31:24]==sliding_window[59:52])? 1'd1 : 1'd0;
					compare[7] <= (sliding_window[31:24]==sliding_window[63:56])? 1'd1 : 1'd0;
					compare[8] <= (sliding_window[31:24]==sliding_window[67:60])? 1'd1 : 1'd0;
				end
			end
			Find_2bits : begin
				if(encode_flag)begin
					compare <= compare;
				end
				else begin
					compare[0] <= (sliding_window[31:28]==sliding_window[35:32])? 1'd1 : 1'd0;
					compare[1] <= (sliding_window[31:28]==sliding_window[39:36])? 1'd1 : 1'd0;
					compare[2] <= (sliding_window[31:28]==sliding_window[43:40])? 1'd1 : 1'd0;
					compare[3] <= (sliding_window[31:28]==sliding_window[47:44])? 1'd1 : 1'd0;
					compare[4] <= (sliding_window[31:28]==sliding_window[51:48])? 1'd1 : 1'd0;
					compare[5] <= (sliding_window[31:28]==sliding_window[55:52])? 1'd1 : 1'd0;
					compare[6] <= (sliding_window[31:28]==sliding_window[59:56])? 1'd1 : 1'd0;
					compare[7] <= (sliding_window[31:28]==sliding_window[63:60])? 1'd1 : 1'd0;
					compare[8] <= (sliding_window[31:28]==sliding_window[67:64])? 1'd1 : 1'd0;
				end
			end
			 ENCODE : begin
				case(match_len)
					3'd0 : begin
						if(sliding_window[31:24]==8'h24)begin //若偵測到"$"
							char_nxt <= (acc > 11'd2041)? 8'h24 : {4'd0 , sliding_window[31:28]}; //若累積編碼數超過2041個，則編後八個bit為"$"
						end
						else begin
							char_nxt <= {4'd0 , sliding_window[31:28]}; //否則只編後四個bit
						end
					end
					3'd1 : begin
						if(sliding_window[27:20]==8'h24)begin
							char_nxt <= (acc > 11'd2041)? 8'h24 : {4'd0 , sliding_window[27:24]};
						end
						else begin
							char_nxt <= {4'd0 , sliding_window[27:24]};
						end
					end
					3'd2 : begin
						if(sliding_window[23:16]==8'h24)begin
							char_nxt <= (acc > 11'd2041)? 8'h24 : {4'd0 , sliding_window[23:20]};
						end
						else begin
							char_nxt <= {4'd0 , sliding_window[23:20]};
						end
					end
					3'd3 : begin
						if(sliding_window[19:12]==8'h24)begin
							char_nxt <= (acc > 11'd2041)? 8'h24 : {4'd0 , sliding_window[19:16]};
						end
						else begin
							char_nxt <= {4'd0 , sliding_window[19:16]};
						end
					end
					3'd4 : begin
						if(sliding_window[15:8]==8'h24)begin
							char_nxt <= (acc > 11'd2041)? 8'h24 : {4'd0 , sliding_window[15:12]};
						end
						else begin
							char_nxt <= {4'd0 , sliding_window[15:12]};
						end
					end
					3'd5 : begin
						if(sliding_window[11:4]==8'h24)begin
							char_nxt <= (acc > 11'd2041)? 8'h24 : {4'd0 , sliding_window[11:8]};
						end
						else begin
							char_nxt <= {4'd0 , sliding_window[11:8]};
						end
					end
					3'd6 : begin
						if(sliding_window[7:0]==8'h24)begin
							char_nxt <= (acc > 11'd2041)? 8'h24 : {4'd0 , sliding_window[7:4]};
						end
						else begin
							char_nxt <= {4'd0 , sliding_window[7:4]};
						end
					end
					3'd7 : char_nxt <= {4'd0 , sliding_window[3:0]};
				endcase
				index_count <= index_count;
				compare <= 9'd0;
				com1 <= (temp1 > temp2)? temp1 : temp2;
				com2 <= (temp3 > temp4)? temp3 : temp4;
				com3 <= (temp5 > temp6)? temp5 : temp6;
				com4 <= (temp7 > temp8)? temp7 : temp8;
			end
			VALID : begin
				acc <= acc + {11'd0 , match_len} + 14'd1; //累加平移的格數
				case(acc + match_len + 1)
					14'd0 : sliding_window[31:0] <= overall_input[8199:8168]; //---------------------------------------------------
					14'd1 : sliding_window[35:0] <= overall_input[8199:8164];
					14'd2 : sliding_window[39:0] <= overall_input[8199:8160];
					14'd3 : sliding_window[43:0] <= overall_input[8199:8156];
					14'd4 : sliding_window[47:0] <= overall_input[8199:8152]; //若還沒填滿search buffer的下一個sliding window
					14'd5 : sliding_window[51:0] <= overall_input[8199:8148]; //         (即累積平移格數<9)
					14'd6 : sliding_window[55:0] <= overall_input[8199:8144];
					14'd7 : sliding_window[59:0] <= overall_input[8199:8140];
					14'd8 : sliding_window[63:0] <= overall_input[8199:8136]; //---------------------------------------------------
					default : sliding_window[67:0] <= overall_input[8199 + ((9 - (acc + match_len + 1)) <<< 2) -: 68]; //已填滿search buffer的下一個sliding window
					//                                                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ 每次滑動match_len + 1格，再加上之前累積的match_len，再加9(search buffer有9格，從第10格開始會超出格子)
					//                                              ^^^^ 最後加上8195(原本的最左邊)來確定oveall input的最左邊索引值 
				endcase
			end 
			default : begin
				index_count <= index_count;
				acc <= acc;
				compare <= compare;
				sliding_window <= sliding_window;
				char_nxt <= char_nxt;
			end
		endcase
	end
end


/* Next state logic */
always@(*)begin
	case(st)
		READ : begin
			if(chardata==8'h24)begin //若讀到"$"則進入下一個state，且sliding window開始讀取
				st_ns = PAUSE;
				len = 3'd0;
				encode_flag = 1'd0;
			end
			else begin
				st_ns = READ;
				len = 3'd0;
				encode_flag = 1'd0;
			end
		end
		PAUSE : begin 
				st_ns = Find_7bits;
				len = 3'd0;
				encode_flag = 1'd0;
		end
		Find_7bits : begin //開始尋找match_len為7的匹配字串。若compare中的九個flag有一個是舉起的，代表存在match_len為7的匹配字串，進入ENCODE state
			if(compare[0] || compare[1] || compare[2] || compare[3] || compare[4] || compare[5] || compare[6] || compare[7] || compare[8])begin
				st_ns = ENCODE;
				len = 3'd7;
				encode_flag = 1'd1;
			end
			else begin
				st_ns = Find_6bits;
				len = 3'd0;
				encode_flag = 1'd0;
			end
		end
		Find_6bits : begin //開始尋找match_len為6的匹配字串。若compare中的九個flag有一個是舉起的，代表存在match_len為6的匹配字串，進入ENCODE state
			if(compare[0] || compare[1] || compare[2] || compare[3] || compare[4] || compare[5] || compare[6] || compare[7] || compare[8])begin
				st_ns = ENCODE;
				len = 3'd6;
				encode_flag = 1'd1;
			end
			else begin
				st_ns = Find_5bits;
				len = 3'd0;
				encode_flag = 1'd0;
			end
		end	
		Find_5bits : begin //開始尋找match_len為5的匹配字串。若compare中的九個flag有一個是舉起的，代表存在match_len為5的匹配字串，進入ENCODE state
			if(compare[0] || compare[1] || compare[2] || compare[3] || compare[4] || compare[5] || compare[6] || compare[7] || compare[8])begin
				st_ns = ENCODE;
				len = 3'd5;
				encode_flag = 1'd1;
			end
			else begin
				st_ns = Find_4bits;
				len = 3'd0;
				encode_flag = 1'd0;
			end
		end	
		Find_4bits : begin //開始尋找match_len為4的匹配字串。若compare中的九個flag有一個是舉起的，代表存在match_len為4的匹配字串，進入ENCODE state
			if(compare[0] || compare[1] || compare[2] || compare[3] || compare[4] || compare[5] || compare[6] || compare[7] || compare[8])begin
				st_ns = ENCODE;
				len = 3'd4;
				encode_flag = 1'd1;
			end
			else begin
				st_ns = Find_3bits;
				len = 3'd0;
				encode_flag = 1'd0;
			end
		end	
		Find_3bits : begin //開始尋找match_len為3的匹配字串。若compare中的九個flag有一個是舉起的，代表存在match_len為3的匹配字串，進入ENCODE state
			if(compare[0] || compare[1] || compare[2] || compare[3] || compare[4] || compare[5] || compare[6] || compare[7] || compare[8])begin
				st_ns = ENCODE;
				len = 3'd3;
				encode_flag = 1'd1;
			end
			else begin
				st_ns = Find_2bits;
				len = 3'd0;
				encode_flag = 1'd0;
			end
		end	
		Find_2bits : begin //開始尋找match_len為2的匹配字串。若compare中的九個flag有一個是舉起的，代表存在match_len為2的匹配字串，進入ENCODE state
			if(compare[0] || compare[1] || compare[2] || compare[3] || compare[4] || compare[5] || compare[6] || compare[7] || compare[8])begin
				st_ns = ENCODE;
				len = 3'd2;
				encode_flag = 1'd1;
			end
			else begin
				st_ns = Find_1bits;
				len = 3'd0;
				encode_flag = 1'd0;
			end
		end	
		Find_1bits : begin //開始尋找match_len為1的匹配字串。若compare中的九個flag有一個是舉起的，代表存在match_len為1的匹配字串，進入ENCODE state
			if(compare[0] || compare[1] || compare[2] || compare[3] || compare[4] || compare[5] || compare[6] || compare[7] || compare[8])begin
				st_ns = ENCODE;
				len = 3'd1;
				encode_flag = 1'd1;
			end
			else begin
				st_ns = ENCODE;
				len = 3'd0;
				encode_flag = 1'd1;
			end
		end
		 ENCODE : begin
			st_ns = VALID;
			len = 3'd0;
			encode_flag = 1'd0; 
		end
		VALID : begin
			if(char_nxt==8'h24)begin //若char_nxt為"$"代表編碼完成，進入FINISH state
				st_ns = FINISH;
				len = 3'd0;
				encode_flag = 1'd0;
			end
			else begin
				st_ns = PAUSE;
				len = 3'd0;
				encode_flag = 1'd0;
			end
		end
		FINISH : begin
			st_ns = FINISH;
			len = 3'd0;
			encode_flag = 1'd0;
		end
		default : begin
			st_ns = 4'd11;
			len = 3'd0;
			encode_flag = 1'd0;
		end
	endcase
end

/* Output logic */
always@(*)begin
	case(st)
		READ : begin
			valid = 1'd0;
			encode = 1'd0;
			finish = 1'd0;
			offset = 4'd0;
		end
		PAUSE : begin
			valid = 1'd0;
			encode = 1'd1;
			finish = 1'd0;
			offset = 4'd0;
		end
		Find_7bits : begin
			valid = 1'd0;
			encode = 1'd1;
			finish = 1'd0;
			offset = 4'd0;
		end
		Find_6bits : begin
			valid = 1'd0;
			encode = 1'd1;
			finish = 1'd0;
			offset = 4'd0;
		end
		Find_5bits : begin
			valid = 1'd0;
			encode = 1'd1;
			finish = 1'd0;
			offset = 4'd0;
		end
		Find_4bits : begin
			valid = 1'd0;
			encode = 1'd1;
			finish = 1'd0;
			offset = 4'd0;
		end
		Find_3bits : begin
			valid = 1'd0;
			encode = 1'd1;
			finish = 1'd0;
			offset = 4'd0;
		end
		Find_2bits : begin
			valid = 1'd0;
			encode = 1'd1;
			finish = 1'd0;
			offset = 4'd0;
		end
		Find_1bits : begin
			valid = 1'd0;
			encode = 1'd1;
			finish = 1'd0;
			offset = 4'd0;
		end
		ENCODE : begin
			valid = 1'd0;
			encode = 1'd1;
			finish = 1'd0;
			temp1 = (compare[1])? 4'd1 : 4'd0;
			temp2 = (compare[2])? 4'd2 : 4'd0;
			temp3 = (compare[3])? 4'd3 : 4'd0;   
			temp4 = (compare[4])? 4'd4 : 4'd0; 
			temp5 = (compare[5])? 4'd5 : 4'd0; 
			temp6 = (compare[6])? 4'd6 : 4'd0; 
			temp7 = (compare[7])? 4'd7 : 4'd0; 
			temp8 = (compare[8])? 4'd8 : 4'd0; 
		end
		VALID : begin
			valid = 1'd1;
			encode = 1'd1;
			finish = 1'd0;
			com5 = (com1 > com2)? com1 : com2;
			com6 = (com3 > com4)? com3 : com4;
			offset = (com5 > com6)? com5 : com6;
		end
		FINISH : begin
			valid = 1'd0;
			encode = 1'd1;
			finish = 1'd1;
			offset = 4'd0;
		end
		default : begin
			valid = 1'd0;
			encode = 1'd0;
			finish = 1'd0;
			offset = 4'd0;
		end
	endcase
end

endmodule

