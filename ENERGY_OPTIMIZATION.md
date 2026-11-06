# Energy optimisation: status of "SADCG"

*Rewritten in the November 2026 recovery audit. The earlier version of this
file described the September 2026 code as working DSP48E1 clock-enable gating.
The audit measured that it is not. Details and evidence:
[`docs/RECOVERY_REPORT.md`](docs/RECOVERY_REPORT.md) §5.2.*

## 1. What the project documents claim (March 2026)

The project report and IEEE paper describe **Sparsity-Aware Dynamic Clock
Gating (SADCG)**: detect ReLU-induced zero activations and gate the clock of
the multiplier DSP slice through an integrated clock-gating (latch + AND) cell.
They give a table of 2.367 W (baseline) vs 2.002 W (SADCG), i.e. "≈41 % lower PL
dynamic power". The final presentation lists clock gating as a reason for low
power, but reports only a single figure: **1.725 W**.

**Status:** no RTL, Vivado report or screenshot from the original period
supporting the SADCG implementation or the 2.367 W / 2.002 W figures was found.
The one surviving implementation result (screenshot, 2 Mar 2026, ZedBoard
`xc7z020clg484-1`) is **1.725 W total, vectorless, confidence "Low"**, with **160
DSP48E1**, which is the same DSP count as the unmodified reference design.
These claims are therefore treated as **unverified**.

## 2. What the code in this repository does (September 2026 reconstruction)

Written with Google Antigravity on 13 Sep 2026 in `sources_1/new/mul.sv` and
`sources_1/new/MAC.sv`:

```systemverilog
// mul.sv
wire activation_zero = (data_i == 12'sd0);
wire compute_en      = valid_i & ~activation_zero;
always @(posedge clk_i)
  if (!rstn_i)          result <= 0;
  else if (compute_en)  result <= data_i * weight_i;
  else                  result <= 0;      // also taken when data_i == 0
```

* When the activation is zero, the register is loaded with `0`, which is the
  product the multiplier would have produced anyway. The register sequence is
  unchanged.
* The else-branch is an assignment, not a hold, so **no clock enable is
  implied** and nothing maps to DSP48E1 `CEM`/`CEP`.
* The DSP input operands (`data_i`, `weight_i`; `input_ff`, `weight_ff` in
  `MAC.sv`) are still updated every valid cycle.
* These `.sv` files are **not in the Vivado project source set**. The `.xpr`
  synthesises `sources_1/imports/cnn/*.v`, which has no zero detection.

## 3. Measurements made in the audit (ModelSim-Altera 10.1d)

| Check | Result |
|---|---|
| 10-image classification, base `.sv` vs SADCG `.sv` | Identical: 0–9, both finish at 73,155,000 ns |
| `tb_sadcg_verify` (5 tests, incl. 1,000 random vectors vs ungated copies) | PASS, 0 errors |
| Bit toggles of all 150 PE `mul.result` registers, full 10-image run | **1,553,474 base / 1,553,474 SADCG** |
| Bit toggles of all 10 FC `MAC.mul` registers | **42,258 base / 42,258 SADCG** |
| VCD of all multiplier registers, base vs SADCG | Byte-identical |

Reproduce with `sim/modelsim/run_all.do`, `sim/modelsim/dump_mult_toggles.do`
and `sim/tools/vcd_toggle_count.py`.

**Not done:** synthesis, SAIF-annotated power analysis, or any hardware power
measurement of this code. **No power saving is claimed.**

## 4. What a real implementation would need (not attempted here)

For anyone who wants to continue the idea:

1. Gate with a **clock enable that holds** the multiplier input/pipeline
   registers (e.g. register `data_i`/`weight_i` inside the DSP with `CEA/CEB`
   driven by `~zero`) and select 0 at the output with a separate flag. Do not
   gate the clock itself in fabric logic.
2. Add the files to the Vivado source set. Confirm in the synthesised netlist
   that the DSP48E1 `CE*` pins are driven.
3. Run behavioural/post-route simulation, write a SAIF and compare
   `report_power` for baseline and modified designs **with the same activity**.
4. Note that most "zeros" at the conv1 input are background pixels of the
   image. The testbench zero ratios (68–83 %) are not ReLU sparsity.
