
// ----------------------------------------------------------------------------------------------------
// DESCRIÇÃO: Classe `coverage_out` para verificação UVM do multiplicador binário de 32x32 bits
//             - Coleta cobertura funcional das saídas do DUT, como o produto e os sinais de status.
//             - Verifica a resposta do DUT em diferentes condições e valida os resultados esperados.
//             - Garante cobertura sobre a variação do produto gerado pelo multiplicador, incluindo valores de borda.
// ----------------------------------------------------------------------------------------------------
// RELEASE HISTORY  :
// DATA                 VERSÃO      AUTOR                    DESCRIÇÃO
// 2024-09-20           0.1         Cleisson                 Versão inicial.
//                                  Pedro Henrique
//                                  
// ----------------------------------------------------------------------------------------------------
class coverage_out extends bvm_cover #(tr_out);
   `uvm_component_utils(coverage_out)

   covergroup transaction_covergroup;                             // predefined name of covergroup
      option.per_instance = 1;
    endgroup
   `bvm_cover_utils(tr_out)
    
endclass : coverage_out