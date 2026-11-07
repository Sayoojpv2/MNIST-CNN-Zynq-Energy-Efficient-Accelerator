# Recovery report: MNIST CNN on Zynq mini-project

*Audit date: 6 November 2026. Branch `recovery/mnist-mini-project-evidence-2026-11`.*
*The audit was carried out with Claude Code (Anthropic), at the request of the repository owner.*

This report records what could and could not be established about the original
college mini-project. It draws on three sources:

1. this Git repository and its history;
2. screenshots and documents on the author's laptop;
3. local Google Antigravity data.

Where sources disagree, the disagreement is kept and explained.

---

## 1. Summary of findings

| Question | Finding | Confidence |
|---|---|---|
| What was the original project? | The open-source **foodinsect/MNIST-CNN-FPGA** Vivado 2019.1 project (MIT, © 2024 "Hoooo"; built for the Digilent Zybo Z7-20). The team **retargeted it to an Avnet ZedBoard** (`xc7z020clg484-1`), added an **AXI GPIO** input path and an interactive SDK/MATLAB single-digit demo, implemented it, and programmed a physical board. | High (screenshots of 21 Feb – 21 Mar 2026) |
| Who did it | Mini-project of ECE 2023–27 Team 06, Muthoot Institute of Technology and Science (Adith M, Anandhakrishnan M, Benison P Baby, Sayooj P V; guides Ms Deepa Prabhu and Ms Nayana P K), March 2026 | High (report, paper, presentation) |
| Physical board used? | **Yes, a ZedBoard.** JTAG programming log with a "Digilent Zed" cable, a photo of the powered board, and UART results in MATLAB | High |
| Original implementation results | `impl_1` *write_bitstream Complete*: LUT 17,890 · FF 20,302 · BRAM 8.5 · DSP 160 · WNS +4.532 ns · **1.725 W** (vectorless, confidence Low) | High (screenshot) |
| Was SADCG (Sparsity-Aware Dynamic Clock Gating) implemented in the original RTL? | **No evidence found.** SADCG appears in the March 2026 report, paper and a conceptual presentation slide. No original RTL, report or screenshot shows it, and the 160 DSPs match the unmodified reference design. | Unresolved; no supporting evidence |
| Report/paper power table (2.367 W → 2.002 W, "41 % PL dynamic reduction") | **Not supported** by any report or screenshot found. It conflicts with the 1.725 W screenshot, which is also the only figure in the presentation. | No supporting evidence |
| What is in this repository? | Commit `f9cdfe3` ("BASE: Recovered original…") is a **byte-identical copy of the downloaded reference project** (12,320 of 12,320 files identical). It is **not** the team's modified project. The SADCG RTL (`4c779d2`) was written on **13 Sep 2026** with Google Antigravity (Claude Opus 4.6, then Gemini 3.8 Flash). | High |
| Does the SADCG RTL do anything? | It is functionally equivalent to the base. Its register switching is **also identical**: the VCD toggle counts match exactly (§5.2). It does **not** infer a clock enable, and it is **not** in the Vivado project's source set. | High (measured) |
| What was lost? | The team's modified RTL (`arm_gpio_in` port), block design with AXI GPIO, `zedboard_pins.xdc`, the `CNN_Interactive` SDK app, the single-digit MATLAB script, the ZedBoard bitstream and the run reports. The original project lived on a `D:` drive that is not present on the laptop. | High |

---

## 2. Source 1: the GitHub repository

### 2.1 History

All four commits were made from the repository owner's GitHub account (`Sayoojpv2`) on 13 Sep 2026 (IST), within one hour, from the Antigravity session described in §3. There are no other branches or tags.

