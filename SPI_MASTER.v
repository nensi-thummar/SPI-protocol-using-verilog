module spi #(parameter WIDTH=16,
             parameter DIVIDER=4,
             parameter CPOL=1,
             parameter CPHA=0)(
  input clk,
  input rst,
  input [WIDTH-1:0] master_tx_data,
  input start,
  input [1:0] slave_select,

  output reg sclk,
  output reg [2:0] cs,
  output reg mosi,
  input miso,

  output reg [WIDTH-1:0] master_rx_data,
  output reg done,
  output reg busy
);

  reg [WIDTH-1:0] shift_reg;

  integer count;
  integer clk_count;

  reg [1:0] state;

  reg sample_edge;
  reg shift_edge;

  localparam IDLE=2'd0,
             TRANSFER=2'd1,
             DONE=2'd2;

  always @(posedge clk or posedge rst)
  begin
    if(rst)
    begin
      state<=IDLE;

      done<=0;
      busy<=0;

      sclk<=CPOL;

      cs<=3'b111;

      mosi<=0;

      count<=WIDTH-1;

      clk_count<=0;

      shift_reg<=0;

      master_rx_data<=0;
    end

    else
    begin
      case(state)

        IDLE:
        begin
          sclk<=CPOL;

          cs<=3'b111;

          done<=0;

          busy<=0;

          clk_count<=0;

          if(start)
          begin
            state<=TRANSFER;

            case(slave_select)

              2'd0: cs<=3'b110;

              2'd1: cs<=3'b101;

              2'd2: cs<=3'b011;

              default: cs<=3'b111;

            endcase

            busy<=1;

            shift_reg<=master_tx_data;

            count<=WIDTH-1;

            master_rx_data<=0;

            if(CPHA==0)
              mosi<=master_tx_data[WIDTH-1];
          end
        end

        TRANSFER:
        begin

          if(clk_count==DIVIDER-1)
          begin
            clk_count<=0;

            if(sclk==CPOL)
            begin
              sample_edge=(CPHA==0);
              shift_edge=(CPHA==1);
            end

            else
            begin
              sample_edge=(CPHA==1);
              shift_edge=(CPHA==0);
            end

            sclk<=~sclk;

            if(sample_edge)
            begin
              master_rx_data<={master_rx_data[WIDTH-2:0],miso};

              if(count!=0)
                count<=count-1;

              else
              begin
                state<=DONE;

                done<=1;

                busy<=0;
              end
            end

            if(shift_edge)
            begin

              if(CPHA==0)
              begin
                shift_reg<=shift_reg<<1;

                mosi<=shift_reg[WIDTH-2];
              end

              else
              begin
                mosi<=shift_reg[WIDTH-1];

                shift_reg<=shift_reg<<1;
              end

            end

          end

          else
          begin
            clk_count<=clk_count+1;
          end

        end

        DONE:
        begin
          state<=IDLE;

          busy<=0;

          cs<=3'b111;

          sclk<=CPOL;

          mosi<=0;
        end

        default:
          state<=IDLE;

      endcase
    end
  end

endmodule
