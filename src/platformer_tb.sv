`default_nettype none

module platformer_tb();

  logic [3:0][15:0][7:0] display_output;
  logic [7:0] bus;
  logic clk, reset;
  logic enable_l, RS, RW;
  logic jump;

  // instantiate platformer
  platformer game(.*);

  // instantiate display
  // Display disp(.*);

  parameter CHK_OUTPUT = 1;

  initial
  begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  // primitive output testbench & jump generator
  initial
  begin
    $monitor($time,,
              "Bus: %0b, RS: %b, RW: %b, enable: %b",
              bus, RS, RW, enable_l);

    reset = 1'b0;
    #1 reset = 1'b1;
    #1 reset = 1'b0;

    @(posedge clk);

    for (int i = 0; i < 10000000; i++)
    begin
      @(posedge clk);
      jump = i % 2;
    end

    $finish;
  end

  generate
    if (CHK_OUTPUT)
    begin
      // invaraints
      
      logic top_pltfm_addr, middle_pltfm_addr, bot_pltfm_addr, new_pltfm_addr, new_player_addr;
      logic dram_base;

      assign dram_base
      assign top_pltfm_addr

      assert property (@(posedge clk) $fell(enable_l) |-> ##2 $rose(enable_l));

      task check_command(input logic[7:0] command);
        assert (bus === command);
        assert (RS === 1'd0);
        assert (RW === 1'd0);
      endtask

      task check_write(input logic[7:0] data);
        assert (bus === data);
        assert (RS === 1'b1);
        assert (RW === 1'b0);
      endtask

      // Initialization checking
      initial
      begin
        // check enable is zeroed at beginning
        wait(~reset);
        @(posedge clk);
        assert ( enable_l = 1'b0 );
        // check for wake up call #1
        wait(game.initialization_counter === game.WKUP1);
        @(posedge clk);
        @(posedge clk);
        check_command(8'h30);
        // check for wake up call #2
        wait(game.initialization_counter === game.WKUP2);
        @(posedge clk);
        @(posedge clk);
        check_command(8'h30);
        // check for wake up call #3
        wait(game.initialization_counter === game.WKUP3);
        @(posedge clk);
        @(posedge clk);
        check_command(8'h30);
        // check for function set command
        wait(game.initialization_counter === game.DYNAMIC);
        wait(game.op_state === game.OP)
        @(posedge clk);
        @(posedge clk);
        check_command(8'h38);
        // check for cursor set command
        wait(game.op_state === game.OP)
        @(posedge clk);
        @(posedge clk);
        check_command(8'h10);
        // check for display on command
        wait(game.op_state === game.OP)
        @(posedge clk);
        @(posedge clk);
        check_command(8'h0C);
        // check for entry mode set command
        wait(game.op_state === game.OP)
        @(posedge clk);
        @(posedge clk);
        check_command(8'h06);
        // check for clear screen command
        wait(game.op_state === game.OP)
        @(posedge clk);
        @(posedge clk);
        check_command(8'h01);
        // check for return home command
        wait(game.op_state === game.OP)
        @(posedge clk);
        @(posedge clk);
        check_command(8'h02);
        
        // check for addressing to 0x50
        wait(game.op_state === game.OP)
        @(posedge clk);
        @(posedge clk);
        check_command(8'h80 | 8'h50);

        // check all the writes for the initial platform
        for (int i = 0; i < 16; i++)
        begin  
          wait(game.op_state === game.OP)
          @(posedge clk);
          @(posedge clk);
          check_write(8'hFF);
        end

        // check the adressing to 0x13 for the player
        wait(game.op_state === game.OP)
        @(posedge clk);
        @(posedge clk);
        check_command(8'h80 | 8'h13);

        // check for a write of 0xFF to player pos
        wait(game.op_state === game.OP)
        @(posedge clk);
        @(posedge clk);
        check_write(8'hFF);
        
        // end of game
        wait(game.game_end === 1'd1);
        $finish
      end

      // Main procedure 
      initial
      begin
        
        while (game.game_end != 1'd1)
        begin
          // wait for WAIT stage to be over
          wait(game.game_state === game.CLEAN_UP);
          @(posedge clk);
          @(posedge clk);


          // check for addressing of top platform position (0x40)
          wait(game.game_state === game.CLEAN_UP && game.interval_counter === 16'd1);
          @(posedge clk);
          @(posedge clk);
          check_command(8'h80 | top_pltfm_addr);

          // check for erasure of top platform pos
          wait(game.game_state === game.CLEAN_UP && game.interval_counter === 16'd2);
          @(posedge clk);
          @(posedge clk);
          check_write(8'h20);
          
          // check for addressing of middle platform (0x10)
          wait(game.game_state === game.CLEAN_UP && game.interval_counter === 16'd3);
          @(posedge clk);
          @(posedge clk);
          check_command(8'h80 | middle_pltfm_addr);
          
          // check for erasure of middle platform pos
          wait(game.game_state === game.CLEAN_UP && game.interval_counter === 16'd4);
          @(posedge clk);
          @(posedge clk);
          check_write(8'h20);
          
          // check for addressing of bottom platform (0x50)
          wait(game.game_state === game.CLEAN_UP && game.interval_counter === 16'd5);
          @(posedge clk);
          @(posedge clk);
          check_command(8'h80 | bot_pltfm_addr);
          
          // check for erausre of bottom platform pos
          wait(game.game_state === game.CLEAN_UP && game.interval_counter === 16'd6);
          @(posedge clk);
          @(posedge clk);
          check_write(8'h20);
          
          // transition to shift state
          // check for shift command
          wait(game.game_state === game.SHIFT && game.interval_counter === 16'd8);
          @(posedge clk);
          @(posedge clk);
          check_command(8'h18);

          // calculation of new platform height
          wait(game.game_state === game.PLATFORM_EXT && game.interval_counter === 16'd9);
          @(posedge clk);
          @(posedge clk);
          
          // check for addressing of new platform address
          wait(game.game_state === game.PLATFORM_EXT && game.interval_counter === 16'd10);
          @(posedge clk);
          @(posedge clk);
          check_command(8'h80 | new_pltfm_addr);
          
          // check for write of FF to new platform address
          wait(game.game_state === game.PLATFORM_EXT && game.interval_counter === 16'd11);
          @(posedge clk);
          @(posedge clk);
          check_write(8'hFF);
          
          // transition to player height recalculation
          wait(game.game_state === game.PLATFORM_EXT && game.interval_counter === 16'd12);
          
          // check for addressing to new player height
          wait(game.game_state === game.PLAYER_HEIGHT && game.interval_counter === 16'd13);
          @(posedge clk);
          @(posedge clk);
          check_command(8'h80 | new_player_addr);
          
          // check for the write of 0xFF to new player addr
          wait(game.game_state === game.PLAYER_HEIGHT && game.interval_counter === 16'd13);
          @(posedge clk);
          @(posedge clk);
          check_write(8'hFF);
          
          // repeat

        end
        
        // end of game
        $finish
      end
    end
    else
    begin
      // basic Monitoring testbench
      initial
      begin
      end
    end
  endgenerate

  // display testbench
  /*
  initial
  begin
    reset = 1'b0;
    #1 reset = 1'b1;
    #1 reset = 1'b0;

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