| Commit | Time (IST) | What it actually contains |
|---|---|---|
| `f9cdfe3` BASE: Recovered original MNIST-CNN-FPGA project (pre-SADCG) | 18:41 | 12,320 files. Byte-identical to a local folder `MNIST-CNN-FPGA-main - Copy`, an unmodified extraction of the foodinsect GitHub ZIP made at 18:15 that day. It includes the reference author's Vivado logs/runs (host `LAPTOP-foodbug`, `C:/Users/foodbug`, `D:/MNIST-CNN-FPGA-S`, dated 12 May 2025). |
| `4c779d2` FEAT: Implement validated SADCG | 19:07 | Edits to `sources_1/new/{mul,MAC,glbl_controller,top,top_cnn}.sv`, the two testbenches and a new `tb_sadcg_verify.sv`. Adds `.gitignore`, `PROJECT_RECOVERY.md`, `ENERGY_OPTIMIZATION.md`. Deletes 1,200+ generated files (`.runs`, `.sim`, `.cache`, `.hw`, `.ip_user_files`, logs) and moves 4 historical reports to `reports/`. |
| `d9b3d1f` DOCS: Add project report, presentation and results | 19:24 | `docs/*.pdf`, byte-identical to `sayooj_merged.pdf`, `ieee paper (1).pdf` and `finalreview(3).pdf` in the author's downloads folder. Six `results/*.jpg` **extracted from the presentation PDF** by Antigravity. |
| `f0285df` DOCS: Align hardware specifications in README | 19:35 | README only. |

### 2.2 Which RTL does the Vivado project actually use?

* `MNIST_CNN_FPGA.xpr` (Vivado 2019.1, part `xc7z020clg400-1`, board `digilentinc.com:zybo-z7-20:part0:1.0`, board repo `C:/Users/foodbug/...`) lists **only `sources_1/imports/cnn/*.v`** plus `sources_1/new/TDP.v` in `sources_1`. Top: `design_1_wrapper`. Sim top: `tb_top_cnn`.
* The block design (`design_1.bd`) instantiates `top_cnn` as a **module reference** (`xilinx.com:module_ref:top_cnn:1.0`), so it uses whichever `top_cnn` is in the source set, i.e. `imports/cnn/top_cnn.v`.
* The historical synthesis log in the base commit (`MNIST_CNN_FPGA.runs/design_1_top_cnn_0_0_synth_1/design_1_top_cnn_0_0.vds`, 12 May 2025) shows every module synthesised from `D:/MNIST-CNN-FPGA-S/.../imports/cnn/*.v`.
* Conclusion: the SADCG files under `sources_1/new/*.sv` **were never part of synthesis, implementation or hardware testing** in this project. They are used only by the ModelSim flow created in September 2026.
* `sources_1/new/*.sv` (base) and `imports/cnn/*.v` are **different RTL revisions**, not just different languages. `top`, `glbl_controller`, `PE_Array` and `Sliding_Window` differ substantially. In simulation the `.sv` set writes results to `y_buf` addresses 4, 8, … and finishes at 73.155 ms; the `.v` set writes to 0, 4, … and finishes at 74.545 ms. Both classify the 10 test images correctly.
* The repository has a reference **bitstream** (`MNIST_CNN_FPGA.sdk/design_1_wrapper_hw_platform_0/design_1_wrapper.bit`) and `.hdf` from the reference author's Zybo build. **No bitstream or hardware export from the team's ZedBoard build exists.**

### 2.3 Historical reports in `reports/`

| Report | Source | Key values |
|---|---|---|
| `design_1_wrapper_power_routed.rpt` | LAPTOP-foodbug, 12 May 2025, `xc7z020clg400-1` | 1.920 W total (dynamic 1.772 W: PS7 1.399 W, DSP 0.116 W), static 0.148 W |
| `design_1_wrapper_timing_summary_routed.rpt` | same | `clk_fpga_0` = **50 MHz**; WNS +0.023 ns; the 125 MHz `sys_clk_pin` constraint applies to an unused Zybo `clk` pin |
| `design_1_top_cnn_0_0_utilization_synth.rpt` | same | 160 DSP48E1 |

These are the **reference author's results**, not the team's. Earlier README text attributed them to this project and described the accelerator as "clocked at 125 MHz". The fabric clock driving the CNN is the 50 MHz PS clock (`PCW_ACT_FPGA0_PERIPHERAL_FREQMHZ = 50`, `rst_ps7_0_50M`).

### 2.4 Absolute paths and machine dependencies

