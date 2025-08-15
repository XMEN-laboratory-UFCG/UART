`timescale 10ns/1ns
module tb;
    logic clock,clock2, nreset,nreset2,sdata1,sdata2,clock_out;
    logic [11:0] dataout,regds;
    logic [11:0] tmpdata;
    logic [7:0] tmpdata_frame,pdata1,pdata2;
    logic ready_rx, valid_rx, valid_tx1,valid_tx2;


    realtime    rtime1,    rtime2;
    parameter BYTESIZES = 8, OVERSAMPLING = 16, BAUDRATE = 9600,COUNTER_CLOCK_INPUT = 50_000_000,COUNTER_CLOCK_INPUT2 = 100_000_000, CLOCK_REF = 5_000_000;

    uart_rx #(.BYTESIZES(BYTESIZES), .OVERSAMPLING(OVERSAMPLING), .BAUDRATE(BAUDRATE),.COUNTER_CLOCK_INPUT(COUNTER_CLOCK_INPUT),.CLOCK_REF(CLOCK_REF))rx(
        .clock       (clock    )        ,
        .nreset      (nreset   )        ,
        .sdata_rx_in (sdata1   )       ,
        .valid_rx_in (valid_tx1 )        ,
        .ready_rx_out(ready_rx )        ,
        .data_rx_out (dataout )   
    );
    uart_tx #(.BYTESIZES(BYTESIZES), .OVERSAMPLING(1), .BAUDRATE(BAUDRATE),.COUNTER_CLOCK_INPUT(COUNTER_CLOCK_INPUT2),.CLOCK_REF(CLOCK_REF))tx1(
        .clock       (clock2       ),
        .nreset      (nreset       ),
        .valid_tx_in (valid_tx1    ),
        .data_tx_in  (pdata1       ),
        .sdata_tx_out(sdata1       )
    );

    // uart_tx #(.BYTESIZES(BYTESIZES), .OVERSAMPLING(1), .BAUDRATE(BAUDRATE),.COUNTER_CLOCK_INPUT(COUNTER_CLOCK_INPUT2))tx2(
    //     .clock  (clock2  ),
    //     .nreset (nreset ),
    //     .valid  (valid_tx1   ),
    //     .data   (pdata1  ),
    //     .sdata  (sdata2  )
    // );
    initial begin
        rtime1 = 1/(2*COUNTER_CLOCK_INPUT);
        rtime2 = 1/(2*COUNTER_CLOCK_INPUT2);
         clock = 0;
         clock2 = 1;
         valid_tx1 = 1;
         nreset = 0;
         #10ns nreset =0;

        #3000000ns nreset = 0;
        #3008000ns nreset = 1;

         #50000000ns $finish;

    end
    always #10ns clock = ~ clock;
    always #5ns clock2 = ~ clock2;
    always_ff@(posedge clock)begin
        if(!nreset) pdata1 <= 120;
        if(tx1.data_tx_in==rx.data_rx_out) pdata1 <= $random()%2**(BYTESIZES-1);
        valid_rx <= $random%2;
    end
    assign pdata2 = pdata1;

endmodule