`timescale 10ns/10ns
module tb;
    logic clock, nreset,nreset2,sdata,clock_out;
    logic [11:0] dataout,regds;
    logic [11:0] tmpdata;
    logic [7:0] tmpdata_frame;
    logic h;
    uart_rx #(.BYTESIZES(8), .OVERSAMPLING(16), .BAUDRATE(115200),.COUNTER_CLOCK_INPUT(50_000_000))rx(
        .clock  (clock  )       ,
        .nreset (nreset )       ,
        .sdata  (sdata  )       ,
        .dataout(dataout)           
    );
    uart_tx #(.BAUDRATE(115200),.OVERSAMPLING(1),.COUNTER_CLOCK_INPUT(50_000_000))tx(
        .clock(clock),
        .nreset(nreset),
        .valid(1'b1),
        .data(8'd128),
        .sdata(sdata
        )
    );
    initial tmpdata =12'b1_1111_0101_011;
    assign tmpdata_frame = tmpdata[10:3];
    initial begin
         clock = 0;
         nreset = 0;
         #100 nreset =1;
         #50000 $finish;

    end
    always #10ns clock = ~ clock;
    always_ff@(posedge clock)if(tx.data==rx.dataout);

endmodule