`timescale 1ns/10ps

module ELA(clk, rst, ready, in_data, data_rd, req, wen, addr, data_wr, done);

	input				clk;
	input				rst;
	input				ready;
	input		[7:0]	in_data;
	input		[7:0]	data_rd;
	output 	reg			req;
	output 	reg			wen;
	output 	reg	[12:0]	addr;
	output 	reg	[7:0]	data_wr;
	output 	reg			done;


	/*-------------------------------------/
	/		Write your code here~		   /
	/-------------------------------------*/
	
reg [1:0] st, next_st;
reg [7:0] upper_row [0:127];
reg [7:0] lower_row [0:127];
reg [6:0] st_count;
reg [7:0] D1, D2, D3;
reg [7:0] D4, D5;
reg [7:0] P, Q;
reg [7:0] d_temp1, d_temp2, d_temp3, d_min;
reg [2:0] index1, index2, index3, index_min;
reg [2:0] addr_flag;
integer i;

parameter  IDLE = 2'd0,
           s1 = 2'd1, //最一開始填滿upper_row
		   UPDATE = 2'd2, //將lower_row的data移到upper_row，同時將輸入存進lower_row
		   INTERPOLATION = 2'd3;

always@(posedge clk or posedge rst)begin
	if(rst)begin
		addr <= 13'd0;
	end
	else if(ready)begin
		case(addr_flag)
			3'd0 : addr <= addr + 13'd1;  //一般記數
			3'd1 : addr <= addr + 13'd129; //跳過一行再記數 
			3'd2 : addr <= addr + 13'd257; //跳過兩行再記數 
			3'd3 : addr <= addr - 13'd255; //退後一行再記數 
			3'd4 : addr <= addr; //停止記數
		endcase
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
		st <= IDLE;
		st_count <= 7'd0;
		done <= 1'd0;
		for(i=0; i<128; i=i+1)begin
			upper_row[i] <= 8'd0;
			lower_row[i] <= 8'd0;
		end
	end
	else if(ready)begin
		st <= next_st;
		case(st)
			s1 : begin
				st_count <= st_count + 7'd1;
				upper_row[addr] <= in_data;
				/* if(next_st==UPDATE)begin
					lower_row[st_count] <= in_data;
				end */
			end
			UPDATE : begin
				st_count <= st_count + 7'd1;
				lower_row[st_count] <= in_data;
			end
			INTERPOLATION : begin
				st_count <= st_count + 7'd1;
				if(next_st==UPDATE)begin
				 	for(i=0; i<128; i=i+1)begin
						upper_row[i] <= lower_row[i];
					end
				end
				done <= (addr==13'd7935)? 1'd1 : 1'd0;
			end
		endcase
	end
end

always@(*)begin
	case(st)
		IDLE : begin
			next_st = (ready)? s1 : IDLE;
			addr_flag = 3'd4;
		end
		s1 : begin
			if(st_count==7'd127)begin
				next_st = UPDATE;
				addr_flag = 3'd1;
			end
			else begin
				next_st = s1;
				addr_flag = 3'd0;
			end
		end
		UPDATE : begin
			if(st_count==7'd127)begin
				next_st = INTERPOLATION;
				addr_flag = 3'd3;
			end
			else begin
				next_st = UPDATE;
				addr_flag = 3'd0;
			end
		end
		INTERPOLATION : begin
			if(addr==13'd7935)begin
				next_st = INTERPOLATION;
				addr_flag = 3'd4;
			end
			else if(st_count==7'd127)begin
				next_st = UPDATE;
				addr_flag = 3'd2;
			end
			else begin
				next_st = INTERPOLATION;
				addr_flag = 3'd0;
			end
		end
		default : begin
			next_st = IDLE;
			addr_flag = 3'd4;
		end
	endcase
end

always@(*)begin
	case(st)
		IDLE : begin
			req = 1'd0;
			wen = 1'd0;
			data_wr = in_data;
			D1 = 8'd0;
			D2 = 8'd0;
			D3 = 8'd0;
		end
		s1 : begin
			req = 1'd1;
			wen = 1'd1;
			data_wr = in_data;
			D1 = 8'd0;
			D2 = 8'd0;
			D3 = 8'd0;
		end
		UPDATE : begin
			req = 1'd1;
			wen = 1'd1;
			data_wr = in_data;
			D1 = 8'd0;
			D2 = 8'd0;
			D3 = 8'd0;
		end
		INTERPOLATION : begin
			req = 1'd0;
			wen = 1'd1;
				D1 = (upper_row[st_count - 7'd1] > lower_row[st_count + 7'd1])? (upper_row[st_count - 7'd1] - lower_row[st_count + 7'd1]) : (lower_row[st_count + 7'd1] - upper_row[st_count - 7'd1]);
				D2 = (upper_row[st_count       ] > lower_row[st_count       ])? (upper_row[st_count       ] - lower_row[st_count       ]) : (lower_row[st_count       ] - upper_row[st_count       ]);
				D3 = (upper_row[st_count + 7'd1] > lower_row[st_count - 7'd1])? (upper_row[st_count + 7'd1] - lower_row[st_count - 7'd1]) : (lower_row[st_count - 7'd1] - upper_row[st_count + 7'd1]);
				if(st_count==7'd0 || st_count==7'd127)begin
					data_wr = ({1'd0 , upper_row[st_count]} + {1'd0 , lower_row[st_count]}) >>> 1;
				end
				else begin
					data_wr = (D3 < D1)? ((D3 < D2)? ({1'd0 , upper_row[st_count + 7'd1]} + {1'd0 , lower_row[st_count - 7'd1]}) >>> 1 : ({1'd0 , upper_row[st_count]} + {1'd0 , lower_row[st_count]}) >>> 1) : //若D3 < D1且D3 < D2則為0.5(a+f)，否則為1/2(b+e)
										 ((D1 < D2)? ({1'd0 , upper_row[st_count - 7'd1]} + {1'd0 , lower_row[st_count + 7'd1]}) >>> 1 : ({1'd0 , upper_row[st_count]} + {1'd0 , lower_row[st_count]}) >>> 1) ; //若D1 <= D3且D1 < D2則為0.5(c+d)，否則為1/2(b+e) */
				end
		end
		default : begin
			req = 1'd0;
			wen = 1'd0;
			data_wr = 8'd0;
			D1 = 8'd0;
			D2 = 8'd0;
			D3 = 8'd0;
		end
	endcase
end


endmodule