// ----------------------------------------------------------------------------------------------------
// DESCRIÇÃO: Classe `monitor` para verificação UVM do multiplicador binário de 32x32 bits
//             - Captura e observa sinais do DUT.
//             - Converte sinais de back-to-back em transações UVM para o scoreboard.
//             - Verifica aderência ao protocolo de handshake e sequencialidade das operações.
// ----------------------------------------------------------------------------------------------------
// RELEASE HISTORY  :
// DATA                 VERSÃO      AUTOR                    DESCRIÇÃO
// 2024-09-20           0.1         Cleisson                 Versão inicial.
//                                  Pedro Henrique
//                                  
// ----------------------------------------------------------------------------------------------------



class uart_monitor #(
  parameter int BAUDRATE    = 115200,
  parameter int CLOCK_INPUT = 100_000_000 
) extends uvm_monitor;

  `uvm_component_param_utils(uart_monitor#(BAUDRATE, CLOCK_INPUT))

  virtual uart_if.MON vif;
  // 1. Para bytes recebidos do DUT (via RX paralelo)
  uvm_analysis_port #(uart_transaction) rx_ap;

  // 2. Para bytes enviados pelo DUT (via TX serial)
  uvm_analysis_port #(uart_transaction) tx_ap;
  localparam int CLKS_PER_BIT = (CLOCK_INPUT + (BAUDRATE / 2)) / BAUDRATE;


  function new(string name = "uart_monitor", uvm_component parent);
    super.new(name, parent);

    rx_ap = new("rx_ap", this);
    tx_ap = new("tx_ap", this);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual uart_if.MON)::get(this, "", "vif_mon", vif))
      `uvm_fatal(get_type_name(), "Nao foi possivel encontrar a interface virtual 'vif_mon'")
    `uvm_info(get_type_name(), $sformatf("Monitor usando CLKS_PER_BIT = %0d", CLKS_PER_BIT), UVM_MEDIUM)
  endfunction : build_phase


  virtual task run_phase(uvm_phase phase);
   `uvm_info(get_type_name(), "Monitor esperando reset...", UVM_MEDIUM)
    wait (vif.nreset == 1);
    `uvm_info(get_type_name(), "Monitor: Reset liberado, iniciando...", UVM_MEDIUM)
    fork
      monitor_tx_serial_bus();
      monitor_rx_parallel_bus();
    join
  endtask : run_phase


  // Task 1: Decodifica a linha serial TX (sdata_tx_out)
  protected virtual task monitor_tx_serial_bus();
    logic [7:0] data_byte;
    uart_transaction txn;

    `uvm_info(get_type_name(), "Monitor TX (Serial) iniciado...", UVM_MEDIUM)
    
    forever begin
      // 1. Espera por um Start Bit (borda de descida)
      @(negedge vif.mon_cb.sdata_tx_out);
      
      // Verifica se eh um start bit (0)
      if (vif.mon_cb.sdata_tx_out == 1'b0) begin
        `uvm_info(get_type_name(), "MON-TX: Start bit detectado", UVM_HIGH)

        // 2. Espera metade do tempo de bit para ir ao meio do start bit
        repeat (CLKS_PER_BIT / 2) @(vif.mon_cb);

        // 3. Loop para capturar os 8 bits de dados
        for (int i = 0; i < 8; i++) begin
          repeat (CLKS_PER_BIT) @(vif.mon_cb);
          data_byte[i] = vif.mon_cb.sdata_tx_out;
        end

        // 4. Espera pelo Stop Bit
        repeat (CLKS_PER_BIT) @(vif.mon_cb);

        // 5. Verifica o Stop Bit
        if (vif.mon_cb.sdata_tx_out == 1'b1) begin
          // SUCESSO!
          `uvm_info(get_type_name(), $sformatf("MON-TX: Byte 0x%h recebido", data_byte), UVM_HIGH)
          
          // Cria a transacao e envia pela porta de analise
          txn = uart_transaction::type_id::create("txn_tx");
          txn.data = data_byte;
          tx_ap.write(txn);
        end 
        else begin
          `uvm_error(get_type_name(), "MON-TX: Erro de Framing! Stop bit nao encontrado.")
        end
      end 
    end 
  endtask : monitor_tx_serial_bus

// Task 2: Monitora a saida paralela RX (data_rx_out)
  protected virtual task monitor_rx_parallel_bus();
    uart_transaction txn;
    logic [7:0] data_byte;
    logic ready_last_cycle = 1'b0; // Flag para detectar a borda

    `uvm_info(get_type_name(), "Monitor RX (Paralelo) iniciado...", UVM_MEDIUM)

    forever begin
      // 1. Espera o proximo ciclo de clock
      @(vif.mon_cb);

      // --- INICIO DA NOVA LOGICA ---
      // 2. Procura pela BORDA DE SUBIDA (0 -> 1)
      if (vif.mon_cb.ready_rx_out == 1'b1 && ready_last_cycle == 1'b0) begin

        // 3. Borda detectada! Captura o dado.
        data_byte = vif.mon_cb.data_rx_out;

        `uvm_info(get_type_name(), $sformatf("MON-RX: Byte 0x%h capturado", data_byte), UVM_HIGH)

        // 4. Envia para o scoreboard
        txn = uart_transaction::type_id::create("txn_rx");
        txn.data = data_byte;
        rx_ap.write(txn);
      end

      // 5. Armazena o valor atual para a proxima iteracao
      ready_last_cycle = vif.mon_cb.ready_rx_out;
      // --- FIM DA NOVA LOGICA ---
    end
  endtask : monitor_rx_parallel_bus

endclass : uart_monitor


