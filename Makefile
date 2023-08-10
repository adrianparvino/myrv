myrv.json: furv.v alu.v decoder.v immdecoder.v
	yosys -p "read_verilog furv.v alu.v decoder.v immdecoder.v; proc; wreduce; alumacc; share -aggressive; opt_share; opt_expr -full; opt;; wreduce;; opt;; opt_expr -full;; opt;;  wreduce;; opt;; wreduce;; synth_gowin -json myrv.json";

pnrmyrv.json: myrv.json
	nextpnr-gowin --json myrv.json --write pnrmyrv.json --device GW1NR-LV9QN88PC6/I5
