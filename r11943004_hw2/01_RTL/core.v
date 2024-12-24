module core #( // DO NOT MODIFY INTERFACE!!!
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
) ( 
    input i_clk,
    input i_rst_n,

    // Testbench IOs
    output [2:0] o_status, 
    output       o_status_valid,

    // Memory IOs
    output [ADDR_WIDTH-1:0] o_addr,
    output [DATA_WIDTH-1:0] o_wdata,
    output                  o_we,
    input  [DATA_WIDTH-1:0] i_rdata
);
`include "../00_TB/define.v"
// ---------------------------------------------------------------------------
// Wires and Registers
// ---------------------------------------------------------------------------
// ---- Add your own wires and registers here if needed ---- //
//Register_File
parameter INIT  = 3'd0;
parameter IDLE  = 3'd1;
parameter IF    = 3'd2;
parameter ID    = 3'd3;
parameter EX    = 3'd4;
parameter WB    = 3'd5;
parameter PROCESS_END    = 3'd6;

// parameter R_TYPE_SUCCESS  = 3'd0;
// parameter I_TYPE_SUCCESS  = 3'd1;
// parameter S_TYPE_SUCCESS  = 3'd2;
// parameter B_TYPE_SUCCESS  = 3'd3;
// parameter INVALID_TYPE    = 3'd4;
// parameter EOF_TYPE        = 3'd5;


reg  [DATA_WIDTH-1:0] Register_file [0:ADDR_WIDTH-1];
reg  [DATA_WIDTH-1:0] Register_file_FP32 [0:ADDR_WIDTH-1];

reg  [DATA_WIDTH-1:0]RegisterData1,RegisterData2,RegisterData1_FP,RegisterData2_FP;
wire [DATA_WIDTH-1:0]Register_Write_data;
reg  [DATA_WIDTH-1:0]store_address;
reg  [ADDR_WIDTH-1:0]pc;
wire signed [DATA_WIDTH-1:0]ALU_data1,ALU_data2;
reg  signed [DATA_WIDTH-1:0]alu_result;
wire [DATA_WIDTH-1:0] Inst;





reg  signed [DATA_WIDTH:0]  alu_result_33;





wire  [6:0] opcode;
reg   [6:0]opcode_r;
wire  [4:0]WriteRegister_addr,ReadRegister1_addr,ReadRegister2_addr,ReadRegister1_addrFP,ReadRegister2_addrFP;
reg   [4:0]count;
reg   [7:0]count2;
reg [2:0] o_status_r,o_status_w;
reg [2:0] state, n_state;


reg [3:0] ALUsrc;

reg o_status_valid_r;
reg instaddr_Overflow,data_Overflow,MemWrite,EOF,alu_branch,MemtoReg,RegWrite,RegWrite_FP32,FP_Reg;
reg R_type,I_type,S_type,B_type,INVALID_type,EOF_type;

integer i;
reg flag;
reg [31:0]Inst_r;
reg [278:0]mantissa_a,mantissa_b;
reg [279:0]mantissa_sum,mantissa_sum2;
reg [23:0]mantissa_round,mantissa_sum_24,mantissa_temp;
reg [22:0]mantissa,mantissa_23;
reg signed[8:0]exponentDiff;
reg [7:0]exponent,exponent_b;
reg mantissa_sum_overflow,carry_out;
reg [3:0]TEST;
always@(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        RegisterData1<=0;
        RegisterData2<=0;
        for (i = 0; i < ADDR_WIDTH; i = i + 1) 
            Register_file[i] <= 0;
    end
    else begin
        if (RegWrite) begin
            Register_file[WriteRegister_addr] <= Register_Write_data;
        end
        else 
             RegisterData1<= Register_file[ReadRegister1_addr];
             RegisterData2<= Register_file[ReadRegister2_addr];
    end       
end
always@(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
         RegisterData1_FP <= 0;
         RegisterData2_FP <= 0;
        for (i = 0; i < ADDR_WIDTH; i = i + 1) 
            Register_file_FP32[i] <= 0;
    end
    else begin
        if (RegWrite_FP32) begin
            Register_file_FP32[WriteRegister_addr] <= Register_Write_data;
        end
        else 
             RegisterData1_FP<= Register_file_FP32[ReadRegister1_addrFP];
             RegisterData2_FP<= Register_file_FP32[ReadRegister2_addrFP];
    end       
end
// ---------------------------------------------------------------------------
// Continuous Assignment
// ---------------------------------------------------------------------------
// ---- Add your own wire data assignments here if needed ---- //

// assign o_wdata=RegisterData2;
// assign o_addr=pc;
assign o_wdata=(state==WB && (opcode_r==`OP_FSW))?RegisterData2_FP:RegisterData2;
assign o_addr=(state==WB && (opcode_r==`OP_SW || opcode_r==`OP_FSW))?store_address:(state==EX &&(opcode==`OP_LW || opcode==`OP_FLW))?alu_result:pc;
assign o_we=MemWrite;
assign Register_Write_data=(MemtoReg)?i_rdata:alu_result;


assign o_status= o_status_r;
assign o_status_valid=o_status_valid_r;

assign opcode            =Inst[6:0];
assign ReadRegister1_addr=Inst[19:15];
assign ReadRegister2_addr=Inst[24:20];
assign ReadRegister1_addrFP=Inst[19:15];
assign ReadRegister2_addrFP=Inst[24:20];
assign WriteRegister_addr=(opcode_r==`OP_LW ||opcode_r==`OP_FLW )?Inst_r[11:7]:Inst[11:7];
assign Inst=i_rdata;
assign ALU_data1=FP_Reg?RegisterData1_FP:RegisterData1;

