Visual System Intergrator (VSI) System Generator is a easy to use python api that allows users to generate VSI projects in an easy to share and easy to modify format. To build your own system you will want to do the following steps:

1. Import VsiSystemGenerator and any other modules you may use

    ```python
        from vsi_system_generator import VsiSystemGenerator as vsg
    ```

1. Create a function called "def", we will fill the function with everything we want to do:

    ```python
        def gen():
    ```

2. (Optional) Setup any enviorment variables reference in yaml files, or in in the python file.

    ```python
        current_dir = os.path.dirname(os.path.realpath(__file__))
        os.environ["YAML_SRC_DIR"] = "{}/../".format(current_dir)
        os.environ["KERNEL_SRC_DIR"] = "{}/../../kernel_src".format(current_dir)
    ```
3. Create your Platform object using the Platform class constructor.

    ```python
         vck_platform = vsg.Platform("vck190_base_platform", "${YAML_SRC_DIR}/platform/vck190_base_platform.yaml")
    ```

    * The Platform object holds the contexts that the platform contains, they can be accessed with the . operation (e.g. versal_ps is one of the context of the platform):

    ```python
        vck_platform.versal_ps
    ```


   * Edit any platform setting as required.

    ```python
        vck_platform.versal_ps["c_compiler_options"] = "-std=c11"
    ```

   * The Platform Context's objects holds the system interfaces that exist in the platform, they can be accessed with the . operation (e.g. noc_lpddr4_S00_AXI is one of the system interfaces):

    ```python
        vck_platform.versal_fabric.noc_lpddr4_S00_AXI
    ```

4. Create KernelDef objects by using the KernelDef class constructor and importing yaml. These kernels will be added to your application later.

    ```python
        aie_mult_blk = vsg.KernelDef(yaml_file = "${YAML_SRC_DIR}/kernels/aie_mult.yaml")
    ```

   * Edit any kernel setting as required (e.g. setting the fifo_size of in1 interface of the aie_mult_blk).

    ```python
        aie_mult_blk.in1["fifo_size"] = 32640
    ```

5. Create MemoryInterface objects by using the MemoryInterface class constructor. The kernels MemoryInterface will needs a platform system interface to connect to the physical memory, and will be place in one context that the system interface comes from.

    ```python
        fabric_ddr4 = vsg.MemoryInterface("fabric_ddr4",        # Name
                524288,               # Size 512GB
                512,                  # Bus Width Bit
                vck_platform.versal_fabric.noc_lpddr4_S00_AXI, # platform interface
                vck_platform.versal_fabric.clk_wiz_clk_out2) # platform clock
    ```


1. Create ArrayDef objects by using the ArrayDef class constructor. These ArrayDef objects represent array variables and can be used to infer data movement to kernels in the application

    ```python
        myVar = vsg.ArrayDef(name = "myVar",
                dimensions = [16, 8, 256], #
                element_size = 4)
    ```


   * Edit any ArrayDef setting as required.

1. Create Your Application object using the Application class constructor and referencing the earlier created Platform.

    ```python
        myApp = vsg.Application("myApp", vck_platform)
    ```

   * The contexts from the platform along with their parameters will be automatically copied into the application.
   * Edit any context parameters if required.

1. Add required KernelDefs, and ArrayDefs to your Application.

      * When a KernelDef is added to your Application it will return a Kernel object, or a KernelList object (if multiple KernelDefs is being added)

    ```python
        myApp.versal_aie.add_kernels(aie_mult_blk*4)
    ```

      * Kernel Objects represent the Kernel in the Application and can be modified after being added to the Application.

    ```python
        aie_mult_blk[:]["kernel_col"] = [1, 1, 3, 3]
    ```


      * The Kernel object holds the interface the kernel contains, they can be accessed with the . operation (e.g. setting the async buffer of in1 interface of the first kernel of the aie_mult_blk to True):

    ```python
        aie_mult_blk[0].in1["async"] = True
    ```

      * When an ArrayDefs is added to your Application it will return an Array object.

    ```python
        myVar = myApp.add_array(myVar, fabric_ddr4, 16384)
    ```

    * Array Objects represent the array variable in the Application and has an associated memory and memory offset.
    * When connecting an array to an Kernel Interface the data to be sent should be specified, there are three ways to do this:

    * Use brackets to specify how much data from each array dimension is wanted:

        * use range(start, stop, step) to specify data that you want to send in that row
        * use slice[start:stop:step] to specify data that will go to different endpoints (e.g. sending 256 data to in1 interface of 4 different blocks of aie_mult_blk, for 16 times )

    ```python
        myVar[range(0,16)][0:4][range(0,256)].connect(aie_mult_blk[:].in1)
    ```

    * Use the "get()" function to specify how much data from each array dimension is wanted, see get command.
    * Write your own command and put it the connection properties as "rdma_program":

        * Instead of writing "aie(#)" in the rdma program use $AIE and the correct AIE endpoint number will be filled in
        * An equation can be inserted into the program, wrapped with curley brackets: example: {(x+1)*1024}

            * If the the other_side is an interface list then x will be a counter starting at 0 and increasting by one for each interface in the interface list.
            * If the the other_side is an just an interface then x will be 0
            * The equation expects a python expression, supports many different

    ```python
        {10 if x > 2 else 2}
    ```

1. Connect interfaces together as required for the application.
1. Finalize the project by calling:

    ```python
    my_application.convert()
    ```

