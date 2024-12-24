
module core (                       //Don't modify interface
	input         i_clk,
	input         i_rst_n,
	input         i_op_valid,
	input  [ 3:0] i_op_mode,
    output        o_op_ready,
	input         i_in_valid,
	input  [ 7:0] i_in_data,
	output        o_in_ready,
	output        o_out_valid,
	output [13:0] o_out_data
);
//opcode

parameter OP_LOAD    	   = 4'b0000;
parameter OP_R_SHIFT   	   = 4'b0001;
parameter OP_L_SHIFT       = 4'b0010;
parameter OP_UP_SHIFT      = 4'b0011;
parameter OP_DOWN_SHIFT    = 4'b0100;
parameter OP_DOWN_CHANNEL  = 4'b0101;
parameter OP_UP_CHANNEL    = 4'b0110;
parameter OP_DISPLAY       = 4'b0111;
parameter OP_CONVOLUTION   = 4'b1000; 
parameter OP_MEDIANFILTER  = 4'b1001; 
parameter OP_SOBEL     	   = 4'b1010; 
//state
parameter INIT  	  	  = 4'd0;
parameter IDLE  	  	  = 4'd1;
parameter LOAD  	  	  = 4'd2;
parameter SHIFT       	  = 4'd3;
parameter RESIZE          = 4'd4;
parameter DISPLAY         = 4'd5;
parameter CONVOLUTION     = 4'd6;
parameter CONVOLUTION_out = 4'd7;  //送出最後累加結果
parameter MEDIANFILTER    = 4'd8;  //取值
parameter MEDIAN_out      = 4'd9;  //sort並送出output
parameter SOBEL           = 4'd10;
parameter SOBEL_out       = 4'd11;
// ---------------------------------------------------------------------------
// Wires and Registers
// ---------------------------------------------------------------------------
// ---- Add your own wires and registers here if needed ---- //
reg  [2:0]  row, col , row_w,col_w;
reg  [10:0] counter,counter2,counter3;
reg  [13:0] o_out_data_r;
reg  [18:0] conv_image[0:3];
wire [18:0] conv_image_rounding[0:3];
reg  [7:0]	in_data_r ,data_temp;
reg  [13:0] pixel[0:15];
reg  [9:0]  pixel_10[0:35];//多2bit : 1 for signed bit、1 for left shift
reg  [11:0] Gx[0:3],Gy[0:3];
reg  [12:0] G[0:3],G_out[0:3];
reg i_in_valid_r;
reg  [11:0] ABS_Gx[0:3],ABS_Gy[0:3];
reg  [1:0]  dk[0:3];
reg  [3:0] op_mode_r;
reg  		o_out_valid_r,o_op_ready_r,o_in_ready_r;
reg [8:0] sram_addr[0:3]; 
reg sram_wen[0:3];
reg sram_CEN[0:3];
reg [7:0] sram_q[0:3];
reg [3:0] state, n_state;
reg [5:0]channel_size;
reg flag;
integer i,j;
reg [7:0]sort_data[0:35];
reg [7:0]temp[0:35];

// ---------------------------------------------------------------------------
// Continuous Assignment
// ---------------------------------------------------------------------------
// ---- Add your own wire data assignments here if needed ---- //
assign o_op_ready=o_op_ready_r;
assign o_out_valid=o_out_valid_r;
assign o_in_ready=o_in_ready_r;
assign o_out_data=o_out_data_r;
assign conv_image_rounding[0] =((conv_image[0][18:0])>>4)+conv_image[0][3];
assign conv_image_rounding[1] =((conv_image[1][18:0])>>4)+conv_image[1][3];
assign conv_image_rounding[2] =((conv_image[2][18:0])>>4)+conv_image[2][3];
assign conv_image_rounding[3] =((conv_image[3][18:0])>>4)+conv_image[3][3];



// ---------------------------------------------------------------------------
// Combinational Blocks
// ---------------------------------------------------------------------------
// ---- Write your conbinational block design here ---- //
sram_512x8 sram_0 (.Q(sram_q[0]), .CLK(i_clk), .CEN(sram_CEN[0]), .WEN(sram_wen[0]), .A(sram_addr[0]), .D(in_data_r));
sram_512x8 sram_1 (.Q(sram_q[1]), .CLK(i_clk), .CEN(sram_CEN[1]), .WEN(sram_wen[1]), .A(sram_addr[1]), .D(in_data_r));
sram_512x8 sram_2 (.Q(sram_q[2]), .CLK(i_clk), .CEN(sram_CEN[2]), .WEN(sram_wen[2]), .A(sram_addr[2]), .D(in_data_r));
sram_512x8 sram_3 (.Q(sram_q[3]), .CLK(i_clk), .CEN(sram_CEN[3]), .WEN(sram_wen[3]), .A(sram_addr[3]), .D(in_data_r));
always@(*)begin
	if(state==SOBEL_out)begin
	G_out[0]=0;
	G_out[1]=0;
	G_out[2]=0;
	G_out[3]=0;

	Gx[0]=(~pixel_10[0]+1)+(pixel_10[2])+((~pixel_10[3]+1)<<1)+(pixel_10[5]<<1)+(~pixel_10[6]+1)+(pixel_10[8]);
	Gy[0]=(~pixel_10[0]+1)+((~pixel_10[1]+1)<<1)+(~pixel_10[2]+1)+(pixel_10[6])+(pixel_10[7]<<1)+(pixel_10[8]);
	Gx[1]=(~pixel_10[9]+1)+(pixel_10[11])+((~pixel_10[12]+1)<<1)+(pixel_10[14]<<1)+(~pixel_10[15]+1)+(pixel_10[17]);
	Gy[1]=(~pixel_10[9]+1)+((~pixel_10[10]+1)<<1)+(~pixel_10[11]+1)+(pixel_10[15])+(pixel_10[16]<<1)+(pixel_10[17]);
	Gx[2]=(~pixel_10[18]+1)+(pixel_10[20])+((~pixel_10[21]+1)<<1)+(pixel_10[23]<<1)+(~pixel_10[24]+1)+(pixel_10[26]);
	Gy[2]=(~pixel_10[18]+1)+((~pixel_10[19]+1)<<1)+(~pixel_10[20]+1)+(pixel_10[24])+(pixel_10[25]<<1)+(pixel_10[26]);
	Gx[3]=(~pixel_10[27]+1)+(pixel_10[29])+((~pixel_10[30]+1)<<1)+(pixel_10[32]<<1)+(~pixel_10[33]+1)+(pixel_10[35]);
	Gy[3]=(~pixel_10[27]+1)+((~pixel_10[28]+1)<<1)+(~pixel_10[29]+1)+(pixel_10[33])+(pixel_10[34]<<1)+(pixel_10[35]);
	for(i=0;i<4;i=i+1)//取絕對值
	begin
		ABS_Gx[i]=Gx[i];
		ABS_Gy[i]=Gy[i];
		if($signed(Gx[i])<0)
			ABS_Gx[i]=~Gx[i]+1;
		if($signed(Gy[i])<0)
			ABS_Gy[i]=~Gy[i]+1;
		G[i]=ABS_Gx[i]+ABS_Gy[i];
	end

	for(i=0;i<4;i=i+1)//nms dk
	begin
		if(ABS_Gx[i]==0 &&ABS_Gy[i]==0)
			dk[i]=0;
		else if($signed({ABS_Gy[i],14'd0}-{ABS_Gx[i],7'd0}*(7'b0110101))>=0 && $signed({2'd0,ABS_Gy[i],14'd0}-{ABS_Gx[i],7'd0}*(9'b100110101))<=0 )
			dk[i]=(Gx[i][11]==Gy[i][11])?1:3;
		else if($signed({2'd0,ABS_Gy[i],14'd0}-{ABS_Gx[i],7'd0}*(9'b100110101))>0 )
			dk[i]=2;	
		else if($signed({ABS_Gy[i],14'd0}-{ABS_Gx[i],7'd0}*(7'b0110101))<0)
			dk[i]=0;	
		else 
			dk[i]=0;
	end
	//nms
	if(dk[0]==0)
		G_out[0]=(G[0]<G[1])?0:G[0];
	else if(dk[0]==1)
		G_out[0]=(G[0]<G[3])?0:G[0];
	else if(dk[0]==2)
		G_out[0]=(G[0]<G[2])?0:G[0];
	else 
		G_out[0]=G[0];

	if(dk[1]==0)
		G_out[1]=(G[1]<G[0])?0:G[1];
	else if(dk[1]==1)
		G_out[1]=G[1];
	else if(dk[1]==2)
		G_out[1]=(G[1]<G[3])?0:G[1];
	else 
		G_out[1]=(G[1]<G[2])?0:G[1];

	if(dk[2]==0)
		G_out[2]=(G[2]<G[3])?0:G[2];
	else if(dk[2]==1)
		G_out[2]=G[2];
	else if(dk[2]==2)
		G_out[2]=(G[2]<G[0])?0:G[2];
	else 
		G_out[2]=(G[2]<G[1])?0:G[2];

	if(dk[3]==0)
		G_out[3]=(G[3]<G[2])?0:G[3];
	else if(dk[3]==1)
		G_out[3]=(G[3]<G[0])?0:G[3];
	else if(dk[3]==2)
		G_out[3]=(G[3]<G[1])?0:G[3];
	else 
		G_out[3]=G[3];



	end
	else begin

	G_out[0]=0;
	G_out[1]=0;
	G_out[2]=0;
	G_out[3]=0;
	Gx[0]=0;
	Gy[0]=0;
	Gx[1]=0;
	Gy[1]=0;
	Gx[2]=0;
	Gy[2]=0;
	Gx[3]=0;
	Gy[3]=0;
	ABS_Gx[0]=0;
	ABS_Gy[0]=0;
	ABS_Gx[1]=0;
	ABS_Gy[1]=0;
	ABS_Gx[2]=0;
	ABS_Gy[2]=0;
	ABS_Gx[3]=0;
	ABS_Gy[3]=0;
	dk[0]=0;
	dk[1]=0;
	dk[2]=0;
	dk[3]=0;

	end

end
always@(*) begin
	sram_CEN[0]=0;
	sram_CEN[1]=0;
	sram_CEN[2]=0;
	sram_CEN[3]=0;
	sram_wen[0]=1;
	sram_wen[1]=1;
	sram_wen[2]=1;
	sram_wen[3]=1;
	col_w=col;
	row_w=row;
	sram_addr[0]=0;
	sram_addr[1]=0;
	sram_addr[2]=0;
	sram_addr[3]=0;
	for(i=0;i<35;i=i+1)//nms dk
	begin
		temp[i]=0;
	end
	case(state)

		INIT:begin

			n_state = IDLE;
		end
		IDLE :begin	
			if(i_op_mode==OP_LOAD && i_op_valid==1)begin
				n_state = LOAD;
			end
			else if(i_op_mode==OP_DISPLAY &&i_op_valid==1)begin
				n_state = DISPLAY;
			end
			else if(i_op_mode==OP_R_SHIFT || i_op_mode==OP_L_SHIFT || i_op_mode==OP_UP_SHIFT || i_op_mode==OP_DOWN_SHIFT && i_op_valid==1)begin
				n_state = SHIFT;
			end
			else if(i_op_mode==OP_DOWN_CHANNEL || i_op_mode==OP_UP_CHANNEL &&i_op_valid==1)begin
				n_state = RESIZE;
			end
			else if(i_op_mode==OP_CONVOLUTION&&i_op_valid==1)begin
				n_state = CONVOLUTION;
			end
			else if(i_op_mode==OP_MEDIANFILTER&&i_op_valid==1)begin
				n_state =MEDIANFILTER;
			end
			else if(i_op_mode==OP_SOBEL&&i_op_valid==1)begin
				n_state =SOBEL;
			end
			else begin
				n_state = IDLE;
			end
		end
		LOAD:begin 
			if(counter == 11'd2047) begin
				n_state = IDLE;
			end
			else begin 
				n_state=LOAD;				
			end
			sram_addr[0]=counter[10:2];
			sram_addr[1]=counter[10:2];
			sram_addr[2]=counter[10:2];
			sram_addr[3]=counter[10:2];

			if(counter%4==0 &&flag)begin
				sram_wen[0]=0;
			end
			else if(counter%4==1)begin
				sram_wen[1]=0;		
			end
			else if(counter%4==2)begin
				sram_wen[2]=0;		
			end
			else if(counter%4==3)begin
				sram_wen[3]=0;		
			end		
		end
		SHIFT:begin
			if(op_mode_r==OP_R_SHIFT)   begin
				row_w=row;
				if($signed(col+1)<=6)
					col_w=col+1;
				else 
					col_w=col;

			end
			else if(op_mode_r==OP_L_SHIFT)   begin
				row_w=row;
				if($signed(col-1)>=0)
					col_w=col-1;
				else 
					col_w=col;

			end
			else if(op_mode_r==OP_UP_SHIFT)  begin
				col_w=col;
				if($signed(row-1)>=0)
					row_w=row-1;
				else 
					row_w=row;
			end
			else if(op_mode_r==OP_DOWN_SHIFT)begin
				col_w=col;
				if($signed(row+1)<=6)
					row_w=row+1;
				else 
					row_w=row;
			end
			n_state=IDLE;
		end
		DISPLAY:begin
	
			if(counter == channel_size*4) begin
				n_state = IDLE;
			end
			else begin 
				n_state=DISPLAY;				
			end
			if(counter%4==0)begin
				sram_wen[{counter[6:2],row,col}%4]=1;
				sram_addr[{counter[6:2],row,col}%4]={counter[6:2],row,col}>>2;
			end
			else if(counter%4==1)begin
				sram_wen[(1+{counter[6:2],row,col})%4]=1;
				sram_addr[(1+{counter[6:2],row,col})%4]=(1+{counter[6:2],row,col})>>2;
			end
			else if(counter%4==2)begin
				sram_wen[(8+{counter[6:2],row,col})%4]=1;
				sram_addr[(8+{counter[6:2],row,col})%4]=(8+{counter[6:2],row,col})>>2;
			end
			else if(counter%4==3)begin
				sram_wen[(9+{counter[6:2],row,col})%4]=1;
				sram_addr[(9+{counter[6:2],row,col})%4]=(9+{counter[6:2],row,col})>>2;

			end		

		end
		CONVOLUTION:begin

			if(counter == 1+(channel_size)*4) begin
				n_state = CONVOLUTION_out;
			end
			else begin 
				n_state=CONVOLUTION;				
			end
			//非邊界條件
			if(($signed(row-1)>=0)&&($signed(row+2)<=7)&&($signed(col-1)>=0)&&($signed(col+2)<=7))begin

				if(counter%4==0)begin
				sram_addr[({counter[6:2],row-3'd1,col-3'd1})%4]=({counter[6:2],row-3'd1,col-3'd1})>>2;
				sram_addr[({counter[6:2],row-3'd1,col})%4]  =({counter[6:2],row-3'd1,col})>>2;
				sram_addr[({counter[6:2],row-3'd1,col+3'd1})%4]=({counter[6:2],row-3'd1,col+3'd1})>>2;
				sram_addr[({counter[6:2],row-3'd1,col+3'd2})%4]=({counter[6:2],row-3'd1,col+3'd2})>>2;


				end
				else if(counter%4==1)begin
				sram_addr[({counter[6:2],row,col-3'd1})%4]=({counter[6:2],row,col-3'd1})>>2;
				sram_addr[({counter[6:2],row,col})%4]  =({counter[6:2],row,col})>>2;
				sram_addr[({counter[6:2],row,col+3'd1})%4]=({counter[6:2],row,col+3'd1})>>2;
				sram_addr[({counter[6:2],row,col+3'd2})%4]=({counter[6:2],row,col+3'd2})>>2;
				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd1,col-3'd1}%4]={counter[6:2],row+3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd2}%4]={counter[6:2],row+3'd1,col+3'd2}>>2;
				end
				else if(counter%4==3)begin
				sram_addr[{counter[6:2],row+3'd2,col-3'd1}%4]={counter[6:2],row+3'd2,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col}%4]     ={counter[6:2],row+3'd2,col}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd1}%4]={counter[6:2],row+3'd2,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd2}%4]={counter[6:2],row+3'd2,col+3'd2}>>2;
				end		
			end
			//考慮邊界條件
			// 補7個0
			else if((row==0)&&(col==0)) begin
				if(counter%4==0)begin
				sram_addr[{counter[6:2],row,col}%4]     ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]={counter[6:2],row,col+3'd1}>>2;
				sram_addr[{counter[6:2],row,col+3'd2}%4]={counter[6:2],row,col+3'd2}>>2;

				end
				else if(counter%4==1)begin
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd2}%4]={counter[6:2],row+3'd1,col+3'd2}>>2;

				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd2,col}%4]     ={counter[6:2],row+3'd2,col}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd1}%4]={counter[6:2],row+3'd2,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd2}%4]={counter[6:2],row+3'd2,col+3'd2}>>2;

				end

			end


			// 補7個0
//
			else if((row==6)&&(col==0)) begin
				if(counter%4==0)begin
				sram_addr[{counter[6:2],row-3'd1,col}%4]     ={counter[6:2],row-3'd1,col}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd1}%4]={counter[6:2],row-3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd2}%4]={counter[6:2],row-3'd1,col+3'd2}>>2;

				end
				else if(counter%4==1)begin
				sram_addr[{counter[6:2],row,col}%4]    ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]  ={counter[6:2],row,col+3'd1}>>2;
				sram_addr[{counter[6:2],row,col+3'd2}%4]  ={counter[6:2],row,col+3'd2}>>2;
				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd2}%4]={counter[6:2],row+3'd1,col+3'd2}>>2;
				end

			end
			// 補7個0
//
			else if((row==0)&&(col==6)) begin
				if(counter%4==0)begin
				sram_addr[{counter[6:2],row,col-3'd1}%4]  ={counter[6:2],row,col-3'd1}>>2;
				sram_addr[{counter[6:2],row,col}%4]       ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]  ={counter[6:2],row,col+3'd1}>>2;

				end
				else if(counter%4==1)begin
				sram_addr[{counter[6:2],row+3'd1,col-3'd1}%4]  ={counter[6:2],row+3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col}%4]       ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]  ={counter[6:2],row+3'd1,col+3'd1}>>2;
				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd2,col-3'd1}%4]  ={counter[6:2],row+3'd2,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col}%4]       ={counter[6:2],row+3'd2,col}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd1}%4]  ={counter[6:2],row+3'd2,col+3'd1}>>2;
				end
			end
			// 補7個0
//
			else if((row==6)&&(col==6)) begin
				if(counter%4==0)begin
				sram_addr[{counter[6:2],row-3'd1,col-3'd1}%4]  ={counter[6:2],row-3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row-3'd1,col}%4]       ={counter[6:2],row-3'd1,col}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd1}%4]  ={counter[6:2],row-3'd1,col+3'd1}>>2;

				end
				else if(counter%4==1)begin
				sram_addr[{counter[6:2],row,col-3'd1}%4]  ={counter[6:2],row,col-3'd1}>>2;
				sram_addr[{counter[6:2],row,col}%4]       ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]  ={counter[6:2],row,col+3'd1}>>2;
				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd1,col-3'd1}%4]  ={counter[6:2],row+3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col}%4]       ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]  ={counter[6:2],row+3'd1,col+3'd1}>>2;
				end
			end
			// 補4個0
			else if(row!=0&& row!=6&&col==0)begin
				if(counter%4==0)begin

				sram_addr[{counter[6:2],row-3'd1,col}%4]     ={counter[6:2],row-3'd1,col}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd1}%4]={counter[6:2],row-3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd2}%4]={counter[6:2],row-3'd1,col+3'd2}>>2;

				end
				else if(counter%4==1)begin
				sram_addr[{counter[6:2],row,col}%4]     ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]={counter[6:2],row,col+3'd1}>>2;
				sram_addr[{counter[6:2],row,col+3'd2}%4]={counter[6:2],row,col+3'd2}>>2;

				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd2}%4]={counter[6:2],row+3'd1,col+3'd2}>>2;

				end
				else if(counter%4==3)begin
				sram_addr[{counter[6:2],row+3'd2,col}%4]     ={counter[6:2],row+3'd2,col}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd1}%4]={counter[6:2],row+3'd2,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd2}%4]={counter[6:2],row+3'd2,col+3'd2}>>2;
				//temp1={counter[10:2],row+3'd2,col};
				//temp2={counter[10:2],row+3'd2,col+3'd1};
				//temp3={counter[10:2],row+3'd2,col+3'd2};
				end


			end
			// 補4個0
			else if((row==0)&&(col!=3'd0 && col!=3'd6))begin
				if(counter%4==0)begin

				sram_addr[{counter[6:2],row,col-3'd1}%4]={counter[6:2],row,col-3'd1}>>2;
				sram_addr[{counter[6:2],row,col}%4]     ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]={counter[6:2],row,col+3'd1}>>2;
				sram_addr[{counter[6:2],row,col+3'd2}%4]={counter[6:2],row,col+3'd2}>>2;
				end
				else if(counter%4==1)begin
				sram_addr[{counter[6:2],row+3'd1,col-3'd1}%4]={counter[6:2],row+3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd2}%4]={counter[6:2],row+3'd1,col+3'd2}>>2;
				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd2,col-3'd1}%4]={counter[6:2],row+3'd2,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col}%4]     ={counter[6:2],row+3'd2,col}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd1}%4]={counter[6:2],row+3'd2,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd2}%4]={counter[6:2],row+3'd2,col+3'd2}>>2;
			end
			end
			// 補4個0
