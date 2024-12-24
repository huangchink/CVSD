module alu #(
    parameter INST_W = 4,
    parameter INT_W  = 6,
    parameter FRAC_W = 10,
    parameter DATA_W = INT_W + FRAC_W
)(
    input                      i_clk,
    input                      i_rst_n,

    input                      i_in_valid,
    output                     o_busy,
    input         [INST_W-1:0] i_inst,
    input  signed [DATA_W-1:0] i_data_a,
    input  signed [DATA_W-1:0] i_data_b,

    output                     o_out_valid,
    output        [DATA_W-1:0] o_data
);

    // Local Parameters
    //fixed-point(6-bit signed integer + 10-bit fraction)
    parameter ADD=      4'b0000;
    parameter SUB=      4'b0001;
    parameter MUL=      4'b0010;
    parameter Accum=    4'b0011;
    parameter Softplus= 4'b0100;
    //integer
    parameter XOR=4'b0101;
    parameter ARS=4'b0110;
    parameter LR =4'b0111;
    parameter CLZ=4'b1000;
    parameter ReverseM4=4'b1001;


    // Wires and Regs
    reg        [INST_W-1:0]   inst_r;
    reg signed [DATA_W-1:0]   data_a_r,data_b_r;



    reg signed [DATA_W-1:0]  o_data_r;
    reg        [DATA_W-1+1:0] sum;
    reg signed [DATA_W-1:0]   o_data_w;
    reg         o_out_valid_r,o_busy_r;
    reg  signed      [2*DATA_W-1:0] product;
    reg  signed  [2*DATA_W-1-10:0]product_round;
    reg signed [27:0]product_round_28;
    reg signed [44:0]product_round_45;

    reg [2:0] state, n_state;

    parameter INIT      = 3'd0;
    parameter READ    =   3'd1;
    parameter Calculate = 3'd2;
    parameter DONE    =   3'd3;
    reg Done,RegWrite;
    reg [1:0]counter;
    wire  [3:0]WriteRegister_addr,ReadRegister_addr;
    reg  signed [19:0] RegisterData;
    wire [19:0] Register_Write_data;
    parameter ADDR_WIDTH = 16;
    reg  [19:0] Register_file [0:ADDR_WIDTH-1];
    reg  signed[20:0] accum_num;
    integer i;
    reg found;

    // Continuous Assignments
    assign o_data=o_data_r;
    assign o_out_valid=o_out_valid_r;
    assign o_busy=o_busy_r;
    assign WriteRegister_addr=ReadRegister_addr;
    assign Register_Write_data=accum_num;
    assign ReadRegister_addr=data_a_r;
    // wire signed [15:0] multiplier_1_div_3_16 = {16'b0000000101010101};  // 約等於 1/3
    wire signed [25:0] multiplier_1_div_3_26 = {16'b0000000101010101,{5{2'b01}}};  // 約等於 1/3
    // wire signed [35:0] multiplier_1_div_3_36 = {16'b0000000101010101,{10{2'b01}}};  // 約等於 1/3

    // wire signed [15:0] multiplier_1_div_9 = 16'b0000000001110001;   // 約等於 1/9
    reg [57:0]temp_58;  
    reg [56:0]temp_57;  
    reg [15:0]temp_16;  

    reg [23:0]temp_round24;
    reg [41:0]temp_42;

    reg [42:0]temp_43;
    reg [82:0]temp2_83;                                          
    // Sequential Blocks
    always@(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) state <= INIT;
        else         state <= n_state;
    end
    
    always@(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) begin
                RegisterData<= 0;

            for (i = 0; i < ADDR_WIDTH; i = i + 1) 
                Register_file[i] <= 0;
        end
        else begin
            if (RegWrite) begin
                Register_file[WriteRegister_addr] <= Register_Write_data;
            end
            else 
                RegisterData<= Register_file[ReadRegister_addr];
        end       
    end

    always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        counter<=0;
    end 
    else if(state==Calculate)
        counter<=counter+1;
    else
        counter<=0;
    end

    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            inst_r    <= 0;
            data_a_r  <= 0;
            data_b_r  <= 0;
            o_out_valid_r <=0;
            o_data_r  <=0;

        end 
        else if(state==READ) begin
            inst_r    <= i_inst;
            data_a_r  <= i_data_a;
            data_b_r  <= i_data_b;
            o_out_valid_r<=0;

        end
        else if(state==Calculate)begin
            o_out_valid_r <= Done;
            o_data_r  <= o_data_w;

        end
        else begin
            o_out_valid_r<=0;

        end
    end
    always @(posedge i_clk or negedge i_rst_n) begin
        if(!i_rst_n) begin
            o_busy_r    <=1;
        end
        else if(state==INIT)
            o_busy_r    <=0;
        else if(state==READ && i_in_valid==1)
            o_busy_r    <=1;
        else if(state==READ && i_in_valid==0)
            o_busy_r    <=0;
        else if(state==Calculate && Done==1)
        o_busy_r    <=0;
        else if(state==Calculate && Done==0)
        o_busy_r    <=1;
        else 
            o_busy_r    <=0;

    end



    // Combinatorial Blocks
    always@(*) begin
        case(state)
            INIT:begin  
                if(o_busy_r==1)   
                    n_state = READ;
                else 
                    n_state=INIT;
            end

            READ: begin 
                if(o_busy==0 && i_in_valid==1)
                    n_state = Calculate;
                else if(i_in_valid==0)
                    n_state = READ;
                else 
                    n_state=READ;
            end
            Calculate: begin 
                if(Done)
                n_state = READ;
                else 
                n_state = Calculate;
            end

            default:n_state = INIT;
        endcase
    end

