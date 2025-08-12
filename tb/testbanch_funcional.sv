`timescale 10ns/10ns
module tb;
    logic clock, nreset,nreset2,sdata,clock_out;
    logic [11:0] dataout,regds;
    logic [11:0] tmpdata;
    logic [7:0] tmpdata_frame,pdata;
    logic ready_rx, valid_rx, valid_tx;

    parameter BYTESIZES = 16, OVERSAMPLING = 16, BAUDRATE = 9600,COUNTER_CLOCK_INPUT = 50_000_000;

    uart_rx #(.BYTESIZES(BYTESIZES), .OVERSAMPLING(OVERSAMPLING), .BAUDRATE(BAUDRATE),.COUNTER_CLOCK_INPUT(COUNTER_CLOCK_INPUT))rx(
        .clock  (clock    )       ,
        .nreset (nreset   )       ,
        .sdata  (sdata    )       ,
        .dataout(dataout  )       ,
        .ready  (ready_rx )       ,
        .valid  (valid_tx )   
    );
    uart_tx #(.BYTESIZES(BYTESIZES), .OVERSAMPLING(1), .BAUDRATE(BAUDRATE),.COUNTER_CLOCK_INPUT(COUNTER_CLOCK_INPUT))tx(
        .clock  (clock  ),
        .nreset (nreset ),
        .valid  (valid_tx   ),
        .data   (pdata  ),
        .sdata  (sdata  )
    );
    initial begin
         clock = 0;
         valid_tx = 1;
         nreset = 0;
         #10ns nreset =0;

        #3000000ns nreset = 0;
        #3008000ns nreset = 1;

         #50000000ns $finish;

    end
    always #10ns clock = ~ clock;
    always_ff@(posedge clock)begin
        if(!nreset) pdata <= 120;
        if(tx.data==rx.dataout) pdata <= $random()%2**(BYTESIZES-1);
        valid_rx <= $random%2;
    end

endmodule