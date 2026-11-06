# dump_mult_toggles.do - dump every multiplier output register to toggles.vcd
# Used in the 2026-11 audit to compare switching activity of the SADCG
# reconstruction against the pre-SADCG base RTL (see docs/RECOVERY_REPORT.md).
# Run inside an already-compiled library, e.g.:
#   vsim -c -G/tb_top_cnn/dut/VIVADO_PROJECT_LOCATION=<repo>/cnn_verilog \
#        -do dump_mult_toggles.do lib_sv.tb_top_cnn
# then: python sim/tools/vcd_toggle_count.py toggles.vcd
onbreak {resume}
vcd file toggles.vcd
set n 0
foreach inst [find instances -r /tb_top_cnn/dut/*] {
  set p [lindex $inst 0]
  if {[string match {*/MUL} $p]}      { vcd add $p/result; incr n }
  if {[string match {*/MAC_inst} $p]} { vcd add $p/mul $p/input_ff $p/weight_ff; incr n }
}
echo "multiplier instances dumped: $n"
run -all
vcd flush
quit -f
