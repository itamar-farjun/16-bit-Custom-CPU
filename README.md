# Custom 16-bit Multi-Cycle RISC CPU

## Overview
This repository contains the VHDL implementation of a custom 16-bit Von Neumann RISC processor. Developed as an independent personal project out of a passion for computer architecture, it encompasses the complete logic design of the CPU core from scratch, including a custom Instruction Set Architecture (ISA), Control Unit (FSM), ALU, and Register File.

Currently, the project is verified via simulation (Vivado) using a dedicated Testbench, with hardware deployment planned for the near future.

### Datapath & Block Diagram

```mermaid
graph TD
    %% Main Data Bus
    Bus["================== 16-bit Data Bus =================="]

    subgraph Control_Unit_Section [Control & Decode]
        CU["Control Unit (FSM)"]
        IR["Instruction Register"]
    end

    subgraph Memory_Interface [Memory Interface]
        MAR["Memory Address Reg"]
        MDR["Memory Data Reg"]
        RAM["External RAM"]
    end

    subgraph Execution_Path [Execution & Registers]
        PC["Program Counter"]
        RegFile["Register File"]
        ALU["ALU"]
    end

    %% Bus Connections (Datapath)
    PC -->|"PC_Out"| Bus
    Bus -->|"PC_In"| PC
    
    Bus -->|"IR_In"| IR
    IR -->|"Imm/Addr"| Bus
    
    RegFile -->|"Data_Out"| Bus
    Bus -->|"Data_In"| RegFile
    
    ALU -->|"ALU_Out"| Bus
    
    Bus -->|"MAR_In"| MAR
    Bus -->|"MDR_In"| MDR
    MDR -->|"MDR_Out"| Bus

    %% Control & Dedicated Routing
    IR -.->|"Opcode"| CU
    RegFile ==>|"A_In / B_In"| ALU
    ALU -.->|"Z_Flag"| CU
    
    MAR ==>|"Mem_Addr"| RAM
    RAM -->|"Data_In"| MDR
    MDR -->|"Data_Out"| RAM
    CU -.->|"Mem_Ctrl"| RAM

## Architecture: Advantages and Disadvantages
The CPU is based on a Multi-Cycle Von Neumann architecture. This design choice presents specific trade-offs:

**Advantages:**
* **Resource Efficiency:** By using a Multi-Cycle approach, complex functional units like the ALU and single memory buses are shared across different clock cycles, significantly saving hardware resources (LUTs).
* **Unified Memory:** The Von Neumann architecture allows data and instructions to reside in the same memory space, simplifying memory management and reducing the need for dual memory interfaces.
* **Higher Clock Speed:** Breaking down instructions into smaller, distinct stages (Fetch, Decode, Execute) allows the processor to run at a higher clock frequency compared to a single-cycle implementation.

**Disadvantages:**
* **Throughput:** It takes several clock cycles (3 to 6) to complete a single instruction, resulting in a lower IPC (Instructions Per Cycle) compared to pipelined processors.
* **Memory Bottleneck:** Since both instructions and data share the same bus, they cannot be accessed simultaneously, creating a potential bottleneck during memory-intensive operations.

## Instruction Set Architecture (ISA) Overview
The ALU and Control Unit support a streamlined set of operations, including:
* **Arithmetic & Logic:** `ADD`, `SUB`, `DIV`, `MOD`, `AND`, `OR`
* **Memory Access:** `LOAD`, `STORE`
* **Control Flow:** `JMP` (Unconditional), `JZ` (Jump if Zero), `HALT`
* **Immediate:** `LDI` (Load Immediate)

## Future Work
* Hardware integration and synthesis on a Digilent Arty S7 FPGA board.
* Implementation of a hardware debouncer for physical push-button inputs.
* Development of a Python-based Assembler to automate machine-code generation.
