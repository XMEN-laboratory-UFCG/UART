// ----------------------------------------------------------------------------------------------------
// DESCRIÇÃO: Classe `env` para verificação UVM do multiplicador binário de 32x32 bits
//             - Integra os componentes de verificação: driver, sequencer, monitor, scoreboard.
//             - Controla o fluxo de dados e a integração de diferentes agentes.
// ----------------------------------------------------------------------------------------------------
// RELEASE HISTORY  :
// DATA                 VERSÃO      AUTOR                    DESCRIÇÃO
// 2024-09-20           0.1         Cleisson                 Versão inicial.
//                                  Pedro Henrique
//                                  
// ----------------------------------------------------------------------------------------------------

class env extends uvm_env;
   `uvm_component_utils(env)
    


    uart_agent m_agent;
    uart_scoreboard m_scoreboard;


   function new(string name, uvm_component parent);
     super.new(name, parent);
   endfunction
   
   function void build_phase(uvm_phase phase);
     super.build_phase(phase);
  
     `uvm_info(get_type_name(), "Construindo ambiente...", UVM_MEDIUM)
     m_agent = uart_agent::type_id::create("m_agent", this);
     m_scoreboard = uart_scoreboard::type_id::create("m_scoreboard", this);
     
   endfunction

   function void connect_phase(uvm_phase phase);


     `uvm_info(get_type_name(), "Conectando monitor ao scoreboard...", UVM_MEDIUM)
    // m_agent -> m_monitor -> tx_ap (porta) --> (conecta) --> m_scoreboard -> tx_export (export)
    m_agent.m_monitor.tx_ap.connect(m_scoreboard.tx_export);
    // m_agent -> m_monitor -> rx_ap (porta) --> (conecta) --> m_scoreboard -> rx_export (export)
    m_agent.m_monitor.rx_ap.connect(m_scoreboard.rx_export);

   endfunction
   
endclass

