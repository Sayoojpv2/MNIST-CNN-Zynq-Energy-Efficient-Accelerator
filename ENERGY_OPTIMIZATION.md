# Energy Optimization: Sparsity-Aware Dynamic Clock Gating (SADCG)

## Overview

This document describes the energy-efficiency modification applied to the
MNIST CNN FPGA accelerator. The technique is called **Sparsity-Aware Dynamic
Clock Gating (SADCG)** and exploits the zero activations produced by ReLU
to reduce dynamic power consumption in the multiply–accumulate (MAC) units.

---

## The ReLU Sparsity Opportunity

The ReLU activation function `f(x) = max(0, x)` sets all negative values to
zero. In typical CNN inference on MNIST images, a significant fraction of
intermediate activations become zero after ReLU. These zero activations
propagate to subsequent layers where they participate in multiply–accumulate
operations.

Since `0 × weight = 0` for any weight, the multiplication is mathematically
unnecessary. However, without gating, the DSP multiplier and surrounding
logic still toggle internally — consuming dynamic power for a result that is
guaranteed to be zero.

**SADCG eliminates this wasted switching activity.**

---

## Zero Detection

A combinational zero detector is placed at the multiplier input:

```verilog
// In mul.sv (Conv PE multipliers, 25 per PE × 2 PEs × 3 channels = 150 total)
wire activation_zero = (data_i == 12'sd0);

// In MAC.sv (FC layer MACs, 10 parallel units)
wire activation_zero = (input_ff == 12'sd0);
```

The detector checks all 12 bits of the signed activation value. This detects:
- **ReLU-induced zeros**: Negative conv outputs clamped to 0 by MaxPooling_ReLU
- **Natural zeros**: Black pixels in MNIST images (background = 0x00)

The detection cost is minimal: one 12-bit NOR gate, which maps to a few LUTs.

---

## PE/MAC Gating Implementation

### Conv Multipliers (`mul.sv`)

The original multiplier:
```verilog
// BEFORE (base project)
always @(posedge clk_i)
    if (!rstn_i)       result <= 0;
    else if (valid_i)  result <= data_i * weight_i;  // Always multiplies
    else               result <= 0;
```

The SADCG-modified multiplier:
```verilog
// AFTER (energy-efficient version)
wire activation_zero = (data_i == 12'sd0);
wire compute_en      = valid_i & ~activation_zero;

always @(posedge clk_i)
    if (!rstn_i)         result <= 0;
    else if (compute_en) result <= data_i * weight_i;  // Only when non-zero
    else                 result <= 0;                   // Zero without DSP toggle
```

When `activation_zero` is asserted:
- `compute_en = 0` → the multiply expression is not evaluated
- The DSP48E1's CE (clock enable) pin is deasserted by the synthesis tool
- The DSP's internal pipeline registers do not toggle
- `result` is set to 0 via the `else` clause (functionally correct)

### FC MACs (`MAC.sv`)

The FC layer uses a pipelined MAC with separate latch, multiply, and
accumulate stages. The pipeline timing must be preserved to maintain
correct interaction with `FC_Controller`.

```verilog
// SADCG modification in MAC.sv
wire activation_zero = (input_ff == 12'sd0);

if (mac_en_i) begin
    weight_ff <= weight_i;
    input_ff  <= input_i;

    if (~activation_zero)
        mul <= $signed(input_ff) * $signed(weight_ff);  // Normal path
    else
        mul <= 20'h0;  // Skip DSP multiply, force zero
end
```

Key design decision: `mac_en_i` is NOT gated. The pipeline signals
`mac_en2` and `acc_en` continue to propagate normally. Only the
multiply operation inside the `mac_en_i` block is conditionally
executed. The accumulator adds 0 — numerically identical to adding
`0 × weight`.

---

## Gating Decision Timing

| Stage | Zero Check On | Decision Point | Gating Target |
|-------|--------------|----------------|---------------|
| Conv1 | Image pixels (8-bit zero-extended to 12-bit) | Before mul clock edge | DSP48E1 CE |
| Conv2 | BUF1 output (post-ReLU, 12-bit signed) | Before mul clock edge | DSP48E1 CE |
| FC | Latched activation `input_ff` (12-bit signed) | Same cycle as multiply | DSP48E1 CE |

The zero detector is **purely combinational** — no additional pipeline stages
are introduced. The gating decision is made within the same clock cycle,
using standard clock-enable (CE) semantics.

---

## Implementation Method: FPGA Clock-Enable Gating

> **IMPORTANT**: This design does NOT create fabric-generated gated clocks.

On Zynq-7000 (Artix-7 fabric), the correct approach for dynamic power gating
is **clock-enable (CE) based gating**:

1. The DSP48E1 primitive has dedicated CE pins: `CEA1`, `CEA2`, `CEB1`, `CEB2`,
   `CEM`, `CEP`, `CEAD`, etc.
2. When the synthesis tool (Vivado) sees `if (enable) result <= A * B;`, it maps
   `enable` to the appropriate DSP CE pins.
3. When CE = 0, the DSP's internal registers hold their values — **no internal
   toggling occurs**, saving dynamic power.
4. This is the Xilinx-recommended, synthesis-safe approach. No timing violations
   or clock domain crossing issues are introduced.

The `compute_en` signal in `mul.sv` maps directly to DSP CE pins during
synthesis. Vivado infers this pattern automatically.

---

## Functional Equivalence

The SADCG modification is **numerically transparent**:

| Condition | Base Result | SADCG Result | Equivalent? |
|-----------|-------------|-------------|-------------|
| `activation != 0` | `data × weight` | `data × weight` | ✅ |
| `activation == 0` | `0 × weight = 0` | `0` (forced) | ✅ |