always@(*) begin
    o_data_w=16'd0;
    Done=0;
    RegWrite=0;
    accum_num=0;
    sum=0;
    product=0;
    product_round=0;
    if(state==Calculate)begin
    case(inst_r) 
    ADD:begin
        sum=data_a_r+data_b_r;
        o_data_w = ((sum[16]^sum[15])==1)?(data_a_r[15]==0)?16'b0111111111111111:16'b1000000000000000:sum[15:0]; //正+正的溢位 or 負+負的溢位
        Done=1;
    end
    SUB:begin
        sum=data_a_r-data_b_r;
        o_data_w = ((sum[16]^sum[15])==1)?(data_a_r[15]==0)?16'b0111111111111111:16'b1000000000000000:sum[15:0]; //正-負的溢位 or 負-正的溢位
        Done=1;
    end
    MUL:begin
         product = data_a_r * data_b_r;
         product_round   = product[31:10]+product[9]; //rounding to the nearest number
         o_data_w=(product_round>$signed(16'b0111111111111111))?16'b0111111111111111:(product_round<$signed(16'b1000000000000000))?16'b1000000000000000:product_round[15:0];
         Done=1;
    end

    Accum: begin
        if(counter==0)begin
            RegWrite=0;
            Done=0;

        end
        else begin
            RegWrite=1;
            // Register_Write_data=RegisterData+data_b_r;
            accum_num=RegisterData+data_b_r;
            o_data_w=(accum_num>$signed(16'b0111111111111111))?16'b0111111111111111:(accum_num<$signed(16'b1000000000000000))?16'b1000000000000000:accum_num[15:0];
            Done=1;
        end
    end
    Softplus: begin
        if ($signed(data_a_r) >= $signed(16'b0000100000000000)) begin
            // x >= 2
            o_data_w = data_a_r;
        end
        else if ($signed(16'b0000000000000000) <= $signed(data_a_r) && $signed(data_a_r) < $signed(16'b0000100000000000)) // 0 <= x < 2, (2x + 2)/3

        begin
            product = ($signed(16'b0000100000000000) * data_a_r + $signed({16'b0000100000000000,10'b0}));  // 2x + 2
            temp_57 = (product * multiplier_1_div_3_26);  //  (2x + 2) *  1/3
            product_round_28=temp_57[56:30]+temp_57[29]; //rounding
            o_data_w=($signed(product_round_28)>$signed(16'b0111111111111111))?16'b0111111111111111:($signed(product_round_28)<$signed(16'b1000000000000000))?16'b1000000000000000:product_round_28[15:0];

        end

        else if ($signed(16'b1111110000000000) <= $signed(data_a_r) && $signed(data_a_r) < $signed(16'b0000000000000000))// -1 <= x < 0, (x + 2)/3

        begin
            sum = (data_a_r + $signed({16'b0000100000000000}));  // x + 2
            temp_43 = (sum * multiplier_1_div_3_26) ;  // 乘以 1/3
            temp_round24=temp_43[42:20]+temp_43[19]; //rounding
            o_data_w=($signed(temp_round24)>$signed(16'b0111111111111111))?16'b0111111111111111:($signed(temp_round24)<$signed(16'b1000000000000000))?16'b1000000000000000:temp_round24[15:0];


        end




        else if ($signed(16'b1111100000000000) <= $signed(data_a_r) && $signed(data_a_r) < $signed(16'b1111110000000000)) // -2 <= x < -1, (2x + 5)/9

        begin
            product = ($signed(16'b0000100000000000) * $signed(data_a_r) + $signed({16'b0001010000000000,10'b0}));  // 2x + 5
            temp_57 = (product * multiplier_1_div_3_26);  // 乘以 1/3
            temp2_83 = temp_57* multiplier_1_div_3_26;  // 乘以 1/3

            sum=temp2_83[65:50]+temp2_83[49]; //rounding
            o_data_w=($signed(sum)>$signed(16'b0111111111111111))?16'b0111111111111111:($signed(sum)<$signed(16'b1000000000000000))?16'b1000000000000000:sum[15:0];
        end
        else if ($signed(16'b1111010000000000) <= $signed(data_a_r) && $signed(data_a_r) < $signed(16'b1111100000000000))// -3 <= x < -2, (x + 3)/9
        begin
            product = (data_a_r + $signed(16'b0000110000000000));  // x + 3
            temp_42 = (product * multiplier_1_div_3_26);  // 乘以 1/3
            temp_58 = temp_42* multiplier_1_div_3_26;  // 乘以 1/3
            sum=temp_58[55:40]+temp_58[39]; //rounding      
            o_data_w=($signed(sum)>$signed(16'b0111111111111111))?16'b0111111111111111:($signed(sum)<$signed(16'b1000000000000000))?16'b1000000000000000:sum[15:0];
        end
        else begin
            // x <= -3
            o_data_w = 16'b0;  // 將輸出設為 0
        end
        Done = 1;
    end
    XOR:begin
        o_data_w=data_a_r^data_b_r;
        Done = 1;

    end
    ARS:begin
        o_data_w = data_a_r >>> data_b_r;
        Done = 1;

    end
    LR:begin
        o_data_w = (data_a_r << data_b_r) | (data_a_r >> (16'd16 - data_b_r)); 
        Done = 1;

    end
    CLZ:begin 
        o_data_w = 16'd16;    
        found = 1'b0;     
        
        for (i = 15; i >= 0; i = i - 1) begin
            if (!found && data_a_r[i] == 1) begin
                o_data_w = 16'd15 - i;  
                found = 1'b1;           
            end
        end
        
        Done = 1'b1; 

            
    end

    ReverseM4:begin
            for (i = 0; i <= 12; i = i + 1) begin
                if (data_a_r[i+:4] == data_b_r[(12-i)+:4])
                    o_data_w[i] = 1;
                else
                    o_data_w[i] = 0;
            end
            // 設定 i = 13 到 15
            for (i = 13; i <= 15; i = i + 1) begin
                o_data_w[i] = 0;
            end    
    Done=1;

    end
    default:begin
        o_data_w=0;Done=0;
    end




    endcase
    end
end



endmodule
