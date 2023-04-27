`default_nettype none

/* Display Abstraction for Testing Purposes:
 * 4 rows x 16 columns 8-bit character display output
 * DDRAM addr range (inclusive): 00-4F
 * (RS: 0, RW: 0) -> Write Instruction Code
 * (RS: 0, RW: 1) ->
 */
module Display(
  input logic clk, rst_l,
  input logic enable_l,
  input logic RS, RW,
  input logic [7:0] bus,
  output logic [3:0][15:0][7:0] display_output);

  // display function
  parameter CLR = {1'b0, 1'b0, 8'b0000_0000};
  parameter RET = {1'b0, 1'b0, 8'b0000_001x};
  parameter ENT = {1'b0, 1'b0, 8'b0000_01xx};
  parameter DSP = {1'b0, 1'b0, 8'b0000_1xxx};
  parameter CSR = {1'b0, 1'b0, 8'b0001_xxxx};
  parameter FNC = {1'b0, 1'b0, 8'b001x_xxxx};
  parameter CGR = {1'b0, 1'b0, 8'b01xx_xxxx};
  parameter DDR = {1'b0, 1'b0, 8'b1xxx_xxxx};
  parameter BSY = {1'b0, 1'b1, 8'bxxxx_xxxx};
  parameter DRD = {1'b1, 1'b0, 8'bxxxx_xxxx};
  parameter DWR = {1'b1, 1'b1, 8'bxxxx_xxxx};

  logic busy;

  always_comb
  begin
    casex ({RS, RW, bus})
      CLR:
        begin
        end
      RET:
        begin
        end
      ENT:
        begin
        end
      DSP:
        begin
        end
      CSR:
        begin
        end
      FNC:
        begin
        end
      CGR:
        begin
        end
      DDR:
        begin
        end
    endcase
  end

  always_ff @(posedge clk, negedge rst_l)
  begin
    if (~rst_l)
    begin
      busy <= 1'b0;
    end
    else
    begin
      busy <= 1'b1;
    end
  end

endmodule: Display
