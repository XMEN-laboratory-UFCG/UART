


`uvm_analysis_imp_decl(_rx)
`uvm_analysis_imp_decl(_tx)

class uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(uart_scoreboard)

  // Exports de Analise (Para o 'env' se conectar)
  uvm_analysis_export #(uart_transaction) rx_export;
  uvm_analysis_export #(uart_transaction) tx_export;

  // Imports (Implementacoes) Internos

  uvm_analysis_imp_rx #(uart_transaction, uart_scoreboard) rx_imp;
  uvm_analysis_imp_tx #(uart_transaction, uart_scoreboard) tx_imp;


  protected uart_transaction tx_fifo[$];
  protected uart_transaction rx_fifo[$];

  protected int tx_pkt_count = 0;
  protected int rx_pkt_count = 0;
  protected int match_count = 0;
  protected int mismatch_count = 0;

  function new(string name = "uart_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Cria os exports (para fora)
    rx_export = new("rx_export", this);
    tx_export = new("tx_export", this);
    
    // Cria os imports (internos)
    rx_imp = new("rx_imp", this);
    tx_imp = new("tx_imp", this);
  
  endfunction : build_phase

  // A connect_phase DEVE conectar o export (externo) ao imp (interno)
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    rx_export.connect(rx_imp);
    tx_export.connect(tx_imp);
  endfunction : connect_phase

  // Funcao 'write' para o import do TX
  virtual function void write_tx(uart_transaction t);
    `uvm_info(get_type_name(), $sformatf("Scoreboard: Recebeu byte TX 0x%h", t.data), UVM_HIGH)
    tx_pkt_count++;
    tx_fifo.push_back(t);
  endfunction : write_tx
  
  // Funcao 'write' para o import do RX
  virtual function void write_rx(uart_transaction t);
    `uvm_info(get_type_name(), $sformatf("Scoreboard: Recebeu byte RX 0x%h", t.data), UVM_HIGH)
    rx_pkt_count++;
    rx_fifo.push_back(t);
  endfunction : write_rx

  // Tarefa principal: compara as filas
  virtual task run_phase(uvm_phase phase);
    uart_transaction rx_pkt;
    uart_transaction tx_pkt;
    
    forever begin
      wait (rx_fifo.size() > 0 && tx_fifo.size() > 0);

      `uvm_info(get_type_name(), "Scoreboard: Comparando pacotes...", UVM_HIGH)
      rx_pkt = rx_fifo.pop_front();
      tx_pkt = tx_fifo.pop_front();

      if (rx_pkt.data == tx_pkt.data) begin
        `uvm_info(get_type_name(), $sformatf("MATCH: TX(0x%h) == RX(0x%h)", tx_pkt.data, rx_pkt.data), UVM_LOW)
        match_count++;
      end else begin
        `uvm_error(get_type_name(), $sformatf("MISMATCH: TX(0x%h) != RX(0x%h)", tx_pkt.data, rx_pkt.data))
        mismatch_count++;
      end
    end
  endtask : run_phase
  
  // Fase de relatorio
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), "--- Relatorio do Scoreboard ---", UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Bytes TX Recebidos: %0d", tx_pkt_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Bytes RX Recebidos: %0d", rx_pkt_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Matches: %0d", match_count), UVM_LOW)
    `uvm_info(get_type_name(), $sformatf("Mismatches: %0d", mismatch_count), UVM_LOW)
    
    if (mismatch_count > 0 || tx_pkt_count != rx_pkt_count || tx_pkt_count == 0) begin
       `uvm_error(get_type_name(), "--- TESTE FALHOU ---")
    end else begin
       `uvm_info(get_type_name(), "--- TESTE PASSOU ---", UVM_NONE)
    end
  endfunction : report_phase
  
endclass : uart_scoreboard
