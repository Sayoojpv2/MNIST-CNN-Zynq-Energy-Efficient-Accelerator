# =============================================================================
# run_all.do - reproducible ModelSim regression for this repository
#
# Added during the November 2026 recovery audit (see docs/RECOVERY_REPORT.md).
# It does NOT modify any RTL in the repository. All build products go to
# sim/modelsim/out/ (git-ignored).
#
# Usage (from this directory):
#     vsim -c -do run_all.do
#
# Verified with: ModelSim ALTERA STARTER EDITION 10.1d (Quartus 13.1), Windows 11.
#
# Configurations
#   vivado_v : the Verilog sources the Vivado project (MNIST_CNN_FPGA.xpr)
#              actually compiles: sources_1/imports/cnn/*.v + sources_1/new/TDP.v.
#              These files contain sv2v-style "localparam i = i;" lines inside
#              generate loops. Vivado accepts them; ModelSim 10.1d rejects them.
#              The script therefore compiles a scratch COPY with only those
#              no-op lines removed.
#   sadcg_sv : the SystemVerilog sources in sources_1/new/*.sv (contains the
#              2026-09 SADCG reconstruction). These files are NOT part of the
#              Vivado project source set.
#
# Pass criterion for tb_top_cnn / tb_top: the 10 images stored in
# cnn_verilog/INT8_input_image_hex.txt are the digits 0,1,...,9 in that order,
# so the 10 captured y_buf results must be 0..9 in order.
# =============================================================================

onerror {resume}
onbreak {resume}
set here   [file normalize [pwd]]
set root   [file normalize [file join $here .. ..]]
set srcs   [file join $root MNIST_CNN_FPGA.srcs]
set data   [file join $root cnn_verilog]
set out    [file join $here out]
file mkdir $out
# Compiled libraries go to $out unless MNIST_SIM_LIBDIR is set. Set it to a
# short directory (e.g. C:/msl) if the repository sits in a deep Windows path:
# ModelSim library files can otherwise exceed the 260-character path limit.
if {[info exists ::env(MNIST_SIM_LIBDIR)]} { set libdir [file normalize $::env(MNIST_SIM_LIBDIR)] } else { set libdir $out }
file mkdir $libdir

set summary {}

proc check_log {logfile label} {
    upvar summary summary
    set fh [open $logfile r]; set txt [read $fh]; close $fh
    set preds [regexp -all -inline {y_buf: addr=[0-9]+, data=([0-9xXzZ]+)} $txt]
    set vals {}
    foreach {all v} $preds { lappend vals $v }
    set expect {0 1 2 3 4 5 6 7 8 9}
    if {$vals eq $expect} { set st PASS } else { set st FAIL }
    if {[regexp {STATUS: ALL TESTS PASSED} $txt]} { set st PASS }
    if {[regexp {Errors Detected\s*:\s*[1-9]} $txt]} { set st FAIL }
    lappend summary [format "%-28s %s  %s" $label $st $vals]
}

proc run_tb {workdir lib top logname extra} {
    set cwd [pwd]
    cd $workdir
    transcript file $logname
    eval [list vsim -c -onfinish stop] $extra [list $lib.$top]
    run -all
    quit -sim
    transcript file transcript_idle.log
    cd $cwd
}

# -----------------------------------------------------------------------------
# 1. vivado_v  (run directory must be exactly 4 levels below the repo root so
#    that the relative INIT_FILE paths "../../../../cnn_verilog/..." in top.v
#    resolve to <repo>/cnn_verilog)
# -----------------------------------------------------------------------------
set vdir [file join $out v]
set vsrc [file join $vdir src]
file mkdir $vsrc
foreach f [glob -directory [file join $srcs sources_1 imports cnn] *.v] {
    set fh [open $f r]; set t [read $fh]; close $fh
    regsub -all -line {^\s*localparam\s+(\w+)\s*=\s*\1\s*;\s*$} $t {} t
    set oh [open [file join $vsrc [file tail $f]] w]; puts -nonewline $oh $t; close $oh
}
file copy -force [file join $srcs sources_1 new TDP.v] [file join $vsrc TDP.v]
cd $vdir
set vlibp [file join $libdir lib_v]
if {[file exists $vlibp]} { vdel -lib $vlibp -all }
vlib $vlibp
vmap lib_v $vlibp
eval [list vlog -work lib_v] [glob -directory $vsrc *.v]
vlog -sv -work lib_v [file join $srcs sim_1 new tb_top_cnn.sv] [file join $srcs sim_1 new tb_top.sv]
cd $here
run_tb $vdir lib_v tb_top_cnn tb_top_cnn.log {}
check_log [file join $vdir tb_top_cnn.log] "vivado_v/tb_top_cnn"
run_tb $vdir lib_v tb_top tb_top.log {}
check_log [file join $vdir tb_top.log] "vivado_v/tb_top"

# -----------------------------------------------------------------------------
# 2. sadcg_sv  (absolute data path passed with -G; the RTL default is a
#    machine-specific absolute path)
# -----------------------------------------------------------------------------
set sdir [file join $out sv]
file mkdir $sdir
cd $sdir
set slibp [file join $libdir lib_sv]
if {[file exists $slibp]} { vdel -lib $slibp -all }
vlib $slibp
vmap lib_sv $slibp
eval [list vlog -sv -work lib_sv] [glob -directory [file join $srcs sources_1 new] *.sv] [list [file join $srcs sources_1 new TDP.v]]
eval [list vlog -sv -work lib_sv] [glob -directory [file join $srcs sim_1 new] *.sv]
cd $here
run_tb $sdir lib_sv tb_top_cnn tb_top_cnn.log [list -G/tb_top_cnn/dut/VIVADO_PROJECT_LOCATION=$data]
check_log [file join $sdir tb_top_cnn.log] "sadcg_sv/tb_top_cnn"
run_tb $sdir lib_sv tb_top tb_top.log [list -G/tb_top/dut/VIVADO_PROJECT_LOCATION=$data]
check_log [file join $sdir tb_top.log] "sadcg_sv/tb_top"
run_tb $sdir lib_sv tb_sadcg_verify tb_sadcg_verify.log {}
check_log [file join $sdir tb_sadcg_verify.log] "sadcg_sv/tb_sadcg_verify"

echo "=================== REGRESSION SUMMARY ==================="
foreach l $summary { echo $l }
echo "=========================================================="
set fh [open [file join $out summary.txt] w]
foreach l $summary { puts $fh $l }
close $fh
quit -f
