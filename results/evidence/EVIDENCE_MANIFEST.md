# Evidence manifest

This folder holds copies of screenshots and one photo found on the project
author's laptop during the November 2026 recovery audit. Each copy got a
descriptive file name. **Seven are unmodified byte-for-byte copies. Items 2 and
6 are cropped derivatives and item 10 is a redacted derivative** (see the notes
below the table). These three were edited only to keep unrelated personal
content out of the public repository. The originals on the laptop were not
renamed, moved, cropped, overwritten or deleted. MD5 hashes were checked after
copying. Original paths are given relative to the laptop user's profile folder,
written `<user profile>`.

Classification key (same as [`PROJECT_RECOVERY.md`](../../PROJECT_RECOVERY.md)):

* **Original**: captured during the original mini-project work (Feb–Mar 2026), before the original files were deleted.
* **Recovered**: found later in a backup, workspace or conversation.
* **Reconstructed / Modified / Unverified**: see `PROJECT_RECOVERY.md`.

All ten items below are **Original** evidence. Windows names screenshots
`Screenshot YYYY-MM-DD HHMMSS.png`, and in every case below that name matches the
file's creation and modification time, which supports (but does not prove) the
capture date.

| # | Copy in this folder | Original file (laptop) | Size (bytes) | MD5 | Pixels | Created / modified (IST) |
|---|---|---|---|---|---|---|
| 1 | `2026-02-21_vivado-block-design-with-axi-gpio.png` | `<user profile>\Pictures\Screenshots\Screenshot 2026-02-21 194657.png` | 81,624 | `1adcc4cb9b24422dc793686c6653d1a1` | 1564×641 | 2026-02-21 19:46:57 |
| 2 | `2026-02-21_matlab-uart-predictions-0-to-9.png` (**cropped copy**, see note) | `<user profile>\Pictures\Screenshots\Screenshot 2026-02-21 170356.png` | original 84,189 | original `abb99fb14ea0702a9e65601176e8320f` | original 1892×1079 | 2026-02-21 17:03:57 |
| 3 | `2026-02-21_sdk-cnn-interactive-jtag-fpga-configured.png` | `<user profile>\Pictures\Screenshots\Screenshot 2026-02-21 215724.png` | 202,845 | `1b9feffe8c6ec27e43ed9dc3b7ee3886` | 1920×1080 | 2026-02-21 21:57:24 |
| 4 | `2026-02-21_matlab-single-digit-misprediction-1-as-9.png` | `<user profile>\Pictures\Screenshots\Screenshot 2026-02-21 222120.png` | 36,936 | `7c61d2a50663dce81c0fa2659ee0bc86` | 1076×864 | 2026-02-21 22:21:20 |
| 5 | `2026-03-02_vivado-implemented-power-1.725W-xc7z020clg484.png` | `<user profile>\Pictures\Screenshots\Screenshot 2026-03-02 124514.png` | 218,085 | `edb9e709ed811afd9d0c7932e90467ea` | 1920×1080 | 2026-03-02 12:45:14 |
| 6 | `2026-03-03_vivado-behavioral-sim-tb_top_cnn-first-1us.png` (**cropped copy**, see note) | `<user profile>\Pictures\Screenshots\Screenshot 2026-03-03 224253.png` | original 156,220 | original `822886adacaa4f9e8e93e614f80ab9ca` | original 1920×1080 | 2026-03-03 22:42:53 |
| 7 | `2026-03-09_vivado-design-runs-zedboard-bitstream-complete.png` | `<user profile>\Pictures\Screenshots\Screenshot 2026-03-09 111537.png` | 168,671 | `d460850d15506c20178739a07f879e1f` | 1906×1038 | 2026-03-09 11:15:37 |
| 8 | `2026-03-21_mspaint-handwritten-input-4.png` | `<user profile>\Pictures\Screenshots\Screenshot 2026-03-21 121111.png` | 51,860 | `09f6f7c64108183354cfb749d9351a11` | 1377×729 | 2026-03-21 12:11:11 |
| 9 | `2026-03-21_matlab-single-digit-prediction-4.png` | `<user profile>\Pictures\Screenshots\Screenshot 2026-03-21 121152.png` | 20,287 | `7f474ab1e6be1eacacb9fe66e76ffcaf` | 1038×698 | 2026-03-21 12:11:52 |
| 10 | `2026-03-21_zedboard-powered-photo.jpeg` (**redacted copy**, see note) | `<user profile>\Documents\Downloads\fpga.jpeg` | original 304,800 | original `b7998daade269e2296058becd2cad8e7` | original 1280×1269 stored, EXIF orientation 8 (displays as 1269×1280) | modified 2026-03-21 12:24:15 (file created on this disk 2026-09-04; the only EXIF tag is orientation, with no camera or location data) |

**Note on item 2 (cropped public copy).** The original screenshot also shows an
unrelated web-chat window overlapping the bottom of the screen and that chat's
sidebar along the left edge. To keep that chat content out of the public
repository, the published file is a **crop** of the original, not a
byte-for-byte copy.

