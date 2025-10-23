
// Interface para a UART, assumindo tamanho de dado fixo de 8 bits
interface uart_if (input logic clock, nreset);

  // --- Sinais do DUT ---
  logic                  sdata_rx_in;
  logic                  valid_rx_in;
  logic                  ready_rx_out;
  logic [7:0]            data_rx_out; // Tamanho fixo
  
  logic                  valid_tx_in;
  logic [7:0]            data_tx_in;   // Tamanho fixo
  logic                  ready_tx_out;
  logic                  sdata_tx_out;

  // --- Clocking Blocks ---
  
  // Clocking block para o Driver TX (Lado Paralelo)
  clocking tx_drv_cb @(posedge clock);
    default input #1 output #1;
    input  ready_tx_out;
    output valid_tx_in, data_tx_in;
  endclocking : tx_drv_cb
  
  // Clocking block para o Driver RX (Lado Serial)
  clocking rx_drv_cb @(posedge clock);
    default input #1 output #1;
    // Este driver nao precisa ler nenhum sinal do DUT, apenas dirigir
    output sdata_rx_in, valid_rx_in;
  endclocking : rx_drv_cb
  
  // Clocking block para o Monitor (Le tudo)
  clocking mon_cb @(posedge clock);
    default input #1 output #1;
    input sdata_rx_in, valid_rx_in, ready_rx_out, data_rx_out;
    input valid_tx_in, data_tx_in, ready_tx_out, sdata_tx_out;
  endclocking : mon_cb

  // --- Modports ---
  modport DUT (
    input  clock, nreset,
    input  sdata_rx_in, valid_rx_in, valid_tx_in, data_tx_in,
    output ready_rx_out, data_rx_out, ready_tx_out, sdata_tx_out
  );
  
  // Modport para o Driver TX
  modport TX_DRV (clocking tx_drv_cb, input nreset);
  
  // Modport para o Driver RX
  modport RX_DRV (clocking rx_drv_cb, input nreset);
  
  // Modport para o Monitor
  modport MON (clocking mon_cb, input nreset);

endinterface : uart_if