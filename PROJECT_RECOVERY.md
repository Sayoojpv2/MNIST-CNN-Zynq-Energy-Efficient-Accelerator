# Project Recovery Status

This document tracks which parts of the project are original recovered code,
which were reconstructed, and which are new modifications.

---

## 1. RECOVERED FROM BASE REPOSITORY

The following files are the **original, unmodified** source code recovered
from the base GitHub repository `MNIST-CNN-FPGA-main`:

### RTL Source Files (24 files in `sources_1/new/`)
| File | Status | Notes |
|------|--------|-------|
| `top_cnn.sv` | Recovered | Path parameter added (non-functional) |
| `top.sv` | Recovered | Path default updated (non-functional) |
| `glbl_controller.sv` | Recovered | Duplicate FC_SET case removed (bugfix) |
| `PE.sv` | Recovered | **Unmodified** |
| `PE_Array.sv` | Recovered | **Unmodified** |
| `mul.sv` | Recovered | **SADCG modification applied** |
| `acc.sv` | Recovered | **Unmodified** |
| `Accumulator.sv` | Recovered | **Unmodified** |
| `MAC.sv` | Recovered | **SADCG modification applied** |
| `matmul.sv` | Recovered | **Unmodified** |
| `FC_Layer.sv` | Recovered | **Unmodified** |
| `FC_Controller.sv` | Recovered | **Unmodified** |
| `Sliding_Window.sv` | Recovered | **Unmodified** |
| `FIFO.sv` | Recovered | **Unmodified** |
| `Comparator.sv` | Recovered | **Unmodified** |
| `MaxPooling_ReLU.sv` | Recovered | **Unmodified** |
| `BUF1.sv` | Recovered | **Unmodified** |
| `BUF2.sv` | Recovered | **Unmodified** |
| `Max_finder.sv` | Recovered | **Unmodified** |
| `y_buf.sv` | Recovered | **Unmodified** |
| `Bias_ROM.sv` | Recovered | **Unmodified** |
| `FC_Bias_ROM.sv` | Recovered | **Unmodified** |
| `single_port_bram.sv` | Recovered | **Unmodified** |
| `TDP.v` | Recovered | **Unmodified** |

### Imported Sources (24 files in `sources_1/imports/cnn/`)
- All `.v` files are older Verilog versions of the above
- **Status**: Recovered, unmodified (kept for reference)

### Block Design (`sources_1/bd/design_1/`)
- `design_1.bd` — Recovered, unmodified
- `design_1_wrapper.v` — Recovered, unmodified
- All IP instances — Recovered, unmodified

### Constraints
- `Zybo-Z7-Master.xdc` — Recovered, unmodified

### Data Files (`cnn_verilog/data/`)
- All weight, bias, and input files — Recovered, unmodified

### SDK (`MNIST_CNN_FPGA.sdk/`)
- `helloworld.c` — Recovered, unmodified
- All BSP and HW platform files — Recovered, unmodified

### MATLAB
- `mlp_demo.m` — Recovered, unmodified

### Vivado Project
- `MNIST_CNN_FPGA.xpr` — Recovered, unmodified

---

## 2. RECONSTRUCTED FROM PROJECT DOCUMENTATION

Nothing was reconstructed from external documentation. All RTL, testbenches,
and data files were present in the recovered repository.

---

## 3. MODIFIED FOR ENERGY-EFFICIENT VERSION

The following files were modified to implement SADCG:

### Core SADCG Changes
| File | Modification |
|------|-------------|
| `mul.sv` | Added 12-bit zero detector, clock-enable gating, simulation counters |
| `MAC.sv` | Added zero detector on latched input, multiply gating, simulation counters |

### Bug Fixes (Required for correct operation)
| File | Fix |
|------|-----|
| `glbl_controller.sv` | Removed duplicate `FC_SET` case block (was overriding conv_done) |
| `top_cnn.sv` | Made `VIVADO_PROJECT_LOCATION` a parameter instead of hardcoded |
| `top.sv` | Updated default path to current workspace |

### Testbench Updates
| File | Change |
|------|--------|
| `tb_top_cnn.sv` | Added SADCG activity monitoring, zero-count statistics, result capture |
| `tb_top.sv` | Added SADCG activity monitoring, zero-count statistics, result capture |

### New Documentation
| File | Content |
|------|---------|
| `ENERGY_OPTIMIZATION.md` | SADCG technical description |
| `PROJECT_RECOVERY.md` | This file |
| `README.md` | Updated with SADCG architecture and build instructions |

---

## 4. HISTORICAL RUN ARTIFACTS IN REPOSITORY

The following historical run artifacts were found preserved in `MNIST_CNN_FPGA.runs/`:

| Artifact | Location | Value / Status |
|---|---|---|
| Historical Vivado Synthesis Report | `MNIST_CNN_FPGA.runs/design_1_top_cnn_0_0_synth_1/` | 15,661 LUTs, 16,035 FFs, 160 DSPs, 9 RAMB18E1 |
| Historical Routed Timing Summary | `MNIST_CNN_FPGA.runs/impl_1/design_1_wrapper_timing_summary_routed.rpt` | 125 MHz met, WNS = +0.023 ns, 0 failing endpoints |
| Historical Routed Power Report | `MNIST_CNN_FPGA.runs/impl_1/design_1_wrapper_power_routed.rpt` | Total: 1.920 W (PS: 1.399 W, PL: 0.373 W, Static: 0.148 W) |

### Non-Recovered Original Assets
| Item | Status |
|---|---|
| 1000-image testbench (`tb_top_1000.v`) | Referenced in README but not present in repo files |
| Original ASIC simulation netlists | Referenced in README screenshots only |
| Training scripts / PyTorch model | Not in repo |
| Weight quantization scripts | Not in repo |

---

## Git History

The base project was committed as the initial git commit:
```
git log --oneline
```
```
xxxxxxx BASE: Recovered original MNIST-CNN-FPGA project (pre-SADCG)
```

All SADCG modifications are tracked as subsequent commits. The base can be
restored at any time with:
```
git checkout HEAD~1  # or the specific base commit hash
```
