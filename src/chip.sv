`default_nettype none

module my_chip (
    input logic [11:0] io_in, // Inputs to your chip
    output logic [11:0] io_out, // Outputs from your chip
    input logic clock,
    input logic reset // Important: Reset is ACTIVE-HIGH
);
  
  output logic RS, RW,
  output logic [7:0] bus,
  output logic enable_l);
    
   platformer pltfm(.clk(clock), .reset, .jump(io_in[0]), 
                    .RS(io_out[0]), .RW(io_out[1]), .enable_l(io_out[2]),
                    .bus(io_out[10:3])); 

  assign io_out[11] = 1'b0;
endmodule
