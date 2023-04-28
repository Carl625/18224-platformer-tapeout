`default_nettype none

module platformer(
  input logic clk, reset,
  input logic jump,
  output logic RS, RW,
  output logic [7:0] bus,
  output logic enable_l);

  // display commands
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

  // ASSUMING 500KHz CLOCK

  // bus modes
  enum { COMMAND, RD_BUSY, DRAM_RD, DRAM_WR } bus_mode;
  enum { ENABLE_HIGH, OP, ENABLE_LOW } op_state;

  // static initialization phase timings
  parameter ENABLE = 16'd0;
  parameter WKUP1 = 16'd20000;
  parameter WKUP2 = WKUP1 + 16'd2500 + 16'd1;
  parameter WKUP3 = WKUP2 + 16'd80 + 16'd1;
  parameter DYNAMIC = WKUP3 + 16'd80 + 16'd1;

  // game phase sub-phases
  enum { WAIT, CLEAN_UP, SHIFT, PLATFORM_EXT, PLAYER_HEIGHT, END_CHECK } game_state;

  // initialization phase trackers
  logic [15:0] initialization_counter;
  logic [3:0] dynamic_init_phases;
  logic [3:0] pltfm_write_counter;

  // game state info
  logic [11:0] pltfm_height_history[1:0];
  logic [15:0] interval_counter;
  logic [7:0] pltfm_addr, player_addr;
  logic [5:0] SH, SH_prev;
  logic [1:0] pltfm_height, plyr_height, plyr_pltfm_height;
  logic jmp_logged, unlog;

  // internal state info
  logic [7:0] next_data, next_command;
  logic command_processing, game_start, game_end;

  plyr_height_to_addr plyr_conv(.plyr_height, .player_addr);
  pltfm_height_to_addr pltfm_conv(.pltfm_height, .pltfm_addr);

  always_ff @(posedge clk, posedge reset)
  begin
    if (reset)
    begin
      pltfm_height_history[0] <= 2'b0;
      pltfm_height_history[1] <= 2'b0;
      pltfm_height_history[2] <= 2'b0;
      pltfm_height_history[3] <= 2'b0;
      pltfm_height_history[4] <= 2'b0;
      pltfm_height_history[5] <= 2'b0;
      pltfm_height_history[6] <= 2'b0;
      pltfm_height_history[7] <= 2'b0;
      pltfm_height_history[8] <= 2'b0;
      pltfm_height_history[9] <= 2'b0;
      pltfm_height_history[10] <= 2'b0;
      pltfm_height_history[11] <= 2'b0;

      SH_prev <= 6'd0;
    end
    else
    begin
      if (SH != SH_prev)
      begin
        pltfm_height_history[0] <= pltfm_height;
        pltfm_height_history[1] <= pltfm_height_history[0];
        pltfm_height_history[2] <= pltfm_height_history[1];
        pltfm_height_history[3] <= pltfm_height_history[2];
        pltfm_height_history[4] <= pltfm_height_history[3];
        pltfm_height_history[5] <= pltfm_height_history[4];
        pltfm_height_history[6] <= pltfm_height_history[5];
        pltfm_height_history[7] <= pltfm_height_history[6];
        pltfm_height_history[8] <= pltfm_height_history[7];
        pltfm_height_history[9] <= pltfm_height_history[8];
        pltfm_height_history[10] <= pltfm_height_history[9];
        pltfm_height_history[11] <= pltfm_height_history[10];
      end

      SH_prev <= SH;
    end
  end

  assign plyr_pltfm_height = pltfm_height_history[11];

  // jump logging
  assign jmp_logged = reset ? 1'b0:(jump | jmp_logged);

  // bus logic
  always_comb
  begin
    case (bus_mode)
      COMMAND:
      begin
        RS <= 1'b0;
        RW <= 1'b0;
        bus <= 8'd0;

        casex ({RS, RW, next_command})
          CLR:
            begin
              bus <= next_command;
            end
          RET:
            begin
              bus <= next_command;
            end
          ENT:
            begin
              bus <= next_command;
            end
          DSP:
            begin
              bus <= next_command;
            end
          CSR:
            begin
              bus <= next_command;
            end
          FNC:
            begin
              bus <= next_command;
            end
          CGR:
            begin
              // never used!
            end
          DDR:
            begin
              bus <= next_command;
            end
          default:
            begin
              bus <= 8'd0;
            end
        endcase
      end
      RD_BUSY:
      begin
        RS <= 1'b0;
        RW <= 1'b1;
        bus <= 8'd0;
      end
      DRAM_WR:
      begin
        RS <= 1'b1;
        RW <= 1'b0;
        bus <= next_data;
      end
      DRAM_RD:
      begin
        RS <= 1'b1;
        RW <= 1'b1;
        bus <= 8'd0;
        // never used!
      end
      default:
      begin
        // what to do here?
        RS <= 1'b0;
        RW <= 1'b0;
        bus <= 8'd0;
      end
    endcase
  end

  // initialization logic
  always_ff @(posedge clk, posedge reset)
  begin
    if (reset)
    begin
      enable_l <= 1'b0;
      bus_mode <= COMMAND;

      next_command <= 8'h00;
      command_processing <= 1'b0;

      initialization_counter <= 16'd0;
      dynamic_init_phases <= 4'd0;
      pltfm_write_counter <= 4'd0;

      game_start <= 1'b0;

      op_state = ENABLE_HIGH;
      game_state <= WAIT;
      interval_counter <= 16'd1;

      SH <= 6'd0;
      pltfm_height <= 2'd0;
      plyr_height <= 2'd1;

      unlog <= 1'b0;
    end
    else
    begin
      case (initialization_counter)
        ENABLE:
        begin
          enable_l <= 1'b1;
          bus_mode <= COMMAND;
          command_processing <= 1'b0;
        end
        WKUP1:
        begin
          enable_l <= 1'b1;
          bus_mode <= COMMAND;
          next_command <= 8'h30;
          command_processing <= 1'b1;
        end
        WKUP2:
        begin
          enable_l <= 1'b1;
          bus_mode <= COMMAND;
          next_command <= 8'h30;
          command_processing <= 1'b1;
        end
        WKUP3:
        begin
          enable_l <= 1'b1;
          bus_mode <= COMMAND;
          next_command <= 8'h30;
          command_processing <= 1'b1;
        end
        default:
        begin
          if ( initialization_counter >= DYNAMIC ) // contains all phases for sending commands that require waiting for 37 us
          begin
            if (command_processing) // wait for 19 cycles
            begin
              enable_l <= 1'b0;
              bus_mode <= COMMAND;
              command_processing <= ((initialization_counter - DYNAMIC) > 18) ?  1'b0:1'b1;
            end
            else
            begin
                // wrap operations in this 3 cycle procedure
                case (op_state)
                  ENABLE_HIGH:
                  begin
                    enable_l <= 1'b1;
                    bus_mode <= bus_mode;
                    command_processing <= command_processing;
                    op_state <= game_start ? ENABLE_HIGH:OP;
                  end
                  OP:
                  begin
                    enable_l <= enable_l;
                    bus_mode <= COMMAND;
                    command_processing <= 1'b1;
                    initialization_counter <= DYNAMIC;
                    dynamic_init_phases <= dynamic_init_phases + 4'd1;

                    case (dynamic_init_phases)
                      0:
                      begin
                        // function set
                        next_command <= 8'h38;
                      end
                      1:
                      begin
                        // cursor set
                        next_command <= 8'h10;
                      end
                      2:
                      begin
                        // display on
                        next_command <= 8'h0C;
                      end
                      3:
                      begin
                        // entry set
                        next_command <= 8'h06;
                      end
                      4:
                      begin
                        // clear screen
                        next_command <= 8'h01;
                      end
                      5:
                      begin
                        //return home
                        next_command <= 8'h02;
                      end
                      6:
                      begin
                        next_command <= (8'h80 | pltfm_addr - 8'h0F);
                      end
                      7:
                      begin
                        bus_mode <= DRAM_WR;
                        next_data <= 8'hFF;
                        pltfm_write_counter <= pltfm_write_counter + 4'd1;
                        // run this for 16 cycles to completely draw the
                        // initial platform
                        dynamic_init_phases <=  (pltfm_write_counter == 8'hFF) ? (dynamic_init_phases + 4'd1):dynamic_init_phases; 
                      end
                      8:
                      begin
                        next_command <= (8'h80 | player_addr);
                      end
                      9:
                      begin
                        // only need to draw this once in initialization!
                        bus_mode <= DRAM_WR;
                        next_data <= 8'hFF;
                      end
                      default:
                      begin
                        // GAME PHASE, pause initialization phases forever
                        dynamic_init_phases <= dynamic_init_phases;

                        case (game_state)
                          WAIT:
                          begin
                            enable_l <= 1'b0;
                            bus_mode <= COMMAND;
                            next_command <= 8'h00;
                            game_state <= interval_counter ? WAIT:CLEAN_UP;
                            interval_counter <= interval_counter + 16'd1;
                            unlog <= 1'b1;
                          end
                          CLEAN_UP:
                          begin
                            case (interval_counter)
                              1: // look at top platform to clean
                              begin
                                enable_l <= 1'b1;
                                bus_mode <= COMMAND;
                                next_command <= (8'h80 | ({2'b0, SH} + 8'h40));
                              end
                              2:
                              begin
                                enable_l <= 1'b1;
                                bus_mode <= DRAM_WR;
                                next_data <= 8'h20;
                              end
                              3: // look at middle platform to clean
                              begin
                                enable_l <= 1'b1;
                                bus_mode <= COMMAND;
                                next_command <= (8'h80 | ({2'b0, SH} + 8'h10));
                              end
                              4:
                              begin
                                enable_l <= 1'b1;
                                bus_mode <= DRAM_WR;
                                next_data <= 8'h20;
                              end
                              5: // look at bottom platform to clean
                              begin
                                enable_l <= 1'b1;
                                bus_mode <= COMMAND;
                                next_command <= (8'h80 | ({2'b0, SH} + 8'h50));
                              end
                              6:
                              begin
                                enable_l <= 1'b1;
                                bus_mode <= DRAM_WR;
                                next_data <= 8'h20;
                              end
                              7: // look at player character to clean
                              begin
                                enable_l <= 1'b1;
                                bus_mode <= COMMAND;
                                next_command <= (8'h80 | ({2'b0, SH} + player_addr));
                              end
                              default:
                              begin

                                game_state <= SHIFT;
                              end
                            endcase

                            interval_counter <= interval_counter + 16'd1;
                          end
                          SHIFT:
                          begin
                            SH <= (SH + 6'd1) % 6'h28;
                            enable_l <= 1'b1;
                            bus_mode <= COMMAND;
                            next_command <= 8'h18;
                            game_state <= PLATFORM_EXT;
                          end
                          PLATFORM_EXT:
                          begin
                            enable_l <= 1'b1;

                            case (interval_counter)
                              9: // update platform height
                              begin
                                pltfm_height <= (pltfm_height == plyr_pltfm_height) ? ((pltfm_height + 2'd1) % 2'd3):pltfm_height;
                              end
                              10: // target new address
                              begin
                                enable_l <= 1'b1;
                                bus_mode <= COMMAND;
                                next_command <= (8'h80 | ({2'b0, SH} + pltfm_addr));
                              end
                              11:
                              begin
                                enable_l <= 1'b1;
                                bus_mode <= DRAM_WR;
                                next_data <= 8'hFF;
                              end
                              default:
                              begin
                                game_state <= PLAYER_HEIGHT;
                              end
                            endcase
                          end
                          PLAYER_HEIGHT:
                          begin
                            enable_l <= 1'b1;

                            case (interval_counter)
                              13: // update player height
                              begin
                                plyr_height <= ((plyr_height - plyr_pltfm_height) > 1) ?
                                                ((jmp_logged && (plyr_height > 2'd0)) ? plyr_height:(plyr_height - 2'd1)):
                                                ((jmp_logged && (plyr_height < 2'd3)) ? (plyr_height + 2'd1):plyr_height);
                              end
                              14: // target new address
                              begin
                                enable_l <= 1'b1;
                                bus_mode <= COMMAND;
                                next_command <= (8'h80 | ({2'b0, SH} + player_addr));
                              end
                              15:
                              begin
                                enable_l <= 1'b1;
                                bus_mode <= DRAM_WR;
                                next_data <= 8'hFF;
                              end
                              default:
                              begin // CHECK whether the player is crashed

                                game_end <= (plyr_pltfm_height == plyr_height);
                                game_state <= END_CHECK;
                              end
                            endcase
                          end
                          END_CHECK:
                          begin
                            unlog <= 1'b1;
                            game_state <= WAIT;
                          end
                        endcase
                      end
                    endcase

                    op_state <= ENABLE_LOW;
                  end
                  ENABLE_LOW:
                  begin
                    enable_l <= 1'b0;
                    bus_mode <= bus_mode;
                    command_processing <= command_processing;
                    op_state <= ENABLE_HIGH;
                  end
              endcase
            end
          end
          else
          begin
            enable_l <= 1'b0;
          end

          initialization_counter <= initialization_counter + 16'd1;
        end
      endcase
    end
  end

endmodule: platformer

module plyr_height_to_addr(
  input logic[1:0] plyr_height,
  output logic[7:0] player_addr);

  always_comb
  begin
    case (plyr_height)
      2'b00: player_addr = 8'h53;
      2'b01: player_addr = 8'h13;
      2'b10: player_addr = 8'h43;
      2'b11: player_addr = 8'h03;
    endcase
  end

endmodule: plyr_height_to_addr

module pltfm_height_to_addr(
  input logic[1:0] pltfm_height,
  output logic[7:0] pltfm_addr);

  always_comb
  begin
    case (pltfm_height)
      2'b00: pltfm_addr = 8'h5F;
      2'b01: pltfm_addr = 8'h1F;
      2'b10: pltfm_addr = 8'h4F;
      2'b11: pltfm_addr = 8'h0F;
    endcase
  end

endmodule: pltfm_height_to_addr