| | Original (laptop, unchanged) | Public copy in this folder |
|---|---|---|
| File | `Screenshot 2026-02-21 170356.png` | `2026-02-21_matlab-uart-predictions-0-to-9.png` |
| Size (bytes) | 84,189 | 50,547 |
| MD5 | `abb99fb14ea0702a9e65601176e8320f` | `d79e2bc6c40ad996ccc137ba91bf2a78` |
| Pixels | 1892×1079, RGBA | 1859×895, RGBA |

* Crop box in original pixel coordinates: left 33, top 0, right 1892, bottom 895
  (columns 33–1891, rows 0–894). This is exactly the MATLAB figure window,
  including its 1-pixel border. Columns 0–32 (chat sidebar) and rows 895–1078
  (chat input box) were discarded.
* The pixels inside the crop box are **identical** to the original (verified by a
  pixel-by-pixel comparison). Nothing was redrawn, resized, enhanced or
  annotated. The title, the "predict label / input image" panel and all ten
  "Predicted: 0" … "Predicted: 9" labels and digit images are as captured. The
  file was re-saved as PNG, so the bytes and hash differ from the original.
* The original's 2026-02-21 17:03:57 timestamps are given in the table above.
  The cropped copy was made on 2026-11-06.

**Note on item 6 (cropped public copy).** The original screenshot includes the
Windows taskbar (app icons, a messaging-app unread badge, clock and date).

| | Original (laptop, unchanged) | Public copy in this folder |
|---|---|---|
| File | `Screenshot 2026-03-03 224253.png` | `2026-03-03_vivado-behavioral-sim-tb_top_cnn-first-1us.png` |
| Size (bytes) | 156,220 | 117,355 |
| MD5 | `822886adacaa4f9e8e93e614f80ab9ca` | `4afa59b5e34e1509db8c28f1d723bba8` |
| Pixels | 1920×1080, RGBA | 1920×1020, RGBA |

* Crop box: left 0, top 0, right 1920, bottom 1020 (rows 0–1019, the full Vivado
  window). Rows 1020–1079 (the taskbar) were discarded. Pixels inside the box are
  identical to the original. Nothing was redrawn, resized or enhanced: the window
  title, signal names and values, waveforms and the 995–1,045 ns time axis are as
  captured. The file was re-saved as PNG (new bytes and hash).
* The taskbar clock showed the only on-screen date (03-03-2026). The capture date
  now rests on the original's file name and its 2026-03-03 22:42:53 timestamps.

**Note on item 10 (redacted public copy).** The original photo shows the board's
white barcode and serial-number sticker (below the "REV D" silkscreen, left of
the heatsink).

| | Original (laptop, unchanged) | Public copy in this folder |
|---|---|---|
| File | `fpga.jpeg` | `2026-03-21_zedboard-powered-photo.jpeg` |
| Size (bytes) | 304,800 | 581,023 |
| MD5 | `b7998daade269e2296058becd2cad8e7` | `0f708c329ea4ec3f6bc4ed0cb61664d2` |
| Pixels | 1280×1269 stored + EXIF orientation 8 | 1269×1280, no EXIF |

* The pixels were rotated according to the EXIF orientation tag, so the photo
  appears as before, and then all EXIF data was removed. The original's only
  EXIF tag was orientation; it contained no camera, date or GPS data.
* An opaque black rectangle covers the sticker: box left 236, top 646, right 438,
  bottom 711, in the rotated (display) coordinates. Nothing else was edited. The
  copy was re-encoded as JPEG (quality 95), which causes small compression
  differences elsewhere in the image.
* The separate round "QC.OK" inspection sticker has no serial number and was not
  redacted.

## What each item shows, and what it does / does not prove

1. **Block design with AXI GPIO.** Zynq PS7, AXI SmartConnect, AXI BRAM controller and Block Memory Generator, plus an **AXI GPIO** whose 32-bit output drives an `arm_gpio_in[31:0]` port on the `top_cnn_0` module reference; reset block `rst_ps7_0_50M`.
   *Proves:* the original work modified the reference design: it added a GPIO path from the ARM into the accelerator and an extra RTL port.
   *Note:* neither the AXI GPIO nor the `arm_gpio_in` port exists anywhere in this repository. The modified RTL, block design and XDC were lost when the original files were deleted.
2. **MATLAB figure "MNIST CNN (Predicted Labels & Input Images)" showing predictions 0–9 for the 10 stored test images.** This figure is drawn by `matlab/mlp_demo.m`, which reads the 10 results from a serial port (COM6, 115200 baud). In the original screenshot a Gemini web-chat window overlapped the bottom of the screen. It has been cropped out of the public copy (see the note above). Earlier screenshots the same day (13:46 and 15:11, not copied) show every prediction as `5` before the problem was fixed.
   *Supports:* end-to-end operation of the 10-image flow on 21 Feb 2026, with results received over UART. The screenshot alone cannot prove the UART data came from the FPGA rather than another source. Taken together with items 3 and 7 it is the strongest functional evidence available. It also shows that AI chat assistance (Gemini) was used while debugging the original project.
