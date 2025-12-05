**RISC-V Project**
- The main testbench to test all the instructions together is main_tb.v. All the other testbench files only tests individual components. 
- The file components.v programs all components except the ALU, sign extender, and the controller
- The file main.v combines all modules together to create the RISCV32I single cycle architecture
