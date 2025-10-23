// ----------------------------------------------------------------------------------------------------
// DESCRIÇÃO: Classe `top` para verificação UVM do multiplicador binário de 32x32 bits
//             - Classe principal que instancia o ambiente de verificação completo.
//             - Conecta os componentes principais: `env`, `coverage_in`, `coverage_out`, driver, sequencer, monitor, scoreboard.
//             - Inicializa o DUT e gerencia os testes UVM, incluindo a geração de relatórios e logs.
//             - Executa os cenários de teste, coordenando o fluxo de simulação.
// ----------------------------------------------------------------------------------------------------
// / RELEASE HISTORY  :
// DATA                 VERSÃO      AUTOR                    DESCRIÇÃO
// 2024-09-20           0.1         Cleisson                 Versão inicial.
//                                  Pedro Henrique
//                                  
// ----------------------------------------------------------------------------------------------------
module top;
   import uvm_pkg::*;
   import test_pkg::*;

   // Clock generator
   logic clock;
   localparam HALF_PERIOD = 5;

  initial begin
    clock = 0;
    forever #HALF_PERIOD clock = ~clock;
  end

   // Reset generator
   logic reset;
   initial begin
     reset = 1;
     repeat(2) @(negedge clock);
     reset = 0;
   end

   // APB clock and reset are the same
   logic PCLK, PRESETn;
   assign PCLK = clock;
   assign PRESETn = ~reset;

   uart_if  uart_vif(.clock(PCLK), .nreset(PRESETn));


uart_top #(
      .BYTESIZES            (8),
      .OVERSAMPLING         (16),
      .BAUDRATE             (115200),
      .COUNTER_CLOCK_INPUT  (100_000_000), 
      .CLOCK_REF            (10_000_000)
  ) 
uart_teste (
      // Conecta aos sinais da interface 
      .clock        (uart_vif.clock), 
      .nreset       (uart_vif.nreset),
      
      // --- pinout RX ---
      // Driver UVM (via vif) -> DUT
      .sdata_rx_in  (uart_vif.sdata_rx_in),
      .valid_rx_in  (uart_vif.valid_rx_in),
      // DUT -> Monitor UVM (via vif)
      .ready_rx_out (uart_vif.ready_rx_out),
      .data_rx_out  (uart_vif.data_rx_out),
      
      // --- pinout TX ---
      // Driver UVM (via vif) -> DUT
      .valid_tx_in  (uart_vif.valid_tx_in),
      .data_tx_in   (uart_vif.data_tx_in),
      // DUT -> Monitor UVM (via vif)
      .ready_tx_out (uart_vif.ready_tx_out), 
      .sdata_tx_out (uart_vif.sdata_tx_out)            
  );



   initial begin
      // vendor dependent waveform recording
      `ifdef XCELIUM
        $shm_open("waves.shm");
        $shm_probe("AS");
      `endif
      `ifdef VCS
        $vcdpluson;
      `endif
      `ifdef QUESTA
        $wlfdumpvars();
      `endif
      // register the input and output interface instance in the database

    uvm_config_db#(virtual uart_if.TX_DRV)::set(null, "uvm_test_top.env_h.m_agent.m_tx_driver", "vif_tx", uart_vif.TX_DRV);

    uvm_config_db#(virtual uart_if.RX_DRV)::set(null, "uvm_test_top.env_h.m_agent.m_rx_driver", "vif_rx", uart_vif.RX_DRV);

    uvm_config_db#(virtual uart_if.MON)::set(null, "uvm_test_top.env_h.m_agent.m_monitor", "vif_mon", uart_vif.MON);
      run_test("test");
   end
endmodule