//
			else if((row==6)&&(col!=0 && col!=6))begin
			if(counter%4==0)begin

				sram_addr[{counter[6:2],row-3'd1,col-3'd1}%4]={counter[6:2],row-3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row-3'd1,col}%4]     ={counter[6:2],row-3'd1,col}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd1}%4]={counter[6:2],row-3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd2}%4]={counter[6:2],row-3'd1,col+3'd2}>>2;
			end
			else if(counter%4==1)begin
				sram_addr[{counter[6:2],row,col-3'd1}%4]={counter[6:2],row,col-3'd1}>>2;
				sram_addr[{counter[6:2],row,col}%4]     ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]={counter[6:2],row,col+3'd1}>>2;
				sram_addr[{counter[6:2],row,col+3'd2}%4]={counter[6:2],row,col+3'd2}>>2;
			end
			else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd1,col-3'd1}%4]={counter[6:2],row+3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd2}%4]={counter[6:2],row+3'd1,col+3'd2}>>2;
			end
			end			

			// 補4個0
//
			else if((row!=0)&&(row!=6)&&(col==6))begin
			if(counter%4==0)begin

				sram_addr[{counter[6:2],row-3'd1,col-3'd1}%4]={counter[6:2],row-3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row-3'd1,col}%4]     ={counter[6:2],row-3'd1,col}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd1}%4]={counter[6:2],row-3'd1,col+3'd1}>>2;
			end
			else if(counter%4==1)begin
				sram_addr[{counter[6:2],row,col-3'd1}%4]={counter[6:2],row,col-3'd1}>>2;
				sram_addr[{counter[6:2],row,col}%4]     ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]={counter[6:2],row,col+3'd1}>>2;
			end
			else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd1,col-3'd1}%4]={counter[6:2],row+3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
			end
			else if(counter%4==3)begin
				sram_addr[{counter[6:2],row+3'd2,col-3'd1}%4]={counter[6:2],row+3'd2,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col}%4]     ={counter[6:2],row+3'd2,col}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd1}%4]={counter[6:2],row+3'd2,col+3'd1}>>2;
			end
			end		

		end

		MEDIANFILTER:begin


			if(counter==17)
				n_state = IDLE;
			else if(counter>1 && counter%4==0 &&flag==0) begin
				n_state = MEDIAN_out;
			end
			else if(counter>1 && counter%4==0 &&counter2==1) begin
				n_state = MEDIAN_out;
			end
			else begin 
				n_state=MEDIANFILTER;				
			end
			//非邊界條件
			if(($signed(row-1)>=0)&&($signed(row+2)<=7)&&($signed(col-1)>=0)&&($signed(col+2)<=7))begin

				if(counter%4==0)begin
				sram_addr[({counter[6:2],row-3'd1,col-3'd1})%4]=({counter[6:2],row-3'd1,col-3'd1})>>2;
				sram_addr[({counter[6:2],row-3'd1,col})%4]  =({counter[6:2],row-3'd1,col})>>2;
				sram_addr[({counter[6:2],row-3'd1,col+3'd1})%4]=({counter[6:2],row-3'd1,col+3'd1})>>2;
				sram_addr[({counter[6:2],row-3'd1,col+3'd2})%4]=({counter[6:2],row-3'd1,col+3'd2})>>2;


				end
				else if(counter%4==1)begin
				sram_addr[({counter[6:2],row,col-3'd1})%4]=({counter[6:2],row,col-3'd1})>>2;
				sram_addr[({counter[6:2],row,col})%4]  =({counter[6:2],row,col})>>2;
				sram_addr[({counter[6:2],row,col+3'd1})%4]=({counter[6:2],row,col+3'd1})>>2;
				sram_addr[({counter[6:2],row,col+3'd2})%4]=({counter[6:2],row,col+3'd2})>>2;
				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd1,col-3'd1}%4]={counter[6:2],row+3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd2}%4]={counter[6:2],row+3'd1,col+3'd2}>>2;
				end
				else if(counter%4==3)begin
				sram_addr[{counter[6:2],row+3'd2,col-3'd1}%4]={counter[6:2],row+3'd2,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col}%4]     ={counter[6:2],row+3'd2,col}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd1}%4]={counter[6:2],row+3'd2,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd2}%4]={counter[6:2],row+3'd2,col+3'd2}>>2;
				end		
			end
			//考慮邊界條件
			// 補7個0
			else if((row==0)&&(col==0)) begin
				if(counter%4==0)begin
				sram_addr[{counter[6:2],row,col}%4]     ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]={counter[6:2],row,col+3'd1}>>2;
				sram_addr[{counter[6:2],row,col+3'd2}%4]={counter[6:2],row,col+3'd2}>>2;

				end
				else if(counter%4==1)begin
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd2}%4]={counter[6:2],row+3'd1,col+3'd2}>>2;

				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd2,col}%4]     ={counter[6:2],row+3'd2,col}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd1}%4]={counter[6:2],row+3'd2,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd2}%4]={counter[6:2],row+3'd2,col+3'd2}>>2;

				end

			end


			// 補7個0
//
			else if((row==6)&&(col==0)) begin
				if(counter%4==0)begin
				sram_addr[{counter[6:2],row-3'd1,col}%4]     ={counter[6:2],row-3'd1,col}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd1}%4]={counter[6:2],row-3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd2}%4]={counter[6:2],row-3'd1,col+3'd2}>>2;

				end
				else if(counter%4==1)begin
				sram_addr[{counter[6:2],row,col}%4]    ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]  ={counter[6:2],row,col+3'd1}>>2;
				sram_addr[{counter[6:2],row,col+3'd2}%4]  ={counter[6:2],row,col+3'd2}>>2;
				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd2}%4]={counter[6:2],row+3'd1,col+3'd2}>>2;
				end

			end
			// 補7個0
