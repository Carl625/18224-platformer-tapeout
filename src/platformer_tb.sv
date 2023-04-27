`default_nettype none

module platformer_tb();

  logic [3:0][15:0][7:0] display_output;
  logic [7:0] bus;
  logic clk, rst_l;
  logic enable_l, RS, RW;
  logic jump;

  // instantiate platformer
  platformer game(.*);

  // instantiate display
  // Display disp(.*);

  initial
  begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // primitive output testbench
  initial
  begin
    $monitor($time,,
              "Bus: %0b, RS: %b, RW: %b, enable: %b",
              bus, RS, RW, enable_l);

    rst_l = 1'b1;
    #1 rst_l = 1'b0;
    #1 rst_l = 1'b1;

    @(posedge clk);

    for (int i = 0; i < 10000000; i++)
    begin
      @(posedge clk);
    end

    $finish;
  end



  // Initialization checking
  // Main procedure 

  // display testbench
  /*
  initial
  begin
    rst_l = 1'b1;
    #1 rst_l = 1'b0;
    #1 rst_l = 1'b1;

    @(posedge clk);

    jump = 1'b1;

    for (int i = 0; i < 1000; i++)
    begin
      //Top line
      $display("", );
      // Line 3
      $display();
      // Line 22
      $display();
      // Bottom Line
      $display();
      @(posedge clk);
    end

    $finish;
  end
  */

endmodule: platformer_tb

/*
module display_to_char(
  input logic [3:0][15:0][7:0] disp_output,
  output string [3:0][15:0] disp_output_chars);

  genvar i, j;
  generate
    for (int i = 0; i < 4; i++)
    begin
      for (int j = 0; j < 16; i++)
      begin

        always_comb
        begin
          case (disp_output[i][j][7:4])
            4'h0:
              case (disp_output[i][j][3:0])
                4'h0: disp_output_chars[i][j] = " ";
                4'h1: disp_output_chars[i][j] = " ";
                4'h2: disp_output_chars[i][j] = " ";
                4'h3: disp_output_chars[i][j] = " ";
                4'h4: disp_output_chars[i][j] = " ";
                4'h5: disp_output_chars[i][j] = " ";
                4'h6: disp_output_chars[i][j] = " ";
                4'h7: disp_output_chars[i][j] = " ";
                4'h8: disp_output_chars[i][j] = " ";
                4'h9: disp_output_chars[i][j] = " ";
                4'hA: disp_output_chars[i][j] = " ";
                4'hB: disp_output_chars[i][j] = " ";
                4'hC: disp_output_chars[i][j] = " ";
                4'hD: disp_output_chars[i][j] = " ";
                4'hE: disp_output_chars[i][j] = " ";
                4'hF: disp_output_chars[i][j] = " ";
              endcase
            4'h1:
              case (disp_output[i][j][3:0])
                4'h0: disp_output_chars[i][j] = " ";
                4'h1: disp_output_chars[i][j] = " ";
                4'h2: disp_output_chars[i][j] = " ";
                4'h3: disp_output_chars[i][j] = " ";
                4'h4: disp_output_chars[i][j] = " ";
                4'h5: disp_output_chars[i][j] = " ";
                4'h6: disp_output_chars[i][j] = " ";
                4'h7: disp_output_chars[i][j] = " ";
                4'h8: disp_output_chars[i][j] = " ";
                4'h9: disp_output_chars[i][j] = " ";
                4'hA: disp_output_chars[i][j] = " ";
                4'hB: disp_output_chars[i][j] = " ";
                4'hC: disp_output_chars[i][j] = " ";
                4'hD: disp_output_chars[i][j] = " ";
                4'hE: disp_output_chars[i][j] = " ";
                4'hF: disp_output_chars[i][j] = " ";
              endcase
            4'h2:
              case (disp_output[i][j][3:0])
                4'h0: disp_output_chars[i][j] = " ";
                4'h1: disp_output_chars[i][j] = "!";
                4'h2: disp_output_chars[i][j] = "\"";
                4'h3: disp_output_chars[i][j] = "#";
                4'h4: disp_output_chars[i][j] = "$";
                4'h5: disp_output_chars[i][j] = "%";
                4'h6: disp_output_chars[i][j] = "&";
                4'h7: disp_output_chars[i][j] = "\'";
                4'h8: disp_output_chars[i][j] = "(";
                4'h9: disp_output_chars[i][j] = ")";
                4'hA: disp_output_chars[i][j] = "*";
                4'hB: disp_output_chars[i][j] = "+";
                4'hC: disp_output_chars[i][j] = ",";
                4'hD: disp_output_chars[i][j] = "-";
                4'hE: disp_output_chars[i][j] = ".";
                4'hF: disp_output_chars[i][j] = "/";
              endcase
            4'h3:
              case (disp_output[i][j][3:0])
                4'h0: disp_output_chars[i][j] = "0";
                4'h1: disp_output_chars[i][j] = "1";
                4'h2: disp_output_chars[i][j] = "2";
                4'h3: disp_output_chars[i][j] = "3";
                4'h4: disp_output_chars[i][j] = "4";
                4'h5: disp_output_chars[i][j] = "5";
                4'h6: disp_output_chars[i][j] = "6";
                4'h7: disp_output_chars[i][j] = "7";
                4'h8: disp_output_chars[i][j] = "8";
                4'h9: disp_output_chars[i][j] = "9";
                4'hA: disp_output_chars[i][j] = ":";
                4'hB: disp_output_chars[i][j] = ";";
                4'hC: disp_output_chars[i][j] = "<";
                4'hD: disp_output_chars[i][j] = "=";
                4'hE: disp_output_chars[i][j] = ">";
                4'hF: disp_output_chars[i][j] = "?";
              endcase
            4'h4:
              case (disp_output[i][j][3:0])
                4'h0: disp_output_chars[i][j] = "@";
                4'h1: disp_output_chars[i][j] = "A";
                4'h2: disp_output_chars[i][j] = "B";
                4'h3: disp_output_chars[i][j] = "C";
                4'h4: disp_output_chars[i][j] = "D";
                4'h5: disp_output_chars[i][j] = "E";
                4'h6: disp_output_chars[i][j] = "F";
                4'h7: disp_output_chars[i][j] = "G";
                4'h8: disp_output_chars[i][j] = "H";
                4'h9: disp_output_chars[i][j] = "I";
                4'hA: disp_output_chars[i][j] = "J";
                4'hB: disp_output_chars[i][j] = "K";
                4'hC: disp_output_chars[i][j] = "L";
                4'hD: disp_output_chars[i][j] = "M";
                4'hE: disp_output_chars[i][j] = "N";
                4'hF: disp_output_chars[i][j] = "O";
              endcase
            4'h5:
              case (disp_output[i][j][3:0])
                4'h0: disp_output_chars[i][j] = "P";
                4'h1: disp_output_chars[i][j] = "Q";
                4'h2: disp_output_chars[i][j] = "R";
                4'h3: disp_output_chars[i][j] = "S";
                4'h4: disp_output_chars[i][j] = "T";
                4'h5: disp_output_chars[i][j] = "U";
                4'h6: disp_output_chars[i][j] = "V";
                4'h7: disp_output_chars[i][j] = "W";
                4'h8: disp_output_chars[i][j] = "X";
                4'h9: disp_output_chars[i][j] = "Y";
                4'hA: disp_output_chars[i][j] = "Z";
                4'hB: disp_output_chars[i][j] = "[";
                4'hC: disp_output_chars[i][j] = "Y";
                4'hD: disp_output_chars[i][j] = "]";
                4'hE: disp_output_chars[i][j] = "^";
                4'hF: disp_output_chars[i][j] = "_";
              endcase
            4'h6:
              case (disp_output[i][j][3:0])
                4'h0: disp_output_chars[i][j] = "`";
                4'h1: disp_output_chars[i][j] = "a";
                4'h2: disp_output_chars[i][j] = "b";
                4'h3: disp_output_chars[i][j] = "c";
                4'h4: disp_output_chars[i][j] = "d";
                4'h5: disp_output_chars[i][j] = "e";
                4'h6: disp_output_chars[i][j] = "f";
                4'h7: disp_output_chars[i][j] = "g";
                4'h8: disp_output_chars[i][j] = "h";
                4'h9: disp_output_chars[i][j] = "i";
                4'hA: disp_output_chars[i][j] = "j";
                4'hB: disp_output_chars[i][j] = "k";
                4'hC: disp_output_chars[i][j] = "l";
                4'hD: disp_output_chars[i][j] = "m";
                4'hE: disp_output_chars[i][j] = "n";
                4'hF: disp_output_chars[i][j] = "o";
              endcase
            4'h7:
              case (disp_output[i][j][3:0])
                4'h0: disp_output_chars[i][j] = "p";
                4'h1: disp_output_chars[i][j] = "q";
                4'h2: disp_output_chars[i][j] = "r";
                4'h3: disp_output_chars[i][j] = "s";
                4'h4: disp_output_chars[i][j] = "t";
                4'h5: disp_output_chars[i][j] = "u";
                4'h6: disp_output_chars[i][j] = "v";
                4'h7: disp_output_chars[i][j] = "w";
                4'h8: disp_output_chars[i][j] = "x";
                4'h9: disp_output_chars[i][j] = "y";
                4'hA: disp_output_chars[i][j] = "z";
                4'hB: disp_output_chars[i][j] = "(";
                4'hC: disp_output_chars[i][j] = "|";
                4'hD: disp_output_chars[i][j] = ")";
                4'hE: disp_output_chars[i][j] = "->";
                4'hF: disp_output_chars[i][j] = "<-";
              endcase
            4'h8:
              case (disp_output[i][j][3:0])
                4'h0: disp_output_chars[i][j] = " ";
                4'h1: disp_output_chars[i][j] = " ";
                4'h2: disp_output_chars[i][j] = " ";
                4'h3: disp_output_chars[i][j] = " ";
                4'h4: disp_output_chars[i][j] = " ";
                4'h5: disp_output_chars[i][j] = " ";
                4'h6: disp_output_chars[i][j] = " ";
                4'h7: disp_output_chars[i][j] = " ";
                4'h8: disp_output_chars[i][j] = " ";
                4'h9: disp_output_chars[i][j] = " ";
                4'hA: disp_output_chars[i][j] = " ";
                4'hB: disp_output_chars[i][j] = " ";
                4'hC: disp_output_chars[i][j] = " ";
                4'hD: disp_output_chars[i][j] = " ";
                4'hE: disp_output_chars[i][j] = " ";
                4'hF: disp_output_chars[i][j] = " ";
              endcase
            4'h9:
              case (disp_output[i][j][3:0])
                4'h0: disp_output_chars[i][j] = " ";
                4'h1: disp_output_chars[i][j] = " ";
                4'h2: disp_output_chars[i][j] = " ";
                4'h3: disp_output_chars[i][j] = " ";
                4'h4: disp_output_chars[i][j] = " ";
                4'h5: disp_output_chars[i][j] = " ";
                4'h6: disp_output_chars[i][j] = " ";
                4'h7: disp_output_chars[i][j] = " ";
                4'h8: disp_output_chars[i][j] = " ";
                4'h9: disp_output_chars[i][j] = " ";
                4'hA: disp_output_chars[i][j] = " ";
                4'hB: disp_output_chars[i][j] = " ";
                4'hC: disp_output_chars[i][j] = " ";
                4'hD: disp_output_chars[i][j] = " ";
                4'hE: disp_output_chars[i][j] = " ";
                4'hF: disp_output_chars[i][j] = " ";
              endcase
            4'hA:
              case (disp_output[i][j][3:0])
                4'h0: disp_output_chars[i][j] = " ";
                4'h1: disp_output_chars[i][j] = ".";
                4'h2: disp_output_chars[i][j] = "<";
                4'h3: disp_output_chars[i][j] = ">";
                4'h4: disp_output_chars[i][j] = "\\";
                4'h5: disp_output_chars[i][j] = ".";
                4'h6: disp_output_chars[i][j] = " ";
                4'h7: disp_output_chars[i][j] = " ";
                4'h8: disp_output_chars[i][j] = " ";
                4'h9: disp_output_chars[i][j] = " ";
                4'hA: disp_output_chars[i][j] = " ";
                4'hB: disp_output_chars[i][j] = " ";
                4'hC: disp_output_chars[i][j] = " ";
                4'hD: disp_output_chars[i][j] = " ";
                4'hE: disp_output_chars[i][j] = " ";
                4'hF: disp_output_chars[i][j] = " ";
              endcase
            4'hB:
              case (disp_output[i][j][3:0])
                4'h0: disp_output_chars[i][j] = "_";
                4'h1: disp_output_chars[i][j] = " ";
                4'h2: disp_output_chars[i][j] = " ";
                4'h3: disp_output_chars[i][j] = " ";
                4'h4: disp_output_chars[i][j] = " ";
                4'h5: disp_output_chars[i][j] = " ";
                4'h6: disp_output_chars[i][j] = " ";
                4'h7: disp_output_chars[i][j] = " ";
                4'h8: disp_output_chars[i][j] = " ";
                4'h9: disp_output_chars[i][j] = " ";
                4'hA: disp_output_chars[i][j] = " ";
                4'hB: disp_output_chars[i][j] = " ";
                4'hC: disp_output_chars[i][j] = " ";
                4'hD: disp_output_chars[i][j] = " ";
                4'hE: disp_output_chars[i][j] = " ";
                4'hF: disp_output_chars[i][j] = " ";
              endcase
            4'hC:
              case (disp_output[i][j][3:0])
                4'h0: disp_output_chars[i][j] = " ";
                4'h1: disp_output_chars[i][j] = " ";
                4'h2: disp_output_chars[i][j] = " ";
                4'h3: disp_output_chars[i][j] = " ";
                4'h4: disp_output_chars[i][j] = " ";
                4'h5: disp_output_chars[i][j] = " ";
                4'h6: disp_output_chars[i][j] = " ";
                4'h7: disp_output_chars[i][j] = " ";
                4'h8: disp_output_chars[i][j] = " ";
                4'h9: disp_output_chars[i][j] = " ";
                4'hA: disp_output_chars[i][j] = " ";
                4'hB: disp_output_chars[i][j] = " ";
                4'hC: disp_output_chars[i][j] = " ";
                4'hD: disp_output_chars[i][j] = " ";
                4'hE: disp_output_chars[i][j] = " ";
                4'hF: disp_output_chars[i][j] = " ";
              endcase
            4'hD:
              case (disp_output[i][j][3:0])
                4'h1: disp_output_chars[i][j] = " ";
                4'h2: disp_output_chars[i][j] = " ";
                4'h3: disp_output_chars[i][j] = " ";
                4'h4: disp_output_chars[i][j] = " ";
                4'h5: disp_output_chars[i][j] = " ";
                4'h6: disp_output_chars[i][j] = " ";
                4'h7: disp_output_chars[i][j] = " ";
                4'h8: disp_output_chars[i][j] = " ";
                4'h9: disp_output_chars[i][j] = " ";
                4'hA: disp_output_chars[i][j] = " ";
                4'hB: disp_output_chars[i][j] = " ";
                4'hC: disp_output_chars[i][j] = " ";
                4'hD: disp_output_chars[i][j] = " ";
                4'hE: disp_output_chars[i][j] = " ";
                4'hF: disp_output_chars[i][j] = " ";
              endcase
            4'hE:
              case (disp_output[i][j][3:0])
                4'h0: disp_output_chars[i][j] = " ";
                4'h1: disp_output_chars[i][j] = " ";
                4'h2: disp_output_chars[i][j] = " ";
                4'h3: disp_output_chars[i][j] = " ";
                4'h4: disp_output_chars[i][j] = " ";
                4'h5: disp_output_chars[i][j] = " ";
                4'h6: disp_output_chars[i][j] = " ";
                4'h7: disp_output_chars[i][j] = " ";
                4'h8: disp_output_chars[i][j] = " ";
                4'h9: disp_output_chars[i][j] = " ";
                4'hA: disp_output_chars[i][j] = " ";
                4'hB: disp_output_chars[i][j] = " ";
                4'hC: disp_output_chars[i][j] = " ";
                4'hD: disp_output_chars[i][j] = " ";
                4'hE: disp_output_chars[i][j] = " ";
                4'hF: disp_output_chars[i][j] = " ";
              endcase
            4'hF:
              case (disp_output[i][j][3:0])
                4'h0: disp_output_chars[i][j] = " ";
                4'h1: disp_output_chars[i][j] = " ";
                4'h2: disp_output_chars[i][j] = " ";
                4'h3: disp_output_chars[i][j] = " ";
                4'h4: disp_output_chars[i][j] = " ";
                4'h5: disp_output_chars[i][j] = " ";
                4'h6: disp_output_chars[i][j] = " ";
                4'h7: disp_output_chars[i][j] = " ";
                4'h8: disp_output_chars[i][j] = " ";
                4'h9: disp_output_chars[i][j] = " ";
                4'hA: disp_output_chars[i][j] = " ";
                4'hB: disp_output_chars[i][j] = " ";
                4'hC: disp_output_chars[i][j] = " ";
                4'hD: disp_output_chars[i][j] = " ";
                4'hE: disp_output_chars[i][j] = " ";
                4'hF: disp_output_chars[i][j] = "*";
              endcase
          endcase
        end
      end
    end
  endgenerate

endmodule: display_to_char
*/