3. **Xilinx SDK, application `CNN_Interactive`.** `helloworld.c` includes `xuartps.h` and defines `GPIO_BASEADDR XPAR_AXI_GPIO_0_BASEADDR` with the comment "This is the address of the AXI GPIO block we just added in Vivado!". The SDK log reads: `Connected to target on host '127.0.0.1' and port '3121'`, `targets -set -filter {jtag_cable_name =~ "Digilent Zed …"}`, `FPGA configured successfully with bitstream "D:/SDK_Work/…"`.
   *Proves:* a physical ZedBoard was connected over JTAG and programmed with a bitstream on 21 Feb 2026 at 21:56. *Does not prove* which RTL version that bitstream contained.
4. **MATLAB "AI Prediction: 9" for an input that is clearly a handwritten "1".** Captured 25 minutes after item 3.
   *Shows:* the interactive single-digit flow was running but misclassified at least one input. It is kept deliberately as honest evidence that results were not perfect.
5. **Vivado 2019.1 Implemented Design power summary.** Project `MNIST_CNN_FPGA.xpr` in a project folder on the laptop's `D:` drive, part **xc7z020clg484-1** (ZedBoard part), `write_bitstream Complete`. Total on-chip power **1.725 W**: dynamic 1.582 W (PS7 1.399 W, DSP 0.074 W, logic 0.032 W, signals 0.044 W, clocks 0.029 W, BRAM 0.004 W), device static 0.143 W, confidence level **Low** (vectorless).
   *Proves:* the original project was implemented for the ZedBoard and gave this vectorless power estimate. It is the same 1.725 W shown in the final presentation. *Does not prove* any SADCG power reduction: no baseline-vs-SADCG comparison was found.
6. **Vivado behavioural simulation of `tb_top_cnn`** in the same project, cursor at 1,000 ns. The taskbar is cropped from the public copy (see the note above).
   *Proves:* behavioural simulation was set up and run in Vivado. *Does not show* a completed classification, because only the first 1 µs is visible.
7. **Vivado Project Summary + Design Runs.** Project part *ZedBoard Zynq Evaluation and Development Kit (xc7z020clg484-1)*, board part `em.avnet.com:zed:part0:1.4`. `impl_1`: *write_bitstream Complete!*, WNS **+4.532 ns**, TNS 0, WHS +0.015 ns, total power **1.725 W**, LUT **17,890**, FF **20,302**, BRAM **8.5**, DSP **160**, started 2/22/26 9:32 AM.
   *Proves:* the original implementation's resource and timing figures. These differ from the reference project's reports kept in `reports/` (Zybo part, 1.920 W) and from the numbers in the IEEE paper (see `docs/RECOVERY_REPORT.md`). The 160 DSPs match the unmodified reference architecture (150 PE multipliers + 10 FC MACs).
8. **MS Paint canvas with a hand-drawn "4"** (white on black).
9. **MATLAB "AI Prediction: 4"** showing the binarised 28×28 version of that drawing, captured 41 s after item 8.
   *Together (8, 9):* the single-digit demo used in the review presentation. *Does not prove* where the prediction was computed. The MATLAB/SDK code for this interactive flow was not recovered, so it cannot be confirmed whether the FPGA produced this result.
10. **Photo of a powered ZedBoard** (Avnet/Digilent, power LED and DONE LED lit; serial sticker redacted in the public copy). The original file is in the user's downloads folder (likely received via a messaging app). Its modification time, 21 Mar 2026 12:24, falls during the session of items 8–9.
    *Proves:* a ZedBoard was used and powered, and the DONE LED indicates it was configured. It does not show which design was loaded.

## Candidates reviewed but not copied

* Other project screenshots from 21 Feb – 21 Mar 2026 were reviewed visually and are summarised in `docs/RECOVERY_REPORT.md` §3. They include IP-upgrade and critical-warning dialogs, `$readmemh` path errors, BSP generation, the first "all predictions = 5" runs, a second ZedBoard lab project (`project_1`, unrelated), an IEEE-paper draft and further waveforms. They were not copied because they duplicate or add little to the items above.
* `results/*.jpg` previously in this repository (`vivado_power_report.jpg`, `vivado_simulation_waveform.jpg`, `ai_prediction_output_4.jpg`, `handwritten_input_digit_4.jpg`, `zynq_fpga_board_hardware.jpg`) were **extracted by Google Antigravity on 13 Sep 2026 from `docs/Final_Presentation.pdf`**. They are lower-resolution derivatives of items 5, 6, 8, 9 and 10 and were removed in favour of the originals. They remain in Git history (`git show d9b3d1f:results/<name>`).
* `results/methodology_block_diagram.jpg` (kept) is a slide from the March 2026 presentation. It is a **conceptual diagram of intent** (it shows a "SADCG controller") and not evidence of implementation.
* Two further images that Antigravity extracted from the presentation (a CNN-operations infographic and a "CNN-based Handwritten Digit Recognition on Zynq FPGA" flow picture) are AI-generated illustrations with garbled text. They were never in the repository and were not added.
* Excluded on privacy grounds: identity documents, personal photographs, and screenshots of unrelated web apps, chats and games found in the same folders.
