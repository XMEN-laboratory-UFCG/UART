//============================================================
// Nome do Bloco    : baudRateGenerator
// Versão           : 1.0
// Autor(a)         : Valmir Ferreira
// Data de Criação  : --/--/--
// Última Modificação: 16/07/2025
//
// Descrição:
//  Gerador de BaudRate para funcionamento do protocolo UART
// 
//============================================================

module baudRateGenerator#(parameter BAUDRATE = 9600,OVERSAMPLING  = 8, CLOCK_INPUT = 50_000_000) (
    input  logic nreset                  ,
    input   logic ena                    ,
    input   logic ena2                    ,
    input  logic clock                   ,
    output logic clock_out               ,
    output logic counting_done2          ,
	 output logic [31:0] counter_out	
);

    parameter STOPCOUNTER = CLOCK_INPUT/(2*BAUDRATE*OVERSAMPLING)+1;
    parameter WIDTH=$clog2(STOPCOUNTER);

    logic [WIDTH-1:0] counter, next_counter;
    logic base_clock;
    logic sampling;

    counter #(.MOD(STOPCOUNTER)) base_clock_counter( //Contador que gera a base de tempo stop_counter(clock_input,baundrate,oversampling)
        
        .clock          (clock           ),
        .ena            (1'b1            ),
        .nreset         (nreset          ),
        .counting_done  (base_clock      )
    );
    
    counter #(.MOD(OVERSAMPLING)) sampling_counter( //Contador gerador de amostragem

        .clock          (clock_out      ),
        .ena            (ena            ),
        .nreset         (nreset         ),
        .counting_done  ( counting_done2              ),
        .counter1       (counter_out)
    );
    logic next_clock;
    always_ff@(posedge clock, negedge nreset)
        if(!nreset)         clock_out <= 0          ;
        else                clock_out <= next_clock ;
    assign next_clock   =   base_clock ? ~ clock_out: clock_out;
    
endmodule
