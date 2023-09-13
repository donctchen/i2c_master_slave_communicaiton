`timescale 1 ns/1 ns

module testbench;
reg	reset_n, clk;
wire pass_led;

i2c_top i2c_top (
    .clk(clk),
    .reset_n(reset_n),
    .pass_led(pass_led),
    .sda(sda),
    .scl(scl)
);

//wire sda, scl;
pullup(sda);
pullup(scl);

//wire scl, sda;
//pullup(scl);  // pull up signal
//pullup(sda);

//assign  scl = (scl_ctl) ? scl_out : 1'bz;
//assign  sda = (sda_ctl) ? sda_out : 1'bz;

// set up clk with 10 ns period 100 MHz
parameter clkper = 10;
initial
begin
	clk = 1;	// Time = 0
end

always 
begin
	#(clkper / 2)  clk = ~clk;
end

initial
begin
 reset_n  = 1'b0;	// Time = 0

 #200;			
 reset_n  = 1'b1;
// #50;	
//  reset_n  = 1'b0;
//  #50;	
//  reset_n  = 1'b1;
 
end
endmodule
