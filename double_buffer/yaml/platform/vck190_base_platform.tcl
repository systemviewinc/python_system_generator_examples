################################################################
# VSI Platform of vck190
################################################################
proc get_type {} {
  return "platform"
}

proc get_adaptable_apps {} {
  set app_list "benchmark_mem_vck190 r5_passthrough load_on_demand sort"
  return $app_list
}

namespace eval _tcl {
  proc get_script_folder {} {
    set script_path [file normalize [info script]]
    set script_folder [file dirname $script_path]
    return $script_folder
  }
}

variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2021.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
  puts ""
  catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "WARNING" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}
}

proc CheckIP { } {
  set bCheckIPsPassed 1
  ##################################################################
  # CHECK IPs
  ##################################################################
  set bCheckIPs 1
  if { $bCheckIPs == 1 } {
     set list_check_ips "\
  vsi.com:vsi_software_lib:vsi_common_driver:1.0\
  vsi.com:platform:vsi_context:1.0\
  xilinx.com:ip:versal_cips:3*\
  xilinx.com:ip:axi_noc:1.0\
  xilinx.com:ip:ai_engine:2.0\
  xilinx.com:ip:clk_wizard:1.0\
  vsi.com:ip:common_interface:2.0\
  xilinx.com:ip:proc_sys_reset:5.0\
  vsi.com:vsi_software_lib:rpmsg:1.0\
  "

     set list_ips_missing ""
     common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

     foreach ip_vlnv $list_check_ips {
        set ip_obj [get_ipdefs -all $ip_vlnv]
        if { $ip_obj eq "" } {
           lappend list_ips_missing $ip_vlnv
        }
     }

     if { $list_ips_missing ne "" } {
        catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
        set bCheckIPsPassed 0
     }

  }

  if { $bCheckIPsPassed != 1 } {
    common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
    return 3
  }
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: versal_r5
proc create_hier_cell_versal_r5 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_versal_r5() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S0_AXI


  # Create pins

  # Create instance: rpmsg_0, and set properties
  set rpmsg_0 [ create_bd_cell -type ip -vlnv vsi.com:vsi_software_lib:rpmsg:1.0 rpmsg_0 ]

  # Create instance: vsi_context_versal_r5, and set properties
  set vsi_context_versal_r5 [ create_bd_cell -type ip -vlnv vsi.com:platform:vsi_context:1.0 vsi_context_versal_r5 ]
  set_property -dict [ list \
   CONFIG.LOGO_FILE {data/vsi_context_cpp.png} \
   CONFIG.OS {FreeRTOS} \
   CONFIG.cc_prefix {armr5-none-eabi-} \
   CONFIG.cpu_type {4} \
   CONFIG.fpga_family {null} \
   CONFIG.is_cc {true} \
   CONFIG.is_main {false} \
   CONFIG.type {1} \
 ] $vsi_context_versal_r5

  # Create interface connections
  connect_bd_intf_net -intf_net S0_AXI_1 [get_bd_intf_pins S0_AXI] [get_bd_intf_pins rpmsg_0/S0_AXI]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: versal_ps
proc create_hier_cell_versal_ps { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_versal_ps() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI

  create_bd_intf_pin -mode Master -vlnv vsi.com:interface:platform_rtl:1.0 PLATFORM


  # Create pins

  # Create instance: vsi_common_driver_0, and set properties
  set vsi_common_driver_0 [ create_bd_cell -type ip -vlnv vsi.com:vsi_software_lib:vsi_common_driver:1.0 vsi_common_driver_0 ]
  set_property -dict [ list \
   CONFIG.driver_type {2} \
 ] $vsi_common_driver_0

  # Create instance: vsi_common_driver_1, and set properties
  set vsi_common_driver_1 [ create_bd_cell -type ip -vlnv vsi.com:vsi_software_lib:vsi_common_driver:1.0 vsi_common_driver_1 ]
  set_property -dict [ list \
   CONFIG.driver_library_name {vsi_rpmsg_driver.ko} \
   CONFIG.driver_type {3} \
   CONFIG.major {260} \
 ] $vsi_common_driver_1

  set hostname localhost
  if {[info exists ::env(TARGET_HOSTNAME)]} {
    set hostname $::env(TARGET_HOSTNAME)
  }
  # Create instance: vsi_context_versal_ps, and set properties
  set vsi_context_versal_ps [ create_bd_cell -type ip -vlnv vsi.com:platform:vsi_context:1.0 vsi_context_versal_ps ]
  set_property -dict [ list \
   CONFIG.LOGO_FILE {data/vsi_context_cpp.png} \
   CONFIG.cc_prefix {aarch64-linux-gnu-} \
   CONFIG.cpu_type {3} \
   CONFIG.fpga_family {null} \
   CONFIG.is_main {true} \
   CONFIG.hostname $hostname \
   CONFIG.is_cc {true} \
   CONFIG.is_system_gui {false} \
   CONFIG.type {1} \
 ] $vsi_context_versal_ps

  # Create interface connections
  connect_bd_intf_net -intf_net vsi_common_driver_0_PLATFORM [get_bd_intf_pins PLATFORM] [get_bd_intf_pins vsi_common_driver_0/PLATFORM]
  connect_bd_intf_net -intf_net vsi_common_driver_1_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins vsi_common_driver_1/M_AXI]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: versal_fabric
proc create_hier_cell_versal_fabric { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_versal_fabric() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv vsi.com:interface:platform_rtl:1.0 PLAT_INTERFACE

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S01_AXI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch0_lpddr4_c0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch0_lpddr4_c1

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch1_lpddr4_c0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch1_lpddr4_c1

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 ddr4_dimm1

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ddr4_dimm1_sma_clk

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 lpddr4_sma_clk1

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 lpddr4_sma_clk2


  # Create pins
  create_bd_pin -dir O -type clk clk_out1
  create_bd_pin -dir O -type clk clk_out2
  create_bd_pin -dir O -type clk clk_out4
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn_0
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn_1
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn_2

  # Create instance: CIPS_0, and set properties
  set CIPS_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:versal_cips:3* CIPS_0 ]
  set_property -dict [ list \
   CONFIG.CLOCK_MODE {Custom} \
   CONFIG.PS_BOARD_INTERFACE {ps_pmc_fixed_io} \
   CONFIG.CPM_CONFIG {CPM_DMA_CREDIT_INIT_DEMUX 1 CPM_PCIE0_MODES None\
CPM_PCIE0_EXT_PCIE_CFG_SPACE_ENABLED None CPM_PCIE1_EXT_PCIE_CFG_SPACE_ENABLED\
None CPM_PCIE1_PF0_CLASS_CODE 58000 CPM_PCIE0_PF1_SUB_CLASS_VALUE 80\
CPM_PCIE1_PF1_SUB_CLASS_VALUE 80 CPM_PCIE0_PF2_SUB_CLASS_VALUE 80\
CPM_PCIE1_PF2_SUB_CLASS_VALUE 80 CPM_PCIE0_PF3_SUB_CLASS_VALUE 80\
CPM_PCIE1_PF3_SUB_CLASS_VALUE 80 CPM_PCIE0_PF0_SUB_CLASS_INTF_MENU\
Other_memory_controller CPM_PCIE1_PF0_SUB_CLASS_INTF_MENU\
Other_memory_controller CPM_PCIE0_PF1_SUB_CLASS_INTF_MENU\
Other_memory_controller CPM_PCIE1_PF1_SUB_CLASS_INTF_MENU\
Other_memory_controller CPM_PCIE0_PF2_SUB_CLASS_INTF_MENU\
Other_memory_controller CPM_PCIE1_PF2_SUB_CLASS_INTF_MENU\
Other_memory_controller CPM_PCIE0_PF3_SUB_CLASS_INTF_MENU\
Other_memory_controller CPM_PCIE1_PF3_SUB_CLASS_INTF_MENU\
Other_memory_controller CPM_PCIE0_PF1_BASE_CLASS_VALUE 05\
CPM_PCIE1_PF1_BASE_CLASS_VALUE 05 CPM_PCIE0_PF2_BASE_CLASS_VALUE 05\
CPM_PCIE1_PF2_BASE_CLASS_VALUE 05 CPM_PCIE0_PF3_BASE_CLASS_VALUE 05\
CPM_PCIE1_PF3_BASE_CLASS_VALUE 05 CPM_PCIE0_PF0_USE_CLASS_CODE_LOOKUP_ASSISTANT\
1 CPM_PCIE1_PF0_USE_CLASS_CODE_LOOKUP_ASSISTANT 1\
CPM_PCIE0_PF1_USE_CLASS_CODE_LOOKUP_ASSISTANT 1\
CPM_PCIE1_PF1_USE_CLASS_CODE_LOOKUP_ASSISTANT 1\
CPM_PCIE0_PF2_USE_CLASS_CODE_LOOKUP_ASSISTANT 1\
CPM_PCIE1_PF2_USE_CLASS_CODE_LOOKUP_ASSISTANT 1\
CPM_PCIE0_PF3_USE_CLASS_CODE_LOOKUP_ASSISTANT 1\
CPM_PCIE1_PF3_USE_CLASS_CODE_LOOKUP_ASSISTANT 1 CPM_PCIE0_PF1_INTERFACE_VALUE\
00 CPM_PCIE1_PF1_INTERFACE_VALUE 00 CPM_PCIE0_PF2_INTERFACE_VALUE 00\
CPM_PCIE1_PF2_INTERFACE_VALUE 00 CPM_PCIE0_PF3_INTERFACE_VALUE 00\
CPM_PCIE1_PF3_INTERFACE_VALUE 00}\
   CONFIG.PS_PL_CONNECTIVITY_MODE {Custom} \
   CONFIG.PS_PMC_CONFIG {CLOCK_MODE Custom DESIGN_MODE 1 PCIE_APERTURES_DUAL_ENABLE 0\
PCIE_APERTURES_SINGLE_ENABLE 0 PMC_CRP_CFU_REF_CTRL_ACT_FREQMHZ 299.997009\
PMC_CRP_CFU_REF_CTRL_DIVISOR0 4 PMC_CRP_CFU_REF_CTRL_SRCSEL PPLL\
PMC_CRP_DFT_OSC_REF_CTRL_DIVISOR0 3 PMC_CRP_DFT_OSC_REF_CTRL_SRCSEL PPLL\
PMC_CRP_HSM0_REF_CTRL_DIVISOR0 36 PMC_CRP_HSM0_REF_CTRL_SRCSEL PPLL\
PMC_CRP_HSM1_REF_CTRL_DIVISOR0 9 PMC_CRP_HSM1_REF_CTRL_SRCSEL PPLL\
PMC_CRP_I2C_REF_CTRL_DIVISOR0 12 PMC_CRP_I2C_REF_CTRL_SRCSEL PPLL\
PMC_CRP_LSBUS_REF_CTRL_ACT_FREQMHZ 99.999001 PMC_CRP_LSBUS_REF_CTRL_DIVISOR0 12\
PMC_CRP_LSBUS_REF_CTRL_SRCSEL PPLL PMC_CRP_NOC_REF_CTRL_ACT_FREQMHZ 949.990479\
PMC_CRP_NOC_REF_CTRL_SRCSEL NPLL PMC_CRP_NPI_REF_CTRL_DIVISOR0 4\
PMC_CRP_NPI_REF_CTRL_SRCSEL PPLL PMC_CRP_NPLL_CTRL_CLKOUTDIV 4\
PMC_CRP_NPLL_CTRL_FBDIV 114 PMC_CRP_NPLL_CTRL_SRCSEL REF_CLK\
PMC_CRP_NPLL_TO_XPD_CTRL_DIVISOR0 1 PMC_CRP_OSPI_REF_CTRL_DIVISOR0 4\
PMC_CRP_OSPI_REF_CTRL_SRCSEL PPLL PMC_CRP_PL0_REF_CTRL_ACT_FREQMHZ 199.998001\
PMC_CRP_PL0_REF_CTRL_DIVISOR0 6 PMC_CRP_PL0_REF_CTRL_FREQMHZ 200\
PMC_CRP_PL0_REF_CTRL_SRCSEL PPLL PMC_CRP_PL1_REF_CTRL_DIVISOR0 3\
PMC_CRP_PL1_REF_CTRL_SRCSEL NPLL PMC_CRP_PL2_REF_CTRL_DIVISOR0 3\
PMC_CRP_PL2_REF_CTRL_SRCSEL NPLL PMC_CRP_PL3_REF_CTRL_DIVISOR0 3\
PMC_CRP_PL3_REF_CTRL_SRCSEL NPLL PMC_CRP_PPLL_CTRL_CLKOUTDIV 2\
PMC_CRP_PPLL_CTRL_FBDIV 72 PMC_CRP_PPLL_CTRL_SRCSEL REF_CLK\
PMC_CRP_PPLL_TO_XPD_CTRL_DIVISOR0 2 PMC_CRP_QSPI_REF_CTRL_ACT_FREQMHZ\
199.998001 PMC_CRP_QSPI_REF_CTRL_DIVISOR0 6 PMC_CRP_QSPI_REF_CTRL_SRCSEL PPLL\
PMC_CRP_SDIO0_REF_CTRL_DIVISOR0 6 PMC_CRP_SDIO0_REF_CTRL_SRCSEL PPLL\
PMC_CRP_SDIO1_REF_CTRL_ACT_FREQMHZ 199.998001 PMC_CRP_SDIO1_REF_CTRL_DIVISOR0 6\
PMC_CRP_SDIO1_REF_CTRL_SRCSEL PPLL PMC_CRP_SD_DLL_REF_CTRL_ACT_FREQMHZ\
1199.988037 PMC_CRP_SD_DLL_REF_CTRL_DIVISOR0 1 PMC_CRP_SD_DLL_REF_CTRL_SRCSEL\
PPLL PMC_CRP_TEST_PATTERN_REF_CTRL_DIVISOR0 6\
PMC_CRP_TEST_PATTERN_REF_CTRL_SRCSEL PPLL PMC_GPIO0_MIO_PERIPHERAL {{ENABLE 1}\
{IO {PMC_MIO 0 .. 25}}} PMC_GPIO1_MIO_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 26 ..\
51}}} PMC_HSM0_CLK_ENABLE 1 PMC_HSM1_CLK_ENABLE 1 PMC_MIO0 {{AUX_IO 0}\
{DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup}\
{SCHMITT 1} {SLEW slow} {USAGE Reserved}} PMC_MIO12 {{AUX_IO 0} {DIRECTION out}\
{DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW\
slow} {USAGE Reserved}} PMC_MIO13 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH\
8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE\
Reserved}} PMC_MIO24 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA}\
{OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}}\
PMC_MIO37 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA high}\
{PULL pulldown} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} PMC_MIO40 {{AUX_IO 0}\
{DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup}\
{SCHMITT 1} {SLEW slow} {USAGE Reserved}} PMC_MIO43 {{AUX_IO 0} {DIRECTION out}\
{DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW\
slow} {USAGE Reserved}} PMC_MIO48 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH\
8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}}\
PMC_MIO49 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA\
default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} PMC_MIO5 {{AUX_IO\
0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup}\
{SCHMITT 1} {SLEW slow} {USAGE Reserved}} PMC_MIO51 {{AUX_IO 0} {DIRECTION out}\
{DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW\
slow} {USAGE Reserved}} PMC_MIO6 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH\
8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE\
Reserved}} PMC_MIO7 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA}\
{OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}}\
PMC_MIO_TREE_PERIPHERALS {QSPI#QSPI#QSPI#QSPI#QSPI#QSPI#Loopback\
Clk#QSPI#QSPI#QSPI#QSPI#QSPI#QSPI#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB 0#USB\
0#USB 0#USB 0#USB 0#USB 0#USB\
0#SD1/eMMC1#SD1/eMMC1#SD1#SD1/eMMC1#SD1/eMMC1#SD1/eMMC1#SD1/eMMC1#SD1/eMMC1#SD1/eMMC1#SD1/eMMC1#SD1/eMMC1#GPIO\
1###CAN 1#CAN 1#UART 0#UART 0#I2C 1#I2C 1#I2C 0#I2C 0#GPIO 1#GPIO\
1##SD1/eMMC1#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet 0#Enet\
0#Enet 0#Enet 0#Enet 0#Enet 1#Enet 1#Enet 1#Enet 1#Enet 1#Enet 1#Enet 1#Enet\
1#Enet 1#Enet 1#Enet 1#Enet 1#Enet 0#Enet 0} PMC_MIO_TREE_SIGNALS\
qspi0_clk#qspi0_io[1]#qspi0_io[2]#qspi0_io[3]#qspi0_io[0]#qspi0_cs_b#qspi_lpbk#qspi1_cs_b#qspi1_io[0]#qspi1_io[1]#qspi1_io[2]#qspi1_io[3]#qspi1_clk#usb2phy_reset#ulpi_tx_data[0]#ulpi_tx_data[1]#ulpi_tx_data[2]#ulpi_tx_data[3]#ulpi_clk#ulpi_tx_data[4]#ulpi_tx_data[5]#ulpi_tx_data[6]#ulpi_tx_data[7]#ulpi_dir#ulpi_stp#ulpi_nxt#clk#dir1/data[7]#detect#cmd#data[0]#data[1]#data[2]#data[3]#sel/data[4]#dir_cmd/data[5]#dir0/data[6]#gpio_1_pin[37]###phy_tx#phy_rx#rxd#txd#scl#sda#scl#sda#gpio_1_pin[48]#gpio_1_pin[49]##buspwr/rst#rgmii_tx_clk#rgmii_txd[0]#rgmii_txd[1]#rgmii_txd[2]#rgmii_txd[3]#rgmii_tx_ctl#rgmii_rx_clk#rgmii_rxd[0]#rgmii_rxd[1]#rgmii_rxd[2]#rgmii_rxd[3]#rgmii_rx_ctl#rgmii_tx_clk#rgmii_txd[0]#rgmii_txd[1]#rgmii_txd[2]#rgmii_txd[3]#rgmii_tx_ctl#rgmii_rx_clk#rgmii_rxd[0]#rgmii_rxd[1]#rgmii_rxd[2]#rgmii_rxd[3]#rgmii_rx_ctl#gem0_mdc#gem0_mdio\
PMC_QSPI_FBCLK {{ENABLE 1} {IO {PMC_MIO 6}}} PMC_QSPI_PERIPHERAL_DATA_MODE x4\
PMC_QSPI_PERIPHERAL_ENABLE 1 PMC_QSPI_PERIPHERAL_MODE {Dual Parallel}\
PMC_SD0_PERIPHERAL {{ENABLE 0} {IO {PMC_MIO 13 .. 25}}} PMC_SD1 {{CD_ENABLE 1}\
{CD_IO {PMC_MIO 28}} {POW_ENABLE 1} {POW_IO {PMC_MIO 51}} {RESET_ENABLE 0}\
{RESET_IO {PMC_MIO 1}} {WP_ENABLE 0} {WP_IO {PMC_MIO 1}}}\
PMC_SD1_DATA_TRANSFER_MODE 8Bit PMC_SD1_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 26\
.. 36}}} PMC_SD1_SLOT_TYPE {SD 3.0} PMC_SD1_SPEED_MODE {high speed}\
PMC_USE_NOC_PMC_AXI0 0 PMC_USE_PMC_NOC_AXI0 1 PSPMC_MANUAL_CLK_ENABLE 1\
PS_BOARD_INTERFACE Custom PS_CAN1_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 40 ..\
41}}} PS_CRF_ACPU_CTRL_ACT_FREQMHZ 999.989990 PS_CRF_ACPU_CTRL_DIVISOR0 1\
PS_CRF_ACPU_CTRL_SRCSEL APLL PS_CRF_APLL_CTRL_CLKOUTDIV 4\
PS_CRF_APLL_CTRL_FBDIV 120 PS_CRF_APLL_CTRL_SRCSEL REF_CLK\
PS_CRF_APLL_TO_XPD_CTRL_DIVISOR0 2 PS_CRF_DBG_FPD_CTRL_ACT_FREQMHZ 299.997009\
PS_CRF_DBG_FPD_CTRL_DIVISOR0 2 PS_CRF_DBG_FPD_CTRL_SRCSEL PPLL\
PS_CRF_DBG_TRACE_CTRL_DIVISOR0 3 PS_CRF_DBG_TRACE_CTRL_SRCSEL PPLL\
PS_CRF_FPD_LSBUS_CTRL_ACT_FREQMHZ 99.999001 PS_CRF_FPD_LSBUS_CTRL_DIVISOR0 6\
PS_CRF_FPD_LSBUS_CTRL_SRCSEL PPLL PS_CRF_FPD_TOP_SWITCH_CTRL_ACT_FREQMHZ\
499.994995 PS_CRF_FPD_TOP_SWITCH_CTRL_DIVISOR0 2\
PS_CRF_FPD_TOP_SWITCH_CTRL_SRCSEL APLL PS_CRL_CAN0_REF_CTRL_DIVISOR0 12\
PS_CRL_CAN0_REF_CTRL_SRCSEL PPLL PS_CRL_CAN1_REF_CTRL_ACT_FREQMHZ 149.998505\
PS_CRL_CAN1_REF_CTRL_DIVISOR0 4 PS_CRL_CAN1_REF_CTRL_FREQMHZ 150\
PS_CRL_CAN1_REF_CTRL_SRCSEL PPLL PS_CRL_CPM_TOPSW_REF_CTRL_ACT_FREQMHZ\
474.995239 PS_CRL_CPM_TOPSW_REF_CTRL_DIVISOR0 2\
PS_CRL_CPM_TOPSW_REF_CTRL_FREQMHZ 775 PS_CRL_CPM_TOPSW_REF_CTRL_SRCSEL NPLL\
PS_CRL_CPU_R5_CTRL_ACT_FREQMHZ 374.996246 PS_CRL_CPU_R5_CTRL_DIVISOR0 2\
PS_CRL_CPU_R5_CTRL_SRCSEL RPLL PS_CRL_DBG_LPD_CTRL_ACT_FREQMHZ 299.997009\
PS_CRL_DBG_LPD_CTRL_DIVISOR0 2 PS_CRL_DBG_LPD_CTRL_SRCSEL PPLL\
PS_CRL_DBG_TSTMP_CTRL_ACT_FREQMHZ 299.997009 PS_CRL_DBG_TSTMP_CTRL_DIVISOR0 2\
PS_CRL_DBG_TSTMP_CTRL_SRCSEL PPLL PS_CRL_GEM0_REF_CTRL_ACT_FREQMHZ 124.998749\
PS_CRL_GEM0_REF_CTRL_DIVISOR0 6 PS_CRL_GEM0_REF_CTRL_SRCSEL RPLL\
PS_CRL_GEM1_REF_CTRL_ACT_FREQMHZ 124.998749 PS_CRL_GEM1_REF_CTRL_DIVISOR0 6\
PS_CRL_GEM1_REF_CTRL_SRCSEL RPLL PS_CRL_GEM_TSU_REF_CTRL_ACT_FREQMHZ 249.997498\
PS_CRL_GEM_TSU_REF_CTRL_DIVISOR0 3 PS_CRL_GEM_TSU_REF_CTRL_SRCSEL RPLL\
PS_CRL_I2C0_REF_CTRL_ACT_FREQMHZ 99.999001 PS_CRL_I2C0_REF_CTRL_DIVISOR0 6\
PS_CRL_I2C0_REF_CTRL_SRCSEL PPLL PS_CRL_I2C1_REF_CTRL_ACT_FREQMHZ 99.999001\
PS_CRL_I2C1_REF_CTRL_DIVISOR0 6 PS_CRL_I2C1_REF_CTRL_SRCSEL PPLL\
PS_CRL_IOU_SWITCH_CTRL_DIVISOR0 3 PS_CRL_IOU_SWITCH_CTRL_SRCSEL RPLL\
PS_CRL_LPD_LSBUS_CTRL_ACT_FREQMHZ 99.999001 PS_CRL_LPD_LSBUS_CTRL_DIVISOR0 6\
PS_CRL_LPD_LSBUS_CTRL_SRCSEL PPLL PS_CRL_LPD_TOP_SWITCH_CTRL_ACT_FREQMHZ\
374.996246 PS_CRL_LPD_TOP_SWITCH_CTRL_DIVISOR0 2\
PS_CRL_LPD_TOP_SWITCH_CTRL_SRCSEL RPLL PS_CRL_PSM_REF_CTRL_ACT_FREQMHZ\
299.997009 PS_CRL_PSM_REF_CTRL_DIVISOR0 2 PS_CRL_PSM_REF_CTRL_SRCSEL PPLL\
PS_CRL_RPLL_CTRL_CLKOUTDIV 4 PS_CRL_RPLL_CTRL_FBDIV 90 PS_CRL_RPLL_CTRL_SRCSEL\
REF_CLK PS_CRL_RPLL_TO_XPD_CTRL_DIVISOR0 3 PS_CRL_SPI0_REF_CTRL_DIVISOR0 6\
PS_CRL_SPI0_REF_CTRL_SRCSEL PPLL PS_CRL_SPI1_REF_CTRL_DIVISOR0 6\
PS_CRL_SPI1_REF_CTRL_SRCSEL PPLL PS_CRL_TIMESTAMP_REF_CTRL_DIVISOR0 6\
PS_CRL_TIMESTAMP_REF_CTRL_SRCSEL PPLL PS_CRL_UART0_REF_CTRL_ACT_FREQMHZ\
99.999001 PS_CRL_UART0_REF_CTRL_DIVISOR0 6 PS_CRL_UART0_REF_CTRL_SRCSEL PPLL\
PS_CRL_UART1_REF_CTRL_DIVISOR0 12 PS_CRL_UART1_REF_CTRL_SRCSEL PPLL\
PS_CRL_USB0_BUS_REF_CTRL_ACT_FREQMHZ 19.999800\
PS_CRL_USB0_BUS_REF_CTRL_DIVISOR0 30 PS_CRL_USB0_BUS_REF_CTRL_FREQMHZ 60\
PS_CRL_USB0_BUS_REF_CTRL_SRCSEL PPLL PS_CRL_USB3_DUAL_REF_CTRL_ACT_FREQMHZ 100\
PS_CRL_USB3_DUAL_REF_CTRL_DIVISOR0 100 PS_CRL_USB3_DUAL_REF_CTRL_FREQMHZ 100\
PS_ENET0_MDIO {{ENABLE 1} {IO {PS_MIO 24 .. 25}}} PS_ENET0_PERIPHERAL {{ENABLE\
1} {IO {PS_MIO 0 .. 11}}} PS_ENET1_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 12 ..\
23}}} PS_GEM0_ROUTE_THROUGH_FPD 1 PS_GEM1_ROUTE_THROUGH_FPD 1\
PS_GEN_IPI0_ENABLE 1 PS_GEN_IPI0_MASTER A72 PS_GEN_IPI1_ENABLE 1\
PS_GEN_IPI1_MASTER R5_0 PS_GEN_IPI2_ENABLE 1 PS_GEN_IPI2_MASTER R5_1\
PS_GEN_IPI3_ENABLE 1 PS_GEN_IPI3_MASTER A72 PS_GEN_IPI4_ENABLE 1\
PS_GEN_IPI4_MASTER A72 PS_GEN_IPI5_ENABLE 1 PS_GEN_IPI5_MASTER A72\
PS_GEN_IPI6_ENABLE 1 PS_GEN_IPI6_MASTER A72 PS_GEN_IPI_PMCNOBUF_ENABLE 1\
PS_GEN_IPI_PMC_ENABLE 1 PS_GEN_IPI_PSM_ENABLE 1 PS_GPIO2_MIO_PERIPHERAL\
{{ENABLE 1} {IO {PS_MIO 0 .. 25}}} PS_I2C0_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO\
46 .. 47}}} PS_I2C1_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 44 .. 45}}}\
PS_IRQ_USAGE {{CH0 1} {CH1 1} {CH10 0} {CH11 0} {CH12 0} {CH13 0} {CH14 0}\
{CH15 0} {CH2 1} {CH3 0} {CH4 0} {CH5 0} {CH6 0} {CH7 0} {CH8 0} {CH9 0}}\
PS_MIO0 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default}\
{PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} PS_MIO1 {{AUX_IO 0}\
{DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup}\
{SCHMITT 1} {SLEW slow} {USAGE Reserved}} PS_MIO12 {{AUX_IO 0} {DIRECTION out}\
{DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW\
slow} {USAGE Reserved}} PS_MIO13 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH\
8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE\
Reserved}} PS_MIO14 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA}\
{OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}}\
PS_MIO15 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default}\
{PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} PS_MIO16 {{AUX_IO 0}\
{DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup}\
{SCHMITT 1} {SLEW slow} {USAGE Reserved}} PS_MIO17 {{AUX_IO 0} {DIRECTION out}\
{DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW\
slow} {USAGE Reserved}} PS_MIO2 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH\
8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE\
Reserved}} PS_MIO24 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA}\
{OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}}\
PS_MIO3 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default}\
{PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} PS_MIO4 {{AUX_IO 0}\
{DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup}\
{SCHMITT 1} {SLEW slow} {USAGE Reserved}} PS_MIO5 {{AUX_IO 0} {DIRECTION out}\
{DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW\
slow} {USAGE Reserved}} PS_M_AXI_FPD_DATA_WIDTH 128 PS_M_AXI_LPD_DATA_WIDTH 128\
PS_NUM_FABRIC_RESETS 1 PS_PCIE1_PERIPHERAL_ENABLE 0 PS_PCIE2_PERIPHERAL_ENABLE\
0 PS_PL_CONNECTIVITY_MODE Custom PS_S_AXI_FPD_DATA_WIDTH 64\
PS_S_AXI_GP2_DATA_WIDTH 128 PS_TTC0_PERIPHERAL_ENABLE 1\
PS_TTC0_REF_CTRL_ACT_FREQMHZ 99.999001 PS_TTC0_REF_CTRL_FREQMHZ 99.999001\
PS_TTC1_PERIPHERAL_ENABLE 1 PS_TTC1_REF_CTRL_ACT_FREQMHZ 99.999001\
PS_TTC1_REF_CTRL_FREQMHZ 99.999001 PS_TTC2_PERIPHERAL_ENABLE 1\
PS_TTC2_REF_CTRL_ACT_FREQMHZ 99.999001 PS_TTC2_REF_CTRL_FREQMHZ 99.999001\
PS_TTC3_PERIPHERAL_ENABLE 1 PS_TTC3_REF_CTRL_ACT_FREQMHZ 99.999001\
PS_TTC3_REF_CTRL_FREQMHZ 99.999001 PS_UART0_BAUD_RATE 115200\
PS_UART0_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 42 .. 43}}} PS_USB3_PERIPHERAL\
{{ENABLE 1} {IO {PMC_MIO 13 .. 25}}} PS_USE_FPD_AXI_NOC0 1 PS_USE_FPD_AXI_NOC1\
1 PS_USE_FPD_CCI_NOC 1 PS_USE_M_AXI_FPD 0 PS_USE_M_AXI_LPD 1\
PS_USE_NOC_FPD_CCI0 0 PS_USE_NOC_LPD_AXI0 1 PS_USE_PMCPL_CLK0 1\
PS_USE_S_AXI_FPD 0 PS_USE_S_AXI_GP2 0 PS_WDT0_REF_CTRL_ACT_FREQMHZ 99.999001\
PS_WDT0_REF_CTRL_FREQMHZ 99.999001 PS_WDT0_REF_CTRL_SEL APB PS_WWDT0_CLK\
{{ENABLE 0} {IO APB}} PS_WWDT0_PERIPHERAL {{ENABLE 1} {IO EMIO}} SMON_ALARMS\
Set_Alarms_On SMON_ENABLE_TEMP_AVERAGING 0 SMON_TEMP_AVERAGING_SAMPLES 8}\
   CONFIG.PS_PMC_CONFIG_APPLIED {1} \
 ] $CIPS_0

  set_property SELECTED_SIM_MODEL tlm  $CIPS_0

  # Create instance: NOC_1, and set properties
  set NOC_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.0 NOC_1 ]
  set_property -dict [ list \
   CONFIG.CH0_DDR4_0_BOARD_INTERFACE {ddr4_dimm1} \
   CONFIG.CONTROLLERTYPE {DDR4_SDRAM} \
   CONFIG.HBM_DENSITY_PER_CHNL {1GB} \
   CONFIG.LOGO_FILE {data/noc_mc.png} \
   CONFIG.MC0_CONFIG_NUM {config17} \
   CONFIG.MC1_CONFIG_NUM {config17} \
   CONFIG.MC2_CONFIG_NUM {config17} \
   CONFIG.MC3_CONFIG_NUM {config17} \
   CONFIG.MC_ADDR_BIT7 {BG1} \
   CONFIG.MC_ADDR_BIT8 {BA0} \
   CONFIG.MC_ADDR_BIT9 {BA1} \
   CONFIG.MC_ADDR_BIT10 {CA3} \
   CONFIG.MC_ADDR_BIT11 {CA4} \
   CONFIG.MC_ADDR_BIT12 {CA5} \
   CONFIG.MC_ADDR_BIT13 {CA6} \
   CONFIG.MC_ADDR_BIT14 {CA7} \
   CONFIG.MC_ADDR_BIT15 {CA8} \
   CONFIG.MC_ADDR_BIT16 {CA9} \
   CONFIG.MC_BA_WIDTH {2} \
   CONFIG.MC_BG_WIDTH {2} \
   CONFIG.MC_BOARD_INTRF_EN {true} \
   CONFIG.MC_CASLATENCY {24} \
   CONFIG.MC_CHAN_REGION0 {DDR_LOW0} \
   CONFIG.MC_CHAN_REGION1 {DDR_LOW1} \
   CONFIG.MC_COMPONENT_WIDTH {x8} \
   CONFIG.MC_CONFIG_NUM {config17} \
   CONFIG.MC_DATAWIDTH {64} \
   CONFIG.MC_DDR4_2T {Disable} \
   CONFIG.MC_F1_LPDDR4_MR1 {0x0000} \
   CONFIG.MC_F1_LPDDR4_MR2 {0x0000} \
   CONFIG.MC_F1_TRCD {13750} \
   CONFIG.MC_F1_TRCDMIN {13750} \
   CONFIG.MC_INPUTCLK0_PERIOD {5000} \
   CONFIG.MC_INPUT_FREQUENCY0 {200.000} \
   CONFIG.MC_INTERLEAVE_SIZE {128} \
   CONFIG.MC_MEMORY_DEVICETYPE {UDIMMs} \
   CONFIG.MC_MEMORY_SPEEDGRADE {DDR4-3200AA(22-22-22)} \
   CONFIG.MC_MEMORY_TIMEPERIOD0 {625} \
   CONFIG.MC_NETLIST_SIMULATION {true} \
   CONFIG.MC_NO_CHANNELS {Single} \
   CONFIG.MC_PRE_DEF_ADDR_MAP_SEL {ROW_COLUMN_BANK} \
   CONFIG.MC_RANK {1} \
   CONFIG.MC_READ_BANDWIDTH {6400.0} \
   CONFIG.MC_ROWADDRESSWIDTH {16} \
   CONFIG.MC_TRC {47000} \
   CONFIG.MC_TRCD {15000} \
   CONFIG.MC_TRCDMIN {13750} \
   CONFIG.MC_TRCMIN {45750} \
   CONFIG.MC_TRP {15000} \
   CONFIG.MC_TRPMIN {13750} \
   CONFIG.MC_WRITE_BANDWIDTH {6400.0} \
   CONFIG.MC_XPLL_CLKOUT1_PHASE {238.176} \
   CONFIG.NUM_CLKS {0} \
   CONFIG.NUM_MC {1} \
   CONFIG.NUM_MCP {1} \
   CONFIG.NUM_MI {0} \
   CONFIG.NUM_NSI {1} \
   CONFIG.NUM_SI {0} \
   CONFIG.sys_clk0_BOARD_INTERFACE {ddr4_dimm1_sma_clk} \
 ] $NOC_1

  set_property SELECTED_SIM_MODEL tlm  $NOC_1

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 { read_bw {128} write_bw {128} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /versal_fabric/NOC_1/S00_INI]

  # Create instance: ai_engine_0, and set properties
  set ai_engine_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ai_engine:2.0 ai_engine_0 ]
  set_property -dict [ list \
   CONFIG.AUTO_PIPELINE_MI_AXIS {M00_AXIS{AUTO_PIPELINE 0}:M01_AXIS{AUTO_PIPELINE 0}:M02_AXIS{AUTO_PIPELINE\
0}:M03_AXIS{AUTO_PIPELINE 0}:M04_AXIS{AUTO_PIPELINE 0}:M05_AXIS{AUTO_PIPELINE\
0}:M06_AXIS{AUTO_PIPELINE 0}:M07_AXIS{AUTO_PIPELINE 0}}\
   CONFIG.AUTO_PIPELINE_SI_AXIS {S00_AXIS{AUTO_PIPELINE 0}:S01_AXIS{AUTO_PIPELINE 0}:S02_AXIS{AUTO_PIPELINE\
0}:S03_AXIS{AUTO_PIPELINE 0}:S04_AXIS{AUTO_PIPELINE 0}:S05_AXIS{AUTO_PIPELINE\
0}:S06_AXIS{AUTO_PIPELINE 0}:S07_AXIS{AUTO_PIPELINE 0}}\
   CONFIG.CLK_NAMES {aclk0,} \
   CONFIG.FIFO_TYPE_MI_AXIS {M00_AXIS{FIFO_TYPE 0}:M01_AXIS{FIFO_TYPE 0}:M02_AXIS{FIFO_TYPE\
0}:M03_AXIS{FIFO_TYPE 0}:M04_AXIS{FIFO_TYPE 0}:M05_AXIS{FIFO_TYPE\
0}:M06_AXIS{FIFO_TYPE 0}:M07_AXIS{FIFO_TYPE 0}}\
   CONFIG.FIFO_TYPE_SI_AXIS {S00_AXIS{FIFO_TYPE 0}:S01_AXIS{FIFO_TYPE 0}:S02_AXIS{FIFO_TYPE\
0}:S03_AXIS{FIFO_TYPE 0}:S04_AXIS{FIFO_TYPE 0}:S05_AXIS{FIFO_TYPE\
0}:S06_AXIS{FIFO_TYPE 0}:S07_AXIS{FIFO_TYPE 0}}\
   CONFIG.NAME_MI_AXI {} \
   CONFIG.NAME_MI_AXIS {M00_AXIS,M01_AXIS,M02_AXIS,M03_AXIS,M04_AXIS,M05_AXIS,M06_AXIS,M07_AXIS,} \
   CONFIG.NAME_SI_AXI {S00_AXI,S01_AXI,} \
   CONFIG.NAME_SI_AXIS {S00_AXIS,S01_AXIS,S02_AXIS,S03_AXIS,S04_AXIS,S05_AXIS,S06_AXIS,S07_AXIS,} \
   CONFIG.NUM_CLKS {1} \
   CONFIG.NUM_MI_AXI {0} \
   CONFIG.NUM_MI_AXIS {8} \
   CONFIG.NUM_SI_AXI {2} \
   CONFIG.NUM_SI_AXIS {8} \
 ] $ai_engine_0

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins /versal_fabric/ai_engine_0/M00_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins /versal_fabric/ai_engine_0/M01_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins /versal_fabric/ai_engine_0/M02_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins /versal_fabric/ai_engine_0/M03_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins /versal_fabric/ai_engine_0/M04_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins /versal_fabric/ai_engine_0/M05_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins /versal_fabric/ai_engine_0/M06_AXIS]

  set_property -dict [ list \
   CONFIG.TDATA_NUM_BYTES {8} \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins /versal_fabric/ai_engine_0/M07_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {NOC} \
 ] [get_bd_intf_pins /versal_fabric/ai_engine_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins /versal_fabric/ai_engine_0/S00_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {NOC} \
 ] [get_bd_intf_pins /versal_fabric/ai_engine_0/S01_AXI]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins /versal_fabric/ai_engine_0/S01_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins /versal_fabric/ai_engine_0/S02_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins /versal_fabric/ai_engine_0/S03_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins /versal_fabric/ai_engine_0/S04_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins /versal_fabric/ai_engine_0/S05_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins /versal_fabric/ai_engine_0/S06_AXIS]

  set_property -dict [ list \
   CONFIG.CATEGORY {PL} \
 ] [get_bd_intf_pins /versal_fabric/ai_engine_0/S07_AXIS]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXIS:M01_AXIS:M02_AXIS:M03_AXIS:M04_AXIS:M05_AXIS:M06_AXIS:M07_AXIS:S00_AXIS:S01_AXIS:S02_AXIS:S03_AXIS:S04_AXIS:S05_AXIS:S06_AXIS:S07_AXIS} \
 ] [get_bd_pins /versal_fabric/ai_engine_0/aclk0]

  # Create instance: cips_noc, and set properties
  set cips_noc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.0 cips_noc ]
  set_property -dict [ list \
   CONFIG.HBM_DENSITY_PER_CHNL {1GB} \
   CONFIG.LOGO_FILE {data/noc.png} \
   CONFIG.MC_CHAN_REGION0 {DDR_CH1} \
   CONFIG.MC_NETLIST_SIMULATION {true} \
   CONFIG.MC_READ_BANDWIDTH {6400.0} \
   CONFIG.MC_WRITE_BANDWIDTH {6400.0} \
   CONFIG.MC_XPLL_CLKOUT1_PHASE {238.176} \
   CONFIG.NUM_CLKS {10} \
   CONFIG.NUM_MC {0} \
   CONFIG.NUM_MCP {0} \
   CONFIG.NUM_MI {1} \
   CONFIG.NUM_NMI {2} \
   CONFIG.NUM_NSI {0} \
   CONFIG.NUM_SI {9} \
 ] $cips_noc

  set_property SELECTED_SIM_MODEL tlm  $cips_noc

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.REGION {768} \
   CONFIG.CATEGORY {aie} \
 ] [get_bd_intf_pins /versal_fabric/cips_noc/M00_AXI]

  set_property -dict [ list \
   CONFIG.APERTURES {{0x201_4000_0000 1G}} \
 ] [get_bd_intf_pins /versal_fabric/cips_noc/M00_INI]

  set_property -dict [ list \
   CONFIG.APERTURES {{0x201_8000_0000 1G}} \
 ] [get_bd_intf_pins /versal_fabric/cips_noc/M01_INI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS { M01_INI { read_bw {128} write_bw {128}} M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M00_INI { read_bw {128} write_bw {128}} } \
   CONFIG.DEST_IDS {M00_AXI:0x80} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /versal_fabric/cips_noc/S00_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS { M01_INI { read_bw {128} write_bw {128}} M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M00_INI { read_bw {128} write_bw {128}} } \
   CONFIG.DEST_IDS {M00_AXI:0x80} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /versal_fabric/cips_noc/S01_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS { M01_INI { read_bw {128} write_bw {128}} M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M00_INI { read_bw {128} write_bw {128}} } \
   CONFIG.DEST_IDS {M00_AXI:0x80} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /versal_fabric/cips_noc/S02_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS { M01_INI { read_bw {128} write_bw {128}} M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M00_INI { read_bw {128} write_bw {128}} } \
   CONFIG.DEST_IDS {M00_AXI:0x80} \
   CONFIG.CATEGORY {ps_cci} \
 ] [get_bd_intf_pins /versal_fabric/cips_noc/S03_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS { M01_INI { read_bw {128} write_bw {128}} M00_INI { read_bw {128} write_bw {128}} } \
   CONFIG.DEST_IDS {} \
   CONFIG.CATEGORY {ps_nci} \
 ] [get_bd_intf_pins /versal_fabric/cips_noc/S04_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS { M01_INI { read_bw {128} write_bw {128}} M00_INI { read_bw {128} write_bw {128}} } \
   CONFIG.DEST_IDS {} \
   CONFIG.CATEGORY {ps_nci} \
 ] [get_bd_intf_pins /versal_fabric/cips_noc/S05_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS { M01_INI { read_bw {128} write_bw {128}} M00_INI { read_bw {128} write_bw {128}} } \
   CONFIG.DEST_IDS {} \
   CONFIG.CATEGORY {ps_rpu} \
 ] [get_bd_intf_pins /versal_fabric/cips_noc/S06_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {128} \
   CONFIG.CONNECTIONS { M01_INI { read_bw {128} write_bw {128}} M00_AXI { read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} M00_INI { read_bw {128} write_bw {128}} } \
   CONFIG.DEST_IDS {M00_AXI:0x80} \
   CONFIG.CATEGORY {ps_pmc} \
 ] [get_bd_intf_pins /versal_fabric/cips_noc/S07_AXI]

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {64} \
   CONFIG.CONNECTIONS {M01_INI { read_bw {1720} write_bw {1720}} M00_INI { read_bw {1720} write_bw {1720}} } \
   CONFIG.DEST_IDS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /versal_fabric/cips_noc/S08_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
 ] [get_bd_pins /versal_fabric/cips_noc/aclk0]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S01_AXI} \
 ] [get_bd_pins /versal_fabric/cips_noc/aclk1]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S02_AXI} \
 ] [get_bd_pins /versal_fabric/cips_noc/aclk2]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S03_AXI} \
 ] [get_bd_pins /versal_fabric/cips_noc/aclk3]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S04_AXI} \
 ] [get_bd_pins /versal_fabric/cips_noc/aclk4]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S05_AXI} \
 ] [get_bd_pins /versal_fabric/cips_noc/aclk5]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S06_AXI} \
 ] [get_bd_pins /versal_fabric/cips_noc/aclk6]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S07_AXI} \
 ] [get_bd_pins /versal_fabric/cips_noc/aclk7]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI} \
 ] [get_bd_pins /versal_fabric/cips_noc/aclk8]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S08_AXI} \
 ] [get_bd_pins /versal_fabric/cips_noc/aclk9]

  # Create instance: clk_wiz, and set properties
  set clk_wiz [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard:1.0 clk_wiz ]
  set_property -dict [ list \
   CONFIG.CLKFBOUT_MULT {36.000000} \
   CONFIG.CLKOUT1_DIVIDE {16.000000} \
   CONFIG.CLKOUT2_DIVIDE {12.000000} \
   CONFIG.CLKOUT3_DIVIDE {24.000000} \
   CONFIG.CLKOUT4_DIVIDE {6.000000} \
   CONFIG.CLKOUT5_DIVIDE {12} \
   CONFIG.CLKOUT6_DIVIDE {12} \
   CONFIG.CLKOUT7_DIVIDE {12} \
   CONFIG.CLKOUT_DRIVES {BUFG,BUFG,BUFG,BUFG,BUFG,BUFG,BUFG} \
   CONFIG.CLKOUT_DYN_PS {None,None,None,None,None,None,None} \
   CONFIG.CLKOUT_GROUPING {Auto,Auto,Auto,Auto,Auto,Auto,Auto} \
   CONFIG.CLKOUT_MATCHED_ROUTING {false,false,false,false,false,false,false} \
   CONFIG.CLKOUT_PORT {clk_out1,clk_out2,clk_out3,clk_out4,clk_out5,clk_out6,clk_out7} \
   CONFIG.CLKOUT_REQUESTED_DUTY_CYCLE {50.000,50.000,50.000,50.000,50.000,50.000,50.000} \
   CONFIG.CLKOUT_REQUESTED_OUT_FREQUENCY {150.000,200,100,400,200,400,600} \
   CONFIG.CLKOUT_REQUESTED_PHASE {0.000,0.000,0.000,0.000,0.000,0.000,0.000} \
   CONFIG.CLKOUT_USED {true,true,true,true,false,false,false} \
   CONFIG.DIVCLK_DIVIDE {3} \
   CONFIG.JITTER_SEL {Min_O_Jitter} \
   CONFIG.RESET_TYPE {ACTIVE_LOW} \
   CONFIG.USE_LOCKED {true} \
   CONFIG.USE_PHASE_ALIGNMENT {true} \
   CONFIG.USE_RESET {true} \
 ] $clk_wiz

  # Create instance: common_interface_0, and set properties
  set common_interface_0 [ create_bd_cell -type ip -vlnv vsi.com:ip:common_interface:2.0 common_interface_0 ]
  set_property -dict [ list \
   CONFIG.DMA_SIZE_BYTE {8} \
 ] $common_interface_0

  # Create instance: noc_lpddr4, and set properties
  set noc_lpddr4 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.0 noc_lpddr4 ]
  set_property -dict [ list \
   CONFIG.CH0_LPDDR4_0_BOARD_INTERFACE {ch0_lpddr4_c0} \
   CONFIG.CH0_LPDDR4_1_BOARD_INTERFACE {ch0_lpddr4_c1} \
   CONFIG.CH1_LPDDR4_0_BOARD_INTERFACE {ch1_lpddr4_c0} \
   CONFIG.CH1_LPDDR4_1_BOARD_INTERFACE {ch1_lpddr4_c1} \
   CONFIG.CONTROLLERTYPE {LPDDR4_SDRAM} \
   CONFIG.HBM_DENSITY_PER_CHNL {1GB} \
   CONFIG.LOGO_FILE {data/noc_mc.png} \
   CONFIG.MC0_CONFIG_NUM {config26} \
   CONFIG.MC0_FLIPPED_PINOUT {true} \
   CONFIG.MC1_CONFIG_NUM {config26} \
   CONFIG.MC1_FLIPPED_PINOUT {true} \
   CONFIG.MC2_CONFIG_NUM {config26} \
   CONFIG.MC3_CONFIG_NUM {config26} \
   CONFIG.MC_ADDR_BIT2 {CA0} \
   CONFIG.MC_ADDR_BIT3 {CA1} \
   CONFIG.MC_ADDR_BIT4 {CA2} \
   CONFIG.MC_ADDR_BIT5 {CA3} \
   CONFIG.MC_ADDR_BIT6 {CA4} \
   CONFIG.MC_ADDR_BIT7 {NC} \
   CONFIG.MC_ADDR_BIT8 {CA5} \
   CONFIG.MC_ADDR_BIT9 {CA6} \
   CONFIG.MC_ADDR_BIT10 {CA7} \
   CONFIG.MC_ADDR_BIT11 {CA8} \
   CONFIG.MC_ADDR_BIT12 {CA9} \
   CONFIG.MC_ADDR_BIT13 {BA0} \
   CONFIG.MC_ADDR_BIT14 {BA1} \
   CONFIG.MC_ADDR_BIT15 {BA2} \
   CONFIG.MC_ADDR_BIT16 {RA0} \
   CONFIG.MC_ADDR_BIT17 {RA1} \
   CONFIG.MC_ADDR_BIT18 {RA2} \
   CONFIG.MC_ADDR_BIT19 {RA3} \
   CONFIG.MC_ADDR_BIT20 {RA4} \
   CONFIG.MC_ADDR_BIT21 {RA5} \
   CONFIG.MC_ADDR_BIT22 {RA6} \
   CONFIG.MC_ADDR_BIT23 {RA7} \
   CONFIG.MC_ADDR_BIT24 {RA8} \
   CONFIG.MC_ADDR_BIT25 {RA9} \
   CONFIG.MC_ADDR_BIT26 {RA10} \
   CONFIG.MC_ADDR_BIT27 {RA11} \
   CONFIG.MC_ADDR_BIT28 {RA12} \
   CONFIG.MC_ADDR_BIT29 {RA13} \
   CONFIG.MC_ADDR_BIT30 {RA14} \
   CONFIG.MC_ADDR_BIT31 {RA15} \
   CONFIG.MC_ADDR_BIT32 {CH_SEL} \
   CONFIG.MC_ADDR_WIDTH {6} \
   CONFIG.MC_BA_WIDTH {3} \
   CONFIG.MC_BG_WIDTH {0} \
   CONFIG.MC_BOARD_INTRF_EN {true} \
   CONFIG.MC_BURST_LENGTH {16} \
   CONFIG.MC_CASLATENCY {36} \
   CONFIG.MC_CASWRITELATENCY {18} \
   CONFIG.MC_CH0_LP4_CHA_ENABLE {true} \
   CONFIG.MC_CH0_LP4_CHB_ENABLE {true} \
   CONFIG.MC_CH1_LP4_CHA_ENABLE {true} \
   CONFIG.MC_CH1_LP4_CHB_ENABLE {true} \
   CONFIG.MC_CHAN_REGION0 {DDR_CH1} \
   CONFIG.MC_CKE_WIDTH {0} \
   CONFIG.MC_CK_WIDTH {0} \
   CONFIG.MC_COMPONENT_DENSITY {16Gb} \
   CONFIG.MC_COMPONENT_WIDTH {x32} \
   CONFIG.MC_CONFIG_NUM {config26} \
   CONFIG.MC_DATAWIDTH {32} \
   CONFIG.MC_DDR4_2T {Enable} \
   CONFIG.MC_DDR_INIT_TIMEOUT {0x00036330} \
   CONFIG.MC_DM_WIDTH {4} \
   CONFIG.MC_DQS_WIDTH {4} \
   CONFIG.MC_DQ_WIDTH {32} \
   CONFIG.MC_ECC {false} \
   CONFIG.MC_ECC_SCRUB_PERIOD {0x004C4C} \
   CONFIG.MC_ECC_SCRUB_SIZE {4096} \
   CONFIG.MC_EN_BACKGROUND_SCRUBBING {true} \
   CONFIG.MC_EN_ECC_SCRUBBING {false} \
   CONFIG.MC_F1_CASLATENCY {36} \
   CONFIG.MC_F1_CASWRITELATENCY {18} \
   CONFIG.MC_F1_LPDDR4_MR1 {0x0000} \
   CONFIG.MC_F1_LPDDR4_MR2 {0x0000} \
   CONFIG.MC_F1_LPDDR4_MR3 {0x0000} \
   CONFIG.MC_F1_LPDDR4_MR11 {0x0000} \
   CONFIG.MC_F1_LPDDR4_MR13 {0x00C0} \
   CONFIG.MC_F1_LPDDR4_MR22 {0x0000} \
   CONFIG.MC_F1_TCCD_L {0} \
   CONFIG.MC_F1_TCCD_L_MIN {0} \
   CONFIG.MC_F1_TFAW {30000} \
   CONFIG.MC_F1_TFAWMIN {30000} \
   CONFIG.MC_F1_TMOD {0} \
   CONFIG.MC_F1_TMOD_MIN {0} \
   CONFIG.MC_F1_TMRD {14000} \
   CONFIG.MC_F1_TMRDMIN {14000} \
   CONFIG.MC_F1_TMRW {10000} \
   CONFIG.MC_F1_TMRWMIN {10000} \
   CONFIG.MC_F1_TRAS {42000} \
   CONFIG.MC_F1_TRASMIN {42000} \
   CONFIG.MC_F1_TRCD {18000} \
   CONFIG.MC_F1_TRCDMIN {18000} \
   CONFIG.MC_F1_TRPAB {21000} \
   CONFIG.MC_F1_TRPABMIN {21000} \
   CONFIG.MC_F1_TRPPB {18000} \
   CONFIG.MC_F1_TRPPBMIN {18000} \
   CONFIG.MC_F1_TRRD {7500} \
   CONFIG.MC_F1_TRRDMIN {7500} \
   CONFIG.MC_F1_TRRD_L {0} \
   CONFIG.MC_F1_TRRD_L_MIN {0} \
   CONFIG.MC_F1_TRRD_S {0} \
   CONFIG.MC_F1_TRRD_S_MIN {0} \
   CONFIG.MC_F1_TWR {18000} \
   CONFIG.MC_F1_TWRMIN {18000} \
   CONFIG.MC_F1_TWTR {10000} \
   CONFIG.MC_F1_TWTRMIN {10000} \
   CONFIG.MC_F1_TWTR_L {0} \
   CONFIG.MC_F1_TWTR_L_MIN {0} \
   CONFIG.MC_F1_TWTR_S {0} \
   CONFIG.MC_F1_TWTR_S_MIN {0} \
   CONFIG.MC_F1_TZQLAT {30000} \
   CONFIG.MC_F1_TZQLATMIN {30000} \
   CONFIG.MC_INIT_MEM_USING_ECC_SCRUB {false} \
   CONFIG.MC_INPUTCLK0_PERIOD {4992} \
   CONFIG.MC_INPUT_FREQUENCY0 {200.321} \
   CONFIG.MC_IP_TIMEPERIOD0_FOR_OP {1071} \
   CONFIG.MC_IP_TIMEPERIOD1 {512} \
   CONFIG.MC_LP4_CA_A_WIDTH {6} \
   CONFIG.MC_LP4_CA_B_WIDTH {6} \
   CONFIG.MC_LP4_CKE_A_WIDTH {1} \
   CONFIG.MC_LP4_CKE_B_WIDTH {1} \
   CONFIG.MC_LP4_CKT_A_WIDTH {1} \
   CONFIG.MC_LP4_CKT_B_WIDTH {1} \
   CONFIG.MC_LP4_CS_A_WIDTH {1} \
   CONFIG.MC_LP4_CS_B_WIDTH {1} \
   CONFIG.MC_LP4_DMI_A_WIDTH {2} \
   CONFIG.MC_LP4_DMI_B_WIDTH {2} \
   CONFIG.MC_LP4_DQS_A_WIDTH {2} \
   CONFIG.MC_LP4_DQS_B_WIDTH {2} \
   CONFIG.MC_LP4_DQ_A_WIDTH {16} \
   CONFIG.MC_LP4_DQ_B_WIDTH {16} \
   CONFIG.MC_LP4_RESETN_WIDTH {1} \
   CONFIG.MC_MEMORY_DENSITY {2GB} \
   CONFIG.MC_MEMORY_DEVICETYPE {Components} \
   CONFIG.MC_MEMORY_DEVICE_DENSITY {16Gb} \
   CONFIG.MC_MEMORY_SPEEDGRADE {LPDDR4-4267} \
   CONFIG.MC_MEMORY_TIMEPERIOD0 {512} \
   CONFIG.MC_MEMORY_TIMEPERIOD1 {512} \
   CONFIG.MC_MEM_DEVICE_WIDTH {x32} \
   CONFIG.MC_NETLIST_SIMULATION {true} \
   CONFIG.MC_NO_CHANNELS {Dual} \
   CONFIG.MC_ODTLon {8} \
   CONFIG.MC_ODT_WIDTH {0} \
   CONFIG.MC_PER_RD_INTVL {0} \
   CONFIG.MC_PRE_DEF_ADDR_MAP_SEL {ROW_BANK_COLUMN} \
   CONFIG.MC_READ_BANDWIDTH {7812.5} \
   CONFIG.MC_REFRESH_SPEED {1x} \
   CONFIG.MC_TCCD {8} \
   CONFIG.MC_TCCD_L {0} \
   CONFIG.MC_TCCD_L_MIN {0} \
   CONFIG.MC_TCKE {15} \
   CONFIG.MC_TCKEMIN {15} \
   CONFIG.MC_TDQS2DQ_MAX {800} \
   CONFIG.MC_TDQS2DQ_MIN {200} \
   CONFIG.MC_TDQSCK_MAX {3500} \
   CONFIG.MC_TFAW {30000} \
   CONFIG.MC_TFAWMIN {30000} \
   CONFIG.MC_TFAW_nCK {0} \
   CONFIG.MC_TMOD {0} \
   CONFIG.MC_TMOD_MIN {0} \
   CONFIG.MC_TMPRR {0} \
   CONFIG.MC_TMRD {14000} \
   CONFIG.MC_TMRDMIN {14000} \
   CONFIG.MC_TMRD_div4 {10} \
   CONFIG.MC_TMRD_nCK {28} \
   CONFIG.MC_TMRW {10000} \
   CONFIG.MC_TMRWMIN {10000} \
   CONFIG.MC_TMRW_div4 {10} \
   CONFIG.MC_TMRW_nCK {20} \
   CONFIG.MC_TODTon_MIN {3} \
   CONFIG.MC_TOSCO {40000} \
   CONFIG.MC_TOSCOMIN {40000} \
   CONFIG.MC_TOSCO_nCK {79} \
   CONFIG.MC_TPAR_ALERT_ON {0} \
   CONFIG.MC_TPAR_ALERT_PW_MAX {0} \
   CONFIG.MC_TPBR2PBR {90000} \
   CONFIG.MC_TPBR2PBRMIN {90000} \
   CONFIG.MC_TRAS {42000} \
   CONFIG.MC_TRASMIN {42000} \
   CONFIG.MC_TRAS_nCK {83} \
   CONFIG.MC_TRC {63000} \
   CONFIG.MC_TRCD {18000} \
   CONFIG.MC_TRCDMIN {18000} \
   CONFIG.MC_TRCD_nCK {36} \
   CONFIG.MC_TRCMIN {0} \
   CONFIG.MC_TREFI {3904000} \
   CONFIG.MC_TREFIPB {488000} \
   CONFIG.MC_TRFC {0} \
   CONFIG.MC_TRFCAB {280000} \
   CONFIG.MC_TRFCABMIN {280000} \
   CONFIG.MC_TRFCMIN {0} \
   CONFIG.MC_TRFCPB {140000} \
   CONFIG.MC_TRFCPBMIN {140000} \
   CONFIG.MC_TRP {0} \
   CONFIG.MC_TRPAB {21000} \
   CONFIG.MC_TRPABMIN {21000} \
   CONFIG.MC_TRPAB_nCK {42} \
   CONFIG.MC_TRPMIN {0} \
   CONFIG.MC_TRPPB {18000} \
   CONFIG.MC_TRPPBMIN {18000} \
   CONFIG.MC_TRPPB_nCK {36} \
   CONFIG.MC_TRPRE {1.8} \
   CONFIG.MC_TRRD {7500} \
   CONFIG.MC_TRRDMIN {7500} \
   CONFIG.MC_TRRD_L {0} \
   CONFIG.MC_TRRD_L_MIN {0} \
   CONFIG.MC_TRRD_S {0} \
   CONFIG.MC_TRRD_S_MIN {0} \
   CONFIG.MC_TRRD_nCK {15} \
   CONFIG.MC_TRTP_nCK {16} \
   CONFIG.MC_TWPRE {1.8} \
   CONFIG.MC_TWPST {0.4} \
   CONFIG.MC_TWR {18000} \
   CONFIG.MC_TWRMIN {18000} \
   CONFIG.MC_TWR_nCK {36} \
   CONFIG.MC_TWTR {10000} \
   CONFIG.MC_TWTRMIN {10000} \
   CONFIG.MC_TWTR_L {0} \
   CONFIG.MC_TWTR_S {0} \
   CONFIG.MC_TWTR_S_MIN {0} \
   CONFIG.MC_TWTR_nCK {20} \
   CONFIG.MC_TXP {15} \
   CONFIG.MC_TXPMIN {15} \
   CONFIG.MC_TXPR {0} \
   CONFIG.MC_TZQCAL {1000000} \
   CONFIG.MC_TZQCAL_div4 {489} \
   CONFIG.MC_TZQCS_ITVL {0} \
   CONFIG.MC_TZQLAT {30000} \
   CONFIG.MC_TZQLATMIN {30000} \
   CONFIG.MC_TZQLAT_div4 {15} \
   CONFIG.MC_TZQLAT_nCK {59} \
   CONFIG.MC_TZQ_START_ITVL {1000000000} \
   CONFIG.MC_USER_DEFINED_ADDRESS_MAP {16RA-3BA-10CA} \
   CONFIG.MC_WRITE_BANDWIDTH {7812.5} \
   CONFIG.MC_XPLL_CLKOUT1_PERIOD {1024} \
   CONFIG.MC_XPLL_CLKOUT1_PHASE {211.2890625} \
   CONFIG.NUM_CLKS {1} \
   CONFIG.NUM_MC {2} \
   CONFIG.NUM_MCP {2} \
   CONFIG.NUM_MI {0} \
   CONFIG.NUM_NSI {1} \
   CONFIG.NUM_SI {1} \
   CONFIG.sys_clk0_BOARD_INTERFACE {lpddr4_sma_clk1} \
   CONFIG.sys_clk1_BOARD_INTERFACE {lpddr4_sma_clk2} \
 ] $noc_lpddr4

  set_property SELECTED_SIM_MODEL tlm  $noc_lpddr4

  set_property -dict [ list \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.CONNECTIONS {MC_1 { read_bw {1720} write_bw {1720} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /versal_fabric/noc_lpddr4/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 { read_bw {1720} write_bw {1720} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /versal_fabric/noc_lpddr4/S00_INI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
 ] [get_bd_pins /versal_fabric/noc_lpddr4/aclk0]

  # Create instance: psr_100mhz, and set properties
  set psr_100mhz [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 psr_100mhz ]

  # Create instance: psr_200mhz, and set properties
  set psr_200mhz [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 psr_200mhz ]

  # Create instance: psr_300mhz, and set properties
  set psr_300mhz [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 psr_300mhz ]

  # Create instance: psr_400mhz, and set properties
  set psr_400mhz [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 psr_400mhz ]

  set board_part [get_property BOARD_PART [current_project]]
  set fpga_part [get_property PART [current_project]]

  # Create instance: vsi_context_versal_fabric, and set properties
  set vsi_context_versal_fabric [ create_bd_cell -type ip -vlnv vsi.com:platform:vsi_context:1.0 vsi_context_versal_fabric ]
  set_property -dict [ list \
   CONFIG.LOGO_FILE {data/vsi_context_hardware.png} \
   CONFIG.fpga_board $board_part \
   CONFIG.fpga_family {versalaicore} \
   CONFIG.fpga_part $fpga_part \
   CONFIG.is_main {false} \
   CONFIG.impl_strategy {performance} \
   CONFIG.is_system_gui {false} \
   CONFIG.type {2} \
 ] $vsi_context_versal_fabric

  # Create interface connections
  connect_bd_intf_net -intf_net CIPS_0_FPD_AXI_NOC_0 [get_bd_intf_pins CIPS_0/FPD_AXI_NOC_0] [get_bd_intf_pins cips_noc/S04_AXI]
  connect_bd_intf_net -intf_net CIPS_0_FPD_AXI_NOC_1 [get_bd_intf_pins CIPS_0/FPD_AXI_NOC_1] [get_bd_intf_pins cips_noc/S05_AXI]
  connect_bd_intf_net -intf_net CIPS_0_FPD_CCI_NOC_0 [get_bd_intf_pins CIPS_0/FPD_CCI_NOC_0] [get_bd_intf_pins cips_noc/S00_AXI]
  connect_bd_intf_net -intf_net CIPS_0_FPD_CCI_NOC_1 [get_bd_intf_pins CIPS_0/FPD_CCI_NOC_1] [get_bd_intf_pins cips_noc/S01_AXI]
  connect_bd_intf_net -intf_net CIPS_0_FPD_CCI_NOC_2 [get_bd_intf_pins CIPS_0/FPD_CCI_NOC_2] [get_bd_intf_pins cips_noc/S02_AXI]
  connect_bd_intf_net -intf_net CIPS_0_FPD_CCI_NOC_3 [get_bd_intf_pins CIPS_0/FPD_CCI_NOC_3] [get_bd_intf_pins cips_noc/S03_AXI]
  connect_bd_intf_net -intf_net CIPS_0_M_AXI_LPD [get_bd_intf_pins CIPS_0/M_AXI_LPD] [get_bd_intf_pins common_interface_0/S_AXI_1]
  connect_bd_intf_net -intf_net CIPS_0_NOC_LPD_AXI_0 [get_bd_intf_pins CIPS_0/LPD_AXI_NOC_0] [get_bd_intf_pins cips_noc/S06_AXI]
  connect_bd_intf_net -intf_net CIPS_0_PMC_NOC_AXI_0 [get_bd_intf_pins CIPS_0/PMC_NOC_AXI_0] [get_bd_intf_pins cips_noc/S07_AXI]
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins S01_AXI] [get_bd_intf_pins ai_engine_0/S01_AXI]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins ddr4_dimm1_sma_clk] [get_bd_intf_pins NOC_1/sys_clk0]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins PLAT_INTERFACE] [get_bd_intf_pins common_interface_0/PLAT_INTERFACE]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins ddr4_dimm1] [get_bd_intf_pins NOC_1/CH0_DDR4_0]
  connect_bd_intf_net -intf_net Conn5 [get_bd_intf_pins lpddr4_sma_clk2] [get_bd_intf_pins noc_lpddr4/sys_clk1]
  connect_bd_intf_net -intf_net Conn6 [get_bd_intf_pins lpddr4_sma_clk1] [get_bd_intf_pins noc_lpddr4/sys_clk0]
  connect_bd_intf_net -intf_net Conn15 [get_bd_intf_pins ch1_lpddr4_c1] [get_bd_intf_pins noc_lpddr4/CH1_LPDDR4_1]
  connect_bd_intf_net -intf_net Conn16 [get_bd_intf_pins ch1_lpddr4_c0] [get_bd_intf_pins noc_lpddr4/CH1_LPDDR4_0]
  connect_bd_intf_net -intf_net Conn17 [get_bd_intf_pins ch0_lpddr4_c1] [get_bd_intf_pins noc_lpddr4/CH0_LPDDR4_1]
  connect_bd_intf_net -intf_net Conn18 [get_bd_intf_pins ch0_lpddr4_c0] [get_bd_intf_pins noc_lpddr4/CH0_LPDDR4_0]
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins noc_lpddr4/S00_AXI]
  connect_bd_intf_net -intf_net cips_noc_M00_AXI [get_bd_intf_pins ai_engine_0/S00_AXI] [get_bd_intf_pins cips_noc/M00_AXI]
  connect_bd_intf_net -intf_net cips_noc_M00_INI [get_bd_intf_pins NOC_1/S00_INI] [get_bd_intf_pins cips_noc/M00_INI]
  connect_bd_intf_net -intf_net cips_noc_M01_INI [get_bd_intf_pins cips_noc/M01_INI] [get_bd_intf_pins noc_lpddr4/S00_INI]
  connect_bd_intf_net -intf_net common_interface_0_DMA_1 [get_bd_intf_pins cips_noc/S08_AXI] [get_bd_intf_pins common_interface_0/DMA_1]

  # Create port connections
  connect_bd_net -net CIPS_0_fpd_axi_noc_axi0_clk [get_bd_pins CIPS_0/fpd_axi_noc_axi0_clk] [get_bd_pins cips_noc/aclk4]
  connect_bd_net -net CIPS_0_fpd_axi_noc_axi1_clk [get_bd_pins CIPS_0/fpd_axi_noc_axi1_clk] [get_bd_pins cips_noc/aclk5]
  connect_bd_net -net CIPS_0_fpd_cci_noc_axi0_clk [get_bd_pins CIPS_0/fpd_cci_noc_axi0_clk] [get_bd_pins cips_noc/aclk0]
  connect_bd_net -net CIPS_0_fpd_cci_noc_axi1_clk [get_bd_pins CIPS_0/fpd_cci_noc_axi1_clk] [get_bd_pins cips_noc/aclk1]
  connect_bd_net -net CIPS_0_fpd_cci_noc_axi2_clk [get_bd_pins CIPS_0/fpd_cci_noc_axi2_clk] [get_bd_pins cips_noc/aclk2]
  connect_bd_net -net CIPS_0_fpd_cci_noc_axi3_clk [get_bd_pins CIPS_0/fpd_cci_noc_axi3_clk] [get_bd_pins cips_noc/aclk3]
  connect_bd_net -net CIPS_0_lpd_axi_noc_clk [get_bd_pins CIPS_0/lpd_axi_noc_clk] [get_bd_pins cips_noc/aclk6]
  connect_bd_net -net CIPS_0_pl0_ref_clk [get_bd_pins CIPS_0/pl0_ref_clk] [get_bd_pins clk_wiz/clk_in1]
  connect_bd_net -net CIPS_0_pmc_axi_noc_axi0_clk [get_bd_pins CIPS_0/pmc_axi_noc_axi0_clk] [get_bd_pins cips_noc/aclk7]
  connect_bd_net -net ai_engine_0_s00_axi_aclk [get_bd_pins ai_engine_0/s00_axi_aclk] [get_bd_pins cips_noc/aclk8]
  connect_bd_net -net clk_wiz_clk_out2 [get_bd_pins clk_out2] [get_bd_pins clk_wiz/clk_out2] [get_bd_pins psr_200mhz/slowest_sync_clk]
  connect_bd_net -net clk_wiz_clk_out4 [get_bd_pins clk_out4] [get_bd_pins clk_wiz/clk_out4] [get_bd_pins psr_400mhz/slowest_sync_clk]
  connect_bd_net -net clk_wizard_0_clk_out3 [get_bd_pins clk_out1] [get_bd_pins CIPS_0/m_axi_lpd_aclk] [get_bd_pins ai_engine_0/aclk0] [get_bd_pins cips_noc/aclk9] [get_bd_pins clk_wiz/clk_out1] [get_bd_pins common_interface_0/DMA_ACLK] [get_bd_pins common_interface_0/M_AXI_1_ACLK] [get_bd_pins noc_lpddr4/aclk0] [get_bd_pins psr_300mhz/slowest_sync_clk]
  connect_bd_net -net clk_wizard_0_locked [get_bd_pins clk_wiz/locked] [get_bd_pins psr_100mhz/dcm_locked] [get_bd_pins psr_300mhz/dcm_locked]
  connect_bd_net -net common_interface_0_irq_o [get_bd_pins CIPS_0/pl_ps_irq1] [get_bd_pins common_interface_0/irq_o]
  connect_bd_net -net psr_200mhz_peripheral_aresetn [get_bd_pins peripheral_aresetn_0] [get_bd_pins psr_200mhz/peripheral_aresetn]
  connect_bd_net -net psr_300mhz_peripheral_aresetn [get_bd_pins peripheral_aresetn] [get_bd_pins common_interface_0/DMA_ARESETN] [get_bd_pins common_interface_0/M_AXI_1_ARESETN] [get_bd_pins psr_300mhz/peripheral_aresetn]
  connect_bd_net -net psr_400mhz_peripheral_aresetn [get_bd_pins peripheral_aresetn_1] [get_bd_pins psr_400mhz/peripheral_aresetn]
  connect_bd_net -net resetn_1 [get_bd_pins CIPS_0/pl0_resetn] [get_bd_pins clk_wiz/resetn] [get_bd_pins psr_100mhz/ext_reset_in] [get_bd_pins psr_200mhz/ext_reset_in] [get_bd_pins psr_300mhz/ext_reset_in] [get_bd_pins psr_400mhz/ext_reset_in]
  connect_bd_net -net s_axi_aclk_1 [get_bd_pins clk_wiz/clk_out3] [get_bd_pins psr_100mhz/slowest_sync_clk]
  connect_bd_net -net s_axi_aresetn_1 [get_bd_pins peripheral_aresetn_2] [get_bd_pins psr_100mhz/peripheral_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: versal_aie
proc create_hier_cell_versal_aie { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_versal_aie() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI


  # Create pins

  # Create instance: vsi_common_driver_0, and set properties
  set vsi_common_driver_0 [ create_bd_cell -type ip -vlnv vsi.com:vsi_software_lib:vsi_common_driver:1.0 vsi_common_driver_0 ]

  # Create instance: vsi_context_versal_aie, and set properties
  set vsi_context_versal_aie [ create_bd_cell -type ip -vlnv vsi.com:platform:vsi_context:1.0 vsi_context_versal_aie ]
  set_property -dict [ list \
   CONFIG.LOGO_FILE {data/vsi_context_ai.png} \
   CONFIG.c_compiler_options {} \
   CONFIG.cc_compiler_options {} \
   CONFIG.cpu_type {5} \
   CONFIG.fpga_family {null} \
   CONFIG.is_main {false} \
   CONFIG.is_system_gui {false} \
   CONFIG.language {aicore} \
   CONFIG.type {1} \
 ] $vsi_context_versal_aie

  # Create interface connections
  connect_bd_intf_net -intf_net vsi_common_driver_0_M_AXI [get_bd_intf_pins M_AXI] [get_bd_intf_pins vsi_common_driver_0/M_AXI]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { design_name options } {

  variable script_folder
  # Add ip repository
  set_property ip_repo_paths "$::env(VSI_INSTALL)/common/ip_repo" [current_project]

  set project_board_part [get_property BOARD_PART [current_project]]
  set board_family [get_property FAMILY [get_property PART [current_project]]]
  if { $board_family != "versalaicore" && $board_family != "versalaicorees1" } {
    set board_part xilinx.com:vck190:*
    set board_part [lindex [get_board_parts \
      $board_part \
      -latest_file_version] 0 \
    ]
    puts "Warning: The selected board ($project_board_part) is not compatable with this example, the board is changed to $board_part"
    set_property board_part $board_part [current_project]
  } else {
    set board_part [get_property BOARD_PART [current_project]]
    set board_part [lindex [get_board_parts \
      $board_part \
      -latest_file_version] 0 \
    ]
    set_property board_part $board_part [current_project]
  }

  update_ip_catalog
  CheckIP
  create_bd_design -bdsource vsi_platform ${design_name}_platform -mode batch
  current_bd_design ${design_name}_platform


  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance /

  # Create interface ports
  set ch0_lpddr4_c0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch0_lpddr4_c0 ]

  set ch0_lpddr4_c1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch0_lpddr4_c1 ]

  set ch1_lpddr4_c0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch1_lpddr4_c0 ]

  set ch1_lpddr4_c1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:lpddr4_rtl:1.0 ch1_lpddr4_c1 ]

  set ddr4_dimm1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 ddr4_dimm1 ]

  set ddr4_dimm1_sma_clk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 ddr4_dimm1_sma_clk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $ddr4_dimm1_sma_clk

  set lpddr4_sma_clk1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 lpddr4_sma_clk1 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200321000} \
   ] $lpddr4_sma_clk1

  set lpddr4_sma_clk2 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 lpddr4_sma_clk2 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200321000} \
   ] $lpddr4_sma_clk2


  # Create ports

  # Create instance: versal_aie
  create_hier_cell_versal_aie [current_bd_instance .] versal_aie

  # Create instance: versal_fabric
  create_hier_cell_versal_fabric [current_bd_instance .] versal_fabric

  # Create instance: versal_ps
  create_hier_cell_versal_ps [current_bd_instance .] versal_ps

  # Create instance: versal_r5
  create_hier_cell_versal_r5 [current_bd_instance .] versal_r5

  # Create interface connections
  connect_bd_intf_net -intf_net ddr4_dimm1_sma_clk_1 [get_bd_intf_ports ddr4_dimm1_sma_clk] [get_bd_intf_pins versal_fabric/ddr4_dimm1_sma_clk]
  connect_bd_intf_net -intf_net lpddr4_sma_clk1_1 [get_bd_intf_ports lpddr4_sma_clk1] [get_bd_intf_pins versal_fabric/lpddr4_sma_clk1]
  connect_bd_intf_net -intf_net lpddr4_sma_clk2_1 [get_bd_intf_ports lpddr4_sma_clk2] [get_bd_intf_pins versal_fabric/lpddr4_sma_clk2]
  connect_bd_intf_net -intf_net versal_aie_M_AXI [get_bd_intf_pins versal_aie/M_AXI] [get_bd_intf_pins versal_fabric/S01_AXI]
  connect_bd_intf_net -intf_net versal_fabric_ch0_lpddr4_c0 [get_bd_intf_ports ch0_lpddr4_c0] [get_bd_intf_pins versal_fabric/ch0_lpddr4_c0]
  connect_bd_intf_net -intf_net versal_fabric_ch0_lpddr4_c1 [get_bd_intf_ports ch0_lpddr4_c1] [get_bd_intf_pins versal_fabric/ch0_lpddr4_c1]
  connect_bd_intf_net -intf_net versal_fabric_ch1_lpddr4_c0 [get_bd_intf_ports ch1_lpddr4_c0] [get_bd_intf_pins versal_fabric/ch1_lpddr4_c0]
  connect_bd_intf_net -intf_net versal_fabric_ch1_lpddr4_c1 [get_bd_intf_ports ch1_lpddr4_c1] [get_bd_intf_pins versal_fabric/ch1_lpddr4_c1]
  connect_bd_intf_net -intf_net versal_fabric_ddr4_dimm1 [get_bd_intf_ports ddr4_dimm1] [get_bd_intf_pins versal_fabric/ddr4_dimm1]
  connect_bd_intf_net -intf_net versal_ps_M_AXI [get_bd_intf_pins versal_ps/M_AXI] [get_bd_intf_pins versal_r5/S0_AXI]
  connect_bd_intf_net -intf_net versal_ps_PLATFORM [get_bd_intf_pins versal_fabric/PLAT_INTERFACE] [get_bd_intf_pins versal_ps/PLATFORM]

  # Create port connections

  # Create address segments
  assign_bd_address -offset 0x80001000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_fabric/CIPS_0/M_AXI_LPD] [get_bd_addr_segs versal_fabric/common_interface_0/cdma_cell1/axi_cdma_inst/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x80000000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_fabric/CIPS_0/M_AXI_LPD] [get_bd_addr_segs versal_fabric/common_interface_0/irq_cell/axi_intc/S_AXI/Reg] -force
  assign_bd_address -offset 0x8000A000 -range 0x00001000 -target_address_space [get_bd_addr_spaces versal_fabric/CIPS_0/M_AXI_LPD] [get_bd_addr_segs versal_fabric/common_interface_0/lod_controller/decoupler_ctr/s_axi/reg0] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()

set board_part xilinx.com:vck190:*
set board_part [lindex [get_board_parts \
    $board_part \
    -latest_file_version] 0 \
    ]

create_project versal_rdma build -part xcvc1902-vsva2197-2MP-e-S -force
set_property BOARD_PART $board_part [current_project]

set design_name "vck190_base"

create_root_design $design_name ""
puts "done"


common::send_msg_id "BD_TCL-1000" "WARNING" "This Tcl script was generated from a block design that has not been validated. It is possible that design <$design_name> may result in errors during validation."
