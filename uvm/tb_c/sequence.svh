// ----------------------------------------------------------------------------------------------------
// DESCRIÇÃO: Classe `sequencer` para verificação UVM do multiplicador binário de 32x32 bits
//             - Gera sequência de transações para estimular o DUT.
//             - Configura cenários de teste, como valores limites e casos de corner.
// ----------------------------------------------------------------------------------------------------
// RELEASE HISTORY  :
// DATA                 VERSÃO      AUTOR                    DESCRIÇÃO
// 2024-09-20           0.1         Cleisson                 Versão inicial.
//                                  Pedro Henrique
//                                  
// ----------------------------------------------------------------------------------------------------

class uart_tx_seq extends uvm_sequence #(uart_transaction);

  `uvm_object_utils(uart_tx_seq)

  // Quantos bytes aleatorios queremos enviar
  rand int unsigned num_bytes_to_send;

  // Construtor
  function new(string name = "uart_tx_seq");
    super.new(name);
    num_bytes_to_send = 10; 
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), $sformatf("Iniciando sequencia TX. Enviando %0d bytes...", num_bytes_to_send), UVM_MEDIUM)
    
    // Repete para o numero de bytes desejado
    repeat (num_bytes_to_send) begin

      req = uart_transaction::type_id::create("req");
      start_item(req);
      // Randomiza o dado
      if ( !req.randomize() ) begin
        `uvm_error(get_type_name(), "Falha ao randomizar a transacao TX")
      end
      `uvm_info(get_type_name(), $sformatf("Enviando byte TX: 0x%h", req.data), UVM_HIGH)
      // 4. Envia o item para o driver
      finish_item(req);
    
      // 'req' agora eh consumido pelo uart_tx_driver
    end
    
    `uvm_info(get_type_name(), "Sequencia TX concluida", UVM_MEDIUM)
  endtask : body

endclass : uart_tx_seq

class uart_rx_seq extends uvm_sequence #(uart_transaction);

  `uvm_object_utils(uart_rx_seq)

  // Quantos bytes aleatorios queremos simular no pino RX
  rand int unsigned num_bytes_to_send;

  // Construtor
  function new(string name = "uart_rx_seq");
    super.new(name);
    // Valor padrao
    num_bytes_to_send = 10;
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), $sformatf("Iniciando sequencia RX. Simulando %0d bytes...", num_bytes_to_send), UVM_MEDIUM)
    
    repeat (num_bytes_to_send) begin
      req = uart_transaction::type_id::create("req");
      start_item(req);
      if ( !req.randomize() ) begin
        `uvm_error(get_type_name(), "Falha ao randomizar a transacao RX")
      end
      `uvm_info(get_type_name(), $sformatf("Simulando byte RX: 0x%h", req.data), UVM_HIGH)

      finish_item(req);
    end
    
    `uvm_info(get_type_name(), "Sequencia RX concluida", UVM_MEDIUM)
  endtask : body

endclass : uart_rx_seq