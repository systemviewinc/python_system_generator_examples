import os, sys
from vsi_system_generator import VsiSystemGenerator as vsg
def gen():
    current_dir = os.path.dirname(os.path.realpath(__file__))

    os.environ["YAML_SRC_DIR"] = "{}/../".format(current_dir)
    os.environ["DRIVER_SRC_DIR"] = "{}/../../src".format(current_dir)
    os.environ["HLS_SRC_DIR"] = "{}/../../hls_src".format(current_dir)
    os.environ["KERNEL_SRC_DIR"] = "{}/../../kernel_src".format(current_dir)

    platform = vsg.Platform("vck190_base_platform", "${YAML_SRC_DIR}/platform/vck190_base_platform.yaml")

    stream_mux_blk = vsg.KernelDef(yaml_file = "${YAML_SRC_DIR}/kernels/stream_mux_blk.yaml")

    rdma_db = vsg.Application("rdma_double_buffer", platform)


    #set aie_parameters true on multiple kernels at once
    stream_mux_blk.outp["fifo_size"] = 32640

    rdma_db.versal_fabric.add_kernels(stream_mux_blk*4)

    #======================================================
    fabric_ddr4 = vsg.MemoryInterface("fabric_ddr4",        # Name
                                  524288,               # Size 512GB
                                  512,                  # Bus Width Bit
                                  platform.versal_fabric.noc_lpddr4_S00_AXI, # platform interface
                                  platform.versal_fabric.clk_wiz_clk_out2) # platform clock

    #======================================================   
    my_var = vsg.ArrayDef(name = "my_var",
                              dimensions = [16, 8, 256], #
                              element_size = 4)

    rec_var = vsg.ArrayDef(name = "rec_var",
                              dimensions = [8, 16, 256], #
                              element_size = 4)

    load_data = vsg.ArrayDef(name = "load_data",
                              dimensions = [16, 8, 256], #
                              element_size = 4)
    #======================================================

    my_var = rdma_db.add_array(my_var, fabric_ddr4, 16384, double_buffer = True)
    rec_var = rdma_db.add_array(rec_var, fabric_ddr4, 32768, double_buffer = True)
    write_data = rdma_db.add_array(load_data, fabric_ddr4, 16384)
    read_data = rdma_db.add_array(load_data, fabric_ddr4, 32768)

    #======================================================

    #send ainput data
    my_var[range(0,16)][0:4][range(0,256)].connect(stream_mux_blk[:].in1)
    my_var[range(0,16)][4:8][range(0,256)].connect(stream_mux_blk[:].in2)

    rec_var.get(vsg.IntfL(0,4,1),vsg.InnerL(0,16),vsg.DataL(0,256)).connect(stream_mux_blk[0:4].outp)
    rec_var.get(vsg.IntfL(4,8,1),vsg.InnerL(0,16),vsg.DataL(0,256)).connect(stream_mux_blk[0:4].outp)

    write_data[range(0,16)][0:8][range(0,256)].connect(fabric_ddr4, {"write_file": "input.bin"})
    read_data[range(0,16)][0:8][range(0,256)].connect(fabric_ddr4, {"read_file": "output.bin"})

    #======================================================

    rdma_db.add_dataflow([write_data, my_var])
    rdma_db.add_dataflow([rec_var, read_data])
    rdma_db.add_memory(fabric_ddr4)


    rdma_db.process()
