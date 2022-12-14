transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/Job/project_quartus/SPI_TX-main {D:/Job/project_quartus/SPI_TX-main/SPI_TX.v}

vlog -vlog01compat -work work +incdir+D:/Job/project_quartus/SPI_TX-main/simulation/modelsim {D:/Job/project_quartus/SPI_TX-main/simulation/modelsim/SPI_TX.vt}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L fiftyfivenm_ver -L rtl_work -L work -voptargs="+acc"  SPI_TX_vlg_tst

add wave *
view structure
view signals
run -all