* `sources_1/new/top.sv` / `top_cnn.sv`: `VIVADO_PROJECT_LOCATION` = an absolute path into the 13 Sep 2026 local working folder (set by Antigravity; the base had `"F:/cnn_verilog"`). Override it with `-G…VIVADO_PROJECT_LOCATION=<path>`.
* `imports/cnn/top.v`: weights and images load via `"../../../../cnn_verilog/..."`, which is relative to the simulator/synthesis working directory. It works from `MNIST_CNN_FPGA.sim/sim_1/behav/xsim` and from the runs directory.
* `imports/cnn/{Bias_ROM,FC_Bias_ROM}.v`: biases are hard-coded parameters (the `$readmemh("./data/...")` code is commented out).
* `.xpr` `BoardPartRepoPaths`, SDK `.metadata`, `.hdf` and `ps7_init` files contain `C:/Users/foodbug/...` paths.
* `matlab/mlp_demo.m`: hard-coded `COM6`.

### 2.5 `cnn_verilog/mnist/` (10,003 files)

9,999 files named `<index>_label_<digit>.txt` (784 decimal pixel values each: the MNIST test set) plus copies of 4 other data files. A search of all RTL, testbenches, Tcl, MATLAB and SDK sources found **no reference** to this folder. It was presumably used by the reference author's 1000-image testbench (`tb_top_1000`), which is not in the repository. It was removed from the working tree in this branch and remains in history (`git checkout f9cdfe3 -- cnn_verilog/mnist`). `cnn_verilog/data/input_1000.txt` and `labels_1000.txt` are kept.

---

## 3. Source 2: laptop screenshots and documents

### 3.1 Method

* A Python inventory (PIL) recorded path, size, timestamps, pixel size, EXIF and MD5 for every image ≥ 15 kB under Desktop, Pictures (incl. Screenshots, Camera Roll, Saved Pictures), Downloads, Documents, Videos, OneDrive, nine user-created folders at the root of drive `C:` (including the 13 Sep 2026 working folder), an empty Vivado project folder in the user profile, and one loose screenshot at the root of `C:`. Only drive `C:` was present, so no secondary or external drive could be searched.
* **1,560** images found. **1,201** were excluded by location without visual review: OMNeT++ documentation and sample tiles, figure folders of the separate RL-WSN MATLAB project, and one unrelated root folder. Another **30** were excluded by location (game saves, other-project folders, certificates).
* The remaining **329** images were **visually reviewed** on labelled contact sheets (16 per sheet for Feb 2022 – Sep 2026, 36 per sheet afterwards). The 14 images in Antigravity's `.tempmediaStorage` were also reviewed. About 30 key candidates were opened at full resolution.
* Project-related images fall almost entirely on **21 Feb – 21 Mar 2026** (about 85 images). From **July 2026 onward** they are unrelated (RL-WSN work, personal content). Exceptions are the 13 Sep 2026 copies Antigravity made in `C:\mini project\...\results`.
* Duplicates found: `Screenshot 2026-02-21 150817/150848.png` (identical MD5); `Documents\Downloads\ms paint input.png` and `output prediction.png` are near-duplicates of `Screenshot 2026-03-21 121111/121152.png`; the repository's former `results/*.jpg` are downscaled derivatives of originals in `Pictures\Screenshots` and `Documents\Downloads\fpga.jpeg`.
* **10** images were selected and copied to `results/evidence/` (see [`EVIDENCE_MANIFEST.md`](../results/evidence/EVIDENCE_MANIFEST.md)). Seven are byte-for-byte copies. Three public copies are privacy derivatives: the MATLAB 0–9 screenshot is cropped to remove a web-chat overlay, the waveform screenshot is cropped to remove the Windows taskbar, and the board photo has its serial-number sticker blacked out and its EXIF removed. The originals are unchanged.

### 3.2 Chronology reconstructed from screenshots

