
module spi_tb();

  parameter WIDTH=16;
  parameter DIVIDER=4;

  parameter CPOL=1;
  parameter CPHA=0;

  reg clk,rst,start;

  reg [1:0] slave_select;

  reg [WIDTH-1:0] master_tx_data;

  reg [WIDTH-1:0] slave0_tx_data;
  reg [WIDTH-1:0] slave1_tx_data;
  reg [WIDTH-1:0] slave2_tx_data;

  wire [WIDTH-1:0] master_rx_data;

  wire [WIDTH-1:0] slave0_rx_data;
  wire [WIDTH-1:0] slave1_rx_data;
  wire [WIDTH-1:0] slave2_rx_data;

  wire sclk,mosi,miso;

  wire slave0_miso;
  wire slave1_miso;
  wire slave2_miso;

  wire done,busy;

  wire [2:0] cs;

  wire [80:1] state_string;

  assign miso=
         (cs[0]==0) ? slave0_miso :
         (cs[1]==0) ? slave1_miso :
         (cs[2]==0) ? slave2_miso :
         1'b0;

  spi #(WIDTH,DIVIDER,CPOL,CPHA) master(
    .clk(clk),
    .rst(rst),
    .master_tx_data(master_tx_data),
    .start(start),
    .slave_select(slave_select),

    .sclk(sclk),
    .cs(cs),
    .mosi(mosi),
    .miso(miso),

    .master_rx_data(master_rx_data),

    .done(done),
    .busy(busy)
  );

  spi_slave #(WIDTH,CPOL,CPHA) slave0(
    .sclk(sclk),
    .cs(cs[0]),
    .mosi(mosi),

    .slave_tx_data(slave0_tx_data),

    .miso(slave0_miso),

    .slave_rx_data(slave0_rx_data)
  );

  spi_slave #(WIDTH,CPOL,CPHA) slave1(
    .sclk(sclk),
    .cs(cs[1]),
    .mosi(mosi),

    .slave_tx_data(slave1_tx_data),

    .miso(slave1_miso),

    .slave_rx_data(slave1_rx_data)
  );

  spi_slave #(WIDTH,CPOL,CPHA) slave2(
    .sclk(sclk),
    .cs(cs[2]),
    .mosi(mosi),

    .slave_tx_data(slave2_tx_data),

    .miso(slave2_miso),

    .slave_rx_data(slave2_rx_data)
  );

  assign state_string=state_name(master.state);

  initial clk=0;

  always #5 clk=~clk;

  initial
  begin
    $dumpfile("dump.vcd");

    $dumpvars(0,spi_tb);
  end

  function [80:1] state_name;

    input [1:0] state;

    begin
      case(state)

        2'd0: state_name="IDLE";

        2'd1: state_name="TRANSFER";

        2'd2: state_name="DONE";

        default: state_name="UNKNOWN";

      endcase
    end

  endfunction

  initial
  begin
    $monitor("TIME=%0t | CPOL=%0d | CPHA=%0d | SEL=%0d | MASTER_TX=%h | MASTER_RX=%h | SLAVE0_TX=%h | SLAVE0_RX=%h | SLAVE1_TX=%h | SLAVE1_RX=%h | SLAVE2_TX=%h | SLAVE2_RX=%h | SCLK=%b | MOSI=%b | MISO=%b",
              $time,

              CPOL,
              CPHA,

              slave_select,

              master_tx_data,
              master_rx_data,

              slave0_tx_data,
              slave0_rx_data,

              slave1_tx_data,
              slave1_rx_data,

              slave2_tx_data,
              slave2_rx_data,

              sclk,
              mosi,
              miso
             );
  end

  initial
  begin

    rst=1;

    start=0;

    slave_select=0;

    master_tx_data=16'hABCD;

    slave0_tx_data=16'h1234;
    slave1_tx_data=16'h5555;
    slave2_tx_data=16'hF0F0;

    #20;
    rst=0;

    #20;
    start=1;

    #10;
    start=0;

    #3000;



    slave_select=1;

    master_tx_data=16'h1234;

    #20;
    start=1;

    #10;
    start=0;

    #3000;



    slave_select=2;

    master_tx_data=16'h6789;

    #20;
    start=1;

    #10;
    start=0;

    #3000;

    $finish;

  end

endmodule
