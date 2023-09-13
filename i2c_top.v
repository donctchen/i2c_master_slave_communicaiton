`timescale 1ns/1ns

module i2c_top (
    input wire clk,
    input wire reset_n,
    output wire [15:0] pass_led,
    inout wire sda,
    inout wire scl   
);

reg	ena, rw;
reg [6:0] address;
reg [7:0] data_to_write;
reg led_reg;
reg next_led_reg;
assign pass_led = {16{led_reg}};
reg [19:0] init_count;
reg get_started;
reg [2:0] FSM_state = 0;
reg [2:0] next_FSM_state;
reg ena_next, rw_next;
// transfer to wire port to module connection
wire ena_wire;
assign ena_wire = ena;
wire [6:0] addr_wire;
assign addr_wire = address;
wire rw_wire;
assign rw_wire = rw;
wire [7:0] data_wr_wire;
assign data_wr_wire = data_to_write;

wire busy, ack_error;
wire [7:0]	data_rd;


i2c_master i2c_master(
    // input
    .clk(clk),
    .reset_n(reset_n),
    .ena(ena_wire),
    .addr(addr_wire),
    .rw(rw_wire),
    .data_wr(data_wr_wire),
    // output
    .busy(busy),
    .data_rd(data_rd),
    .ack_error(ack_error), // buffer
    // input
    .sda(sda), 
    .scl(scl) );



// slave
I2CTest i2ctest(.CLCK(clk),
				.SCL(scl),
				.SDA(sda));


// FSM
parameter IDLE  = 3'b000;
parameter WRCMD = 3'b001;
parameter WAITWR = 3'b010;
parameter RDCMD = 3'b011;
parameter WAITRD = 3'b100;
parameter COMPARE = 3'b101;
parameter FAILED =  3'b110;
parameter PASS = 3'b111;



always@(posedge clk or negedge reset_n)
begin
    if (!reset_n) begin
        init_count <= 20'h0;
        get_started <= 1'b0;
    end
    else begin
        if (init_count == 20'h0000f) 
            get_started <= #1 1'b1;
        else
            init_count <= #1 init_count + 20'h00001;
    end
end


always@(posedge clk or negedge reset_n)
begin
    if (!reset_n) begin
        FSM_state <= #1 IDLE;
        ena <= #1 1'b0;
        rw <= #1 1'b0;
        led_reg <= #1 1'b0;
    end
    else begin
        FSM_state <= #1 next_FSM_state;
        ena <= #1 ena_next;
        rw <= #1 rw_next;        
        led_reg <= #1 next_led_reg;
    end
end

always@(*)
begin    
    address = 7'h55;
    data_to_write = 8'haa;
    next_FSM_state = FSM_state;
    ena_next = ena;
    rw_next = rw;
    next_led_reg = led_reg;

    case (FSM_state)
        
        IDLE: begin     
            next_led_reg = 1'b0;            
            next_FSM_state =(get_started)? WRCMD : IDLE;
        end

        WRCMD: begin // start write
            ena_next = 1'b1; // enable I2C
            rw_next = 1'b0; // write mode          
            // if busy = 1, start work, go to next wait state  
            // otherwise wait busy on
            next_FSM_state = (busy)? WAITWR: WRCMD;
        end

        WAITWR: begin
            if(ack_error)
                next_FSM_state = FAILED;
            else begin
                 // wait ready 
                if (busy) begin // busy = 1
                    next_FSM_state = WAITWR; 
                    // Master IC get the ena signal
                    ena_next = 1'b0;
                end
                else begin // busy = 0
                    // finish writing       
                    next_FSM_state = RDCMD;
                end
            end           
        end

        RDCMD: begin  // Start read
            ena_next = 1'b1;
            rw_next = 1'b1; // read mode
            // busy = 1, go to next wait state    
            next_FSM_state = (busy)? WAITRD : RDCMD;
        end

        WAITRD: begin
            if(ack_error)
                next_FSM_state = FAILED;
            else begin
                if (busy) begin
                // wait until busy signal low
                    next_FSM_state = WAITRD;
                    ena_next = 1'b0;
                end
                else begin   // finish read              
                    next_FSM_state = COMPARE;
                end
            end
            
        end

        COMPARE: begin
            if (data_rd == 8'haa) begin
                next_FSM_state = PASS;
            end
            else begin
                next_FSM_state = FAILED;
            end
        end

        FAILED: begin
            next_led_reg = 1'b0;
        end

        PASS: begin
            next_led_reg = 1'b1;
        end

        default: begin
            next_FSM_state = IDLE;
        end

    endcase
end
endmodule