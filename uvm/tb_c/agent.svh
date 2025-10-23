
 
class uart_agent extends uvm_agent;

  `uvm_component_utils(uart_agent)

  
  uart_tx_driver  m_tx_driver;
  uart_rx_driver  m_rx_driver;
  
  uart_tx_sequencer m_tx_sequencer;
  uart_rx_sequencer m_rx_sequencer;
  
  // (Voce tambem deve adicionar um monitor aqui)
   uart_monitor m_monitor;


  localparam int BAUDRATE    = 115200;
  localparam int CLOCK_INPUT = 100_000_000; // Clock de 50MHz do seu DUT

  function new(string name = "uart_agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Construindo agente...", UVM_MEDIUM)
    m_monitor = uart_monitor::type_id::create("m_monitor", this);
    
    // Apenas construa drivers/sequencers se o agente for ATIVO
    if (get_is_active() == UVM_ACTIVE) begin
      `uvm_info(get_type_name(), "Agente ATIVO: Construindo Drivers e Sequencers", UVM_MEDIUM)
      
      // Cria os drivers
      m_tx_driver = uart_tx_driver::type_id::create("m_tx_driver", this);
      m_rx_driver = uart_rx_driver#(BAUDRATE, CLOCK_INPUT)::type_id::create("m_rx_driver", this);

      // Cria os sequencers
      m_tx_sequencer = uart_tx_sequencer::type_id::create("m_tx_sequencer", this);
      m_rx_sequencer = uart_rx_sequencer::type_id::create("m_rx_sequencer", this);
    end
  endfunction : build_phase

  virtual function void connect_phase(uvm_phase phase);
    if (get_is_active() == UVM_ACTIVE) begin
      // Conecta o driver TX ao sequencer TX
      m_tx_driver.seq_item_port.connect(m_tx_sequencer.seq_item_export);
      
      // Conecta o driver RX ao sequencer RX
      m_rx_driver.seq_item_port.connect(m_rx_sequencer.seq_item_export);
    end
    
    // Conecte o monitor aqui...
    // if(m_monitor != null) ...
    
  endfunction : connect_phase

endclass : uart_agent