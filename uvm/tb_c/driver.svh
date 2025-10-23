// ----------------------------------------------------------------------------------------------------
// DESCRIÇÃO: Classe `driver` para verificação UVM do multiplicador binário de 32x32 bits
//             - Recebe as transações do sequencer.
//             - Converte transações UVM em estímulos de sinal (estímulo do handshake e dados).
//             - Usa lógica de controle baseada no protocolo (valid e ready).
// ----------------------------------------------------------------------------------------------------
// RELEASE HISTORY  :
// DATA                 VERSÃO      AUTOR                    DESCRIÇÃO
// 2024-09-20           0.1         Cleisson                 Versão inicial.
//                                  Pedro Henrique
//                                  
// ----------------------------------------------------------------------------------------------------

class uart_tx_driver extends uvm_driver #(uart_transaction);
  
  virtual uart_if.TX_DRV vif;
  logic is_first_tx_byte = 1'b1;

  `uvm_component_utils(uart_tx_driver)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual uart_if.TX_DRV)::get(this, "", "vif_tx", vif))
      `uvm_fatal(get_type_name(), "Nao foi possivel encontrar a interface virtual 'vif_tx'")
  endfunction : build_phase


  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Driver TX iniciado", UVM_MEDIUM)
    reset_driver_signals();
    wait (vif.nreset == 1);
    `uvm_info(get_type_name(), "Driver TX: Reset liberado, iniciando loop", UVM_MEDIUM)
    
    forever begin
      seq_item_port.get_next_item(req);

      fork
        drive_tx_byte(req.data);
        wait_for_reset();
      join_any
      
      if (vif.nreset == 0) begin
        `uvm_info(get_type_name(), "TX Driver: Reset detectado", UVM_MEDIUM)
        reset_driver_signals();
      
      end 
      else begin
        
        seq_item_port.item_done();
      end
    end
  endtask : run_phase

  
  // Task: Envia byte PARALELO para o TX
  virtual protected task drive_tx_byte(logic [7:0] data);
    
 repeat(10)begin
    `uvm_info(get_type_name(), $sformatf("Drive TX: Enviando dado 0x%h", data), UVM_HIGH)
    vif.tx_drv_cb.valid_tx_in <= 1; 
    vif.tx_drv_cb.data_tx_in  <= data; 

    // Espera 1 ciclo de clock
    @(vif.tx_drv_cb.ready_tx_out);
    
    // Remove o estimulo
    
    vif.tx_drv_cb.data_tx_in  <= 'x; 
 end
  endtask : drive_tx_byte

  // Reseta os sinais do driver
  virtual protected task reset_driver_signals();
    @(vif.tx_drv_cb); 
    vif.tx_drv_cb.valid_tx_in <= 0; 
    vif.tx_drv_cb.data_tx_in  <= 'x; 
  endtask : reset_driver_signals
  
  virtual protected task wait_for_reset();
    wait (vif.nreset == 0);
  endtask : wait_for_reset

endclass : uart_tx_driver


class uart_rx_driver #(
  parameter int BAUDRATE    = 115200,
  parameter int CLOCK_INPUT = 100_000_000
) extends uvm_driver #(uart_transaction);
  
  virtual uart_if.RX_DRV vif; 

  localparam int CLKS_PER_BIT = (CLOCK_INPUT + (BAUDRATE / 2)) / BAUDRATE;

  `uvm_component_param_utils(uart_rx_driver#(BAUDRATE, CLOCK_INPUT))

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual uart_if.RX_DRV)::get(this, "", "vif_rx", vif))
      `uvm_fatal(get_type_name(), "Nao foi possivel encontrar a interface virtual 'vif_rx'")
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), $sformatf("Driver RX iniciado (Clks_per_bit = %0d)", CLKS_PER_BIT), UVM_MEDIUM)
    reset_driver_signals();
    wait (vif.nreset == 1);
    `uvm_info(get_type_name(), "Driver RX: Reset liberado, iniciando loop", UVM_MEDIUM)

    forever begin
      seq_item_port.get_next_item(req);
      
      fork
        drive_rx_serial(req.data);
        wait_for_reset();
      join_any
      
      if (vif.nreset == 0) begin
        `uvm_info(get_type_name(), "RX Driver: Reset detectado", UVM_MEDIUM)
        reset_driver_signals();
      end 
      else begin
        seq_item_port.item_done();
      end
    end
  endtask : run_phase
  
  virtual protected task drive_rx_serial(logic [7:0] data);
    logic [7:0] frame; 
    frame = {data};
    
    vif.rx_drv_cb.valid_rx_in <= 1; 
    
    `uvm_info(get_type_name(), $sformatf("Drive RX: Enviando frame 0x%h", frame), UVM_FULL)
    
    for (int i = 0; i < 8; i++) begin
      vif.rx_drv_cb.sdata_rx_in <= frame[i]; 
      repeat (CLKS_PER_BIT - 1) @(vif.rx_drv_cb); 
    end
    
    vif.rx_drv_cb.valid_rx_in <= 0;
    vif.rx_drv_cb.sdata_rx_in <= 1; 
    
    repeat (CLKS_PER_BIT) @(vif.rx_drv_cb); 
  endtask : drive_rx_serial
  
  virtual protected task reset_driver_signals();
    @(vif.rx_drv_cb); 
    vif.rx_drv_cb.sdata_rx_in <= 1; 
    vif.rx_drv_cb.valid_rx_in <= 0; 
  endtask : reset_driver_signals

  virtual protected task wait_for_reset();
    wait (vif.nreset == 0);
  endtask : wait_for_reset

endclass : uart_rx_driver