| Date (IST) | Evidence (screenshot time) | What happened |
|---|---|---|
| 21 Feb 2026 11:46 | Vivado Settings | `MNIST_CNN_FPGA` opened from a copy of the upstream project on the laptop's `D:` drive; project device changed to **ZedBoard (xc7z020clg484-1)**; prompt to keep the existing (Zybo) `impl_1` run |
| 21 Feb 11:48–12:20 | IP status, Core Container, critical warnings, BD validation | IPs upgraded for the new part; DQS-skew warnings; `FREQ_HZ` mismatch errors between AXI BRAM controller (50 MHz) and SmartConnect (100 MHz), then fixed |
| 21 Feb 12:32–13:46 | SDK BSP, MATLAB | BSP for the new hardware; `mlp_demo.m` shows **every prediction = 5** (failure) |
| 21 Feb 14:34–14:52 | Find-in-files | `$readmemh`/`INIT_FILE` path debugging (`../../../../cnn_verilog/data/...`) |
| 21 Feb 15:07–15:22 | SDK `CNN_Zedboard` | JTAG launch fails with "AP transaction error, DAP status f0000021"; constraints now include **`Zybo-Z7-Master.xdc` and `zedboard_pins.xdc`** |
| 21 Feb 17:03 | MATLAB + Gemini chat | **Predictions 0–9 correct** for the 10 stored images (evidence #2) |
| 21 Feb 19:09–19:46 | Sources hierarchy, BD | `design_1_top_cnn_0_0` module ref → `top_cnn` → `top`; **AXI GPIO added**, feeding a new `arm_gpio_in[31:0]` port (evidence #1) |
| 21 Feb 20:38–21:57 | SDK `CNN_Interactive` | New app with PS UART and AXI GPIO; **"FPGA configured successfully"** over a Digilent Zed JTAG cable (evidence #3) |
| 21 Feb 22:21 | MATLAB "AI Prediction: 9" | Interactive single-digit demo misclassifies a "1" (evidence #4) |
| 22 Feb 09:32 | Design Runs (captured 9 Mar) | `impl_1` re-run to **write_bitstream** for the ZedBoard (evidence #7) |
| 1 Mar 20:54 | PDF viewer | IEEE-paper draft being edited |
| 2 Mar 12:45 | Power summary | **1.725 W**, project now in a second copy of the folder on `D:` (evidence #5) |
| 2 Mar 19:51–21:46 | `project_1` | A separate small ZedBoard lab project (clock divider/stopwatch). Not this accelerator |
| 3 Mar 22:42 | Vivado sim | Behavioural simulation of `tb_top_cnn` (evidence #6) |
| 9 Mar 11:15 | Project summary | ZedBoard board part, run results (evidence #7) |
| Mar 2026 | `docs/*.pdf` | Report, IEEE paper and presentation (all dated March 2026) |
| 21 Mar 12:11–12:30 | MS Paint, MATLAB, photo | Hand-drawn "4" → "AI Prediction: 4"; photo of powered ZedBoard; `mini project final.pptx` saved 12:30 (evidence #8–10) |
| unknown | – | Original project folder (on `D:`) deleted / no longer available |
| 13 Sep 2026 | Antigravity, Git | Reconstruction from the reference ZIP and publication (§4) |

### 3.3 College documents (`docs/`)

| Document | File on laptop | Notes |
|---|---|---|
| `docs/Project_Report.pdf` | `sayooj_merged.pdf` in downloads (identical MD5) | Team 06, March 2026. Claims SADCG, the power table 2.367 W → 2.002 W, and "implemented … and verified using simulation and hardware testing" |
| `docs/IEEE_Paper.pdf` | `ieee paper (1).pdf` in downloads (identical) | Claims Vivado **2021.1**, `xc7z020clg484-1`/ZedBoard, an ICG latch-based clock gate, 1000-image XSim testbench, a 4-state FSM, AXI4-Lite + AXI GPIO, LUT 14,850 / FF 18,240 / BRAM 24.5 / DSP 55 of 220, and the 2.367 → 2.002 W table |
| `docs/Final_Presentation.pdf` | `finalreview(3).pdf` in downloads (identical) | Reports **Total Power 1.725 W** (matches evidence #5), Gantt chart, methodology diagram with an "SADCG controller", MS Paint input → output |

**Contradictions between the documents and the hard evidence.** These are recorded, not resolved:

* Tool version: screenshots show **Vivado 2019.1**; the paper says 2021.1.
* Resources: the screenshot shows LUT 17,890 / FF 20,302 / BRAM 8.5 / **DSP 160**; the paper says 14,850 / 18,240 / 24.5 / **55**.
* Power: the screenshot and presentation show **1.725 W**; the report and paper show 2.367 W (baseline) vs 2.002 W (SADCG). No 2.367 W or 2.002 W report was found anywhere.
* Clock gating: the paper describes an ICG latch + AND cell driving each DSP clock. No such RTL exists in any version found, and the 160 DSP count is unchanged from the reference.
* FSM: the paper describes 4 states (IDLE/LOAD_WEIGHTS/STREAM_PIXELS/WRITEBACK). The RTL has a 15-state global FSM plus an FC FSM.
* Verification: the paper mentions a 1000-image testbench and parity with a PyTorch golden model. Neither the testbench nor any PyTorch/quantisation code was found.

### 3.4 Other local items

* `~/CNN/CNN.xpr`: empty Vivado 2019.1 project for the ZedBoard created 21 Feb 2026 (no sources).
* `MNIST-CNN-FPGA-main` (local working folder): the 13 Sep 2026 working copy (Git checkout of this repo). `...- Copy` is the pristine reference extraction.
* `Desktop\mini project final.pptx` = `Documents\Downloads\mini project final.pptx` (15 slides, 21 Mar 2026): source deck of the presentation.
* No Vivado installation is currently present. ModelSim-Altera Starter 10.1d (Quartus 13.1) and MATLAB R2026a are installed.

---

## 4. Source 3: Google Antigravity

All access was read-only. The relevant folders were copied to a temporary directory before inspection. Nothing was modified, rebuilt or deleted, and `oauth_creds.json` / `google_accounts.json` were not opened.

| Location | Contents found |
|---|---|
| `%USERPROFILE%\.gemini\antigravity\` | 6 brains / 6 conversations (`.pb` from Feb 2026, one `.db` from 13 Sep 2026), `conversation_summaries.db` |
| `%USERPROFILE%\.gemini\antigravity-ide\` | 16 brains / 16 conversations (Feb–Oct 2026) |
| `%USERPROFILE%\.gemini\antigravity-backup\` | backup of the 5 Feb 2026 conversations |
| `%USERPROFILE%\.gemini\config\projects\<id>.json` | project "MNIST-CNN-FPGA-main" → the local working folder |
| `%APPDATA%\Antigravity IDE\User\workspaceStorage\<id>\workspace.json` | same folder, **first created 13 Sep 2026 18:27** |
| `%APPDATA%\Antigravity\`, `%APPDATA%\Antigravity IDE\` | Electron caches; local `History` has 6 small unrelated entries |

* A keyword search (MNIST, SADCG, Zynq, ZedBoard, Vivado) across every conversation store matched **only one store: the SQLite `.db` of the 13 Sep 2026 conversation in `antigravity-ide/conversations/`**.
* The February 2026 `.pb` files are binary and appear encrypted or compressed. They could not be decoded and no keywords were found in them. Their brain artifacts (`task.md`, `walkthrough.md`) concern an unrelated web-application project.
* **Antigravity was therefore not used during the original Feb–Mar 2026 work.** Screenshots show Google Gemini (web) and MATLAB Copilot being used then. ChatGPT use reported by the author left no local records relevant to this project.

### 4.1 The 13 Sep 2026 conversation (18:29–19:45 IST)

The full transcript is in that conversation's brain folder (`.system_generated/logs/transcript.jsonl`) (9 user messages, ~700 steps; model Claude Opus 4.6 (Thinking), switched to Gemini 3.8 Flash at 18:47).

1. 18:29: the user describes the folder as "the recovered base FPGA project for my college mini-project" and asks for a read-only inventory. The request mentions `BUF_Slide` and `slide_trigger`. These are names from the IEEE paper, not from the RTL.
2. 18:36: "convert this recovered base … into the final energy-efficient mini-project described in our project documentation", i.e. implement SADCG. The plan is `brain/…/implementation_plan.md`.
3. 18:47–19:04: audit requests. Antigravity found **no Vivado** and used ModelSim ASE 10.1d (`vlog`/`vsim`) for `tb_top_cnn`, `tb_top` and `tb_sadcg_verify`. The user explicitly asked not to claim the 2.002 W figure was reproduced.
4. 19:04–19:15: commits; `.gitignore`.
5. 19:15–19:20: Antigravity searched the user profile for PDFs, found `finalreview(3).pdf`, `ieee paper (1).pdf` and `sayooj_merged.pdf`, and **extracted the embedded images** of the presentation into `scratch_img/`. Six were committed as `results/*.jpg`.
6. 19:29–19:45: README check, GitHub repository created and pushed.

**Decisions introduced in September 2026 (not original):** SADCG RTL in `mul.sv`/`MAC.sv`; removal of the duplicate `FC_SET` case; `VIVADO_PROJECT_LOCATION` parameterisation; testbench statistics; `tb_sadcg_verify.sv`; documentation; deletion of generated directories.

---

## 5. Technical audit

### 5.1 Simulations run in this audit

Run with ModelSim-Altera Starter 10.1d via [`sim/modelsim/run_all.do`](../sim/modelsim/run_all.do) (`vsim -c -do run_all.do`):

| Configuration | Testbench | Result |
|---|---|---|
| Vivado source set (`imports/cnn/*.v` + `new/TDP.v`)* | `tb_top_cnn` | **PASS**: 0 1 2 3 4 5 6 7 8 9, done at 74,545,000 ns |
| same | `tb_top` | **PASS**: 0–9, done at 74,525,000 ns |
| SADCG set (`new/*.sv`) | `tb_top_cnn` | **PASS**: 0–9, done at 73,155,000 ns |
| same | `tb_top` | **PASS**: 0–9, done at 73,135,000 ns |
| same | `tb_sadcg_verify` | **PASS**: 5 tests, 0 errors |
| Base `.sv` from `f9cdfe3` (manual run) | `tb_top_cnn` | **PASS**: identical results and timing to the SADCG set |

\* ModelSim 10.1d rejects the sv2v-style `localparam i = i;` lines inside generate loops in `PE.v`, `PE_Array.v`, `matmul.v` and `top.v`. The script compiles a scratch copy with those no-op lines removed. Vivado accepts the originals.

The 10 stored images (`cnn_verilog/INT8_input_image_hex.txt`) were rendered and checked: they are the digits 0–9 in order. So "0–9" is a genuine pass, computed by the datapath. Note the testbenches print results but do not compare them with expected labels themselves; `run_all.do` performs that check.

ModelSim warnings on the `.v` set: `y_buf_addr` port width mismatch (32-bit port, 7-bit connection, `top_cnn.v:82`) and `ACC_clear` left unconnected on `glbl_controller` (`top.v:187`). The reference author's synthesis log reports the same missing connection.

**Not run:** Vivado synthesis, implementation, power analysis, XSim, bitstream generation, board tests (no Vivado or board available). MATLAB/UART flow (needs the board).

### 5.2 SADCG assessment

* **Zero detection** is a 12-bit compare on the multiplier activation (`mul.sv`) and on the latched FC activation (`MAC.sv`).
* **No clock enable is inferred.** When the activation is zero, the RTL writes `0` into the output register (`else result <= 0;` / `mul <= 0;`). That is a reset/assignment, not a hold. It is also the very value the multiply would have produced (0 × w = 0). The register therefore makes exactly the same transitions as in the ungated base.
* **Measured.** Every multiplier output register (150 PE `mul.result` + 10 FC `MAC.mul`) was dumped to VCD during the full 10-image `tb_top_cnn` run, for the base and the SADCG RTL ([`sim/modelsim/dump_mult_toggles.do`](../sim/modelsim/dump_mult_toggles.do), [`sim/tools/vcd_toggle_count.py`](../sim/tools/vcd_toggle_count.py)). The two VCD bodies are **byte-identical**:

  | Signal (all instances) | Base bit toggles | SADCG bit toggles |
  |---|---|---|
  | `mul.result` (150 PE multipliers) | 1,553,474 | 1,553,474 |
  | `MAC.mul` (10 FC MACs) | 42,258 | 42,258 |
  | `MAC.input_ff` / `weight_ff` | 20,630 / 19,190 | 20,630 / 19,190 |

* The DSP **input operands still change every valid cycle**, and nothing in the RTL holds them. Any saving inside the DSP48E1 multiplier array would depend on synthesis mapping and cannot be shown without Vivado power analysis using simulation activity (SAIF).
* **Functional equivalence**: confirmed (`tb_sadcg_verify`, and identical 10-image results and timing). `tb_sadcg_verify` compares against hand-copied ungated modules, so it is a valid equivalence check. It does not measure switching or power.
* `tb_sadcg_verify.sv` is **not** in the `.xpr` simulation set.
* The 68 % / 83 % "zero activation" figures printed by the testbenches count zero values at the PE input. Those zeros come mostly from black background pixels of the input image, not ReLU. The two numbers differ because the two RTL revisions present data differently.
* The duplicate `FC_SET` case removed in `glbl_controller.sv` was **unreachable**: Verilog takes the first matching case item, and the reference synthesis log flags it as "case item 5'b01100 is unreachable". Removing it changed nothing. The earlier claim that it "was overriding conv_done" was wrong.
* **Verdict:** the SADCG code is a September 2026 reconstruction. It is functionally harmless and does not reduce register switching. It is not in the FPGA build, and no power claim can be attached to it. The comments in `mul.sv`/`MAC.sv` that claimed DSP CE gating were corrected in this branch (comments only, no logic change).

### 5.3 CNN architecture (from RTL)

| Item | Finding |
|---|---|
| Input | 28×28, 8-bit **unsigned** pixels (0–255, zero-extended to 12-bit), 10 images stored in BRAM at build time |
| Conv1 | 5×5, 1 → 3 channels, 24×24 output |
| Pool/ReLU | 2×2 max-pool (FIFO column compare + `MaxPooling_ReLU` row compare), ReLU, → 12×12 |
| Conv2 | 5×5, 3 → 3 channels, accumulated over input channels, 8×8 → pool → 4×4×3 = 48 |
| FC | 48 → 10 using 10 `MAC` units, `Max_finder` argmax → class 0–9 |
| PE organisation | `PE_Array` = 2 rows × 3 channels = 6 `PE`, each with 25 `mul` → **150 multipliers** + 10 FC MACs = **160**, matching 160 DSP48E1 in both the reference and the team's implementation |
| Widths | activation 12-bit, weight 8-bit signed, product 20-bit, PE adder tree 20-bit at every level (no growth) |
| Overflow check (conv1) | With the actual weights, worst-case \|Σ w·x\| for 0–255 inputs is 264,180, below the 20-bit signed limit of 524,287, so **conv1 is safe**. Conv2 was **not** proven safe (intermediate ranges not analysed). |
| Interfaces | Results written to a dual-port BRAM through the AXI BRAM controller; `done_intr_o` → PS IRQ 61; SDK reads BRAM and prints over UART at 115200 baud; MATLAB plots |

### 5.4 Reproducibility with Vivado 2019.1

| Item | Status |
|---|---|
| Open `MNIST_CNN_FPGA.xpr` | **Not verified here (no Vivado).** It targets Zybo `xc7z020clg400-1` and needs the Digilent board files. The BD, IP `.xci` and generated IP products are present. |
| Behavioural simulation | Should work in XSim: relative data paths resolve from `MNIST_CNN_FPGA.sim/sim_1/behav/xsim`. Verified equivalent behaviour in ModelSim. |
| Synthesis/implementation | Not verified; generated `.runs` were removed in `4c779d2` (still in history at `f9cdfe3`). |
| Team's ZedBoard version | **Cannot be rebuilt.** The modified RTL, BD, XDC and SDK app are lost. |
| Missing | 1000-image testbench, PyTorch training and quantisation scripts, interactive MATLAB script, `CNN_Interactive` SDK source, ZedBoard bitstream and reports |

---

## 6. Provenance register

See [`PROJECT_RECOVERY.md`](../PROJECT_RECOVERY.md) for the per-file classification (Original / Recovered / Reconstructed / Modified / Unverified).

## 7. Changes made on this branch

See the pull request description and `git diff main...recovery/mnist-mini-project-evidence-2026-11`. In brief: evidence images + manifest, this report, rewritten README/PROJECT_RECOVERY/ENERGY_OPTIMIZATION, ModelSim regression and toggle tooling, comment-only corrections in `mul.sv`/`MAC.sv`, removal of `cnn_verilog/mnist/` (unused) and of five presentation-derived JPEGs. No history was rewritten, so the Git object store (and GitHub's reported size) does not shrink.

## 8. Remaining gaps

* The team's modified RTL, block design, constraints, SDK application, interactive MATLAB script, bitstream and Vivado reports are not recoverable from this laptop. The `D:` drive used in Feb–Mar 2026 is not present.
* No evidence was found for the report/paper power table, the 41 % claim, the resource table, Vivado 2021.1, the ICG clock gate or the 1000-image verification.
* It cannot be confirmed whether the single-digit "AI Prediction" results were computed on the FPGA.
* Encrypted Antigravity `.pb` conversations from Feb 2026 could not be read (they appear unrelated).
* Vivado-based checks (project open, XSim, synthesis, power) could not be run.
