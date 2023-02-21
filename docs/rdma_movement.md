# RDMA movement in Python System Generator

Moving large amount of data into and out of the kernels in a system can be dificult. To solve this issues we have provided automation of the creation and propgraming the data movers which will move the users data.

## Arrays

The Arrray will be the concept used to represent a collection of data. This collection of data will recide in a memory(MemoryInterface) in the system. To create an array first an arrayDef needs to be created. To create an ArrayDef called "myArray" that is 1024 elements, with each element size of 4 bytes:


```python
myArray = vsg.ArrayDef(name = "myArray",
        dimensions = [1024], 
        element_size = 4)
```

ArrayDefs can be multiple dimentions, to create an ArrayDef that is 1024 by 128 elements change the dimensions to the following:

```python
my2dArray = vsg.ArrayDef(name = "myArray",
        dimensions = [128, 1024], 
        element_size = 4)
```
*Note: when describing the dimensions, the ordering is the from outer most to inner most.*

The ArrayDef object then needs to be added to the application, when they are added to the application an Array object is returned.

```python
myArr = myApp.add_array(myArray, fabric_ddr4, 16384)
```
An single array def can be added multiple times at different offsets, or even different memory interfaces.

```python
myArr_1 = myApp.add_array(myArray, fabric_ddr4, 16384)
myArr_2 = myApp.add_array(myArray, fabric_ddr4, 32768)
```

## Movement

After creating the Array objects we use the connect function to describe how data moves in to or out of the array. The [] access function is used to describe how much data we want to read/write into our array. If all the data is to be transfered in the 1024 long array the the following connect statement would be used:

```python
my_var[range(0,1024)].connect(my_kernel_block.input)
```

Or if we were using the 2 dimensional array and only wanted to send half of the inner dimension for all 128 outer dimension:

```python
my_var[range(0,128)][range(0,512)].connect(my_kernel_block.input)
```

In the movement

- Range - [range(X,Y)] indicate that everything from X to Y-1 is included
    - [range(0,256)] means send everything from 0 to 255

If you want to describe sending to multiple different endpoints the instead of using the range function, use the slice function. If there were 1024 my_kernel_block blocks and we wanted to send each one 1 element:

```python
my_var[slice(0,1024)].connect(my_kernel_block[:].input)
```

- Slice - [X:Y] / slice(X,Y) indicate that each value will be sent to different endpoints
    - Must match the endpoint range as well

Or if we were using the 2 dimensional array and only wanted to send half of the inner dimension to 128 different my_kernel_blocks:

```python
my_var[0:128][range(0,512)].connect(my_kernel_block[0:128].input)
```
*Note: Slice can be done as [start:end:step] or slice(start, end, step)

Example: 
- [Automated Data Movement](movement/yaml/constrains/system.py)
