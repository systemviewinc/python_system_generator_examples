import os, sys
from vsi_system_generator import VsiSystemGenerator as vsg
def gen():
    current_dir = os.path.dirname(os.path.realpath(__file__))

    os.environ["YAML_SRC_DIR"] = "{}/../".format(current_dir)
    os.environ["KERNEL_SRC_DIR"] = "{}/../../kernel_src".format(current_dir)

    platform = vsg.Platform("vck190_base_platform", "${YAML_SRC_DIR}/platform/vck190_base_platform.yaml")

    stream_mux_blk = vsg.KernelDef(yaml_file = "${YAML_SRC_DIR}/kernels/stream_mux_blk.yaml")

    rdma_system = vsg.Application("rdma_sys", platform)

    #set aie_parameters true on multiple kernels at once
    reduce[:]["aie_parameters"] = True
    reduce[:]["kernel_row"] = "(x+1)%7"
    reduce[:]["kernel_col"] = "x"

    rdma_system.versal_fabric.add_kernels(stream_mux_blk*4)

    #======================================================
    fabric_ddr4 = vsg.MemoryInterface("fabric_ddr4",        # Name
                                  524288,               # Size 512GB
                                  512,                  # Bus Width Bit
                                  platform.versal_fabric.noc_lpddr4_S00_AXI, # platform interface
                                  platform.versal_fabric.clk_wiz_clk_out2) # platform clock

    #======================================================
    my_var = vsg.ArrayDef(name = "my_var",
                              dimensions = [8, 1024], #
                              element_size = 4)

    rec_var = vsg.ArrayDef(name = "rec_var",
                              dimensions = [4, 1024], #
                              element_size = 4)

    load_data = vsg.ArrayDef(name = "load_data",
                              dimensions = [8, 1024], #
                              element_size = 4)
    #======================================================

    my_var = rdma_system.add_array(my_var, fabric_ddr4, 16384)
    rec_var = rdma_system.add_array(rec_var, fabric_ddr4, 32768)
    write_data = rdma_system.add_array(load_data, fabric_ddr4, 16384)
    read_data = rdma_system.add_array(load_data, fabric_ddr4, 32768)

    #======================================================

    #send ainput data
    my_var[0:4][range(0,1024)].connect(stream_mux_blk[:].instream0)
    my_var[4:8][range(0,1024)].connect(stream_mux_blk[:].instream1)


    rec_var[0:4][range(0,1024)].connect(stream_mux_blk[0:4].outstream)

    write_data[range(0,8)][range(0,1024)].connect(fabric_ddr4, {"write_file": "input.bin"})
    read_data[range(0,8)][range(0,1024)].connect(fabric_ddr4, {"read_file": "output.bin"})

    #======================================================

    rdma_system.add_dataflow([write_data, my_var, rec_var, read_data])

    rdma_system.add_memory(fabric_ddr4)

    rdma_system.process()
