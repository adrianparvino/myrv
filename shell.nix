with import <nixpkgs> {};

mkShell {
  nativeBuildInputs = [pkgs.pkgsCross.riscv32-embedded.pkgsBuildHost.gcc verilog verilator yosys nextpnr python3Packages.apycula];
} 
