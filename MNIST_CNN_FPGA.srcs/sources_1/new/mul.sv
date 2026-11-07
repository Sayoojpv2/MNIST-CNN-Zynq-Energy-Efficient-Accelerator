module mul (
	input wire clk_i,
	input wire rstn_i,
	input wire valid_i,
	(* keep *) input wire signed [11:0] data_i,
	(* keep *) input wire signed [7:0] weight_i,
	(* keep *) output reg signed [19:0] result
);

	// ============================================================
	// SADCG: Sparsity-Aware Dynamic Clock Gating
	// ============================================================
	// Detect zero activation (ReLU-induced or natural zero pixels).
	// When activation == 0, the product is always 0 regardless of
	// weight, so we skip the DSP multiply to reduce switching.
	//
	// AUDIT NOTE (2026-11, see docs/RECOVERY_REPORT.md): the original claim
	// here was "compute_en maps to DSP48E1 CEM/CEP; when CE=0 the DSP
	// registers hold value -> no toggle". That is NOT what this RTL does.
	// The else-branch below loads 0 into `result`, which is exactly the
	// value 0*weight would have produced, so the register sequence is
	// identical to the ungated code (verified: identical VCD toggle counts
	// over the 10-image testbench). This is an assignment, not a hold, so
	// no clock-enable is implied. This file is also NOT in the Vivado
	// project source set (MNIST_CNN_FPGA.xpr uses imports/cnn/mul.v).
	// No synthesis or power analysis has been run on this version.
	// ============================================================
	wire activation_zero = (data_i == 12'sd0);
	wire compute_en      = valid_i & ~activation_zero;

	always @(posedge clk_i)
		if (!rstn_i)
			result <= 20'h00000;
		else if (compute_en)
			result <= $signed(data_i) * $signed(weight_i);
		else
			result <= 20'h00000;

	// ============================================================
	// Simulation-only statistics (not synthesized)
	// ============================================================
	// synthesis translate_off
	reg [31:0] sadcg_total_valid;
	reg [31:0] sadcg_gated_cycles;
	always @(posedge clk_i)
		if (!rstn_i) begin
			sadcg_total_valid  <= 32'd0;
			sadcg_gated_cycles <= 32'd0;
		end else if (valid_i) begin
			sadcg_total_valid  <= sadcg_total_valid + 32'd1;
			if (activation_zero)
				sadcg_gated_cycles <= sadcg_gated_cycles + 32'd1;
		end
	// synthesis translate_on

endmodule
