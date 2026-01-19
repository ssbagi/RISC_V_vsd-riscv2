# RISC-V Workshop

## Environment Setup : Initial Setup

<img width="940" height="503" alt="image" src="https://github.com/user-attachments/assets/976619e6-9375-42e4-876a-07f8949b4033" />

<img width="941" height="504" alt="image" src="https://github.com/user-attachments/assets/71411eec-9092-4cc4-8b59-09d00336080e" />

<img width="940" height="505" alt="image" src="https://github.com/user-attachments/assets/709f13f8-7c90-4561-80a1-a1c19c349216" />

<img width="940" height="504" alt="image" src="https://github.com/user-attachments/assets/5f13810e-8716-4b97-8824-d2c203872d5b" />

<img width="940" height="504" alt="image" src="https://github.com/user-attachments/assets/14910b8a-7a8b-4cb4-8736-a2b94062928b" />

<img width="940" height="506" alt="image" src="https://github.com/user-attachments/assets/973dc8b9-deca-4490-a307-f5dee394fe38" />


## Understanding Check (Mandatory)
- Where is the RISC-V program located in the vsd-riscv2 repository?
  The RISC-V program is located in the samples directory.
  
- How is the program compiled and loaded into memory?
  For compialtion we need to use riscv gcc command. Example : riscv64-unknown-elf-gcc -o sum1ton.o sum1ton.c .
  
- How does the RISC-V core access memory and memory-mapped IO?
  Refering from the datasheet given. The RISC-V core access memory using SPI lines IOB_34a, IOB_32a, IOB_33b and IOB_35b. There are several other DPIO pins and several GPIO pins.
  
- Where would a new FPGA IP block logically integrate in this system?
  The new FPGA IP block will sit inside or reliazed in the Programmable Logic Blocks (PLB). In turn these contain the LUT's and DFF. Just like we have TERASIC FPGA for programming the Labs.