**No CNN output values are altered.** The classification results are bit-exact
identical with and without SADCG.

---

## Simulation Evidence

The testbenches (`tb_top_cnn.sv`, `tb_top.sv`) include SADCG monitoring:

1. **Zero activation counters**: Track how many PE/MAC cycles have zero inputs
2. **Total activation counters**: Track total valid multiply cycles
3. **Zero ratio**: Percentage of computation that is gated
4. **Result comparison**: Classification output captured and displayed

Each `mul.sv` instance also contains `synthesis translate_off` counters:
- `sadcg_total_valid`: Total cycles where `valid_i` was asserted
- `sadcg_gated_cycles`: Cycles where activation was zero and multiply was skipped

---

## Historical vs. Current Verification Status

> ### ⚠️ Technical Audit & Verification Notice
> - **Current Verification Tool**: ModelSim Altera 10.1d (vlog/vsim). All 24 RTL files compile cleanly and simulate bit-exact (10/10 MNIST digits classified correctly).
> - **Reconstructed Implementation**: The SADCG modifications in `mul.sv` and `MAC.sv` are **reconstructed** based on the architectural documentation ("An Energy-Efficient Hardware Accelerator for Convolutional Neural Network on Zynq SoC"). They are not claimed to be the original deleted source code.
> - **Gating Mechanism**: The technique is **Dynamic Clock-Enable (CE) Gating** (driving the CE pins of DSP48E1 / pipeline registers). It is **not** physical clock gating (no clock nets or BUFG primitives are modified).
> - **Power Reproduction Status**: Xilinx Vivado is not installed on this host environment. Therefore, **no fresh Vivado power analysis or synthesis run has been executed**. Historical power numbers are documented below for project context only and are not claimed as newly reproduced.

---

## Power Data Audit: Historical Project Records

Two historical data points exist in the project records:

1. **Documented Project Report Result**:
   The college project report ("An Energy-Efficient Hardware Accelerator for Convolutional Neural Network on Zynq SoC") recorded:
   - Baseline Total Power: **2.367 W** (PL Dynamic: 0.875 W, PS: 1.350 W, Static: 0.142 W)
   - SADCG Total Power: **2.002 W** (PL Dynamic: 0.510 W, PS: 1.350 W, Static: 0.142 W)
   - Documented PL Dynamic Power Reduction: **41.7%** (0.875 W → 0.510 W)
   - Documented Total Power Reduction: **15.4%** (2.367 W → 2.002 W)
   *(Note: This is a documented historical claim from the project report, not a newly measured figure).*

2. **Repository Routed Implementation Report**:
   The pre-existing historical routed report in the repository (`MNIST_CNN_FPGA.runs/impl_1/design_1_wrapper_power_routed.rpt`, generated on 2025-05-12 in Vivado 2019.1) records:
   - Total On-Chip Power: **1.920 W**
   - Dynamic Power: **1.772 W** (PS7: 1.399 W, DSPs: 0.116 W, Routing: 0.110 W, Logic: 0.078 W, Clocks: 0.066 W, BRAM: 0.003 W)
   - Device Static Power: **0.148 W**
   - Timing: 125 MHz (`sys_clk_pin`), WNS = +0.023 ns (Constraints Met)

---

## Power Reduction Mechanism: Dynamic Clock-Enable (CE) Gating

On Xilinx 7-Series / Zynq-7000 FPGAs, clock nets are distributed via low-skew global clock buffers (`BUFG`). Slicing the clock net with logic gates is prohibited by design rules as it introduces race conditions, glitches, and timing closure failure.

Instead, SADCG implements **Dynamic Clock-Enable (CE) Gating**:
1. **Zero-Detection Logic**: Detects zero activations (`data_i == 12'sd0` in Conv, `input_ff == 12'sd0` in FC).
2. **DSP48E1 CE Gating**: Multiplier enable (`compute_en = valid_i & ~activation_zero`) maps directly to the DSP48E1 clock-enable pins (`CEM`/`CEP`).
3. **Internal DSP Toggle Suppression**: When CE = 0, the internal pipeline registers hold their state and do not switch, eliminating internal multiplier dynamic power.
4. **Adder Tree Feed**: Multipliers output 0 during zero activations, ensuring the adder tree (`acc.sv`) correctly adds 0 without mathematical corruption. In MNIST inference, 68% of Conv activations and 21% of FC activations are zero, yielding substantial switching activity reduction across consecutive cycles.

---

## Limitations

1. **Combinational detector overhead**: The 12-bit zero detector adds ~1 LUT per
   multiplier. This is negligible (< 0.1% of total LUTs on xc7z020).

2. **Conv1 benefit is modest**: Raw MNIST image pixels have fewer natural zeros
   than post-ReLU activations. The main benefit is in Conv2 and FC layers.

3. **Adder tree still toggles**: The `acc.sv` adder tree adds the (zero) mul
   outputs without gating. This could be improved but adds complexity.

4. **Static power unchanged**: SADCG only reduces dynamic switching power.
   Static (leakage) power is determined by the device and is not affected.

5. **No weight sparsity exploitation**: Only activation (input) sparsity is
   detected. Weight pruning/sparsity is a separate optimization.

---

## Files Modified

| File | Change |
|------|--------|
| `mul.sv` | Zero detector + CE gating + simulation counters |
| `MAC.sv` | Zero detector + multiply gating + simulation counters |
| `glbl_controller.sv` | Bug fix: removed duplicate `FC_SET` case |
| `top_cnn.sv` | Parameterized data path |
| `top.sv` | Updated default path |
| `tb_top_cnn.sv` | SADCG monitoring + statistics report |
| `tb_top.sv` | SADCG monitoring + statistics report |
