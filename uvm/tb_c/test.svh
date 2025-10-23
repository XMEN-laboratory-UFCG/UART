class test extends uvm_test;  
   `uvm_component_utils(test)

   env env_h;

   function new(string name, uvm_component parent);
     super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     env_h = env::type_id::create("env_h", this);
   endfunction

   task run_phase(uvm_phase phase);
  
     uart_tx_seq tx_seq;
     uart_rx_seq rx_seq;

     phase.raise_objection(this, "Iniciando sequencias TX e RX");
     // Cria os objetos da sequencia
     tx_seq = uart_tx_seq::type_id::create("tx_seq");
     rx_seq = uart_rx_seq::type_id::create("rx_seq");
     `uvm_info(get_type_name(), "Iniciando sequencias TX e RX em paralelo", UVM_MEDIUM)
     fork

       tx_seq.start( env_h.m_agent.m_tx_sequencer );
       rx_seq.start( env_h.m_agent.m_rx_sequencer );
     join
     #1000ns;
     `uvm_info(get_type_name(), "Sequencias concluidas. Teste terminando.", UVM_MEDIUM)
     phase.drop_objection(this, "Sequencias TX e RX concluidas");

   endtask

endclass : test