//
			else if((row==0)&&(col==6)) begin
				if(counter%4==0)begin
				sram_addr[{counter[6:2],row,col-3'd1}%4]  ={counter[6:2],row,col-3'd1}>>2;
				sram_addr[{counter[6:2],row,col}%4]       ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]  ={counter[6:2],row,col+3'd1}>>2;

				end
				else if(counter%4==1)begin
				sram_addr[{counter[6:2],row+3'd1,col-3'd1}%4]  ={counter[6:2],row+3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col}%4]       ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]  ={counter[6:2],row+3'd1,col+3'd1}>>2;
				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd2,col-3'd1}%4]  ={counter[6:2],row+3'd2,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col}%4]       ={counter[6:2],row+3'd2,col}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd1}%4]  ={counter[6:2],row+3'd2,col+3'd1}>>2;
				end
			end
			// 補7個0
//
			else if((row==6)&&(col==6)) begin
				if(counter%4==0)begin
				sram_addr[{counter[6:2],row-3'd1,col-3'd1}%4]  ={counter[6:2],row-3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row-3'd1,col}%4]       ={counter[6:2],row-3'd1,col}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd1}%4]  ={counter[6:2],row-3'd1,col+3'd1}>>2;

				end
				else if(counter%4==1)begin
				sram_addr[{counter[6:2],row,col-3'd1}%4]  ={counter[6:2],row,col-3'd1}>>2;
				sram_addr[{counter[6:2],row,col}%4]       ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]  ={counter[6:2],row,col+3'd1}>>2;
				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd1,col-3'd1}%4]  ={counter[6:2],row+3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col}%4]       ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]  ={counter[6:2],row+3'd1,col+3'd1}>>2;
				end
			end
			// 補4個0
			else if(row!=0&& row!=6&&col==0)begin
				if(counter%4==0)begin

				sram_addr[{counter[6:2],row-3'd1,col}%4]     ={counter[6:2],row-3'd1,col}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd1}%4]={counter[6:2],row-3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd2}%4]={counter[6:2],row-3'd1,col+3'd2}>>2;

				end
				else if(counter%4==1)begin
				sram_addr[{counter[6:2],row,col}%4]     ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]={counter[6:2],row,col+3'd1}>>2;
				sram_addr[{counter[6:2],row,col+3'd2}%4]={counter[6:2],row,col+3'd2}>>2;

				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd2}%4]={counter[6:2],row+3'd1,col+3'd2}>>2;

				end
				else if(counter%4==3)begin
				sram_addr[{counter[6:2],row+3'd2,col}%4]     ={counter[6:2],row+3'd2,col}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd1}%4]={counter[6:2],row+3'd2,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd2}%4]={counter[6:2],row+3'd2,col+3'd2}>>2;
				//temp1={counter[10:2],row+3'd2,col};
				//temp2={counter[10:2],row+3'd2,col+3'd1};
				//temp3={counter[10:2],row+3'd2,col+3'd2};
				end


			end
			// 補4個0
			else if((row==0)&&(col!=3'd0 && col!=3'd6))begin

				if(counter%4==0)begin

				sram_addr[{counter[6:2],row,col-3'd1}%4]={counter[6:2],row,col-3'd1}>>2;
				sram_addr[{counter[6:2],row,col}%4]     ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]={counter[6:2],row,col+3'd1}>>2;
				sram_addr[{counter[6:2],row,col+3'd2}%4]={counter[6:2],row,col+3'd2}>>2;
				end
				else if(counter%4==1)begin
				sram_addr[{counter[6:2],row+3'd1,col-3'd1}%4]={counter[6:2],row+3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd2}%4]={counter[6:2],row+3'd1,col+3'd2}>>2;
				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd2,col-3'd1}%4]={counter[6:2],row+3'd2,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col}%4]     ={counter[6:2],row+3'd2,col}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd1}%4]={counter[6:2],row+3'd2,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd2}%4]={counter[6:2],row+3'd2,col+3'd2}>>2;
			end
			end
			// 補4個0
//
			else if((row==6)&&(col!=0 && col!=6))begin
			if(counter%4==0)begin

				sram_addr[{counter[6:2],row-3'd1,col-3'd1}%4]={counter[6:2],row-3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row-3'd1,col}%4]     ={counter[6:2],row-3'd1,col}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd1}%4]={counter[6:2],row-3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd2}%4]={counter[6:2],row-3'd1,col+3'd2}>>2;
			end
			else if(counter%4==1)begin
				sram_addr[{counter[6:2],row,col-3'd1}%4]={counter[6:2],row,col-3'd1}>>2;
				sram_addr[{counter[6:2],row,col}%4]     ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]={counter[6:2],row,col+3'd1}>>2;
				sram_addr[{counter[6:2],row,col+3'd2}%4]={counter[6:2],row,col+3'd2}>>2;
			end
			else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd1,col-3'd1}%4]={counter[6:2],row+3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd2}%4]={counter[6:2],row+3'd1,col+3'd2}>>2;
			end
			end			

			// 補4個0
//
			else if((row!=0)&&(row!=6)&&(col==6))begin
			if(counter%4==0)begin

				sram_addr[{counter[6:2],row-3'd1,col-3'd1}%4]={counter[6:2],row-3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row-3'd1,col}%4]     ={counter[6:2],row-3'd1,col}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd1}%4]={counter[6:2],row-3'd1,col+3'd1}>>2;
			end
			else if(counter%4==1)begin
				sram_addr[{counter[6:2],row,col-3'd1}%4]={counter[6:2],row,col-3'd1}>>2;
				sram_addr[{counter[6:2],row,col}%4]     ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]={counter[6:2],row,col+3'd1}>>2;
			end
			else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd1,col-3'd1}%4]={counter[6:2],row+3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
			end
			else if(counter%4==3)begin
				sram_addr[{counter[6:2],row+3'd2,col-3'd1}%4]={counter[6:2],row+3'd2,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col}%4]     ={counter[6:2],row+3'd2,col}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd1}%4]={counter[6:2],row+3'd2,col+3'd1}>>2;
			end
			end		

			end
			SOBEL:begin

			if(counter>1 && counter%4==0 &&flag==0) begin
				n_state = SOBEL_out;
			end
			else if(counter>1 && counter%4==0 &&counter2==1) begin
				n_state = SOBEL_out;
			end
			else begin 
				n_state=SOBEL;				
			end
			//非邊界條件
			if(($signed(row-1)>=0)&&($signed(row+2)<=7)&&($signed(col-1)>=0)&&($signed(col+2)<=7))begin

				if(counter%4==0)begin
				sram_addr[({counter[6:2],row-3'd1,col-3'd1})%4]=({counter[6:2],row-3'd1,col-3'd1})>>2;
				sram_addr[({counter[6:2],row-3'd1,col})%4]  =({counter[6:2],row-3'd1,col})>>2;
				sram_addr[({counter[6:2],row-3'd1,col+3'd1})%4]=({counter[6:2],row-3'd1,col+3'd1})>>2;
				sram_addr[({counter[6:2],row-3'd1,col+3'd2})%4]=({counter[6:2],row-3'd1,col+3'd2})>>2;


				end
				else if(counter%4==1)begin
				sram_addr[({counter[6:2],row,col-3'd1})%4]=({counter[6:2],row,col-3'd1})>>2;
				sram_addr[({counter[6:2],row,col})%4]  =({counter[6:2],row,col})>>2;
				sram_addr[({counter[6:2],row,col+3'd1})%4]=({counter[6:2],row,col+3'd1})>>2;
				sram_addr[({counter[6:2],row,col+3'd2})%4]=({counter[6:2],row,col+3'd2})>>2;
				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd1,col-3'd1}%4]={counter[6:2],row+3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd2}%4]={counter[6:2],row+3'd1,col+3'd2}>>2;
				end
				else if(counter%4==3)begin
				sram_addr[{counter[6:2],row+3'd2,col-3'd1}%4]={counter[6:2],row+3'd2,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col}%4]     ={counter[6:2],row+3'd2,col}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd1}%4]={counter[6:2],row+3'd2,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd2}%4]={counter[6:2],row+3'd2,col+3'd2}>>2;
				end		
			end
			//考慮邊界條件
			// 補7個0
			else if((row==0)&&(col==0)) begin
				if(counter%4==0)begin
				sram_addr[{counter[6:2],row,col}%4]     ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]={counter[6:2],row,col+3'd1}>>2;
				sram_addr[{counter[6:2],row,col+3'd2}%4]={counter[6:2],row,col+3'd2}>>2;

				end
				else if(counter%4==1)begin
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd2}%4]={counter[6:2],row+3'd1,col+3'd2}>>2;

				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd2,col}%4]     ={counter[6:2],row+3'd2,col}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd1}%4]={counter[6:2],row+3'd2,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd2}%4]={counter[6:2],row+3'd2,col+3'd2}>>2;

				end

			end


			// 補7個0
//
			else if((row==6)&&(col==0)) begin
				if(counter%4==0)begin
				sram_addr[{counter[6:2],row-3'd1,col}%4]     ={counter[6:2],row-3'd1,col}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd1}%4]={counter[6:2],row-3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd2}%4]={counter[6:2],row-3'd1,col+3'd2}>>2;

				end
				else if(counter%4==1)begin
				sram_addr[{counter[6:2],row,col}%4]    ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]  ={counter[6:2],row,col+3'd1}>>2;
				sram_addr[{counter[6:2],row,col+3'd2}%4]  ={counter[6:2],row,col+3'd2}>>2;
				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd2}%4]={counter[6:2],row+3'd1,col+3'd2}>>2;
				end

			end
			// 補7個0
//
			else if((row==0)&&(col==6)) begin
				if(counter%4==0)begin
				sram_addr[{counter[6:2],row,col-3'd1}%4]  ={counter[6:2],row,col-3'd1}>>2;
				sram_addr[{counter[6:2],row,col}%4]       ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]  ={counter[6:2],row,col+3'd1}>>2;

				end
				else if(counter%4==1)begin
				sram_addr[{counter[6:2],row+3'd1,col-3'd1}%4]  ={counter[6:2],row+3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col}%4]       ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]  ={counter[6:2],row+3'd1,col+3'd1}>>2;
				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd2,col-3'd1}%4]  ={counter[6:2],row+3'd2,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col}%4]       ={counter[6:2],row+3'd2,col}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd1}%4]  ={counter[6:2],row+3'd2,col+3'd1}>>2;
				end
			end
			// 補7個0
//
			else if((row==6)&&(col==6)) begin
				if(counter%4==0)begin
				sram_addr[{counter[6:2],row-3'd1,col-3'd1}%4]  ={counter[6:2],row-3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row-3'd1,col}%4]       ={counter[6:2],row-3'd1,col}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd1}%4]  ={counter[6:2],row-3'd1,col+3'd1}>>2;

				end
				else if(counter%4==1)begin
				sram_addr[{counter[6:2],row,col-3'd1}%4]  ={counter[6:2],row,col-3'd1}>>2;
				sram_addr[{counter[6:2],row,col}%4]       ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]  ={counter[6:2],row,col+3'd1}>>2;
				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd1,col-3'd1}%4]  ={counter[6:2],row+3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col}%4]       ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]  ={counter[6:2],row+3'd1,col+3'd1}>>2;
				end
			end
			// 補4個0
			else if(row!=0&& row!=6&&col==0)begin
				if(counter%4==0)begin

				sram_addr[{counter[6:2],row-3'd1,col}%4]     ={counter[6:2],row-3'd1,col}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd1}%4]={counter[6:2],row-3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd2}%4]={counter[6:2],row-3'd1,col+3'd2}>>2;

				end
				else if(counter%4==1)begin
				sram_addr[{counter[6:2],row,col}%4]     ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]={counter[6:2],row,col+3'd1}>>2;
				sram_addr[{counter[6:2],row,col+3'd2}%4]={counter[6:2],row,col+3'd2}>>2;

				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd2}%4]={counter[6:2],row+3'd1,col+3'd2}>>2;

				end
				else if(counter%4==3)begin
				sram_addr[{counter[6:2],row+3'd2,col}%4]     ={counter[6:2],row+3'd2,col}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd1}%4]={counter[6:2],row+3'd2,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd2}%4]={counter[6:2],row+3'd2,col+3'd2}>>2;
				//temp1={counter[10:2],row+3'd2,col};
				//temp2={counter[10:2],row+3'd2,col+3'd1};
				//temp3={counter[10:2],row+3'd2,col+3'd2};
				end


			end
			// 補4個0
			else if((row==0)&&(col!=3'd0 && col!=3'd6))begin

				if(counter%4==0)begin

				sram_addr[{counter[6:2],row,col-3'd1}%4]={counter[6:2],row,col-3'd1}>>2;
				sram_addr[{counter[6:2],row,col}%4]     ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]={counter[6:2],row,col+3'd1}>>2;
				sram_addr[{counter[6:2],row,col+3'd2}%4]={counter[6:2],row,col+3'd2}>>2;
				end
				else if(counter%4==1)begin
				sram_addr[{counter[6:2],row+3'd1,col-3'd1}%4]={counter[6:2],row+3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd2}%4]={counter[6:2],row+3'd1,col+3'd2}>>2;
				end
				else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd2,col-3'd1}%4]={counter[6:2],row+3'd2,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col}%4]     ={counter[6:2],row+3'd2,col}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd1}%4]={counter[6:2],row+3'd2,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd2}%4]={counter[6:2],row+3'd2,col+3'd2}>>2;
			end
			end
			// 補4個0
