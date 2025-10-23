

// Uma transacao simples que apenas carrega o byte de dados
class uart_transaction extends uvm_sequence_item;
  
  // O dado a ser enviado (seja pelo TX ou RX driver)
  // Tamanho fixado em 8 bits
  rand logic [7:0] data;

  // Metadados UVM
  `uvm_object_utils_begin(uart_transaction)
    `uvm_field_int(data, UVM_DEFAULT)
  `uvm_object_utils_end

  // Construtor
  function new (string name = "uart_transaction");
    super.new(name);
  endfunction : new

endclass : uart_transaction