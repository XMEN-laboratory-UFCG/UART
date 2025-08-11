//============================================================
// Nome do Bloco    : UART_TX
// Versão           : 1.0
// Autor(a)         : Valmir Ferreira
// Data de Criação  : --/--/--
// Última Modificação: 16/07/2025
//
// Descrição:
//  Protocolo de Comunicação UART canal de envio (TX)
// 
//============================================================


module uart_tx#(parameter  BYTESIZES = 8, OVERSAMPLING = 1, BAUDRATE = 115200,	COUNTER_CLOCK_INPUT = 50_000_000)(
    input  logic                     clock       ,
    input  logic                     nreset      ,
    input logic                      valid       ,
    input  logic  [BYTESIZES-1:0]    data        ,
    output logic                     sdata        
);

logic clock_out;
logic [BYTESIZES-1:0]   px_bit, next_px_bit,    counter_max_sampling;
logic [BYTESIZES-1+3:0] pframe_data;

baudRateGenerator #(.BAUDRATE(BAUDRATE),.OVERSAMPLING(OVERSAMPLING), .CLOCK_INPUT(COUNTER_CLOCK_INPUT)) boudrategenerator_inst (
    .nreset        (nreset        		)     ,        
    .ena           (1'b1          		)     ,        
    .ena2          (1'b1          		)     ,        
    .clock         (clock         	    )     ,           
	.counter_out   ()     ,
    .clock_out     (clock_out     		)     ,            
    .counting_done2(sample_center_bit)     
);

always_ff@(posedge clock_out, negedge nreset) begin
    if(!nreset)px_bit      <= 	  0 ;
    else begin      
          sdata <= pframe_data[px_bit];
          px_bit    <= (valid && px_bit != BYTESIZES+2) ? px_bit+1 : 0;       
    end
end

assign pframe_data = valid ? {1'b1,data,3'b011}: 0;

endmodule