//
			else if((row==6)&&(col!=0 && col!=6))begin
			if(counter%4==0)begin

				sram_addr[{counter[6:2],row-3'd1,col-3'd1}%4]={counter[6:2],row-3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row-3'd1,col}%4]     ={counter[6:2],row-3'd1,col}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd1}%4]={counter[6:2],row-3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd2}%4]={counter[6:2],row-3'd1,col+3'd2}>>2;
			end
			else if(counter%4==1)begin
				sram_addr[{counter[6:2],row,col-3'd1}%4]={counter[6:2],row,col-3'd1}>>2;
				sram_addr[{counter[6:2],row,col}%4]     ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]={counter[6:2],row,col+3'd1}>>2;
				sram_addr[{counter[6:2],row,col+3'd2}%4]={counter[6:2],row,col+3'd2}>>2;
			end
			else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd1,col-3'd1}%4]={counter[6:2],row+3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd2}%4]={counter[6:2],row+3'd1,col+3'd2}>>2;
			end
			end			

			// 補4個0
//
			else if((row!=0)&&(row!=6)&&(col==6))begin
			if(counter%4==0)begin

				sram_addr[{counter[6:2],row-3'd1,col-3'd1}%4]={counter[6:2],row-3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row-3'd1,col}%4]     ={counter[6:2],row-3'd1,col}>>2;
				sram_addr[{counter[6:2],row-3'd1,col+3'd1}%4]={counter[6:2],row-3'd1,col+3'd1}>>2;
			end
			else if(counter%4==1)begin
				sram_addr[{counter[6:2],row,col-3'd1}%4]={counter[6:2],row,col-3'd1}>>2;
				sram_addr[{counter[6:2],row,col}%4]     ={counter[6:2],row,col}>>2;
				sram_addr[{counter[6:2],row,col+3'd1}%4]={counter[6:2],row,col+3'd1}>>2;
			end
			else if(counter%4==2)begin
				sram_addr[{counter[6:2],row+3'd1,col-3'd1}%4]={counter[6:2],row+3'd1,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd1,col}%4]     ={counter[6:2],row+3'd1,col}>>2;
				sram_addr[{counter[6:2],row+3'd1,col+3'd1}%4]={counter[6:2],row+3'd1,col+3'd1}>>2;
			end
			else if(counter%4==3)begin
				sram_addr[{counter[6:2],row+3'd2,col-3'd1}%4]={counter[6:2],row+3'd2,col-3'd1}>>2;
				sram_addr[{counter[6:2],row+3'd2,col}%4]     ={counter[6:2],row+3'd2,col}>>2;
				sram_addr[{counter[6:2],row+3'd2,col+3'd1}%4]={counter[6:2],row+3'd2,col+3'd1}>>2;
			end
			end		

			end


			SOBEL_out:begin
				if(counter==16 && counter2==4)
					n_state=IDLE;
				else if(counter2==5)
					n_state=SOBEL;
				else 
					n_state=SOBEL_out;
			end
			MEDIAN_out:begin
				if(counter==17)
					n_state=IDLE;
				else if(counter2==4)
					n_state=MEDIANFILTER;
				else 
					n_state=MEDIAN_out;
				if (counter2==1)begin
				//special sort
				//水平
						{temp[0],temp[1],temp[2]}=sort3(sort_data[0],sort_data[1],sort_data[2]);
						{temp[3],temp[4],temp[5]}=sort3(sort_data[3],sort_data[4],sort_data[5]);
						{temp[6],temp[7],temp[8]}=sort3(sort_data[6],sort_data[7],sort_data[8]);
				//垂直
						{temp[0],temp[3],temp[6]}=sort3(temp[0],temp[3],temp[6]);
						{temp[1],temp[4],temp[7]}=sort3(temp[1],temp[4],temp[7]);
						{temp[2],temp[5],temp[8]}=sort3(temp[2],temp[5],temp[8]);
				//左下到右上
						{temp[2],temp[4],temp[6]}=sort3(temp[2],temp[4],temp[6]);
				end
				else if (counter2==2)begin
				//special sort
				//水平
						{temp[0+9],temp[1+9],temp[2+9]}=sort3(sort_data[0+9],sort_data[1+9],sort_data[2+9]);
						{temp[3+9],temp[4+9],temp[5+9]}=sort3(sort_data[3+9],sort_data[4+9],sort_data[5+9]);
						{temp[6+9],temp[7+9],temp[8+9]}=sort3(sort_data[6+9],sort_data[7+9],sort_data[8+9]);
				//垂直
						{temp[0+9],temp[3+9],temp[6+9]}=sort3(temp[0+9],temp[3+9],temp[6+9]);
						{temp[1+9],temp[4+9],temp[7+9]}=sort3(temp[1+9],temp[4+9],temp[7+9]);
						{temp[2+9],temp[5+9],temp[8+9]}=sort3(temp[2+9],temp[5+9],temp[8+9]);
				//左下到右上
						{temp[2+9],temp[4+9],temp[6+9]}=sort3(temp[2+9],temp[4+9],temp[6+9]);
				end	
				else if (counter2==3)begin
				//special sort
				//水平
						{temp[0+9+9],temp[1+9+9],temp[2+9+9]}=sort3(sort_data[0+9+9],sort_data[1+9+9],sort_data[2+9+9]);
						{temp[3+9+9],temp[4+9+9],temp[5+9+9]}=sort3(sort_data[3+9+9],sort_data[4+9+9],sort_data[5+9+9]);
						{temp[6+9+9],temp[7+9+9],temp[8+9+9]}=sort3(sort_data[6+9+9],sort_data[7+9+9],sort_data[8+9+9]);
				//垂直
						{temp[0+9+9],temp[3+9+9],temp[6+9+9]}=sort3(temp[0+9+9],temp[3+9+9],temp[6+9+9]);
						{temp[1+9+9],temp[4+9+9],temp[7+9+9]}=sort3(temp[1+9+9],temp[4+9+9],temp[7+9+9]);
						{temp[2+9+9],temp[5+9+9],temp[8+9+9]}=sort3(temp[2+9+9],temp[5+9+9],temp[8+9+9]);
				//左下到右上
						{temp[2+9+9],temp[4+9+9],temp[6+9+9]}=sort3(temp[2+9+9],temp[4+9+9],temp[6+9+9]);
				end	
				else if (counter2==4)begin
				//special sort
				//水平
						{temp[0+9+9+9],temp[1+9+9+9],temp[2+9+9+9]}=sort3(sort_data[0+9+9+9],sort_data[1+9+9+9],sort_data[2+9+9+9]);
						{temp[3+9+9+9],temp[4+9+9+9],temp[5+9+9+9]}=sort3(sort_data[3+9+9+9],sort_data[4+9+9+9],sort_data[5+9+9+9]);
						{temp[6+9+9+9],temp[7+9+9+9],temp[8+9+9+9]}=sort3(sort_data[6+9+9+9],sort_data[7+9+9+9],sort_data[8+9+9+9]);
				//垂直
						{temp[0+9+9+9],temp[3+9+9+9],temp[6+9+9+9]}=sort3(temp[0+9+9+9],temp[3+9+9+9],temp[6+9+9+9]);
						{temp[1+9+9+9],temp[4+9+9+9],temp[7+9+9+9]}=sort3(temp[1+9+9+9],temp[4+9+9+9],temp[7+9+9+9]);
						{temp[2+9+9+9],temp[5+9+9+9],temp[8+9+9+9]}=sort3(temp[2+9+9+9],temp[5+9+9+9],temp[8+9+9+9]);
				//左下到右上
						{temp[2+9+9+9],temp[4+9+9+9],temp[6+9+9+9]}=sort3(temp[2+9+9+9],temp[4+9+9+9],temp[6+9+9+9]);
				end					
			end
			CONVOLUTION_out:begin

				if(counter==3)
					n_state=IDLE;
				else 
					n_state=CONVOLUTION_out;

			end
		default:n_state = INIT;
	endcase
end

// ---------------------------------------------------------------------------
// Sequential Block
// ---------------------------------------------------------------------------
// ---- Write your sequential block design here ---- //
always@(posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n) begin
		i_in_valid_r<=0;
	end
	else if(i_in_valid)
			i_in_valid_r<=1;
	else i_in_valid_r<=0;
end
always@(posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n) begin
		in_data_r	 <=0;
		o_op_ready_r <=0;
		o_out_data_r <=0;
		o_out_valid_r<=0;
		o_in_ready_r <=0;
		data_temp<=0;
		row<=0;
		col<=0;
		op_mode_r<=0;
		for(i=0;i<36;i=i+1)begin
			sort_data[i]<=0;
			pixel_10[i]<=0;
		end
		for(i=0;i<16;i=i+1)begin

			pixel[i]<=0;
		end

	end 
	else if(state==IDLE &&o_op_ready_r!=1 &&n_state==IDLE &&i_in_valid==0)begin
		o_op_ready_r <=1;
		o_out_valid_r<=0;
	end
	else if(state==IDLE &&o_op_ready_r==1)begin
		o_op_ready_r <=0;
		o_out_valid_r<=0;

	end
	else if(state==IDLE &&i_op_valid==1)begin
		op_mode_r <=i_op_mode;
		o_out_valid_r<=0;

	end
	else if(state==SHIFT)begin
		row<=row_w;
		col<=col_w;
		o_op_ready_r <=0;
		//o_out_valid_r<=0;
	end
	else if(i_in_valid_r)begin
		o_in_ready_r<=1;
		data_temp<= i_in_data;
		in_data_r  <= data_temp;
		
		o_op_ready_r <=0;
	end
	else if(state==DISPLAY)begin
		o_in_ready_r<=0;
		if(counter>=1)begin
			o_out_valid_r<=1;
			if(counter%4==1)begin
				o_out_data_r<=sram_q[{counter[6:2],row,col}%4];
				end
			else if(counter%4==2)begin
				o_out_data_r<=sram_q[(1+{counter[6:2],row,col})%4];
			end
			else if(counter%4==3)begin
				o_out_data_r<=sram_q[(8+{counter[6:2],row,col})%4];
			end
			else if(counter%4==0)begin
				o_out_data_r<=sram_q[(9+{counter[6:2],row,col})%4];
			end	
		end
	
		else
			o_op_ready_r <=0;
	end
	else if(state==CONVOLUTION_out)begin
		if(counter%4==0)begin
			o_out_valid_r<=1;
			o_out_data_r<=conv_image_rounding[0][13:0];
		end
		else if(counter%4==1)begin
			o_out_valid_r<=1;
			o_out_data_r<=conv_image_rounding[1][13:0];
		end
		else if(counter%4==2)begin
			o_out_valid_r<=1;
			o_out_data_r<=conv_image_rounding[2][13:0];
		end
		else if(counter%4==3)begin
			o_out_valid_r<=1;
			o_out_data_r<=conv_image_rounding[3][13:0];
		end
	end
			//o_out_valid_r<=0;


	


	else if(state==MEDIAN_out)begin
			if(counter2==11'd1)begin
				o_out_data_r<=temp[4];
				o_out_valid_r<=1;
			end
			else if(counter2==11'd2)begin
				o_out_data_r<=temp[13];
				o_out_valid_r<=1;
			end
			else if(counter2==11'd3)begin
				o_out_data_r<=temp[22];
				o_out_valid_r<=1;
			end
			else if(counter2==11'd4)begin
				o_out_data_r<=temp[31];
				o_out_valid_r<=1;
			end

		//bubble sort
       	// if(sort_data[counter2+1]<sort_data[counter2])begin
        //    		sort_data[counter2]<=sort_data[counter2+1];
        //     	sort_data[counter2+1]<=sort_data[counter2];
		// 	end
		
        // if(sort_data[counter2+1+9]<sort_data[counter2+9])begin
        //     sort_data[counter2+9]<=sort_data[counter2+1+9];
        //     sort_data[counter2+1+9]<=sort_data[counter2+9];
		// 	end

       	// if(sort_data[counter2+19]<sort_data[counter2+18])begin
        //    		sort_data[counter2+18]<=sort_data[counter2+19];
        //     	sort_data[counter2+19]<=sort_data[counter2+18];
		// 	end
		
        // if(sort_data[counter2+28]<sort_data[counter2+27])begin
        //     sort_data[counter2+27]<=sort_data[counter2+28];
        //     sort_data[counter2+28]<=sort_data[counter2+27];
		// end
	end
	else if(state==CONVOLUTION)begin
		o_in_ready_r<=0;
		if(counter>=1)begin
			if(($signed(row-1)>=0)&&($signed(row+2)<=7)&&($signed(col-1)>=0)&&($signed(col+2)<=7))begin
				if(counter%4==1)begin
				pixel[0]<=sram_q[{counter[6:2],row-3'd1,col-3'd1}%4];
				pixel[1]<=sram_q[{counter[6:2],row-3'd1,col}%4];
				pixel[2]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				pixel[3]<=sram_q[{counter[6:2],row-3'd1,col+3'd2}%4];
				end
				else if(counter%4==2)begin
				pixel[4]<=sram_q[{counter[6:2],row,col-3'd1}%4];
				pixel[5]<=sram_q[{counter[6:2],row,col}%4];
				pixel[6]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel[7]<=sram_q[{counter[6:2],row,col+3'd2}%4];
				end
				else if(counter%4==3)begin
				pixel[8] <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				pixel[9] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel[10]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel[11]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				end
				else if(counter%4==0)begin
				pixel[12]<=sram_q[{counter[6:2],row+3'd2,col-3'd1}%4];
				pixel[13]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				pixel[14]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				pixel[15]<=sram_q[{counter[6:2],row+3'd2,col+3'd2}%4];
				end	

			end

			else if((row==0)&&(col!=0 && col!=6))begin
				if(counter%4==1)begin
				pixel[4]<=sram_q[{counter[6:2],row,col-3'd1}%4];
				pixel[5]<=sram_q[{counter[6:2],row,col}%4];
				pixel[6]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel[7]<=sram_q[{counter[6:2],row,col+3'd2}%4];
				end
				else if(counter%4==2)begin
				pixel[8] <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				pixel[9] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel[10]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel[11]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				end
				else if(counter%4==3)begin
				pixel[12]<=sram_q[{counter[6:2],row+3'd2,col-3'd1}%4];
				pixel[13]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				pixel[14]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				pixel[15]<=sram_q[{counter[6:2],row+3'd2,col+3'd2}%4];
				end
			end

			else if(row!=0&& row!=6&&col==0)begin
				if(counter%4==1)begin
				pixel[1]<=sram_q[{counter[6:2],row-3'd1,col}%4];
				pixel[2]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				pixel[3]<=sram_q[{counter[6:2],row-3'd1,col+3'd2}%4];
				end
				else if(counter%4==2)begin
				pixel[5]<=sram_q[{counter[6:2],row,col}%4];
				pixel[6]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel[7]<=sram_q[{counter[6:2],row,col+3'd2}%4];
				end
				else if(counter%4==3)begin
				pixel[9] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel[10]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel[11]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				end
				else if(counter%4==0)begin
				pixel[13]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				pixel[14]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				pixel[15]<=sram_q[{counter[6:2],row+3'd2,col+3'd2}%4];
				end

			end
			else if((row!=0)&&(row!=6)&&(col==6))begin
				if(counter%4==1)begin
				pixel[0]<=sram_q[{counter[6:2],row-3'd1,col-3'd1}%4];
				pixel[1]<=sram_q[{counter[6:2],row-3'd1,col}%4];
				pixel[2]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				end
				else if(counter%4==2)begin
				pixel[4]<=sram_q[{counter[6:2],row,col-3'd1}%4];
				pixel[5]<=sram_q[{counter[6:2],row,col}%4];
				pixel[6]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				end
				else if(counter%4==3)begin
				pixel[8] <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				pixel[9]<=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel[10]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				end
				else if(counter%4==0)begin
				pixel[12]<=sram_q[{counter[6:2],row+3'd2,col-3'd1}%4];
				pixel[13]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				pixel[14]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				end

			end

			else if((row==6)&&(col!=0 && col!=6))begin
				if(counter%4==1)begin

				pixel[0]<=sram_q[{counter[6:2],row-3'd1,col-3'd1}%4];
				pixel[1]<=sram_q[{counter[6:2],row-3'd1,col}%4];
				pixel[2]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				pixel[3]<=sram_q[{counter[6:2],row-3'd1,col+3'd2}%4];
				end
				else if(counter%4==2)begin
				pixel[4]<=sram_q[{counter[6:2],row,col-3'd1}%4];
				pixel[5]<=sram_q[{counter[6:2],row,col}%4];
				pixel[6]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel[7]<=sram_q[{counter[6:2],row,col+3'd2}%4];
				end
				else if(counter%4==3)begin
				pixel[8]<=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				pixel[9]<=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel[10]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel[11]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				end
			end

			else if((row==0)&&(col==0)) begin
				if(counter%4==1)begin
				pixel[5]<=sram_q[{counter[6:2],row,col}%4];
				pixel[6]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel[7]<=sram_q[{counter[6:2],row,col+3'd2}%4];

				end
				else if(counter%4==2)begin
				pixel[9] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel[10]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel[11]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				end
				else if(counter%4==3)begin
				pixel[13]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				pixel[14]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				pixel[15]<=sram_q[{counter[6:2],row+3'd2,col+3'd2}%4];
				end

			end
			else if((row==6)&&(col==0)) begin
				if(counter%4==1)begin
				pixel[1] <=sram_q[{counter[6:2],row-3'd1,col}%4];
				pixel[2] <=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				pixel[3] <=sram_q[{counter[6:2],row-3'd1,col+3'd2}%4];

				end
				else if(counter%4==2)begin
				pixel[5] <=sram_q[{counter[6:2],row,col}%4];
				pixel[6] <=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel[7] <=sram_q[{counter[6:2],row,col+3'd2}%4];
				end
				else if(counter%4==3)begin
				pixel[9]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel[10] <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel[11] <=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				end

			end

			else if((row==6)&&(col==6)) begin
				if(counter%4==1)begin
				pixel[0]  <=sram_q[{counter[6:2],row-3'd1,col-3'd1}%4];
				pixel[1]  <=sram_q[{counter[6:2],row-3'd1,col}%4];
				pixel[2]  <=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];

				end
				else if(counter%4==2)begin
				pixel[4]  <=sram_q[{counter[6:2],row,col-3'd1}%4];
				pixel[5]  <=sram_q[{counter[6:2],row,col}%4];
				pixel[6]  <=sram_q[{counter[6:2],row,col+3'd1}%4];
				end
				else if(counter%4==3)begin
				pixel[8]  <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				pixel[9]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel[10]  <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				end
			end



			else if((row==0)&&(col==6)) begin
				if(counter%4==1)begin
				pixel[4]  <=sram_q[{counter[6:2],row,col-3'd1}%4];
				pixel[5]  <=sram_q[{counter[6:2],row,col}%4];
				pixel[6]  <=sram_q[{counter[6:2],row,col+3'd1}%4];

				end
				else if(counter%4==2)begin
				pixel[8]  <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				pixel[9]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel[10] <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				end
				else if(counter%4==3)begin
				pixel[12] <=sram_q[{counter[6:2],row+3'd2,col-3'd1}%4];
				pixel[13] <=sram_q[{counter[6:2],row+3'd2,col}%4];
				pixel[14] <=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				end
			end

		end
	
		else
			o_op_ready_r <=0;
			//o_out_valid_r<=0;
	end
	else if(state==MEDIANFILTER)begin
		o_in_ready_r<=0;
		o_out_valid_r<=0;
		if(counter>=1)begin
			if(($signed(row-1)>=0)&&($signed(row+2)<=7)&&($signed(col-1)>=0)&&($signed(col+2)<=7))begin
				if(counter%4==1)begin
				sort_data[0]<=sram_q[{counter[6:2],row-3'd1,col-3'd1}%4];
				sort_data[1]<=sram_q[{counter[6:2],row-3'd1,col}%4];
				sort_data[2]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
                sort_data[9]<=sram_q[{counter[6:2],row-3'd1,col}%4];
            	sort_data[10]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				sort_data[11]<=sram_q[{counter[6:2],row-3'd1,col+3'd2}%4];
				end
				else if(counter%4==2)begin
				sort_data[3]<=sram_q[{counter[6:2],row,col-3'd1}%4];
				sort_data[4]<=sram_q[{counter[6:2],row,col}%4];
				sort_data[5]<=sram_q[{counter[6:2],row,col+3'd1}%4];

                sort_data[12]<=sram_q[{counter[6:2],row,col}%4];
        		sort_data[13]<=sram_q[{counter[6:2],row,col+3'd1}%4];
                sort_data[14]<=sram_q[{counter[6:2],row,col+3'd2}%4];


				sort_data[18]<=sram_q[{counter[6:2],row,col-3'd1}%4];
				sort_data[19]<=sram_q[{counter[6:2],row,col}%4];
        		sort_data[20]<=sram_q[{counter[6:2],row,col+3'd1}%4];

				sort_data[27]<=sram_q[{counter[6:2],row,col}%4];
        		sort_data[28]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				sort_data[29]<=sram_q[{counter[6:2],row,col+3'd2}%4];
				end
				else if(counter%4==3)begin
				sort_data[6] <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				sort_data[7] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[8]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];

				sort_data[21] <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				sort_data[22] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[23]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];

				sort_data[15] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[16]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				sort_data[17]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];

				sort_data[30] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[31]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				sort_data[32]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				end
				else if(counter%4==0)begin
				sort_data[24]<=sram_q[{counter[6:2],row+3'd2,col-3'd1}%4];
				sort_data[25]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				sort_data[26]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];

				sort_data[33]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				sort_data[34]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				sort_data[35]<=sram_q[{counter[6:2],row+3'd2,col+3'd2}%4];
				end	

			end

			else if((row==0)&&(col!=0 && col!=6))begin
				sort_data[0]<=0;
				sort_data[1]<=0;
                sort_data[9]<=0;
				sort_data[2]<=0;
            	sort_data[10]<=0;
				sort_data[11]<=0;
				if(counter%4==1)begin
				sort_data[3]<=sram_q[{counter[6:2],row,col-3'd1}%4];
				sort_data[4]<=sram_q[{counter[6:2],row,col}%4];
				sort_data[5]<=sram_q[{counter[6:2],row,col+3'd1}%4];


				sort_data[12]<=sram_q[{counter[6:2],row,col}%4];
                sort_data[13]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				sort_data[14]<=sram_q[{counter[6:2],row,col+3'd2}%4];

				sort_data[18]<=sram_q[{counter[6:2],row,col-3'd1}%4];
				sort_data[19]<=sram_q[{counter[6:2],row,col}%4];
				sort_data[20]<=sram_q[{counter[6:2],row,col+3'd1}%4];

				sort_data[27]<=sram_q[{counter[6:2],row,col}%4];
				sort_data[28]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				sort_data[29]<=sram_q[{counter[6:2],row,col+3'd2}%4];
		

                end
				else if(counter%4==2)begin
				sort_data[6] <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				sort_data[7] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[8]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];


				sort_data[15] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[16]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				sort_data[17]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];

				sort_data[21] <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				sort_data[22] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[23]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];

				sort_data[30] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[31]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				sort_data[32]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];

				end
				else if(counter%4==3)begin
				sort_data[24]<=sram_q[{counter[6:2],row+3'd2,col-3'd1}%4];
				sort_data[25]<=sram_q[{counter[6:2],row+3'd2,col}%4];
                sort_data[26]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];

				sort_data[33]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				sort_data[34]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				sort_data[35]<=sram_q[{counter[6:2],row+3'd2,col+3'd2}%4];
				end
			end

			else if(row!=0&& row!=6&&col==0)begin
				sort_data[0]<=0;
                sort_data[3]<=0;
                sort_data[18]<=0;
                sort_data[6]<=0;
                sort_data[21]<=0;
                sort_data[24]<=0;
				if(counter%4==1)begin
				sort_data[1]<=sram_q[{counter[6:2],row-3'd1,col}%4];
				sort_data[2]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];

				sort_data[9]<=sram_q[{counter[6:2],row-3'd1,col}%4];
				sort_data[10]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				sort_data[11]<=sram_q[{counter[6:2],row-3'd1,col+3'd2}%4];
				end
				else if(counter%4==2)begin
				sort_data[4]<=sram_q[{counter[6:2],row,col}%4];
				sort_data[5]<=sram_q[{counter[6:2],row,col+3'd1}%4];

				sort_data[12]<=sram_q[{counter[6:2],row,col}%4];
				sort_data[13]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				sort_data[14]<=sram_q[{counter[6:2],row,col+3'd2}%4];

				sort_data[19]<=sram_q[{counter[6:2],row,col}%4];
				sort_data[20]<=sram_q[{counter[6:2],row,col+3'd1}%4];

				sort_data[27]<=sram_q[{counter[6:2],row,col}%4];
				sort_data[28]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				sort_data[29]<=sram_q[{counter[6:2],row,col+3'd2}%4];
				end
				else if(counter%4==3)begin
				sort_data[7] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[15] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[22] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[30] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[8]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				sort_data[16]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				sort_data[23]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				sort_data[31]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				sort_data[17]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				sort_data[32]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				end
				else if(counter%4==0)begin
				sort_data[25]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				sort_data[33]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				sort_data[26]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				sort_data[34]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				sort_data[35]<=sram_q[{counter[6:2],row+3'd2,col+3'd2}%4];
				end

			end
			else if((row!=0)&&(row!=6)&&(col==6))begin
				sort_data[11]<=0;
				sort_data[14]<=0;
				sort_data[29]<=0;

				sort_data[17]<=0;
				sort_data[32]<=0;

				sort_data[35]<=0;
				if(counter%4==1)begin
				sort_data[0]<=sram_q[{counter[6:2],row-3'd1,col-3'd1}%4];
				sort_data[1]<=sram_q[{counter[6:2],row-3'd1,col}%4];
				sort_data[2]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];

				sort_data[9]<=sram_q[{counter[6:2],row-3'd1,col}%4];
				sort_data[10]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				end
				else if(counter%4==2)begin
				sort_data[3]<=sram_q[{counter[6:2],row,col-3'd1}%4];
				sort_data[4]<=sram_q[{counter[6:2],row,col}%4];
				sort_data[5]<=sram_q[{counter[6:2],row,col+3'd1}%4];

				sort_data[12]<=sram_q[{counter[6:2],row,col}%4];
				sort_data[13]<=sram_q[{counter[6:2],row,col+3'd1}%4];

				sort_data[18]<=sram_q[{counter[6:2],row,col-3'd1}%4];
				sort_data[19]<=sram_q[{counter[6:2],row,col}%4];
				sort_data[20]<=sram_q[{counter[6:2],row,col+3'd1}%4];

				sort_data[27]<=sram_q[{counter[6:2],row,col}%4];
				sort_data[28]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				end
				else if(counter%4==3)begin
				sort_data[6] <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
    			sort_data[7]<=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[8]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				sort_data[15]<=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[16]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];

				sort_data[21] <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				sort_data[22]<=sram_q[{counter[6:2],row+3'd1,col}%4];            
				sort_data[23]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];

				sort_data[30]<=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[31]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];

				end
				else if(counter%4==0)begin
				sort_data[24]<=sram_q[{counter[6:2],row+3'd2,col-3'd1}%4];
				sort_data[25]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				sort_data[33]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				sort_data[26]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				sort_data[34]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				end

			end

			else if((row==6)&&(col!=0 && col!=6))begin
				sort_data[24]<=0;
				sort_data[25]<=0;
				sort_data[33]<=0;
				sort_data[26]<=0;
				sort_data[34]<=0;
				sort_data[35]<=0;				
				if(counter%4==1)begin

				sort_data[0]<=sram_q[{counter[6:2],row-3'd1,col-3'd1}%4];
				sort_data[1]<=sram_q[{counter[6:2],row-3'd1,col}%4];
				sort_data[2]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];

				sort_data[9]<=sram_q[{counter[6:2],row-3'd1,col}%4];
				sort_data[10]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				sort_data[11]<=sram_q[{counter[6:2],row-3'd1,col+3'd2}%4];
				end
				else if(counter%4==2)begin
				sort_data[3]<=sram_q[{counter[6:2],row,col-3'd1}%4];
				sort_data[4]<=sram_q[{counter[6:2],row,col}%4];
                sort_data[5]<=sram_q[{counter[6:2],row,col+3'd1}%4];

				sort_data[12]<=sram_q[{counter[6:2],row,col}%4];
				sort_data[13]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				sort_data[14]<=sram_q[{counter[6:2],row,col+3'd2}%4];

				sort_data[18]<=sram_q[{counter[6:2],row,col-3'd1}%4];
				sort_data[19]<=sram_q[{counter[6:2],row,col}%4];
				sort_data[20]<=sram_q[{counter[6:2],row,col+3'd1}%4];

				sort_data[27]<=sram_q[{counter[6:2],row,col}%4];
				sort_data[28]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				sort_data[29]<=sram_q[{counter[6:2],row,col+3'd2}%4];

				end
				else if(counter%4==3)begin
				sort_data[6]<=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				sort_data[7]<=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[8]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];

				sort_data[15]<=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[16]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				sort_data[17]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];

				sort_data[21]<=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				sort_data[22]<=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[23]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];

				sort_data[30]<=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[31]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				sort_data[32]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];

				end
			end

			else if((row==0)&&(col==0)) begin
				sort_data[0]<=0;
				sort_data[1]<=0;
				sort_data[9]<=0;
				sort_data[2]<=0;
				sort_data[10]<=0;
				sort_data[11]<=0;
  				sort_data[3]<=0;              
				sort_data[18]<=0;
				sort_data[6]<=0;
				sort_data[21]<=0;
				sort_data[24]<=0;

				if(counter%4==1)begin
				sort_data[4]<=sram_q[{counter[6:2],row,col}%4];
				sort_data[5]<=sram_q[{counter[6:2],row,col+3'd1}%4];

				sort_data[12]<=sram_q[{counter[6:2],row,col}%4];
				sort_data[13]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				sort_data[14]<=sram_q[{counter[6:2],row,col+3'd2}%4];

				sort_data[19]<=sram_q[{counter[6:2],row,col}%4];
				sort_data[20]<=sram_q[{counter[6:2],row,col+3'd1}%4];

				sort_data[27]<=sram_q[{counter[6:2],row,col}%4];
				sort_data[28]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				sort_data[29]<=sram_q[{counter[6:2],row,col+3'd2}%4];

				end
				else if(counter%4==2)begin
				sort_data[7] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[8]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];

				sort_data[15] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[16]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				sort_data[17]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];

				sort_data[22] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[23]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];


				sort_data[30] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[31]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				sort_data[32]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				end
				else if(counter%4==3)begin
				sort_data[25]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				sort_data[26]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];

				sort_data[33]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				sort_data[34]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				sort_data[35]<=sram_q[{counter[6:2],row+3'd2,col+3'd2}%4];
				end

			end
			else if((row==6)&&(col==0)) begin
				sort_data[0]<=0;
				sort_data[3]<=0;
				sort_data[18]<=0;
				sort_data[6]<=0;
				sort_data[21]<=0;

				sort_data[24]<=0;
				sort_data[25]<=0;
				sort_data[33]<=0;
				sort_data[26]<=0;
				sort_data[34]<=0;
				sort_data[35]<=0;
				if(counter%4==1)begin
				sort_data[1] <=sram_q[{counter[6:2],row-3'd1,col}%4];
				sort_data[2] <=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				sort_data[9] <=sram_q[{counter[6:2],row-3'd1,col}%4];
				sort_data[10] <=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				sort_data[11] <=sram_q[{counter[6:2],row-3'd1,col+3'd2}%4];

				end
				else if(counter%4==2)begin
				sort_data[4] <=sram_q[{counter[6:2],row,col}%4];
				sort_data[5] <=sram_q[{counter[6:2],row,col+3'd1}%4];

				sort_data[12] <=sram_q[{counter[6:2],row,col}%4];
				sort_data[13] <=sram_q[{counter[6:2],row,col+3'd1}%4];
				sort_data[14] <=sram_q[{counter[6:2],row,col+3'd2}%4];

				sort_data[19] <=sram_q[{counter[6:2],row,col}%4];
				sort_data[20] <=sram_q[{counter[6:2],row,col+3'd1}%4];

				sort_data[27] <=sram_q[{counter[6:2],row,col}%4];
				sort_data[28] <=sram_q[{counter[6:2],row,col+3'd1}%4];
				sort_data[29] <=sram_q[{counter[6:2],row,col+3'd2}%4];

				end
				else if(counter%4==3)begin
				sort_data[7]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
                sort_data[8] <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];

				sort_data[15]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[16] <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				sort_data[17] <=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];

				sort_data[22]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[23] <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];

				sort_data[30]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[31] <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				sort_data[32] <=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				end

			end

			else if((row==6)&&(col==6)) begin
				sort_data[11]<=0;
				sort_data[14]<=0;
				sort_data[29]<=0;
				sort_data[17]<=0;
				sort_data[32]<=0;
				sort_data[24]<=0;
                sort_data[25]<=0;
				sort_data[33]<=0;
				sort_data[26]<=0;
				sort_data[34]<=0;
				sort_data[35]<=0;
				if(counter%4==1)begin
				sort_data[0]  <=sram_q[{counter[6:2],row-3'd1,col-3'd1}%4];
				sort_data[1]  <=sram_q[{counter[6:2],row-3'd1,col}%4];
				sort_data[2]  <=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];

				sort_data[9]  <=sram_q[{counter[6:2],row-3'd1,col}%4];
				sort_data[10]  <=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];

				end
				else if(counter%4==2)begin
				sort_data[3]  <=sram_q[{counter[6:2],row,col-3'd1}%4];
				sort_data[4]  <=sram_q[{counter[6:2],row,col}%4];
				sort_data[5]  <=sram_q[{counter[6:2],row,col+3'd1}%4];

				sort_data[12]  <=sram_q[{counter[6:2],row,col}%4];
				sort_data[13]  <=sram_q[{counter[6:2],row,col+3'd1}%4];

				sort_data[18]  <=sram_q[{counter[6:2],row,col-3'd1}%4];
				sort_data[19]  <=sram_q[{counter[6:2],row,col}%4];
				sort_data[20]  <=sram_q[{counter[6:2],row,col+3'd1}%4];

				sort_data[27]  <=sram_q[{counter[6:2],row,col}%4];
				sort_data[28]  <=sram_q[{counter[6:2],row,col+3'd1}%4];
				end
				else if(counter%4==3)begin
				sort_data[6]  <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				sort_data[7]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[8]  <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];

				sort_data[15]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[16]  <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];

    			sort_data[21]  <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				sort_data[22]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[23]  <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];

				sort_data[30]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[31]  <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				end
			end



			else if((row==0)&&(col==6)) begin
				sort_data[0]<=0;
				sort_data[1]<=0;
				sort_data[9]<=0;
				sort_data[2]<=0;
				sort_data[10]<=0;
				sort_data[11]<=0;
				sort_data[14]<=0;
				sort_data[29]<=0;
				sort_data[17]<=0;
				sort_data[32]<=0;
				sort_data[35]<=0;

				if(counter%4==1)begin
				sort_data[3]  <=sram_q[{counter[6:2],row,col-3'd1}%4];
				sort_data[4]  <=sram_q[{counter[6:2],row,col}%4];
				sort_data[5]  <=sram_q[{counter[6:2],row,col+3'd1}%4];

				sort_data[18]  <=sram_q[{counter[6:2],row,col-3'd1}%4];

				sort_data[12]  <=sram_q[{counter[6:2],row,col}%4];
				sort_data[13]  <=sram_q[{counter[6:2],row,col+3'd1}%4];

				sort_data[19]  <=sram_q[{counter[6:2],row,col}%4];
				sort_data[27]  <=sram_q[{counter[6:2],row,col}%4];
				sort_data[20]  <=sram_q[{counter[6:2],row,col+3'd1}%4];
				sort_data[28]  <=sram_q[{counter[6:2],row,col+3'd1}%4];

				end
				else if(counter%4==2)begin
				sort_data[6]  <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				sort_data[21]  <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				sort_data[7]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[15]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[22]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[30]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				sort_data[8] <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				sort_data[16] <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				sort_data[23] <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				sort_data[31] <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];

				end
				else if(counter%4==3)begin
				sort_data[24] <=sram_q[{counter[6:2],row+3'd2,col-3'd1}%4];
				sort_data[25] <=sram_q[{counter[6:2],row+3'd2,col}%4];
				sort_data[33] <=sram_q[{counter[6:2],row+3'd2,col}%4];
				sort_data[26] <=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				sort_data[34] <=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				end
			end

		end
	
		else
			o_op_ready_r <=0;
			//o_out_valid_r<=0;
	end
	else if(state==SOBEL_out)begin
	if(counter==5)begin
		o_out_data_r<=G_out[counter2-1];
		o_out_valid_r<=1;
		if(counter2==5)
			o_out_valid_r<=0;
	end
	else  begin
		o_out_data_r<=G_out[counter2];
		o_out_valid_r<=1;
		if(counter2==4)
			o_out_valid_r<=0;
		if(counter2==5)
			o_out_valid_r<=0;
	end
	end
	else if(state==SOBEL)begin
		o_in_ready_r<=0;
		o_out_valid_r<=0;
		if(counter>=1)begin
			if(($signed(row-1)>=0)&&($signed(row+2)<=7)&&($signed(col-1)>=0)&&($signed(col+2)<=7))begin
				if(counter%4==1)begin
				pixel_10[0]<=sram_q[{counter[6:2],row-3'd1,col-3'd1}%4];
				pixel_10[1]<=sram_q[{counter[6:2],row-3'd1,col}%4];
                pixel_10[9]<=sram_q[{counter[6:2],row-3'd1,col}%4];
				pixel_10[2]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
            	pixel_10[10]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				pixel_10[11]<=sram_q[{counter[6:2],row-3'd1,col+3'd2}%4];
				end
				else if(counter%4==2)begin
				pixel_10[3]<=sram_q[{counter[6:2],row,col-3'd1}%4];
				pixel_10[18]<=sram_q[{counter[6:2],row,col-3'd1}%4];
				pixel_10[4]<=sram_q[{counter[6:2],row,col}%4];
                pixel_10[12]<=sram_q[{counter[6:2],row,col}%4];
				pixel_10[19]<=sram_q[{counter[6:2],row,col}%4];
				pixel_10[27]<=sram_q[{counter[6:2],row,col}%4];

				pixel_10[5]<=sram_q[{counter[6:2],row,col+3'd1}%4];
        		pixel_10[13]<=sram_q[{counter[6:2],row,col+3'd1}%4];
        		pixel_10[20]<=sram_q[{counter[6:2],row,col+3'd1}%4];
        		pixel_10[28]<=sram_q[{counter[6:2],row,col+3'd1}%4];

                pixel_10[14]<=sram_q[{counter[6:2],row,col+3'd2}%4];
				pixel_10[29]<=sram_q[{counter[6:2],row,col+3'd2}%4];
				end
				else if(counter%4==3)begin
				pixel_10[6] <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				pixel_10[21] <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				pixel_10[7] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[15] <=sram_q[{counter[6:2],row+3'd1,col}%4];

				pixel_10[22] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[30] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[8]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[16]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];

				pixel_10[23]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[31]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[17]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				pixel_10[32]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				end
				else if(counter%4==0)begin
				pixel_10[24]<=sram_q[{counter[6:2],row+3'd2,col-3'd1}%4];
				pixel_10[25]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				pixel_10[33]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				pixel_10[26]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				pixel_10[34]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				pixel_10[35]<=sram_q[{counter[6:2],row+3'd2,col+3'd2}%4];
				end	

			end

			else if((row==0)&&(col!=0 && col!=6))begin
				pixel_10[0]<=0;
				pixel_10[1]<=0;
                pixel_10[9]<=0;
				pixel_10[2]<=0;
            	pixel_10[10]<=0;
				pixel_10[11]<=0;
				if(counter%4==1)begin
				pixel_10[3]<=sram_q[{counter[6:2],row,col-3'd1}%4];
				pixel_10[18]<=sram_q[{counter[6:2],row,col-3'd1}%4];

				pixel_10[4]<=sram_q[{counter[6:2],row,col}%4];
				pixel_10[12]<=sram_q[{counter[6:2],row,col}%4];
				pixel_10[19]<=sram_q[{counter[6:2],row,col}%4];
				pixel_10[27]<=sram_q[{counter[6:2],row,col}%4];

				pixel_10[5]<=sram_q[{counter[6:2],row,col+3'd1}%4];
                pixel_10[13]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[20]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[28]<=sram_q[{counter[6:2],row,col+3'd1}%4];

				pixel_10[14]<=sram_q[{counter[6:2],row,col+3'd2}%4];
				pixel_10[29]<=sram_q[{counter[6:2],row,col+3'd2}%4];
		

                end
				else if(counter%4==2)begin
				pixel_10[6] <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				pixel_10[21] <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];

				pixel_10[7] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[15] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[22] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[30] <=sram_q[{counter[6:2],row+3'd1,col}%4];

				pixel_10[8]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[16]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[23]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[31]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];

				pixel_10[17]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				pixel_10[32]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];

				end
				else if(counter%4==3)begin
				pixel_10[24]<=sram_q[{counter[6:2],row+3'd2,col-3'd1}%4];

				pixel_10[25]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				pixel_10[33]<=sram_q[{counter[6:2],row+3'd2,col}%4];

                pixel_10[26]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				pixel_10[34]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];

				pixel_10[35]<=sram_q[{counter[6:2],row+3'd2,col+3'd2}%4];
				end
			end

			else if(row!=0&& row!=6&&col==0)begin
				pixel_10[0]<=0;
                pixel_10[3]<=0;
                pixel_10[18]<=0;
                pixel_10[6]<=0;
                pixel_10[21]<=0;
                pixel_10[24]<=0;
				if(counter%4==1)begin
				pixel_10[1]<=sram_q[{counter[6:2],row-3'd1,col}%4];
				pixel_10[9]<=sram_q[{counter[6:2],row-3'd1,col}%4];

				pixel_10[2]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				pixel_10[10]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];

				pixel_10[11]<=sram_q[{counter[6:2],row-3'd1,col+3'd2}%4];
				end
				else if(counter%4==2)begin
				pixel_10[4]<=sram_q[{counter[6:2],row,col}%4];
				pixel_10[12]<=sram_q[{counter[6:2],row,col}%4];
				pixel_10[19]<=sram_q[{counter[6:2],row,col}%4];
				pixel_10[27]<=sram_q[{counter[6:2],row,col}%4];

				pixel_10[5]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[13]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[20]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[28]<=sram_q[{counter[6:2],row,col+3'd1}%4];

				pixel_10[14]<=sram_q[{counter[6:2],row,col+3'd2}%4];
				pixel_10[29]<=sram_q[{counter[6:2],row,col+3'd2}%4];
				end
				else if(counter%4==3)begin
				pixel_10[7] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[15] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[22] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[30] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[8]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[16]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[23]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[31]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[17]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				pixel_10[32]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				end
				else if(counter%4==0)begin
				pixel_10[25]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				pixel_10[33]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				pixel_10[26]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				pixel_10[34]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				pixel_10[35]<=sram_q[{counter[6:2],row+3'd2,col+3'd2}%4];
				end

			end
			else if((row!=0)&&(row!=6)&&(col==6))begin
				pixel_10[11]<=0;
				pixel_10[14]<=0;
				pixel_10[29]<=0;

				pixel_10[17]<=0;
				pixel_10[32]<=0;

				pixel_10[35]<=0;
				if(counter%4==1)begin
				pixel_10[0]<=sram_q[{counter[6:2],row-3'd1,col-3'd1}%4];
				pixel_10[1]<=sram_q[{counter[6:2],row-3'd1,col}%4];
				pixel_10[9]<=sram_q[{counter[6:2],row-3'd1,col}%4];
				pixel_10[2]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				pixel_10[10]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				end
				else if(counter%4==2)begin
				pixel_10[3]<=sram_q[{counter[6:2],row,col-3'd1}%4];
				pixel_10[18]<=sram_q[{counter[6:2],row,col-3'd1}%4];
				pixel_10[4]<=sram_q[{counter[6:2],row,col}%4];
				pixel_10[12]<=sram_q[{counter[6:2],row,col}%4];
				pixel_10[19]<=sram_q[{counter[6:2],row,col}%4];
				pixel_10[27]<=sram_q[{counter[6:2],row,col}%4];
				pixel_10[5]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[13]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[20]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[28]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				end
				else if(counter%4==3)begin
				pixel_10[6] <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				pixel_10[21] <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];

    			pixel_10[7]<=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[15]<=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[22]<=sram_q[{counter[6:2],row+3'd1,col}%4];            
				pixel_10[30]<=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[8]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[16]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[23]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[31]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				end
				else if(counter%4==0)begin
				pixel_10[24]<=sram_q[{counter[6:2],row+3'd2,col-3'd1}%4];
				pixel_10[25]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				pixel_10[33]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				pixel_10[26]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				pixel_10[34]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				end

			end

			else if((row==6)&&(col!=0 && col!=6))begin
				pixel_10[24]<=0;
				pixel_10[25]<=0;
				pixel_10[33]<=0;
				pixel_10[26]<=0;
				pixel_10[34]<=0;
				pixel_10[35]<=0;				
				if(counter%4==1)begin

				pixel_10[0]<=sram_q[{counter[6:2],row-3'd1,col-3'd1}%4];
				pixel_10[1]<=sram_q[{counter[6:2],row-3'd1,col}%4];
				pixel_10[9]<=sram_q[{counter[6:2],row-3'd1,col}%4];
				pixel_10[2]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				pixel_10[10]<=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				pixel_10[11]<=sram_q[{counter[6:2],row-3'd1,col+3'd2}%4];
				end
				else if(counter%4==2)begin
				pixel_10[3]<=sram_q[{counter[6:2],row,col-3'd1}%4];
				pixel_10[18]<=sram_q[{counter[6:2],row,col-3'd1}%4];
				pixel_10[4]<=sram_q[{counter[6:2],row,col}%4];
				pixel_10[12]<=sram_q[{counter[6:2],row,col}%4];
				pixel_10[19]<=sram_q[{counter[6:2],row,col}%4];
				pixel_10[27]<=sram_q[{counter[6:2],row,col}%4];
                pixel_10[5]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[13]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[20]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[28]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[14]<=sram_q[{counter[6:2],row,col+3'd2}%4];
				pixel_10[29]<=sram_q[{counter[6:2],row,col+3'd2}%4];

				end
				else if(counter%4==3)begin
				pixel_10[6]<=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				pixel_10[21]<=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				pixel_10[7]<=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[15]<=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[22]<=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[30]<=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[8]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[16]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[23]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[31]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[17]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				pixel_10[32]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];

				end
			end

			else if((row==0)&&(col==0)) begin
				pixel_10[0]<=0;
				pixel_10[1]<=0;
				pixel_10[9]<=0;
				pixel_10[2]<=0;
				pixel_10[10]<=0;
				pixel_10[11]<=0;
  				pixel_10[3]<=0;              
				pixel_10[18]<=0;
				pixel_10[6]<=0;
				pixel_10[21]<=0;
				pixel_10[24]<=0;

				if(counter%4==1)begin
				pixel_10[4]<=sram_q[{counter[6:2],row,col}%4];
				pixel_10[12]<=sram_q[{counter[6:2],row,col}%4];
				pixel_10[19]<=sram_q[{counter[6:2],row,col}%4];
				pixel_10[27]<=sram_q[{counter[6:2],row,col}%4];
				pixel_10[5]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[13]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[20]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[28]<=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[14]<=sram_q[{counter[6:2],row,col+3'd2}%4];
				pixel_10[29]<=sram_q[{counter[6:2],row,col+3'd2}%4];

				end
				else if(counter%4==2)begin
				pixel_10[7] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[15] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[22] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[30] <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[8]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[16]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[23]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[31]<=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[17]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				pixel_10[32]<=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				end
				else if(counter%4==3)begin
				pixel_10[25]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				pixel_10[33]<=sram_q[{counter[6:2],row+3'd2,col}%4];
				pixel_10[26]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				pixel_10[34]<=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];

				pixel_10[35]<=sram_q[{counter[6:2],row+3'd2,col+3'd2}%4];
				end

			end
			else if((row==6)&&(col==0)) begin
				pixel_10[0]<=0;
				pixel_10[3]<=0;
				pixel_10[18]<=0;
				pixel_10[6]<=0;
				pixel_10[21]<=0;

				pixel_10[24]<=0;
				pixel_10[25]<=0;
				pixel_10[33]<=0;
				pixel_10[26]<=0;
				pixel_10[34]<=0;
				pixel_10[35]<=0;
				if(counter%4==1)begin
				pixel_10[1] <=sram_q[{counter[6:2],row-3'd1,col}%4];
				pixel_10[9] <=sram_q[{counter[6:2],row-3'd1,col}%4];
				pixel_10[2] <=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				pixel_10[10] <=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				pixel_10[11] <=sram_q[{counter[6:2],row-3'd1,col+3'd2}%4];

				end
				else if(counter%4==2)begin
				pixel_10[4] <=sram_q[{counter[6:2],row,col}%4];
				pixel_10[12] <=sram_q[{counter[6:2],row,col}%4];
				pixel_10[19] <=sram_q[{counter[6:2],row,col}%4];
				pixel_10[27] <=sram_q[{counter[6:2],row,col}%4];
				pixel_10[5] <=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[13] <=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[20] <=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[28] <=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[14] <=sram_q[{counter[6:2],row,col+3'd2}%4];
				pixel_10[29] <=sram_q[{counter[6:2],row,col+3'd2}%4];

				end
				else if(counter%4==3)begin
				pixel_10[7]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[15]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[22]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[30]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
                pixel_10[8] <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[16] <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[23] <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[31] <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[17] <=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				pixel_10[32] <=sram_q[{counter[6:2],row+3'd1,col+3'd2}%4];
				end

			end

			else if((row==6)&&(col==6)) begin
				pixel_10[11]<=0;
				pixel_10[14]<=0;
				pixel_10[29]<=0;
				pixel_10[17]<=0;
				pixel_10[32]<=0;
				pixel_10[24]<=0;
                pixel_10[25]<=0;
				pixel_10[33]<=0;
				pixel_10[26]<=0;
				pixel_10[34]<=0;
				pixel_10[35]<=0;
				if(counter%4==1)begin
				pixel_10[0]  <=sram_q[{counter[6:2],row-3'd1,col-3'd1}%4];
				pixel_10[1]  <=sram_q[{counter[6:2],row-3'd1,col}%4];
				pixel_10[9]  <=sram_q[{counter[6:2],row-3'd1,col}%4];
				pixel_10[2]  <=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];
				pixel_10[10]  <=sram_q[{counter[6:2],row-3'd1,col+3'd1}%4];

				end
				else if(counter%4==2)begin
				pixel_10[3]  <=sram_q[{counter[6:2],row,col-3'd1}%4];
				pixel_10[18]  <=sram_q[{counter[6:2],row,col-3'd1}%4];
				pixel_10[4]  <=sram_q[{counter[6:2],row,col}%4];
				pixel_10[12]  <=sram_q[{counter[6:2],row,col}%4];
				pixel_10[19]  <=sram_q[{counter[6:2],row,col}%4];
				pixel_10[27]  <=sram_q[{counter[6:2],row,col}%4];
				pixel_10[5]  <=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[13]  <=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[20]  <=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[28]  <=sram_q[{counter[6:2],row,col+3'd1}%4];
				end
				else if(counter%4==3)begin
				pixel_10[6]  <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
    			pixel_10[21]  <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				pixel_10[7]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[15]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[22]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[30]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[8]  <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[16]  <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[23]  <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[31]  <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				end
			end



			else if((row==0)&&(col==6)) begin
				pixel_10[0]<=0;
				pixel_10[1]<=0;
				pixel_10[9]<=0;
				pixel_10[2]<=0;
				pixel_10[10]<=0;
				pixel_10[11]<=0;
				pixel_10[14]<=0;
				pixel_10[29]<=0;
				pixel_10[17]<=0;
				pixel_10[32]<=0;
				pixel_10[35]<=0;

				if(counter%4==1)begin
				pixel_10[3]  <=sram_q[{counter[6:2],row,col-3'd1}%4];
				pixel_10[18]  <=sram_q[{counter[6:2],row,col-3'd1}%4];

				pixel_10[4]  <=sram_q[{counter[6:2],row,col}%4];
				pixel_10[12]  <=sram_q[{counter[6:2],row,col}%4];
				pixel_10[19]  <=sram_q[{counter[6:2],row,col}%4];
				pixel_10[27]  <=sram_q[{counter[6:2],row,col}%4];
				pixel_10[5]  <=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[13]  <=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[20]  <=sram_q[{counter[6:2],row,col+3'd1}%4];
				pixel_10[28]  <=sram_q[{counter[6:2],row,col+3'd1}%4];

				end
				else if(counter%4==2)begin
				pixel_10[6]  <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				pixel_10[21]  <=sram_q[{counter[6:2],row+3'd1,col-3'd1}%4];
				pixel_10[7]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[15]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[22]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[30]  <=sram_q[{counter[6:2],row+3'd1,col}%4];
				pixel_10[8] <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[16] <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[23] <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];
				pixel_10[31] <=sram_q[{counter[6:2],row+3'd1,col+3'd1}%4];

				end
				else if(counter%4==3)begin
				pixel_10[24] <=sram_q[{counter[6:2],row+3'd2,col-3'd1}%4];
				pixel_10[25] <=sram_q[{counter[6:2],row+3'd2,col}%4];
				pixel_10[33] <=sram_q[{counter[6:2],row+3'd2,col}%4];
				pixel_10[26] <=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				pixel_10[34] <=sram_q[{counter[6:2],row+3'd2,col+3'd1}%4];
				end
			end

		end
	
		else
			o_op_ready_r <=0;
			//o_out_valid_r<=0;
	end
end
//FSM
always@(posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n) begin
		state	<=INIT;
	end 
	else begin
		state	<= n_state;
	end
end
//counter
always@(posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n)	begin	
		counter	<=0;
		counter2<=0;
		flag<=0;
	end
	else if(state==IDLE)	begin
		flag<=0;
		counter2<=0;
		counter<=0;
	end
	else if(state==LOAD&&o_in_ready_r&&flag==0)	begin
		counter	<=0;
		flag<=1;
	end
	else if(state==LOAD&&o_in_ready_r&&flag==1)	
		counter	<=counter+1;
	else if(state==DISPLAY)	begin
		counter	<=counter+1;
		flag<=0;

	end

	else if(state==CONVOLUTION && counter==4*(channel_size)+1)begin
		counter	<=0;
	end
	// else if(state==CONVOLUTION_out&&flag==0)	begin
	// 	counter	<=0;
	// 	flag<=1;
	// end
	else if(state==CONVOLUTION_out)	
		counter	<=counter+1;
	else if(state==CONVOLUTION)	
		counter	<=counter+1;


//SOBEL
	else if(state==SOBEL_out &&counter==20)	begin
		counter2	<=0;
		counter<=0;
	end
	else if(state==SOBEL_out &&counter2==5)	begin
		counter2	<=0;
		counter<=counter-1;
	end

	else if(state==SOBEL_out)	
		counter2<=counter2+1;




	else if(state==SOBEL && counter%4==0 && counter>1 &&counter2==1)begin
		counter2<=0;
		flag<=1;

	end
	else if(state==SOBEL && counter%4==0 && counter>1)begin
		counter2<=counter2+1;
		counter<=counter+1;
				flag<=1;
	end
	else if(state==SOBEL)
		counter<=counter+1;



// median filter
	else if(state==MEDIANFILTER && counter==11'd17)begin
		counter	<=0;
	end

	else if(state==MEDIANFILTER && counter%4==0 && counter>1 &&counter2==1)begin
		counter2<=0;
		flag<=1;

	end
	else if(state==MEDIANFILTER && counter%4==0 && counter>1)begin
		counter2<=counter2+1;
		counter<=counter+1;
				flag<=1;

	end
	else if(state==MEDIANFILTER)
		counter<=counter+1;
	// else if(state==MEDIAN_out &&counter2==6 &&counter3==4)	begin
	// 	counter2	<=counter2+1;
	// 	counter<=counter-2;
	// 	flag<=0;
	// end
	else if(state==MEDIAN_out &&counter2==4)	begin
		counter2	<=0;
		counter<=counter-1;
	end
	// else if(state==MEDIAN_out &&counter2==3)	begin
	// 	counter2	<=0;

	// end
	else if(state==MEDIAN_out)	
		counter2	<=counter2+1;
	// else if(state==MEDIANFILTER && counter2!=5)	begin
	// 	counter	<=counter+1;
	// 	counter2<=counter2+1;
	// 	counter3<=0;
	// end


	else 
		counter <=0;
end
//conv
always@(posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n)	begin	
		conv_image[0]	<= 0;
		conv_image[1]	<= 0;
		conv_image[2]	<= 0;
		conv_image[3]	<= 0;
	end
	else if(state==IDLE)begin
		conv_image[0]	<= 0;
		conv_image[1]	<= 0;
		conv_image[2]	<= 0;
		conv_image[3]	<= 0;
	end
	else if(state==CONVOLUTION && counter%4==1 && counter>=4)	begin
		if(($signed(row-1)>=0)&&($signed(row+2)<=7)&&($signed(col-1)>=0)&&($signed(col+2)<=7))begin
			conv_image[0]<=conv_image[0]+(pixel[0]<<0)+(pixel[1]<<1)+(pixel[2]<<0)+(pixel[4]<<1)+(pixel[5]<<2)+(pixel[6]<<1)+(pixel[8]<<0)+(pixel[9]<<1)+(pixel[10]<<0);
			conv_image[1]<=conv_image[1]+(pixel[1]<<0)+(pixel[2]<<1)+(pixel[3]<<0)+(pixel[5]<<1)+(pixel[6]<<2)+(pixel[7]<<1)+(pixel[9]<<0)+(pixel[10]<<1)+(pixel[11]<<0);
			conv_image[2]<=conv_image[2]+(pixel[4]<<0)+(pixel[5]<<1)+(pixel[6]<<0)+(pixel[8]<<1)+(pixel[9]<<2)+(pixel[10]<<1)+(pixel[12]<<0)+(pixel[13]<<1)+(pixel[14]<<0);
			conv_image[3]<=conv_image[3]+(pixel[5]<<0)+(pixel[6]<<1)+(pixel[7]<<0)+(pixel[9]<<1)+(pixel[10]<<2)+(pixel[11]<<1)+(pixel[13]<<0)+(pixel[14]<<1)+(pixel[15]<<0);

		end
		else if((row==0)&&(col!=0 && col!=6))begin
			conv_image[0]<=conv_image[0]+(pixel[4]<<1)+(pixel[5]<<2)+(pixel[6]<<1)+(pixel[8]<<0)+(pixel[9] <<1)+(pixel[10]<<0);
			conv_image[1]<=conv_image[1]+(pixel[5]<<1)+(pixel[6]<<2)+(pixel[7]<<1)+(pixel[9]<<0)+(pixel[10]<<1)+(pixel[11]<<0);
			conv_image[2]<=conv_image[2]+(pixel[4]<<0)+(pixel[5]<<1)+(pixel[6]<<0)+(pixel[8]<<1)+(pixel[9]<<2) +(pixel[10]<<1)+(pixel[12]<<0)+(pixel[13]<<1)+(pixel[14]<<0);
			conv_image[3]<=conv_image[3]+(pixel[5]<<0)+(pixel[6]<<1)+(pixel[7]<<0)+(pixel[9]<<1)+(pixel[10]<<2)+(pixel[11]<<1)+(pixel[13]<<0)+(pixel[14]<<1)+(pixel[15]<<0);			
		end
//
		else if((row==6)&&(col!=0 && col!=6))begin
			conv_image[0]<=conv_image[0]+(pixel[0]<<0)+(pixel[1]<<1)+(pixel[2]<<0)+(pixel[4]<<1)+(pixel[5]<<2)+(pixel[6]<<1)+(pixel[8]<<0)+(pixel[9]<<1)+(pixel[10]<<0);
			conv_image[1]<=conv_image[1]+(pixel[1]<<0)+(pixel[2]<<1)+(pixel[3]<<0)+(pixel[5]<<1)+(pixel[6]<<2)+(pixel[7]<<1)+(pixel[9]<<0)+(pixel[10]<<1)+(pixel[11]<<0);
			conv_image[2]<=conv_image[2]+(pixel[4]<<0)+(pixel[5]<<1)+(pixel[6]<<0)+(pixel[8]<<1)+(pixel[9]<<2)+(pixel[10]<<1);
			conv_image[3]<=conv_image[3]+(pixel[5]<<0)+(pixel[6]<<1)+(pixel[7]<<0)+(pixel[9]<<1)+(pixel[10]<<2)+(pixel[11]<<1);		
		end		

		else if((row==0)&&(col==0))begin
			conv_image[0]<=conv_image[0]+(pixel[5]<<2)+(pixel[6]<<1)+(pixel[9]<<1)+(pixel[10]<<0);
			conv_image[1]<=conv_image[1]+(pixel[5]<<1)+(pixel[6]<<2)+(pixel[7]<<1)+(pixel[9]<<0)+(pixel[10]<<1)+(pixel[11]<<0);
			conv_image[2]<=conv_image[2]+(pixel[5]<<1)+(pixel[6]<<0)+(pixel[9]<<2)+(pixel[10]<<1)+(pixel[13]<<1)+(pixel[14]<<0);
			conv_image[3]<=conv_image[3]+(pixel[5]<<0)+(pixel[6]<<1)+(pixel[7]<<0)+(pixel[9]<<1)+(pixel[10]<<2)+(pixel[11]<<1)+(pixel[13]<<0)+(pixel[14]<<1)+(pixel[15]<<0);	
		end
//
		else if((row==0)&&(col==6))begin
			conv_image[0]<=conv_image[0]+(pixel[4]<<1)+(pixel[5]<<2)+(pixel[6]<<1)+(pixel[8]<<0)+(pixel[9]<<1)+(pixel[10]<<0);
			conv_image[1]<=conv_image[1]+(pixel[5]<<1)+(pixel[6]<<2)+(pixel[9]<<0)+(pixel[10]<<1);
			conv_image[2]<=conv_image[2]+(pixel[4]<<0)+(pixel[5]<<1)+(pixel[6]<<0)+(pixel[8]<<1)+(pixel[9]<<2)+(pixel[10]<<1)+(pixel[12]<<0)+(pixel[13]<<1)+(pixel[14]<<0);
			conv_image[3]<=conv_image[3]+(pixel[5]<<0)+(pixel[6]<<1)+(pixel[9]<<1)+(pixel[10]<<2)+(pixel[13]<<0)+(pixel[14]<<1);			
		end
//
		else if((row==6)&&(col==0))begin
			conv_image[0]<=conv_image[0]+(pixel[1]<<1)+(pixel[2]<<0)+(pixel[5]<<2)+(pixel[6]<<1)+(pixel[9]<<1)+(pixel[10]<<0);
			conv_image[1]<=conv_image[1]+(pixel[1]<<0)+(pixel[2]<<1)+(pixel[3]<<0)+(pixel[5]<<1)+(pixel[6]<<2)+(pixel[7]<<1)+(pixel[9]<<0)+(pixel[10]<<1)+(pixel[11]<<0);
			conv_image[2]<=conv_image[2]+(pixel[5]<<1)+(pixel[6]<<0)+(pixel[9]<<2)+(pixel[10]<<1);
			conv_image[3]<=conv_image[3]+(pixel[5]<<0)+(pixel[6]<<1)+(pixel[7]<<0)+(pixel[9]<<1)+(pixel[10]<<2)+(pixel[11]<<1);	
		end
//
		else if((row==6)&&(col==6))begin
			conv_image[0]<=conv_image[0]+(pixel[0]<<0)+(pixel[1]<<1)+(pixel[2]<<0)+(pixel[4]<<1)+(pixel[5]<<2)+(pixel[6]<<1)+(pixel[8]<<0)+(pixel[9]<<1)+(pixel[10]<<0);
			conv_image[1]<=conv_image[1]+(pixel[1]<<0)+(pixel[2]<<1)+(pixel[5]<<1)+(pixel[6]<<2)+(pixel[9]<<0)+(pixel[10]<<1);
			conv_image[2]<=conv_image[2]+(pixel[4]<<0)+(pixel[5]<<1)+(pixel[6]<<0)+(pixel[8]<<1)+(pixel[9]<<2)+(pixel[10]<<1);
			conv_image[3]<=conv_image[3]+(pixel[5]<<0)+(pixel[6]<<1)+(pixel[9]<<1)+(pixel[10]<<2);		
		end
		else if(row!=0&& row!=6&&col==0)begin
			conv_image[0]<=conv_image[0]+(pixel[1]<<1)+(pixel[2]<<0)+(pixel[5]<<2)+(pixel[6]<<1)+(pixel[9]<<1)+(pixel[10]<<0);
			conv_image[1]<=conv_image[1]+(pixel[1]<<0)+(pixel[2]<<1)+(pixel[3]<<0)+(pixel[5]<<1)+(pixel[6]<<2)+(pixel[7]<<1)+(pixel[9]<<0)+(pixel[10]<<1)+(pixel[11]<<0);
			conv_image[2]<=conv_image[2]+(pixel[5]<<1)+(pixel[6]<<0)+(pixel[9]<<2)+(pixel[10]<<1)+(pixel[13]<<1)+(pixel[14]<<0);
			conv_image[3]<=conv_image[3]+(pixel[5]<<0)+(pixel[6]<<1)+(pixel[7]<<0)+(pixel[9]<<1)+(pixel[10]<<2)+(pixel[11]<<1)+(pixel[13]<<0)+(pixel[14]<<1)+(pixel[15]<<0);		
		end		
//
		else if(row!=0&& row!=6&&col==6)begin
			conv_image[0]<=conv_image[0]+(pixel[0]<<0)+(pixel[1]<<1)+(pixel[2]<<0)+(pixel[4]<<1)+(pixel[5]<<2)+(pixel[6]<<1)+(pixel[8]<<0)+(pixel[9]<<1)+(pixel[10]<<0);
			conv_image[1]<=conv_image[1]+(pixel[1]<<0)+(pixel[2]<<1)+(pixel[5]<<1)+(pixel[6]<<2)+(pixel[9]<<0)+(pixel[10]<<1);
			conv_image[2]<=conv_image[2]+(pixel[4]<<0)+(pixel[5]<<1)+(pixel[6]<<0)+(pixel[8]<<1)+(pixel[9]<<2)+(pixel[10]<<1)+(pixel[12]<<0)+(pixel[13]<<1)+(pixel[14]<<0);
			conv_image[3]<=conv_image[3]+(pixel[5]<<0)+(pixel[6]<<1)+(pixel[9]<<1)+(pixel[10]<<2)+(pixel[13]<<0)+(pixel[14]<<1);		
		end		



	end

end
// channel up or down
always@(posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n)	begin	
		channel_size	<= 32;
	end
	else if(state==RESIZE && channel_size==32 &&op_mode_r==OP_DOWN_CHANNEL)	begin	
		channel_size	<= 16;
	end
	else if(state==RESIZE && channel_size==16 &&op_mode_r==OP_DOWN_CHANNEL)	begin	
		channel_size	<= 8;
	end
	else if(state==RESIZE && channel_size==8 &&op_mode_r==OP_UP_CHANNEL)	begin	
		channel_size	<= 16;
	end
	else if(state==RESIZE && channel_size==16 &&op_mode_r==OP_UP_CHANNEL)	begin	
		channel_size	<= 32;
	end
end

// 定義排序 function
function [23:0] sort3;
	input [7:0] a, b, c;
	reg [7:0] min, mid, max;
	begin
		min=a;
		mid=b;
		max=c;
		if ((a <= b) && (b <= c)) begin
			min = a;
			mid = b;
			max = c;
		end
		else if ((a <= c) && (c <= b)) begin
			min = a;
			mid = c;
			max = b;
		end
		else if ((b <= a) && (a <= c)) begin
			min = b;
			mid = a;
			max = c;
		end
		else if ((b <= c) && (c <= a)) begin
			min = b;
			mid = c;
			max = a;
		end
		else if ((c <= a) && (a <= b)) begin
			min = c;
			mid = a;
			max = b;
		end
		else if ((c <= b) && (b <= a)) begin
			min = c;
			mid = b;
			max = a;
		end
		sort3 = {min, mid, max};
	end
endfunction


endmodule

