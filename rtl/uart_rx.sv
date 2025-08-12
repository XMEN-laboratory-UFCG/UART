//============================================================
// Nome do Bloco    : UART_RX
// Versão           : 2.0
// Autor(a)         : Valmir Ferreira
// Data de Criação  : --/--/--
// Última Modificação: 10/08/2025
//
// Descrição:
//  Protocolo de Comunicação UART canal de recepcao (RX) Validado em FPGA.
// 
//============================================================

module uart_rx#(parameter  BYTESIZES = 8, OVERSAMPLING = 16, BAUDRATE = 115200,	COUNTER_CLOCK_INPUT = 50_000_000)(
    input  logic                     clock       ,
    input  logic                     nreset      ,
    input  logic                     sdata       ,
    input  logic                     valid       ,
    output logic                     ready       ,
    output logic [BYTESIZES-1:0]     dataout        
);

enum {IDLE, START, R_DATA, STOPBIT} next_fsm, current_fsm    ;
logic [31:0] counter_max_sampling;
logic [BYTESIZES-1:0]   px_bit, next_px_bit                  ;
logic [BYTESIZES-1:0]   pdataout                             ;
logic ena,ena_next, valid_in, tmp_sdata                      ;  
logic clock_out, sample_center_bit, bit_start                ;
logic resetting, next_resetting;

baudRateGenerator #(.BAUDRATE(BAUDRATE),.OVERSAMPLING(OVERSAMPLING), .CLOCK_INPUT(COUNTER_CLOCK_INPUT)) boudrategenerator_inst (
    .nreset        (nreset        		)     ,        
    .ena           (ena          		)     ,        
    .ena2          (1'b1          		)     ,        
    .clock         (clock         	    )     ,           
	.counter_out   (counter_max_sampling)     ,
    .clock_out     (clock_out     		)     ,            
    .counting_done2(sample_center_bit   )     
);
assign valid_in = valid;
always_ff@(posedge clock_out, negedge nreset) begin
    if(!nreset)begin 
        current_fsm <= IDLE ;
        px_bit      <= 	  0 ;
        pdataout    <=    0 ;
        ena 	    <=    0 ;
        bit_start   <=    0 ;
        tmp_sdata   <=    1 ;
        dataout     <=    0 ;
    end
    else begin                                            
        tmp_sdata 			<= sdata                                                            ;
	    current_fsm         <= next_fsm                                                         ;
        px_bit              <= next_px_bit                                                      ;
		pdataout[px_bit]    <= current_fsm == R_DATA ? sample_center_bit && tmp_sdata :pdataout ;
        bit_start           <= (!sdata && tmp_sdata) && current_fsm == IDLE                     ;
        ena                 <= ena_next                                                         ;
        dataout             <= ready ?  pdataout: dataout                                       ;
    end
end

always_comb case(current_fsm)
        IDLE:begin
            next_fsm 		= 	bit_start && valid_in ? START :IDLE                             ;
            ena_next 		= 	0									                            ;
            next_px_bit 	= 	0									                            ;
        end
		START:begin
            next_fsm 		=  counter_max_sampling != OVERSAMPLING/2+2  ? START:  R_DATA       ;
            ena_next 		= 	1												                ;
            next_px_bit 	= 	0								    			                ;		  
		end
        R_DATA:begin
            next_px_bit 	= px_bit != BYTESIZES && sample_center_bit  ? px_bit + 1: px_bit    ;
            next_fsm 	  	= px_bit == BYTESIZES-1 && sample_center_bit  ? STOPBIT : R_DATA    ;
            ena_next 		= 1                                                                 ;
        end
        STOPBIT:begin
            next_fsm 		= sample_center_bit ? IDLE :  STOPBIT                               ;
			ena_next 		= 1                                                                 ;
            next_px_bit 	= 0                                                                 ;                             
		end
		default:next_fsm = IDLE;
		
endcase 

always_ff@(posedge clock)begin
    if(current_fsm == IDLE )    ready <=1                               ;
    else                        ready <= 0                              ;
end

endmodule