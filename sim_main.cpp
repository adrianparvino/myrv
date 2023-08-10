#include "Vfurv.h"
#include "verilated.h"
#include <cstdint>
#include <cstdio>

int main(int argc, char** argv) {
  uint32_t rom[16] = {0};
  rom[0] = 0x40000093;
  rom[1] = 0x00000113;
  rom[2] = 0x00100193;
  rom[3] = 0x00310133;
  rom[4] = 0x0020a023;
  rom[5] = 0x002181b3;
  rom[6] = 0x0030a023;
  rom[7] = 0xfe0008e3;
  rom[8] = 0x0000006f;           //j 50 <.L2^B3>

  rom[0] = 0x40000113; // li sp,1024
  rom[1] = 0x01000193; // li gp,16
  rom[2] = 0x00110023; // sb ra,0(sp)
  rom[3] = 0x00108093; // add ra,ra,1
  rom[4] = 0xfe30cce3;
  // rom[4] = 0xfe309ce3; // bne ra,gp,8 <.L1^B1>
  rom[5] = 0x401080b3;
  rom[6] = 0x00110023;
  rom[7] = 0x00000063;

  // rom[0] = 0x40000093; // li ra,1024
  // rom[1] = 0x00100113; // li sp,1
  // rom[2] = 0x00208023; // sb sp,0(ra)
  // rom[3] = 0x00111113; // sll sp,sp,0x1
  // rom[4] = 0xfe011ce3; // bnez sp,28 <.L1^B2>
  // rom[5] = 0x00000063; // beqz zero,34 <.L2^B2>

  // rom[0] = 0x40000093;           //li ra,1024
  // rom[1] = 0x80000137;           //lui sp,0x80000
  // rom[2] = 0xfff00193;           //li gp,-1
  // rom[3] = 0x00208023;           //sb sp,0(ra)
  // rom[4] = 0x40115113;           //sra sp,sp,0x1
  // rom[5] = 0xfe311ce3;           //bne sp,gp,44 <.L1^B3>
  // rom[6] = 0x0000006f;           //j 50 <.L2^B3>

  VerilatedContext* contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  Vfurv* top = new Vfurv{contextp};
  while (!contextp->gotFinish()) { 
    top->instruction = rom[top->pc >> 2];
    top->clk = !top->clk;

    if (top->clk && top->mem_out && !top->mem_read_out) {
      if (top->addr == 1024) {
        printf("data=%010d(0x%08x), addr=%x\n", top->data_out, top->data_out, top->addr);
      }
    }
        fflush(stdout);

    top->eval(); 
  }
  delete top;
  delete contextp;
  return 0;
}
