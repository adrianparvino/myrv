myrv.json: furv.v alu.v decoder.v
	yosys -D LENS_NR=8 -p "read_verilog furv.v alu.v decoder.v; synth_gowin -json myrv.json";

pnrmyrv.json: myrv.json
	nextpnr-gowin --json myrv.json --write pnrmyrv.json --device GW1NR-LV9QN88PC6/I5
