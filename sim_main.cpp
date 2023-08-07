#include "Vfurv.h"
#include "verilated.h"
#include <cstdint>
#include <cstdio>

int main(int argc, char** argv) {
  uint32_t rom[16] = {0};
  rom[0] = 0x40000113; // li	sp,1024
  rom[1] = 0x01000193; // li	gp,16
  rom[2] = 0x00110023; // sb	ra,0(sp)
  rom[3] = 0x00108093; // add	ra,ra,1
  rom[4] = 0xfe309ce3; // bne	ra,gp,8 <.L1^B1>

  VerilatedContext* contextp = new VerilatedContext;
  contextp->commandArgs(argc, argv);
  Vfurv* top = new Vfurv{contextp};
  while (!contextp->gotFinish()) { 
    top->instruction = rom[top->pc >> 2];
    top->clk = !top->clk;

    if (top->clk && top->mem && !top->mem_read) {
      if (top->addr == 1024) {
        printf("data=%x, addr=%x\n", top->data, top->addr);
      }
    }

    top->eval(); 
  }
  delete top;
  delete contextp;
  return 0;
}
