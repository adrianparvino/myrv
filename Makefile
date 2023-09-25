myrv.json: top.v furv.v alu.v decoder.v immdecoder.v rom.v uart.v ram.v firmware
	# yosys -p "read_verilog top.v furv.v alu.v decoder.v immdecoder.v";
	# yosys -p "read_verilog immdecoder.v decoder.v alu.v furv.v rom.v ram.v uart.v top.v; proc; alumacc;; wreduce; share -aggressive; opt_share; opt_expr -full; opt;; wreduce;; opt;; opt_expr -full;; opt;;  wreduce;; opt;; wreduce;; synth_gowin -json myrv.json";
	# yosys -p "read_verilog immdecoder.v decoder.v alu.v furv.v rom.v ram.v uart.v top.v; proc; alumacc; synth_gowin -json myrv.json";
	yosys -p "read_verilog immdecoder.v decoder.v alu.v furv.v rom.v ram.v uart.v top.v; proc; alumacc;; wreduce;; opt;; share -aggressive;; opt_share;; opt_expr -full;; opt;; memory -nomap; synth_gowin -json myrv.json";
	# yosys -p "read_verilog -sv immdecoder.v decoder.v alu.v furv.v rom.v uart.v top.v; synth_gowin -json myrv.json";
	# yosys -p "read_verilog -sv immdecoder.v decoder.v alu.v furv.v rom.v top.v; techmap; synth_gowin -json myrv.json";

pnrmyrv.json: myrv.json tangnano9k.cst
	nextpnr-gowin --json $< --write $@ --device GW1NR-LV9QN88PC6/I5 --family GW1N-9C --cst tangnano9k.cst --parallel-refine

myrv.fs: pnrmyrv.json
	gowin_pack -d GW1N-9C -o myrv.fs pnrmyrv.json

# himbaechel-myrv.json: top.v furv.v alu.v decoder.v immdecoder.v rom.v uart.v ram.v firmware
# 	# yosys -p "read_verilog top.v furv.v alu.v decoder.v immdecoder.v";
# 	yosys -p "read_verilog immdecoder.v decoder.v alu.v furv.v rom.v ram.v uart.v top.v; proc; alumacc;; techmap;; abc;; wreduce; share -aggressive; opt_share; opt_expr -full; opt;; wreduce;; opt;; opt_expr -full;; opt;;  wreduce;; opt;; wreduce;; synth_himbaechel -json himbaechel-myrv.json";
# 	# yosys -p "read_verilog -sv immdecoder.v decoder.v alu.v furv.v rom.v uart.v top.v; synth_gowin -json myrv.json";
# 	# yosys -p "read_verilog -sv immdecoder.v decoder.v alu.v furv.v rom.v top.v; techmap; synth_gowin -json myrv.json";

himbaechel-pnrmyrv.json: myrv.json tangnano9k.cst
	nextpnr-himbaechel --json $< --write $@ --device GW1NR-LV9QN88PC6/I5 --vopt family=GW1N-9C --vopt cst=tangnano9k.cst --parallel-refine

himbaechel-myrv.fs: himbaechel-pnrmyrv.json
	gowin_pack -d GW1N-9C -o himbaechel-myrv.fs himbaechel-pnrmyrv.json

.PHONY: clean

clean:
	rm -f myrv.json pnrmyrv.json myrv.fs himbaechel-pnrmyrv.json himbaechel-myrv.fs
