// ----------------------------------------------------------------------------------------------------
// DESCRIÇÃO: Classe `coverage_in` para verificação UVM do multiplicador binário de 32x32 bits
//             - Coleta cobertura funcional das entradas do DUT, como operandos e sinal de controle.
//             - Verifica a variação dos valores de entrada, garantindo a cobertura de todos os cenários possíveis.
//             - Utiliza bins para cobrir diferentes combinações de multiplicandos (32x32 bits) e sinais de controle.
// ----------------------------------------------------------------------------------------------------
// RELEASE HISTORY  :
// DATA                 VERSÃO      AUTOR                    DESCRIÇÃO
// 2024-09-20           0.1         Cleisson                 Versão inicial.
//                                  Pedro Henrique
//                                  
// ----------------------------------------------------------------------------------------------------
class coverage_in extends bvm_cover #(tr_in);
   `uvm_component_utils(coverage_in)

   covergroup transaction_covergroup;  // predefined name of covergroup
      option.per_instance = 1;
      
 
   endgroup
   `bvm_cover_utils(tr_in)
    
endclass : coverage_in