assign ALU_data2=(ALUsrc==4'b1000)?RegisterData2:
                (ALUsrc ==4'b0100)?{{20{Inst[31]}}, Inst[31:20]}:
                (ALUsrc ==4'b0010)?{{20{Inst[31]}}, Inst[31:25], Inst[11:7]}:
                {{20{Inst[31]}}, Inst[7], Inst[30:25], Inst[11:8], 1'b0};

// ---------------------------------------------------------------------------
// Combinational Blocks
// ---------------------------------------------------------------------------
// ---- Write your conbinational block design here ---- //
always@(*) begin
    case(state)
        INIT:        n_state =IDLE;
        IDLE:        n_state = IF;
        IF:          n_state = (data_Overflow|instaddr_Overflow)?PROCESS_END:ID;
        ID:          n_state = (instaddr_Overflow)?PROCESS_END:EX; 
        EX:          n_state = (data_Overflow|EOF)?PROCESS_END:WB;
        WB:          n_state = IF;
        PROCESS_END: n_state = PROCESS_END;  
        default:n_state = INIT;
    endcase
end

always@(*)begin
    flag=0;
    instaddr_Overflow=0;
    data_Overflow=0;
    RegWrite=0;
    RegWrite_FP32=0;
    MemtoReg=0;
    alu_branch=0;
    EOF=0;
    I_type=0;
    count=0;
    ALUsrc=0;
    TEST=0;
    alu_result=0;
        FP_Reg=0;
        count2=0;
        R_type=0;
        S_type=0;
        B_type=0;
    if(|pc[31:12]==1)   begin //instuction address out of bound
        instaddr_Overflow=1;
        o_status_w=`INVALID_TYPE;
    end
    else if(state==EX)begin
        
        FP_Reg     =((opcode==`OP_FLT)&&({Inst[31:25],Inst[14:12]}== {`FUNCT7_FLT,`FUNCT3_FLT}))|((opcode==`OP_FCLASS)&&({Inst[31:25],Inst[14:12]}== {`FUNCT7_FCLASS,`FUNCT3_FCLASS}))|((opcode==`OP_FADD)&&({Inst[31:25],Inst[14:12]}== {`FUNCT7_FADD,`FUNCT3_FADD}))|((opcode==`OP_FSUB)&&({Inst[31:25],Inst[14:12]}=={`FUNCT7_FSUB,`FUNCT3_FSUB}));
        R_type     =(opcode==`OP_ADD)|(opcode==`OP_SUB)|(opcode==`OP_SLT)|(opcode==`OP_SLL)|(opcode==`OP_SRL)|(opcode==`OP_FADD)|(opcode==`OP_FSUB)|(opcode==`OP_FCLASS)|(opcode==`OP_FLT);
        I_type     =(opcode==`OP_ADDI)|(opcode==`OP_LW)|(opcode==`OP_FLW);
        S_type     =(opcode==`OP_SW)|(opcode==`OP_FSW);
        B_type     =(opcode==`OP_BEQ)|(opcode==`OP_BLT);
        EOF        =(opcode==`OP_EOF); 

        ALUsrc={R_type,I_type,S_type,B_type};
        mantissa_sum_24=0;
        mantissa_a=0;
        mantissa_b=0;
        mantissa_sum=0;
        mantissa_sum2=0;
        mantissa_temp=0;
        mantissa_round=0;
        mantissa=0;
        mantissa_sum_overflow=0;
        exponent=0;
        data_Overflow=0;
        MemtoReg=0;
        RegWrite=0;
        alu_branch=0;
        exponentDiff=0;

        case(ALUsrc)
        4'b1000:begin

            if (opcode==7'b0110011)begin
            case({Inst[31:25],Inst[14:12]})
            {`FUNCT7_ADD,`FUNCT3_ADD}: begin
                alu_result_33 = ALU_data1+ALU_data2;
                data_Overflow = alu_result_33[32]^alu_result_33[31];
                alu_result =alu_result_33[31:0]; //正+正的溢位 or 負+負的溢位
                RegWrite=1;
            end
            {`FUNCT7_SUB,`FUNCT3_SUB}: begin
                alu_result_33 = ALU_data1-ALU_data2;
                data_Overflow = alu_result_33[32]^alu_result_33[31];
                alu_result=alu_result_33[31:0];
                RegWrite=1;
            end

            {`FUNCT7_SLT,`FUNCT3_SLT}: begin 
                RegWrite=1;
                if(ALU_data1<ALU_data2)begin
                alu_result=1;
                end
                else 
                alu_result=0;
            end
            {`FUNCT7_SLL,`FUNCT3_SLL}: begin 
                RegWrite=1;
                alu_result = RegisterData1<<$unsigned(RegisterData2);
            end
            {`FUNCT7_SRL,`FUNCT3_SRL}: begin 
                RegWrite=1;
                alu_result = RegisterData1>>$unsigned(RegisterData2);
            end
            default:alu_result=0;
            endcase
            end

            else if(opcode==7'b1010011)begin
                case({Inst[31:25],Inst[14:12]})
                {`FUNCT7_FADD, `FUNCT3_FADD}: begin
                    if ((ALU_data1[31] == 1 && ALU_data1[30:23] == 8'd255 && ALU_data1[22:0] == 23'd0) || 
                        (RegisterData2_FP[31] == 1 && RegisterData2_FP[30:23] == 8'd255 && RegisterData2_FP[22:0] == 23'd0)) begin
                        data_Overflow = 1;
                    end else if ((ALU_data1[31] == 0 && ALU_data1[30:23] == 8'd255 && ALU_data1[22:0] == 23'd0) || 
                                (RegisterData2_FP[31] == 0 && RegisterData2_FP[30:23] == 8'd255 && RegisterData2_FP[22:0] == 23'd0)) begin
                        data_Overflow = 1;
                    end else if ((ALU_data1[30:23] == 8'd255 && ALU_data1[22:0] != 23'd0) || 
                                (RegisterData2_FP[30:23] == 8'd255 && RegisterData2_FP[22:0] != 23'd0)) begin
                        data_Overflow = 1;
                    end else begin
                        data_Overflow = 0;
                    end

                    RegWrite_FP32 = 1;
                    
                    if (ALU_data1[30:23] != RegisterData2_FP[30:23]) begin
                        mantissa_a = {ALU_data1[22:0], 256'd0};
                        mantissa_b = {RegisterData2_FP[22:0], 256'd0};
                        exponentDiff = ALU_data1[30:23] - RegisterData2_FP[30:23];
                        
                        if (exponentDiff > 0) begin
                            mantissa_b = {1'b1, RegisterData2_FP[22:0], 255'd0}; // 對齊較小指數
                            mantissa_b = mantissa_b >> (exponentDiff - 1);
                                if(RegisterData2_FP[30:23]==0) begin//subnormal-normal
                                    mantissa_b = {1'b0, RegisterData2_FP[22:0], 255'd0}; // 對齊較小指數
                                    mantissa_b = mantissa_b >> (exponentDiff - 2);
                                end
                            if (ALU_data1[31] == RegisterData2_FP[31]) begin // 同號，尾數相加
                                mantissa_sum = mantissa_a + mantissa_b;
                                carry_out = mantissa_sum[279];

                                if (carry_out) begin
                                    mantissa_sum[279] = 0;
                                    mantissa_sum2 = mantissa_sum >> 1;
                                end else begin
                                    mantissa_sum2 = mantissa_sum;
                                end
                                mantissa_round = (mantissa_sum2[255] == 1 && |mantissa_sum2[254:0] == 1||(mantissa_sum2[256] == 1 &&mantissa_sum2[255] == 1))? mantissa_sum2[278:256]+1:{1'b0,mantissa_sum2[278:256]}; // 進位處理
                                mantissa_sum_overflow = mantissa_round[23];
                                exponent =  (mantissa_sum2[255] == 1 && |mantissa_sum2[254:0] == 1||(mantissa_sum2[256] == 1 &&mantissa_sum2[255] == 1))?ALU_data1[30:23] + carry_out + mantissa_sum_overflow:ALU_data1[30:23] + carry_out; // 更新指數
                                mantissa = (mantissa_sum2[255] == 1 && |mantissa_sum2[254:0] == 1||(mantissa_sum2[256] == 1 &&mantissa_sum2[255] == 1)) ? mantissa_round : mantissa_sum2[278:256];



 
                                    if(ALU_data1[30:23]==1 &&RegisterData2_FP[30:23]==0) begin//normal+subnormal special case
                                        mantissa_a = {1'b1 ,ALU_data1[22:0],        255'd0};
                                        mantissa_b = {1'b0 ,RegisterData2_FP[22:0], 255'd0};
                                        mantissa_sum2 = mantissa_a + mantissa_b; // 尾數相加
                                        mantissa_sum_24 = mantissa_sum2[279:256];
                                        carry_out=mantissa_sum2[279];
                                        if(carry_out)begin
                                            mantissa_sum=mantissa_sum2>>1;
                                            mantissa_round = (mantissa_sum[254] == 1 && |mantissa_sum[253:0] == 1||(mantissa_sum[255] == 1 &&mantissa_sum[254] == 1)) ? mantissa_sum[277:255] +1 :{1'b0,mantissa_sum[277:255]};

                                        
                                        end
                                        else                                                                                
                                            mantissa_round = (mantissa_sum2[254] == 1 && |mantissa_sum2[253:0] == 1||(mantissa_sum2[255] == 1 &&mantissa_sum2[254] == 1)) ? mantissa_sum2[277:255] +1 :{1'b0,mantissa_sum2[277:255]};



                                        mantissa_sum_overflow = mantissa_round[23];

                                        exponent = (mantissa_sum2[254] == 1 && |mantissa_sum2[253:0] == 1||(mantissa_sum2[255] == 1 &&mantissa_sum2[254] == 1)) ? ALU_data1[30:23] + carry_out + mantissa_sum_overflow:ALU_data1[30:23] + carry_out;
                                        mantissa = mantissa_round[22:0] ;

                                       

                                    end
                        



                                alu_result = {ALU_data1[31], exponent, mantissa};
                            end else begin // 異號，尾數相減
                                mantissa_sum2 = {1'b1, mantissa_a} - {1'b0, mantissa_b};
                                mantissa_sum_24 = mantissa_sum2[279:256]; // 前 24 位
                                count = count_leading_zeros24(mantissa_sum_24); // 找出前導零
                                count2 = count_leading_zeros24(mantissa_sum_24);
                                if (ALU_data1[30:23]<=count2)begin
                                    if((count2-ALU_data1[30:23])==0)
                                        count=1;
                                    else
                                        count=ALU_data1[30:23]-1;
                                    flag=1;
                                end
                                mantissa_sum = mantissa_sum2 << count;
                                mantissa_round = (mantissa_sum[255] == 1 && |mantissa_sum[254:0] == 1||(mantissa_sum[256] == 1 &&mantissa_sum[255] == 1)) ?mantissa_sum[278:256] +1:{1'b0,mantissa_sum[278:256]}; // 進位處理
                                mantissa_sum_overflow = mantissa_round[23];
                                exponent = (mantissa_sum[255] == 1 && |mantissa_sum[254:0] == 1||(mantissa_sum[256] == 1 &&mantissa_sum[255] == 1)) ?ALU_data1[30:23] - count + mantissa_sum_overflow:ALU_data1[30:23] - count ; // 更新指數
                                if(flag &&(count2-ALU_data1[30:23])>=1)
                                    exponent=1;
                                if(flag &&(count2-ALU_data1[30:23])>=0)
                                    exponent=0;
                                mantissa = (mantissa_sum[255] == 1 && |mantissa_sum[254:0] == 1||(mantissa_sum[256] == 1 &&mantissa_sum[255] == 1)) ? mantissa_round : mantissa_sum[278:256];
                                    if(ALU_data1[30:23]==1 &&RegisterData2_FP[30:23]==0) begin//normal-subnormal special case
                                        mantissa_b = {1'b0 ,RegisterData2_FP[22:0],255'd0};
                                        mantissa_a = {1'b1 ,ALU_data1[22:0], 255'd0};
                                        mantissa_sum2 = mantissa_a-mantissa_b; // 尾數相減
                                        mantissa = mantissa_sum2[277:255];
                                        exponent = (RegisterData2_FP[22:0]>ALU_data1[22:0])?0:1;
                                        if (RegisterData2_FP[22:0]==0 && ALU_data1[22:0]==0)
                                            exponent=1;
                                    end





                                alu_result = {ALU_data1[31], exponent, mantissa};
                            end
                            
                        end else begin
                            // RegisterData2_FP 指數較大
                            mantissa_a = {1'b1, ALU_data1[22:0], 255'd0};
                            mantissa_a = mantissa_a >> ((~exponentDiff + 1) - 1);
                                if(ALU_data1[30:23]==0) begin//subnormal-normal
                                    mantissa_a = {1'b0, ALU_data1[22:0], 255'd0}; // 對齊較小指數
                                    mantissa_a = mantissa_a >> ((~exponentDiff + 1) - 2);
                                end
                            if (ALU_data1[31] == RegisterData2_FP[31]) begin // 同號，尾數相加

                                mantissa_sum = mantissa_a + mantissa_b;
                                carry_out = mantissa_sum[279];

                                if (carry_out) begin
                                    mantissa_sum[279] = 0;
                                    mantissa_sum2 = mantissa_sum >> 1;
                                end else begin
                                    mantissa_sum2 = mantissa_sum;
                                end

                                mantissa_round = (mantissa_sum2[255] == 1 && |mantissa_sum2[254:0] == 1||(mantissa_sum2[256] == 1 &&mantissa_sum2[255] == 1)) ? mantissa_sum2[278:256] +1 :{1'b0,mantissa_sum2[278:256]};
                                mantissa_sum_overflow = mantissa_round[23];
                                exponent = (mantissa_sum2[255] == 1 && |mantissa_sum2[254:0] == 1||(mantissa_sum2[256] == 1 &&mantissa_sum2[255] == 1)) ?RegisterData2_FP[30:23] + carry_out + mantissa_sum_overflow:RegisterData2_FP[30:23] + carry_out;
                                mantissa = (mantissa_sum2[255] == 1 && |mantissa_sum2[254:0] == 1||(mantissa_sum2[256] == 1 &&mantissa_sum2[255] == 1)) ? mantissa_round : mantissa_sum2[278:256];

                                    if(ALU_data1[30:23]==0 &&RegisterData2_FP[30:23]==1) begin//subnormal+normal special case
                                        mantissa_a = {1'b0 ,ALU_data1[22:0],        255'd0};
                                        mantissa_b = {1'b1 ,RegisterData2_FP[22:0], 255'd0};
                                        mantissa_sum2 = mantissa_a + mantissa_b; // 尾數相加
                                        mantissa_sum_24 = mantissa_sum2[279:256];
                                        carry_out=mantissa_sum2[279];
                                        if(carry_out)begin
                                            mantissa_sum=mantissa_sum2>>1;
                                            mantissa_round = (mantissa_sum[254] == 1 && |mantissa_sum[253:0] == 1||(mantissa_sum[255] == 1 &&mantissa_sum[254] == 1)) ? mantissa_sum[277:255] +1 :{1'b0,mantissa_sum[277:255]};

                                        
                                        end
                                        else                                                                                
                                            mantissa_round = (mantissa_sum2[254] == 1 && |mantissa_sum2[253:0] == 1||(mantissa_sum2[255] == 1 &&mantissa_sum2[254] == 1)) ? mantissa_sum2[277:255] +1 :{1'b0,mantissa_sum2[277:255]};



                                        mantissa_sum_overflow = mantissa_round[23];

                                        exponent = (mantissa_sum2[254] == 1 && |mantissa_sum2[253:0] == 1||(mantissa_sum2[255] == 1 &&mantissa_sum2[254] == 1)) ? RegisterData2_FP[30:23] + carry_out + mantissa_sum_overflow:RegisterData2_FP[30:23] + carry_out;
                                        mantissa = mantissa_round[22:0] ;

                                       

                                    end






                                alu_result = {RegisterData2_FP[31], exponent, mantissa};
                            end else begin // 異號，尾數相減
                                mantissa_sum2 = {1'b1, mantissa_b} - {1'b0, mantissa_a};
                                mantissa_sum_24 = mantissa_sum2[279:256];
                                count = count_leading_zeros24(mantissa_sum_24);
                                count2 = count_leading_zeros24(mantissa_sum_24);

                                if (RegisterData2_FP[30:23]<=count2)begin
                                    if((count2-RegisterData2_FP[30:23])==0)
                                        count=1;
                                    else
                                        count=RegisterData2_FP[30:23]-1;
                                    flag=1;
                                end
                                mantissa_sum = mantissa_sum2 << count;
                                mantissa_round =  (mantissa_sum[255] == 1 && |mantissa_sum[254:0] == 1||(mantissa_sum[256] == 1 &&mantissa_sum[255] == 1)) ?mantissa_sum[278:256] +1:{1'b0,mantissa_sum[278:256]};
                                mantissa_sum_overflow = mantissa_round[23];
                                exponent = (mantissa_sum[255] == 1 && |mantissa_sum[254:0] == 1||(mantissa_sum[256] == 1 &&mantissa_sum[255] == 1)) ?RegisterData2_FP[30:23] - count + mantissa_sum_overflow:RegisterData2_FP[30:23] - count ;
                                mantissa = (mantissa_sum[255] == 1 && |mantissa_sum[254:0] == 1||(mantissa_sum[256] == 1 &&mantissa_sum[255] == 1)) ? mantissa_round : mantissa_sum[278:256];
                                if(flag &&(count2-RegisterData2_FP[30:23])>=1)
                                    exponent=1;
                                if(flag &&(count2-RegisterData2_FP[30:23])>=0)
                                    exponent=0;


                                    if(ALU_data1[30:23]==0 &&RegisterData2_FP[30:23]==1) begin//subnormal-normal special case
                                        mantissa_a = {1'b0 ,ALU_data1[22:0],        255'd0};
                                        mantissa_b = {1'b1 ,RegisterData2_FP[22:0], 255'd0};
                                        mantissa_sum2 = mantissa_b - mantissa_a; // 尾數相減
                                        mantissa = mantissa_sum2[277:255];
                                        exponent = (RegisterData2_FP[22:0]>ALU_data1[22:0])?1:0;

                                    end
                                                                    
                                alu_result = {RegisterData2_FP[31], exponent, mantissa};
                            end
                        end
                    end else begin // 指數相同情況
                        if (ALU_data1[22:0] > RegisterData2_FP[22:0]) begin
                            if (ALU_data1[31] == RegisterData2_FP[31]) begin // 同號，尾數相加
                                mantissa_sum_24 = ALU_data1[22:0] + RegisterData2_FP[22:0];
                                mantissa_round = {mantissa_sum_24[23], mantissa_sum_24[22:0]} >> 1;
                                mantissa = (mantissa_sum_24[1]&mantissa_sum_24[0])? mantissa_round+1 :mantissa_round[22:0];
                                if((ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0))begin

                                    mantissa_temp = mantissa_sum_24;
                                end
                                else begin
                                    mantissa_temp = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0)?{1'b0,mantissa_round[22:0]}:{1'b0,mantissa};
                                end
                                mantissa = mantissa_temp[22:0];
                                exponent = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0) ? {7'b0,mantissa_sum_24[23]}: ALU_data1[30:23] + 1;
                                alu_result = {ALU_data1[31], exponent, mantissa};
                            end else begin // 異號，尾數相減
                                mantissa_23 = ALU_data1[22:0] - RegisterData2_FP[22:0];
                                count = count_leading_zeros23(mantissa_23);
                                count2 = count_leading_zeros23(mantissa_23);

                                if (RegisterData2_FP[30:23]<=count2)begin
                                    if((count2-RegisterData2_FP[30:23])==0)
                                        count=1;
                                    else
                                        count=RegisterData2_FP[30:23]-1;
                                flag=1;
                                end
                                else begin
                                    if((RegisterData2_FP[30:23]-count2) ==1)
                                        flag=1;
                                end

                                // mantissa = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0) ? mantissa_23 :mantissa_23 << (count + 1);
                                if((ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0)||(ALU_data1[30:23]==1))begin

                                    mantissa_temp = {1'b0,mantissa_23};
                                end
                                else begin
                                    if(flag)
                                        mantissa_temp = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0) ? {1'b0,mantissa_23} : {1'b0,(mantissa_23 << (count))};
                                    else
                                        mantissa_temp = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0) ? {1'b0,mantissa_23} : {1'b0,(mantissa_23 << (count + 1))};                                end
                                mantissa=mantissa_temp[22:0];
                                exponent = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0) ? 0 : ALU_data1[30:23] - (count + 1);

                                if(ALU_data1[30:23] == 1 || ALU_data1[30:23] == 0)
                                    exponent =  0;

                                else
                                    exponent = ALU_data1[30:23] - (count + 1);
                                if(flag&&(count2-RegisterData2_FP[30:23])>=1)
                                    exponent=1;
                                if(flag&&(count2-RegisterData2_FP[30:23])>=0)
                                    exponent=0;
                                alu_result = {ALU_data1[31], exponent, mantissa};
                            end
                        end else begin
                            if (ALU_data1[31] == RegisterData2_FP[31]) begin // 同號，尾數相加
                                mantissa_sum_24 = ALU_data1[22:0] + RegisterData2_FP[22:0];
                                mantissa_round = {mantissa_sum_24[23], mantissa_sum_24[22:0]} >> 1;
                                mantissa = (mantissa_sum_24[1]&mantissa_sum_24[0])? mantissa_round+1 :mantissa_round[22:0];
                                if((ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0))begin
                                    // mantissa_temp = mantissa_sum_24[22:0];
                                    // mantissa_round = mantissa_sum_24;
                                    // mantissa_round=mantissa_sum_24;
                                    mantissa_temp = mantissa_sum_24;
                                end
                                else begin
                                    mantissa_temp = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0)?{1'b0,mantissa_round[22:0]}:{1'b0,mantissa};
                                end                                
                                mantissa = mantissa_temp[22:0];
                                exponent = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0) ? {7'b0,mantissa_sum_24[23]} : ALU_data1[30:23] + 1;
                                alu_result = {RegisterData2_FP[31], exponent, mantissa};
                            end else begin // 異號，尾數相減
                                mantissa_23 = RegisterData2_FP[22:0] - ALU_data1[22:0];
                                count = count_leading_zeros23(mantissa_23);
                                count2 = count_leading_zeros23(mantissa_23);

                                if (RegisterData2_FP[30:23]<=count2)begin
                                    if((count2-RegisterData2_FP[30:23])==0)
                                        count=1;
                                    else
                                        count=RegisterData2_FP[30:23]-1;
                                    flag=1;
                                end
                                else begin
                                    if((RegisterData2_FP[30:23]-count2) ==1)
                                        flag=1;
                                end
                                // mantissa = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0) ? mantissa_23 :mantissa_23 << (count + 1);
                                if((ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0)||(ALU_data1[30:23]==1))begin

                                    mantissa_temp = {1'b0,mantissa_23};
                                end
                                else begin
                                    if(flag)
                                        mantissa_temp = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0) ?{1'b0,mantissa_23} :{1'b0 ,(mantissa_23 << (count))};
                                    else
                                        mantissa_temp = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0) ? {1'b0,mantissa_23} : {1'b0,(mantissa_23 << (count + 1))};
                                end
                                mantissa=mantissa_temp[22:0];
                                if(ALU_data1[30:23] == 1 || ALU_data1[30:23] == 0)
                                    exponent =  0;

                                else
                                    exponent = RegisterData2_FP[30:23] - (count + 1);
                                if(flag&&(count2-RegisterData2_FP[30:23])>=1)
                                    exponent=1;
                                if(flag&&(count2-RegisterData2_FP[30:23])>=0)
                                    exponent=0;
                                alu_result = {RegisterData2_FP[31], exponent, mantissa};
                            end
                        end
                    end
                    if(ALU_data1[30:0]==RegisterData2_FP[30:0] && ALU_data1[31]!=RegisterData2_FP[31])
                        alu_result = 0;

                    // 處理零和例外情況
                    if (alu_result[31] == 1 && alu_result[30:0] == 0) begin
                        alu_result = 0;
                    end
                    if ((ALU_data1[30:23] == 8'd0 && ALU_data1[22:0] == 23'd0) && 
                        (RegisterData2_FP[30:23] == 8'd0 && RegisterData2_FP[22:0] == 23'd0)) begin
                        alu_result = 0;
                    end else if (ALU_data1[30:23] == 8'd0 && ALU_data1[22:0] == 23'd0) begin
                        alu_result = RegisterData2_FP;
                    end else if (RegisterData2_FP[30:23] == 8'd0 && RegisterData2_FP[22:0] == 23'd0) begin
                        alu_result = ALU_data1;
                    end
                    if(alu_result[30:23] == 8'd255 && alu_result[22:0]!= 23'd0)
                        data_Overflow = 1;
                    if(alu_result[30:23] == 8'd255 && alu_result[22:0]== 23'd0)
                        data_Overflow = 1;
                end
            
                
                {`FUNCT7_FSUB, `FUNCT3_FSUB}: begin 
                    if ((ALU_data1[31] == 1 && ALU_data1[30:23] == 8'd255 && ALU_data1[22:0] == 23'd0) || 
                        (RegisterData2_FP[31] == 1 && RegisterData2_FP[30:23] == 8'd255 && RegisterData2_FP[22:0] == 23'd0)) begin
                        data_Overflow = 1;
                    end else if ((ALU_data1[31] == 0 && ALU_data1[30:23] == 8'd255 && ALU_data1[22:0] == 23'd0) || 
                                (RegisterData2_FP[31] == 0 && RegisterData2_FP[30:23] == 8'd255 && RegisterData2_FP[22:0] == 23'd0)) begin
                        data_Overflow = 1;
                    end else if ((ALU_data1[30:23] == 8'd255 && ALU_data1[22:0] != 23'd0) || 
                                (RegisterData2_FP[30:23] == 8'd255 && RegisterData2_FP[22:0] != 23'd0)) begin
                        data_Overflow = 1;
                    end else begin
                        data_Overflow = 0;
                    end

                    RegWrite_FP32 = 1;
                    
                    if (ALU_data1[30:23] != RegisterData2_FP[30:23]) begin
                        mantissa_a = {ALU_data1[22:0], 256'd0};
                        mantissa_b = {RegisterData2_FP[22:0], 256'd0};
                        exponentDiff = ALU_data1[30:23] - RegisterData2_FP[30:23];
                 
                        if (exponentDiff > 0) begin
                            mantissa_b = {1'b1, RegisterData2_FP[22:0], 255'd0}; // 對齊較小指數
                            mantissa_b = mantissa_b >> (exponentDiff - 1);
                                if(RegisterData2_FP[30:23]==0) begin//normal-subnormal
                                    mantissa_b = {1'b0, RegisterData2_FP[22:0], 255'd0};
                                    mantissa_b = mantissa_b >> (exponentDiff- 2);
                                end       
                            if (ALU_data1[31] == RegisterData2_FP[31]) begin // 同號
                                mantissa_sum2 = {1'b1, mantissa_a} - {1'b0, mantissa_b}; // 尾數相減
                                mantissa_sum_24 = mantissa_sum2[279:256]; // 前 24 位
                                count = count_leading_zeros24(mantissa_sum_24); // 找出前導零
                                count2 = count_leading_zeros24(mantissa_sum_24);

                                if (ALU_data1[30:23]<=count2)begin
                                    if((count2-ALU_data1[30:23])==0)
                                        count=1;
                                    else
                                        count=ALU_data1[30:23]-1;
                                    flag=1;
                                end
                                mantissa_sum = mantissa_sum2 << count;
                                mantissa_round = ((mantissa_sum[255] == 1 && |mantissa_sum[254:0] == 1)||(mantissa_sum[256] == 1 &&mantissa_sum[255] == 1)) ? mantissa_sum[278:256] +1:{1'b0,mantissa_sum[278:256]}; // 進位處理
                                mantissa_sum_overflow = mantissa_round[23];
                                exponent = ((mantissa_sum[255] == 1 && |mantissa_sum[254:0] == 1)||(mantissa_sum[256] == 1 &&mantissa_sum[255] == 1)) ?ALU_data1[30:23] - count + mantissa_sum_overflow:ALU_data1[30:23] - count; // 更新指數
                                mantissa = ((mantissa_sum[255] == 1 && |mantissa_sum[254:0] == 1)||(mantissa_sum[256] == 1 &&mantissa_sum[255] == 1)) ? mantissa_round : mantissa_sum[278:256];
                                if(flag &&(count2-ALU_data1[30:23])>=1)
                                    exponent=1;
                                if(flag &&(count2-ALU_data1[30:23])>=0)
                                    exponent=0;
                                if(ALU_data1[30:23]==1 &&RegisterData2_FP[30:23]==0) begin//normal-subnormal special case
                                    mantissa_b = {1'b0 ,RegisterData2_FP[22:0],255'd0};
                                    mantissa_a = {1'b1 ,ALU_data1[22:0], 255'd0};
                                    mantissa_sum2 = mantissa_a-mantissa_b; // 尾數相減

                                    carry_out=mantissa_sum2[279];
                                    // if(carry_out)
                                    //     mantissa_sum=mantissa_sum2>>1;



                                    mantissa = mantissa_sum2[277:255];
                                    exponent = (RegisterData2_FP[22:0]>ALU_data1[22:0])?0:1;


                                end





                                    
                                alu_result = {ALU_data1[31], exponent, mantissa};





                            end 
                            else begin // 異號，尾數相加
                                mantissa_sum = mantissa_a + mantissa_b;
                                carry_out = mantissa_sum[279];
                                if (carry_out) begin
                                    mantissa_sum[279] = 0;
                                    mantissa_sum2 = mantissa_sum >> 1;
                                end else begin
                                    mantissa_sum2 = mantissa_sum;
                                end
                                



                                
                                mantissa_round = ((mantissa_sum2[255] == 1 && |mantissa_sum2[254:0] == 1) ||(mantissa_sum2[256] == 1 &&mantissa_sum2[255] == 1))?  mantissa_sum2[278:256] +1: {1'b0,mantissa_sum2[278:256]};
                                mantissa_sum_overflow = mantissa_round[23];
                                exponent = ((mantissa_sum2[255] == 1 && |mantissa_sum2[254:0] == 1) ||(mantissa_sum2[256] == 1 &&mantissa_sum2[255] == 1))? ALU_data1[30:23] + carry_out + mantissa_sum_overflow:ALU_data1[30:23] + carry_out ;
                                mantissa = ((mantissa_sum2[255] == 1 && |mantissa_sum2[254:0] == 1) ||(mantissa_sum2[256] == 1 &&mantissa_sum2[255] == 1)) ? mantissa_round : mantissa_sum2[278:256];
                                    if(ALU_data1[30:23]==1 &&RegisterData2_FP[30:23]==0) begin//normal+subnormal
                                        mantissa_a = {1'b1 ,ALU_data1[22:0],        255'd0};
                                        mantissa_b = {1'b0 ,RegisterData2_FP[22:0], 255'd0};
                                        mantissa_sum2 = mantissa_a + mantissa_b; // 尾數相加
                                        mantissa_sum_24 = mantissa_sum2[279:256];
                                        carry_out=mantissa_sum2[279];
                                        if(carry_out)
                                            mantissa_sum2=mantissa_sum2 >> 1;



                                        mantissa_round = (mantissa_sum2[254] == 1 && |mantissa_sum2[253:0] == 1||(mantissa_sum2[255] == 1 &&mantissa_sum2[254] == 1)) ? mantissa_sum2[277:255] +1 :{1'b0,mantissa_sum2[277:255]};
                                        mantissa_sum_overflow = mantissa_round[23];

                                        exponent = (mantissa_sum2[254] == 1 && |mantissa_sum2[253:0] == 1||(mantissa_sum2[255] == 1 &&mantissa_sum2[254] == 1)) ? ALU_data1[30:23] + carry_out + mantissa_sum_overflow:ALU_data1[30:23] + carry_out;
                                        mantissa = (mantissa_sum2[254] == 1 && |mantissa_sum2[253:0] == 1||(mantissa_sum2[255] == 1 &&mantissa_sum2[254] == 1)) ? mantissa_round : mantissa_sum2[277:255];
                                    
                                    end
                                alu_result = {ALU_data1[31], exponent, mantissa};
                            end
                            
                        end else begin
                            // RegisterData2_FP 指數較大
                            mantissa_a = {1'b1, ALU_data1[22:0], 255'd0};
                            mantissa_a = mantissa_a >> ((~exponentDiff + 1) - 1);
                                if(ALU_data1[30:23]==0) begin//subnormal-normal
                                    mantissa_a = {1'b0, ALU_data1[22:0], 255'd0};
                                    mantissa_a = mantissa_a >> ((~exponentDiff + 1) - 2);
                                end
                            if (ALU_data1[31] == RegisterData2_FP[31]) begin // 同號

 
                                mantissa_sum2 = {1'b1, mantissa_b} - {1'b0, mantissa_a}; // 尾數相減
                                // TEMP3= $signed(TEMP2) - $signed(TEMP1);
                                // mantissa_sum_24 = mantissa_sum2[279:256];
                                mantissa_sum_24 = mantissa_sum2[279:256];
                                count2 = count_leading_zeros24(mantissa_sum_24);
                                count = count_leading_zeros24(mantissa_sum_24);

                                if (RegisterData2_FP[30:23]<=count2)begin
                                    if((count2-RegisterData2_FP[30:23])==0)
                                        count=1;
                                    else
                                        count=RegisterData2_FP[30:23]-1;
                                flag=1;
                                end

                                mantissa_sum = mantissa_sum2 << count;
                                mantissa_round = ((mantissa_sum[255] == 1 && |mantissa_sum[254:0] == 1 )||(mantissa_sum[256] == 1 &&mantissa_sum[255] == 1)) ? mantissa_sum[278:256] +1:{1'b0,mantissa_sum[278:256]};
                                mantissa_sum_overflow = mantissa_round[23];
                                exponent = ((mantissa_sum[255] == 1 && |mantissa_sum[254:0] == 1 )||(mantissa_sum[256] == 1 &&mantissa_sum[255] == 1)) ?RegisterData2_FP[30:23] - count + mantissa_sum_overflow:RegisterData2_FP[30:23] - count;
                                if(flag&&(count2-RegisterData2_FP[30:23])>=1)
                                    exponent=1;
                                if(flag&&(count2-RegisterData2_FP[30:23])>=0)
                                    exponent=0;

                                
                                mantissa = ((mantissa_sum[255] == 1 && |mantissa_sum[254:0] == 1) ||(mantissa_sum[256] == 1 &&mantissa_sum[255] == 1)) ? mantissa_round : mantissa_sum[278:256];

                                alu_result = {~ALU_data1[31], exponent, mantissa};
                            
                                    if(ALU_data1[30:23]==0 &&RegisterData2_FP[30:23]==1) begin//subnormal-normal special case
                                        mantissa_a = {1'b0 ,ALU_data1[22:0],        255'd0};
                                        mantissa_b = {1'b1 ,RegisterData2_FP[22:0], 255'd0};
                                        mantissa_sum2 = mantissa_b - mantissa_a; // 尾數相減
                                        // mantissa_sum_24 = mantissa_sum2[279:256];


                                        // count = count_leading_zeros24(mantissa_sum_24);
                                        // mantissa_sum = mantissa_sum2 << count;
                                        // mantissa_round = ((mantissa_sum[256] == 1 && |mantissa_sum[255:0] == 1 )||(mantissa_sum[257] == 1 &&mantissa_sum[256] == 1)) ? mantissa_sum[278:256] +1:mantissa_sum[278:256];
                                        // mantissa_sum_overflow = mantissa_round[23];
                                        // exponent = 1;
                                        // mantissa = ((mantissa_sum[256] == 1 && |mantissa_sum[255:0] == 1) ||(mantissa_sum[257] == 1 &&mantissa_sum[256] == 1)) ? mantissa_round : mantissa_sum[278:256]; 




                                        mantissa = mantissa_sum2[277:255];
                                        exponent = (RegisterData2_FP[22:0]>ALU_data1[22:0])?1:0;



                                       alu_result = {~ALU_data1[31], exponent, mantissa};

                                    end



                            
                            end 
                            else begin // 異號，尾數相加
                                mantissa_sum = mantissa_a + mantissa_b;
                                carry_out = mantissa_sum[279];

                                if (carry_out) begin
                                    mantissa_sum[279] = 0;
                                    mantissa_sum2 = mantissa_sum >> 1;
                                end else begin
                                    mantissa_sum2 = mantissa_sum;
                                end

                                mantissa_round = mantissa_sum2[278:256] +1;
                                mantissa_sum_overflow = mantissa_round[23];
                                exponent = (mantissa_sum2[255] == 1 && |mantissa_sum2[254:0] == 1||(mantissa_sum2[256] == 1 &&mantissa_sum2[255] == 1)) ?RegisterData2_FP[30:23] + carry_out + mantissa_sum_overflow:RegisterData2_FP[30:23] + carry_out ;
                                mantissa = (mantissa_sum2[255] == 1 && |mantissa_sum2[254:0] == 1||(mantissa_sum2[256] == 1 &&mantissa_sum2[255] == 1)) ? mantissa_round : mantissa_sum2[278:256];


                                    if(ALU_data1[30:23]==0 &&RegisterData2_FP[30:23]==1) begin//subnormal+normal
                                        mantissa_a = {1'b0 ,ALU_data1[22:0],        255'd0};
                                        mantissa_b = {1'b1 ,RegisterData2_FP[22:0], 255'd0};
                                        mantissa_sum2 = mantissa_a + mantissa_b; // 尾數相加
                                        mantissa_sum_24 = mantissa_sum2[279:256];
                                        carry_out=mantissa_sum2[279];
                                        if(carry_out)begin
                                            mantissa_sum=mantissa_sum2>>1;
                                            mantissa_round = (mantissa_sum[254] == 1 && |mantissa_sum[253:0] == 1||(mantissa_sum[255] == 1 &&mantissa_sum[254] == 1)) ? mantissa_sum[277:255] +1 :{1'b0,mantissa_sum[277:255]};

                                        
                                        end
                                        else                                                                                
                                            mantissa_round = (mantissa_sum2[254] == 1 && |mantissa_sum2[253:0] == 1||(mantissa_sum2[255] == 1 &&mantissa_sum2[254] == 1)) ? mantissa_sum2[277:255] +1 :{1'b0,mantissa_sum2[277:255]};



                                        mantissa_sum_overflow = mantissa_round[23];

                                        exponent = (mantissa_sum2[254] == 1 && |mantissa_sum2[253:0] == 1||(mantissa_sum2[255] == 1 &&mantissa_sum2[254] == 1)) ? RegisterData2_FP[30:23] + carry_out + mantissa_sum_overflow:RegisterData2_FP[30:23] + carry_out;
                                        mantissa = mantissa_round[22:0] ;

                                       

                                    end


                                alu_result = {~RegisterData2_FP[31], exponent, mantissa};
                            end
                        end
                    end else begin // 指數相同情況
                        if (ALU_data1[22:0] > RegisterData2_FP[22:0]) begin
                                TEST=3;

                            if (ALU_data1[31] == RegisterData2_FP[31]) begin // 同號，直接相減
                                mantissa_23 = ALU_data1[22:0] - RegisterData2_FP[22:0];
                                count = count_leading_zeros23(mantissa_23);
                                
                                
                                count2 = count_leading_zeros24(mantissa_sum_24);

                                if (RegisterData2_FP[30:23]<=count2)begin
                                    if((count2-RegisterData2_FP[30:23])==0)
                                        count=1;
                                    else
                                        count=RegisterData2_FP[30:23]-1;
                                flag=1;
                                end
                                else begin
                                    if((RegisterData2_FP[30:23]-count2) ==1)
                                        flag=1;
                                end


                                if((ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0)||(ALU_data1[30:23]==1))begin

                                    mantissa_temp = {1'b0,mantissa_23};
                                end
                                else begin
                                    if(flag)
                                        mantissa_temp = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0) ? {1'b0,mantissa_23} : {1'b0,(mantissa_23 << (count))};
                                    else
                                        mantissa_temp = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0) ? {1'b0,mantissa_23} : {1'b0,(mantissa_23 << (count + 1))};
                                end

                                mantissa = mantissa_temp[22:0];
                                // mantissa = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0) ? mantissa_23 : (mantissa_23 << (count + 1));
                                if(ALU_data1[30:23] == 1 || ALU_data1[30:23] == 0)
                                    exponent =  0;

                                else
                                    exponent = ALU_data1[30:23] - (count + 1);
                                if(flag&&(count2-RegisterData2_FP[30:23])>=1)
                                    exponent=1;
                                if(flag&&(count2-RegisterData2_FP[30:23])>=0)
                                    exponent=0;

                                alu_result = {ALU_data1[31], exponent, mantissa};
                            end 
                            else begin // 異號，直接相加

                                mantissa_sum_24 = ALU_data1[22:0] + RegisterData2_FP[22:0];

                                mantissa_round = {mantissa_sum_24[23], mantissa_sum_24[22:0]} >> 1;
                                mantissa = (mantissa_sum_24[1]&mantissa_sum_24[0])? mantissa_round+1 :mantissa_round[22:0];
                                if((ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0))begin
                                    // mantissa_temp = mantissa_sum_24[22:0];
                                    mantissa_temp = mantissa_sum_24;

                                end
                                else begin
                                    mantissa_temp = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0)?{1'b0,mantissa_round[22:0]}:{1'b0,mantissa};
                                end                                
                                mantissa = mantissa_temp[22:0];
                                exponent = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0) ?{7'b0, mantissa_sum_24[23]} : ALU_data1[30:23] + 1;
                                alu_result = {ALU_data1[31], exponent, mantissa};

                            end
                        end 
                        else begin
                            if (ALU_data1[31] == RegisterData2_FP[31]) begin // 同號，直接相減
                                mantissa_23 = RegisterData2_FP[22:0] - ALU_data1[22:0];
                                count = count_leading_zeros23(mantissa_23);
                                count2 = count_leading_zeros23(mantissa_23);

                                if (RegisterData2_FP[30:23]<=count2)begin
                                    if((count2-RegisterData2_FP[30:23])==0)
                                        count=1;
                                    else
                                        count=RegisterData2_FP[30:23]-1;
                                flag=1;
                                end
                                else begin
                                    if((RegisterData2_FP[30:23]-count2) ==1)
                                        flag=1;
                                end
                                // mantissa = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0) ? mantissa_23 : (mantissa_23 << (count + 1));
                                if((ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0)||(ALU_data1[30:23]==1))begin

                                    mantissa_temp = {1'b0,mantissa_23};
                                end
                                else begin
                                    if(flag)
                                        mantissa_temp = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0) ? {1'b0,mantissa_23 }: {1'b0,(mantissa_23 << (count))};
                                    else
                                        mantissa_temp = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0) ? {1'b0,mantissa_23} : {1'b0,(mantissa_23 << (count + 1))};
                                end

                                mantissa = mantissa_temp[22:0];

                                // exponent = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0) ? 0 : RegisterData2_FP[30:23] - (count + 1);
/*
                                mantissa_23 = RegisterData2_FP[22:0] - ALU_data1[22:0];
                                count = count_leading_zeros23(mantissa_23);
                                mantissa = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0) ? mantissa_23 :mantissa_23 << (count + 1);

                                if(ALU_data1[30:23] == 1 || ALU_data1[30:23] == 0)
                                    exponent =  0;

                                else
                                    exponent = RegisterData2_FP[30:23] - (count + 1);

                                alu_result = {RegisterData2_FP[31], exponent, mantissa};
*/


                                if(ALU_data1[30:23] == 1 || ALU_data1[30:23] == 0)
                                    exponent =  0;

                                else
                                    exponent = RegisterData2_FP[30:23] - (count + 1);

                                if(flag&&(count2-RegisterData2_FP[30:23])>=1)
                                    exponent=1;
                                if(flag&&(count2-RegisterData2_FP[30:23])>=0)
                                    exponent=0;



                                alu_result = {( ~RegisterData2_FP[31]&& RegisterData2_FP[22:0]>ALU_data1[22:0]), exponent, mantissa};
                            end 
                            else begin // 異號 ，直接相加

            
                                mantissa_sum_24 = ALU_data1[22:0] + RegisterData2_FP[22:0];

                                mantissa_round = {mantissa_sum_24[23], mantissa_sum_24[22:0]} >> 1;
                                mantissa = (mantissa_sum_24[1]&mantissa_sum_24[0])? mantissa_round+1 :mantissa_round[22:0];
                                if((ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0))begin
                                    // mantissa_temp = mantissa_sum_24[22:0];
                                    // mantissa_round=mantissa_sum_24;
                                    mantissa_temp = mantissa_sum_24;
                                end
                                else begin
                                    mantissa_temp = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0)?{1'b0,mantissa_round[22:0]}:{1'b0,mantissa};
                                end                                
                                mantissa = mantissa_temp[22:0];
                                exponent = (ALU_data1[30:23] == 0 && RegisterData2_FP[30:23] == 0) ? {7'b0,mantissa_sum_24[23]} : ALU_data1[30:23] + 1;
                                alu_result = {~RegisterData2_FP[31], exponent, mantissa};
         
                            end
                        end
                    end

                    // 例外處理


                    if (ALU_data1== RegisterData2_FP) begin
                        alu_result = 0;
                    end



                    if (alu_result[31] == 1 && alu_result[30:0] == 0) begin
                        alu_result = 0;
                    end
                    if ((ALU_data1[30:23] == 8'd0 && ALU_data1[22:0] == 23'd0) && (RegisterData2_FP[30:23] == 8'd0 && RegisterData2_FP[22:0] == 23'd0)) begin
                        alu_result = 0;
                    end else if (ALU_data1[30:23] == 8'd0 && ALU_data1[22:0] == 23'd0) begin
                        alu_result = {~RegisterData2_FP[31],RegisterData2_FP[30:0]};
                    end else if (RegisterData2_FP[30:23] == 8'd0 && RegisterData2_FP[22:0] == 23'd0) begin
                        alu_result = ALU_data1;
                    end
                    if(alu_result[30:23] == 8'd255 && alu_result[22:0] != 23'd0)
                        data_Overflow = 1;
                    if(alu_result[30:23] == 8'd255 && alu_result[22:0]== 23'd0)
                        data_Overflow = 1;
                end
                    default:count=0;
                endcase





            case({Inst[31:25],Inst[14:12]})
            
                {`FUNCT7_FCLASS,`FUNCT3_FCLASS}:begin
                    RegWrite=1;
                    if(ALU_data1[31]==1 && ALU_data1[30:23]==8'd255 && ALU_data1[22:0]==23'd0 )begin
                        alu_result=32'd0;
                    end
                    else if(ALU_data1[31]==0 && ALU_data1[30:23]==8'd255 && ALU_data1[22:0]==23'd0 )
                        alu_result=32'd7;
                    else if(ALU_data1[30:23]==8'd255 && ALU_data1[22:0]!=23'd0 )
                        alu_result=32'd8;

                    else if(ALU_data1[31]==1 && ALU_data1[30:23]==8'd0 && ALU_data1[22:0]==23'd0 )
                        alu_result=32'd3;
                    else if(ALU_data1[31]==0 && ALU_data1[30:23]==8'd0 && ALU_data1[22:0]==23'd0 )
                        alu_result=32'd4;


                    else if(ALU_data1[31]==1 && ALU_data1[30:23]!=8'd0 )
                        alu_result=32'd1;
                    else if(ALU_data1[31]==0 && ALU_data1[30:23]!=8'd0 )
                        alu_result=32'd6;

                    else if(ALU_data1[31]==1 && ALU_data1[30:23]==8'd0 && ALU_data1[22:0]!=23'd0)
                        alu_result=32'd2;
                    else if(ALU_data1[31]==0 && ALU_data1[30:23]==8'd0 && ALU_data1[22:0]!=23'd0)
                        alu_result=32'd5;



                end
                {`FUNCT7_FLT,`FUNCT3_FLT}:begin
                     RegWrite=1;
                    if(ALU_data1[31]==1 && RegisterData2_FP[31]==0)begin
                        
                        alu_result=1;
                        //special case
                        if( (ALU_data1[30:23]==8'd0 && ALU_data1[22:0]==23'd0) && !(RegisterData2_FP[30:23]==8'd0 && RegisterData2_FP[22:0]==23'd0) )//-0 < r2
                        begin
                            alu_result=1;
                        end
                        else if((ALU_data1[30:23]==8'd0 && ALU_data1[22:0]==23'd0)&& 
                        (RegisterData2_FP[30:23]==8'd0 && RegisterData2_FP[22:0]==23'd0))// +-0 vs +0
                        begin
                            alu_result=0;

                        end

                    end

                    else if(ALU_data1[31]==0 && RegisterData2_FP[31]==1)begin
                        alu_result=0;


                        if( (ALU_data1[30:23]==8'd0 && ALU_data1[22:0]==23'd0) && !(RegisterData2_FP[30:23]==8'd0 && RegisterData2_FP[22:0]==23'd0) )//+0 < r2
                        begin
                            alu_result=0;
                        end
                        else if((ALU_data1[30:23]==8'd0 && ALU_data1[22:0]==23'd0)&& 
                        (RegisterData2_FP[30:23]==8'd0 && RegisterData2_FP[22:0]==23'd0))// +0 vs -0
                        begin
                            alu_result=0;

                        end
                    
                    
                    
                    end
                    else begin  
                        if(ALU_data1[31]==0)begin
                            if(ALU_data1[30:23]>RegisterData2_FP[30:23])
                                alu_result=0;
                            else if(ALU_data1[30:23]<RegisterData2_FP[30:23])
                                alu_result=1;
                            else begin
                                if(ALU_data1[22:0]>RegisterData2_FP[22:0])
                                    alu_result=0;
                                else if (ALU_data1[22:0]<RegisterData2_FP[22:0])
                                    alu_result=1;
                                else
                                    alu_result=0;
                            end
                            // alu_result=0;                              
                        end
                        else begin
                        
                            if(ALU_data1[30:23]>RegisterData2_FP[30:23])
                                alu_result=1;
                            else if(ALU_data1[30:23]<RegisterData2_FP[30:23])
                                alu_result=0;
                            else begin
                                if(ALU_data1[22:0]>RegisterData2_FP[22:0])
                                    alu_result=1;
                                else if (ALU_data1[22:0]<RegisterData2_FP[22:0])
                                    alu_result=0;
                                else
                                    alu_result=0;
                            end
                            // alu_result=0;        
                        
                        
                        end
                    end
                    if(ALU_data1[30:23] == 8'd255 && ALU_data1[22:0] != 23'd0)
                        data_Overflow = 1;
                    if(ALU_data1[30:23] == 8'd255 && ALU_data1[22:0]== 23'd0)
                        data_Overflow = 1;
                    if(RegisterData2_FP[30:23] == 8'd255 && RegisterData2_FP[22:0] != 23'd0)
                        data_Overflow = 1;
                    if(RegisterData2_FP[30:23] == 8'd255 && RegisterData2_FP[22:0]== 23'd0)
                        data_Overflow = 1;
                     // if(alu_result[31]==1)
                    //     alu_result=1;
                    // else 
                    //     alu_result=0;
                end
                default:count=0;
            endcase

            end
            
        end
        4'b0100:begin
        case(Inst[14:12])

            `FUNCT3_ADDI :begin  
                alu_result_33 = ALU_data1+ALU_data2;
                data_Overflow = alu_result_33[32]^alu_result_33[31];
                alu_result=alu_result_33[31:0];
                RegWrite=1;

            end
            `FUNCT3_LW: begin  
                alu_result_33 = ALU_data1+ALU_data2;
                data_Overflow = (|alu_result_33[32:13])|| (alu_result_33[12]==0);
                alu_result=alu_result_33[31:0];
                RegWrite=0;
            end
            // `FUNCT3_FLW: begin  
            //     alu_result_33 = ALU_data1+ALU_data2;
            //     data_Overflow = (|alu_result_33[32:13])|| (alu_result_33[12]==0);
            //     alu_result=alu_result_33[31:0];
            //     RegWrite=0;
            // end
            default:begin
                            RegWrite=0;

            end
        endcase
        end
        4'b0010:begin
        case(Inst[14:12])
            `FUNCT3_SW: begin
                
                alu_result_33 = ALU_data1+ALU_data2;
                data_Overflow = (|alu_result_33[32:13]) || (alu_result_33[12]==0);
                alu_result=alu_result_33[31:0];
                RegWrite=0;
            end
            default:begin
                            RegWrite=0;

            end
        endcase

        case(Inst[14:12])
            `FUNCT3_FSW: begin
                
                alu_result_33 = ALU_data1+ALU_data2;
                data_Overflow = (|alu_result_33[32:13]) || (alu_result_33[12]==0);
                alu_result=alu_result_33[31:0];
                RegWrite=0;
            end
            default:begin
                            RegWrite=0;

            end
        endcase


        end

        4'b0001:begin
        case(Inst[14:12])
            `FUNCT3_BEQ: begin 
                RegWrite=0;
                if(RegisterData1==RegisterData2)begin
                alu_branch=1;
                alu_result_33=$signed(pc)+$signed(ALU_data2);
                alu_result=alu_result_33[31:0];
                data_Overflow =(|alu_result_33[32:12]);
                end
                else 
                alu_branch=0;
            end
            `FUNCT3_BLT: begin 
                RegWrite=0;
                if($signed(RegisterData1)<$signed(RegisterData2))begin
                alu_branch=1;
                alu_result_33=$signed(pc)+$signed(ALU_data2);
                alu_result=alu_result_33[31:0];
                data_Overflow =(|alu_result_33[32:12]);
                end
                else 
                alu_branch=0;
            end
            default:begin
                            RegWrite=0;

            end
        endcase
        end

            default:begin
                            count=0;

            end
        endcase
    
        o_status_w =((data_Overflow|instaddr_Overflow)&&(!EOF))?`INVALID_TYPE:(EOF)?`EOF_TYPE:(R_type)?`R_TYPE:(I_type)?`I_TYPE:(S_type)?`S_TYPE:(B_type)?`B_TYPE:`I_TYPE;      
    end
    else if(state==WB)
    begin
        RegWrite=0;
        o_status_w =((data_Overflow|instaddr_Overflow)&&(!EOF))?`INVALID_TYPE:(EOF)?`EOF_TYPE:(R_type)?`R_TYPE:(I_type)?`I_TYPE:(S_type)?`S_TYPE:(B_type)?`B_TYPE:`I_TYPE;      

        if(opcode_r==`OP_LW)begin
        MemtoReg=1;
        RegWrite=1;

        end
        else if(opcode_r==`OP_FLW)begin
        MemtoReg=1;
        RegWrite_FP32=1;

        end


    end
    else begin
        alu_result=0;
        RegWrite=0;
        o_status_w=0;
        count=0;
        ALUsrc=0;
        RegWrite_FP32=0;
    end
end

// ---------------------------------------------------------------------------
// Sequential Block
// ---------------------------------------------------------------------------
// ---- Write your sequential block design here ---- //
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) 
        state <= INIT;
    else         
        state <= n_state;
end
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) 
        Inst_r <= 0;
    else 
        Inst_r<=Inst;
end
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) 
        MemWrite <= 0;
    else if(state==EX &&n_state!=PROCESS_END &&(opcode==`OP_SW || opcode==`OP_FSW))        
        MemWrite <= 1;
    else 
        MemWrite<=0;
end

always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        pc <= 0;
    end
    else if(state==EX &&B_type&&alu_branch)begin
        pc <= alu_result;

    end
    else if(state==EX) begin
        pc <= pc+4;
    end
end
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        store_address<=0;
        opcode_r<=0;
    end
    else if(state==EX) begin
        store_address<=alu_result;
        opcode_r<=opcode;
    end
end




always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        o_status_r<=0;
        o_status_valid_r<=0;
    end
    else if(state==IF &&instaddr_Overflow)begin
        o_status_r<=o_status_w;
        o_status_valid_r<=1;
    end
    else if(state==EX &&B_type&&alu_branch)begin
        o_status_r<=o_status_w;
        o_status_valid_r<=1;
    end



    else if(state==EX) begin
        o_status_valid_r<=1;
        o_status_r<=o_status_w;
    end
    else if(state==PROCESS_END) begin
        o_status_valid_r<=0;
        o_status_r<=o_status_w;
    end
    else  o_status_valid_r<=0;
end



function automatic  [7:0] count_leading_zeros23;
    input [22:0] value;
    integer i;
    reg found;
    begin
        found = 1'b0;     
                count_leading_zeros23 = 5'd23;

        for (i = 22; i >= 0; i = i - 1) begin
            if (!found && value[i] == 1) begin
                count_leading_zeros23 = 5'd22 - i;  
                found = 1'b1;           
            end
        end  
    end
endfunction

function automatic  [7:0] count_leading_zeros24;
    input [23:0] value;
    integer i;
    reg found;
    begin
        found = 1'b0;     
                count_leading_zeros24 = 5'd24;

        for (i = 23; i >= 0; i = i - 1) begin
            if (!found && value[i] == 1) begin
                count_leading_zeros24 = 5'd23 - i;  
                found = 1'b1;           
            end
        end  
    end
endfunction


endmodule