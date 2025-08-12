//============================================================
// Nome do Bloco    : UART_TX
// Versão           : 2.0
// Autor(a)         : Valmir Ferreira
// Data de Criação  : --/--/--
// Última Modificação: 10/08/2025
//
// Descrição:
//  Protocolo de Comunicação UART canal de envio (TX) Validado em FPGA.
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
logic start_frame;
logic [BYTESIZES-1:0]   px_bit;
logic [BYTESIZES-1+3:0] pframe_data;
enum {FRAME_1,IDLE, START, R_DATA, STOPBIT} next_fsm,current_fsm;
baudRateGenerator #(.BAUDRATE(BAUDRATE),.OVERSAMPLING(OVERSAMPLING), .CLOCK_INPUT(COUNTER_CLOCK_INPUT)) boudrategenerator_inst (
    .nreset        (nreset        		)     ,        
    .ena           (1'b1          		)     ,        
    .ena2          (1'b1          		)     ,        
    .clock         (clock         	    )     ,           
	.counter_out   ()                         ,
    .clock_out     (clock_out     		)     ,            
    .counting_done2(sample_center_bit)     
);

always_ff@(posedge clock_out, negedge nreset) begin
    if(!nreset)begin 
        px_bit        <= 0                                                  ;
        sdata         <= 1                                                  ; 
        current_fsm   <= FRAME_1                                            ;
    end
    else begin      
          sdata       <= pframe_data[px_bit]                                ;
          px_bit      <= (valid && px_bit != BYTESIZES+2) ? px_bit+1 : 0    ;     
          current_fsm <=   next_fsm                                         ;
    end
end
always_comb begin
    case(current_fsm)
        FRAME_1 :next_fsm = start_frame ? FRAME_1 : IDLE                    ;
        IDLE    :next_fsm = START                                           ;
        START   :next_fsm = R_DATA                                          ;
        R_DATA  :next_fsm = (px_bit < BYTESIZES+2) ? R_DATA : STOPBIT       ;
        STOPBIT :next_fsm = FRAME_1                                         ;
        default :next_fsm = FRAME_1                                         ;
    endcase
end
assign start_frame = (px_bit < 1);
assign pframe_data = valid ? {1'b1,data,3'b011}: 0;
endmodule