//Valmir 
`timescale 10ns/1ns
module tb;
    logic clock,clock2, nreset,nreset2,sdata1,sdata2,clock_out;
    logic [11:0] dataout,regds;
    logic [11:0] tmpdata;
    logic [7:0] tmpdata_frame,pdata1,pdata2;
    logic ready_rx, valid_rx, valid_tx1,valid_tx2;


    realtime    rtime1,    rtime2;
    parameter BYTESIZES = 8, OVERSAMPLING = 16, BAUDRATE = 9600,COUNTER_CLOCK_INPUT = 50_000_000,COUNTER_CLOCK_INPUT2 = 100_000_000, CLOCK_REF = 5_000_000;
    logic valid, ready_env_uart_rx,EvenT_SevenToZero,EvenT_SevenToZero_next;
parameter WIDTHx =1,SIZE = 8, WIDTH = 8;

    uart_top#(.BYTESIZES(BYTESIZES), .OVERSAMPLING(OVERSAMPLING), .BAUDRATE(BAUDRATE),.COUNTER_CLOCK_INPUT(COUNTER_CLOCK_INPUT),.CLOCK_REF(CLOCK_REF))uart_top_h(
        .clock       (clock    )        ,
        .nreset      (nreset   )        ,
        //pinout RX   
        .sdata_rx_in (sdata1)             ,
        .valid_rx_in (valid_tx1)          ,
        .ready_rx_out(ready_rx)           ,
        .data_rx_out (dataout)            ,
        //pinout TX
        .valid_tx_in (valid_tx1)          ,
        .data_tx_in  (pdata1)             ,
        .ready_tx_out(      )             ,
        .sdata_tx_out(sdata1)            
    );

logic [3:0]cnt1,next_cnt1;


logic [WIDTH-1:0]IMPUT_A[2*SIZE-1:0];

assign next_cnt1 =   cnt1 +1 ;

    always_ff@(posedge ready_rx, negedge nreset)begin
        if(!nreset)begin 
            cnt1 <= 0;
            
        end
        else begin 
                  cnt1 <= next_cnt1;
                  IMPUT_A[cnt1] <= dataout; 
        end 
    end
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
        if(uart_top_h.data_tx_in==uart_top_h.data_rx_out) pdata1 <= $random()%2**(BYTESIZES-1);
        valid_rx <= $random%2;
    end
    assign pdata2 = pdata1;

endmodule