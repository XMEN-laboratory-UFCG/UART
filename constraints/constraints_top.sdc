###########################################################
# Arquivo: uart_top.sdc
# Descrição: Restrições de temporização para módulo UART

###########################################################

# ===========================
# 1. Definição do clock principal
# ===========================
# CLOCK_REF é a frequência de referência do clock do sistema.
# Exemplo: CLOCK_REF = 50 MHz → período = 20 ns

create_clock -name clk_uart -period 20.000 [get_ports clock]

# ===========================
# 2. Reset
# ===========================
# Reset assíncrono, não deve gerar avisos de temporização
set_false_path -from [get_ports nreset]

# ===========================
# 3. Entradas e saídas externas
# ===========================
# Ajuste os tempos de setup/hold conforme o dispositivo externo.

# RX (entrada serial)
set_input_delay  -clock clk_uart 2.0 [get_ports sdata_rx_in]
set_input_delay  -clock clk_uart 0.5 -min [get_ports sdata_rx_in]

# TX (saída serial)
set_output_delay -clock clk_uart 2.0 [get_ports sdata_tx_out]
set_output_delay -clock clk_uart 0.5 -min [get_ports sdata_tx_out]

# ===========================
# 4. Caminhos assíncronos
# ===========================
# Se a UART tiver clock interno derivado (por exemplo, divisor de clock),
# e o domínio do RX/TX for o mesmo clock, não há necessidade de multiclocks.
# Caso contrário, isole domínios:
# set_clock_groups -asynchronous -group {clk_uart} -group {rx_clk tx_clk}

# ===========================
# 5. Caminhos não cronometrados (caso necessário)
# ===========================
# Se 'valid_tx_in', 'ready_rx_out', etc. forem handshake lentos (sem requisito de tempo),
# eles podem ser marcados como false path:
# set_false_path -from [get_ports valid_tx_in]
# set_false_path -to   [get_ports ready_rx_out]

###########################################################
# Fim do arquivo SDC
###########################################################
