module spi_slave #(parameter WIDTH=16,
                   parameter CPOL=1,
                   parameter CPHA=0)(
  input sclk,
  input cs,
  input mosi,
  input [WIDTH-1:0] slave_tx_data,

  output miso,

  output reg [WIDTH-1:0] slave_rx_data
);

  reg miso_reg;

  reg [WIDTH-1:0] shift_reg;

  assign miso=(cs==0) ? miso_reg : 1'bz;

  always @(negedge cs)
  begin
    shift_reg<=slave_tx_data;

    slave_rx_data<=0;

    if(CPHA==0)
      miso_reg<=slave_tx_data[WIDTH-1];
  end

  generate

    if(CPOL==0 && CPHA==0)
    begin

      always @(posedge sclk)
      begin
        if(cs==0)
          slave_rx_data<={slave_rx_data[WIDTH-2:0],mosi};
      end

      always @(negedge sclk)
      begin
        if(cs==0)
        begin
          shift_reg<=shift_reg<<1;

          miso_reg<=shift_reg[WIDTH-2];
        end
      end

    end

    else if(CPOL==0 && CPHA==1)
    begin

      always @(negedge sclk)
      begin
        if(cs==0)
          slave_rx_data<={slave_rx_data[WIDTH-2:0],mosi};
      end

      always @(posedge sclk)
      begin
        if(cs==0)
        begin
          miso_reg<=shift_reg[WIDTH-1];

          shift_reg<=shift_reg<<1;
        end
      end

    end

    else if(CPOL==1 && CPHA==0)
    begin

      always @(negedge sclk)
      begin
        if(cs==0)
          slave_rx_data<={slave_rx_data[WIDTH-2:0],mosi};
      end

      always @(posedge sclk)
      begin
        if(cs==0)
        begin
          shift_reg<=shift_reg<<1;

          miso_reg<=shift_reg[WIDTH-2];
        end
      end

    end

    else
    begin

      always @(posedge sclk)
      begin
        if(cs==0)
          slave_rx_data<={slave_rx_data[WIDTH-2:0],mosi};
      end

      always @(negedge sclk)
      begin
        if(cs==0)
        begin
          miso_reg<=shift_reg[WIDTH-1];

          shift_reg<=shift_reg<<1;
        end
      end

    end

  endgenerate

endmodule
