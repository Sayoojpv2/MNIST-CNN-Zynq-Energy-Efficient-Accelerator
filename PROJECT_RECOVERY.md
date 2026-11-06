# Project provenance register

*Rewritten in the November 2026 recovery audit. The September 2026 version of
this file called the base commit "the original, unmodified source code" of the
mini-project and said "nothing was reconstructed". That was inaccurate: the base
commit is the downloaded third-party reference project (see below). Full
evidence is in [`docs/RECOVERY_REPORT.md`](docs/RECOVERY_REPORT.md).*

## Classification key

| Label | Meaning |
|---|---|
| **Original** | Directly evidenced as part of the team's Feb–Mar 2026 mini-project |
| **Recovered** | Found later (backup, download folder, screenshot, conversation) and believed to be from the original period |
| **Reconstructed** | Recreated in Sep 2026 from the similar reference project |
| **Modified** | Changed after the original project (Sep or Nov 2026) |
| **Reference** | Third-party work from the upstream project, used as-is |
| **Unverified** | Origin or actual use cannot be established |

## Background in one paragraph

The mini-project (ECE Team 06, MITS, March 2026) took the open-source
[foodinsect/MNIST-CNN-FPGA](https://github.com/foodinsect/MNIST-CNN-FPGA) Vivado
2019.1 project (MIT licence, © 2024 Hoooo; Zybo Z7-20) and retargeted it to an
Avnet **ZedBoard**. The team added an AXI GPIO input path and an interactive
SDK/MATLAB demo, implemented the design and ran it on a board. Those project
files were later deleted. On 13 Sep 2026 this repository was rebuilt from a fresh
download of the upstream ZIP with Google Antigravity, which also wrote the
SADCG code and documentation.

## Register

### Documentation and evidence

| Item | Class | Notes |
|---|---|---|
| `docs/Project_Report.pdf`, `docs/IEEE_Paper.pdf`, `docs/Final_Presentation.pdf` | **Original** (documents) / **Unverified** (several technical claims) | Byte-identical to files in the author's Downloads. Claims conflicting with hard evidence are listed in `docs/RECOVERY_REPORT.md` §3.3 |
| `results/evidence/*` (10 images) | **Original** | Copies of Feb–Mar 2026 screenshots/photo: seven unmodified. For privacy, the MATLAB 0–9 and waveform screenshots are cropped and the board photo's serial sticker is redacted; see `results/evidence/EVIDENCE_MANIFEST.md` |
| `results/methodology_block_diagram.jpg` | **Recovered** (slide extracted from the presentation) | Conceptual diagram of intent, not implementation evidence |
| `README.md`, `PROJECT_RECOVERY.md`, `ENERGY_OPTIMIZATION.md`, `docs/RECOVERY_REPORT.md` | **Modified** (Nov 2026) | Written with AI assistance (Antigravity in Sep 2026, Claude Code in Nov 2026) |

### Vivado project and hardware platform

| Item | Class | Notes |
|---|---|---|
| `MNIST_CNN_FPGA.xpr` | **Reference** | Zybo `xc7z020clg400-1`. The team's ZedBoard (`xc7z020clg484-1`) version is lost |
| `sources_1/bd/design_1/*` (block design, IP) | **Reference** | No AXI GPIO. The team's BD with AXI GPIO is lost (only a screenshot survives) |
| `sources_1/ip/ila_0` | **Reference** | |
| `constrs_1/imports/01_SoC/Zybo-Z7-Master.xdc` | **Reference** | The team's `zedboard_pins.xdc` is lost |
| `MNIST_CNN_FPGA.sdk/` (BSP, `CNN` app, hw platform, `.bit`, `.hdf`) | **Reference** | Reference author's Zybo build. The team's `CNN_Zedboard` / `CNN_Interactive` apps and bitstream are lost |
| `reports/*.rpt` | **Reference** | Generated on `LAPTOP-foodbug`, 12 May 2025, Zybo part. **Not the team's results** |

### RTL

| Item | Class | Notes |
|---|---|---|
| `sources_1/imports/cnn/*.v` (24 files) | **Reference** | **The only CNN RTL in the Vivado source set.** Used for the reference reports. The team used them too, with an extra `arm_gpio_in` port that is not here |
| `sources_1/new/TDP.v` | **Reference** | In the Vivado source set; identical to `imports/cnn/TDP.v` |
| `sources_1/new/*.sv`, unmodified files (PE, PE_Array, acc, Accumulator, matmul, FC_*, Sliding_Window, FIFO, Comparator, MaxPooling_ReLU, BUF1/2, Max_finder, y_buf, Bias_ROM, single_port_bram) | **Reference** | A *different revision* of the RTL from `imports/cnn/*.v`. **Not in the Vivado source set** |
| `sources_1/new/mul.sv`, `MAC.sv` | **Reconstructed / Modified** (Sep 2026, SADCG). Comments corrected Nov 2026 | Functionally identical to the base and with identical register switching (measured). Not synthesised |
| `sources_1/new/glbl_controller.sv` | **Modified** (Sep 2026) | Removed an unreachable duplicate `FC_SET` case (no functional effect) |
| `sources_1/new/top.sv`, `top_cnn.sv` | **Modified** (Sep 2026) | Data path parameter, set to a machine-specific absolute path |

### Testbenches and simulation

| Item | Class | Notes |
|---|---|---|
| `sim_1/new/tb_top_cnn.sv`, `tb_top.sv` | **Reference**, **Modified** Sep 2026 | Added zero-count statistics and result printing. They work with both RTL sets |
| `sim_1/new/tb_sadcg_verify.sv` | **Reconstructed** (Sep 2026) | Valid equivalence test. Not in the `.xpr` simulation set |
| `tb_top_behav.wcfg`, `tb_top_cnn_behav.wcfg` | **Reference** | |
| `sim/modelsim/*`, `sim/tools/*` | **Modified** (new, Nov 2026) | Regression and toggle-measurement scripts |

### Data and host software

| Item | Class | Notes |
|---|---|---|
| `cnn_verilog/data/*` (weights, biases, 10 test images, 1000-image vectors) | **Reference** | Quantisation/training scripts that produced them are not available |
| `cnn_verilog/debug/*`, `cnn_verilog/*.txt` | **Reference** | Unreferenced debug data, kept |
| `cnn_verilog/mnist/` (10,003 files) | **Reference**, removed Nov 2026 | Unreferenced MNIST test set; still in history at `f9cdfe3` |
| `matlab/mlp_demo.m` | **Reference** | Reads 10 results from a COM port and plots them. The team's single-digit "AI Prediction" script is lost |

## Not recoverable

* Team's modified RTL (`top_cnn` with `arm_gpio_in[31:0]`), block design with AXI GPIO, `zedboard_pins.xdc`
* `CNN_Zedboard` and `CNN_Interactive` SDK applications, interactive MATLAB script
* ZedBoard bitstream, implementation/power reports (only screenshots survive)
* Any SADCG RTL from the original period (if it existed), and any data behind the 2.367 W / 2.002 W table
* 1000-image testbench, PyTorch training and quantisation scripts
