myrv.json: top.v furv.v alu.v decoder.v immdecoder.v
	# yosys -p "read_verilog top.v furv.v alu.v decoder.v immdecoder.v";
	yosys -p "read_verilog immdecoder.v decoder.v alu.v furv.v rom.v top.v; proc; wreduce; alumacc; share -aggressive; opt_share; opt_expr -full; opt;; wreduce;; opt;; opt_expr -full;; opt;;  wreduce;; opt;; wreduce;; synth_gowin -json myrv.json";
	# yosys -p "read_verilog rom.v immdecoder.v decoder.v alu.v furv.v top.v; synth_gowin -json myrv.json";

pnrmyrv.json: myrv.json
	nextpnr-gowin --json $< --write $@ --device GW1NR-LV9QN88PC6/I5 --family GW1N-9C --cst tangnano9k.cst --parallel-refine

myrv.fs: pnrmyrv.json
	gowin_pack -d GW1N-9C -o myrv.fs pnrmyrv.json

.PHONY: clean

clean:
	rm -f myrv.json pnrmyrv.json myrv.fs
