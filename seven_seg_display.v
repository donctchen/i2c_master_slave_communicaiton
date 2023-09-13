`timescale 1ns/1ns
// display normal or error information in seven seg
module seven_seg_display(
    input wire clk,
    input wire reset,
    input wire pass,
    // 7 seg control signals
    output wire seg_a, 
    output wire seg_b,
    output wire seg_c,
    output wire seg_d,
	output wire	seg_e,
    output wire seg_f,
    output wire seg_g,
    output wire seg_dp,
	output wire	com0,
    output wire com1,
    output wire com2,
    output wire com3
);

reg [3:0] text;
reg [6:0] seg_values; 

reg com0_reg = 1; // default off
reg com1_reg = 1;
reg com2_reg = 1;
reg com3_reg = 1;
assign seg_a = ~seg_values[6];
assign seg_b = ~seg_values[5];
assign seg_c = ~seg_values[4];
assign seg_d = ~seg_values[3];
assign seg_e = ~seg_values[2];
assign seg_f = ~seg_values[1];
assign seg_g = ~seg_values[0];
assign seg_dp = ~0; 
assign com0 = com0_reg;
assign com1 = com1_reg;
assign com2 = com2_reg;
assign com3 = com3_reg;



localparam REFRESH_COUNT = 100000; 

// 1 mS = 100,000 count of 10ns (100MHz)
// FSM state
localparam IDLE = 0;
localparam DIGIT0 = 1;
localparam DIGIT1 = 2;
localparam DIGIT2 = 3;
localparam DIGIT3 = 4;
localparam TIMER = 5;
reg [3:0] Sev_Seg_FSM_state = IDLE;
reg [3:0] return_state;
reg [17:0] count;
always@(posedge clk or negedge reset)
begin
    if (!reset) begin    
        Sev_Seg_FSM_state <= IDLE;
        text <= 4'b0000;
        count <= 0;
        return_state <= 0;
    end
    else begin
                    
        case (Sev_Seg_FSM_state)
            IDLE: begin            
                Sev_Seg_FSM_state <= (pass)? DIGIT0: IDLE;
                com0_reg <= 1'b1;
                com1_reg <= 1'b1;
                com2_reg <= 1'b1;
                com3_reg <= 1'b1;                
                count <= 0;
            end

            DIGIT0: begin
                com0_reg <= 1'b0; // turn on 1st 7 seg
                com1_reg <= 1'b1;
                com2_reg <= 1'b1;
                com3_reg <= 1'b1;         
                text <= 4'b0010; // S       
                Sev_Seg_FSM_state <= TIMER;
                return_state <=  DIGIT1;
                count <= REFRESH_COUNT;
            end

            DIGIT1: begin
                com0_reg <= 1'b1;
                com1_reg <= 1'b0;                
                com2_reg <= 1'b1;
                com3_reg <= 1'b1;         
                text <=  4'b0010;                
                Sev_Seg_FSM_state <= TIMER;
                return_state <=  DIGIT2;
                count <= REFRESH_COUNT;           
            end

            DIGIT2: begin
                com0_reg <= 1'b1;
                com1_reg <= 1'b1; 
                com2_reg <= 1'b0;
                com3_reg <= 1'b1; 
                text <= 4'b0001; // A              
                Sev_Seg_FSM_state <= TIMER;
                return_state <=  DIGIT3;
                count <= REFRESH_COUNT;
            end

            DIGIT3: begin
                com0_reg <= 1'b1;
                com1_reg <= 1'b1; 
                com2_reg <= 1'b1;
                com3_reg <= 1'b0;       
                text <= 4'b0000; // P               
                Sev_Seg_FSM_state <= TIMER;
                return_state <=  DIGIT0;
                count <= REFRESH_COUNT;
            end

            TIMER: begin
                count <= (count > 0 )? count - 1 : 0;
                Sev_Seg_FSM_state <= (count > 0)? TIMER: return_state;
            end
        endcase
    end
end


always@(*)
begin
    case (text)
        4'b0000: seg_values = 7'b1100111; // P
        4'b0001: seg_values = 7'b1110111; // A
        4'b0010: seg_values = 7'b1011011; // S
        4'b0011: seg_values = 7'b1000111; // F
        4'b0100: seg_values = 7'b0110000; // I
        4'b0101: seg_values = 7'b0001110; // L
        default: seg_values = 7'b0000000; // 0
    endcase
end

endmodule