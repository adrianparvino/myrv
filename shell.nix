with import <nixpkgs> {};

mkShell {
  nativeBuildInputs = [verilog verilator yosys nextpnr python3Packages.apycula];
} 
