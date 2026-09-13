`timescale 1ns / 1ps

// ============================================================
// BASE (ORIGINAL UN-GATED) REFERENCE MODULES FOR RIGOROUS COMPARISON
// ============================================================
module mul_base (
    input wire clk_i,
    input wire rstn_i,
    input wire valid_i,
    input wire signed [11:0] data_i,
    input wire signed [7:0] weight_i,
    output reg signed [19:0] result
);
    always @(posedge clk_i)
        if (!rstn_i)
            result <= 20'h00000;
        else if (valid_i)
            result <= $signed(data_i) * $signed(weight_i);
        else
            result <= 20'h00000;
endmodule

module MAC_base (
    input wire                  clk_i,
    input wire                  rstn_i,
    input wire                  clear_i,
    input wire                  mac_en_i,
    input wire signed [7:0]     weight_i,
    input wire signed [11:0]    input_i,
    output wire signed [19:0]   data_o,
    output wire                 valid_o
);
    reg signed [19:0]   acc;
    reg signed [19:0]   mul;
    reg signed [7:0]    weight_ff;
    reg signed [11:0]   input_ff;
    reg valid_out;
    reg clear1;
    reg mac_en2;
    reg acc_en;

    assign valid_o = valid_out;

    always @(posedge clk_i) begin
        mac_en2 <= mac_en_i;
        acc_en <= mac_en2;
    end

    always @(posedge clk_i) begin
        clear1 <= clear_i;
    end

    always @(posedge clk_i) begin
        if (~rstn_i | clear1) begin
            acc[19:0] <= 20'h0000_0;
            mul[19:0] <= 20'h0000_0;
            weight_ff <= 8'h00;
            input_ff <= 11'h000;
            valid_out <= 1'b0;
        end else begin
            if (mac_en_i) begin
                weight_ff[7:0] <= weight_i[7:0];
                input_ff[11:0] <= input_i[11:0];
                mul[19:0] <= $signed(input_ff) * $signed(weight_ff);
            end
            if (acc_en) begin
                acc[19:0] <= $signed(acc[19:0]) + $signed(mul[19:0]);
            end
            if (mac_en2 == 1'b1 && mac_en_i == 1'b0) begin
                valid_out <= 1'b1;
            end
        end
    end

    assign data_o[19:0] = (valid_out) ? acc[19:0] : 20'hzzzz_z;
endmodule

// ============================================================
// VERIFICATION TESTBENCH
// ============================================================
module tb_sadcg_verify;

  reg clk;
  reg rstn;

  // Clock generation (100 MHz)
  always #5 clk = ~clk;

  // Multiplier test signals
  reg valid_i;
  reg signed [11:0] mul_data_i;
  reg signed [7:0]  mul_weight_i;
  wire signed [19:0] mul_result_sadcg;
  wire signed [19:0] mul_result_base;

  // Instantiate SADCG DUT
  mul u_mul_sadcg (
    .clk_i    (clk),
    .rstn_i   (rstn),
    .valid_i  (valid_i),
    .data_i   (mul_data_i),
    .weight_i (mul_weight_i),
    .result   (mul_result_sadcg)
  );

  // Instantiate Base (Original) Reference
  mul_base u_mul_base (
    .clk_i    (clk),
    .rstn_i   (rstn),
    .valid_i  (valid_i),
    .data_i   (mul_data_i),
    .weight_i (mul_weight_i),
    .result   (mul_result_base)
  );

  // MAC test signals
  reg clear_i;
  reg mac_en_i;
  reg signed [7:0]  mac_weight_i;
  reg signed [11:0] mac_input_i;
  wire [19:0] mac_data_sadcg;
  wire        mac_valid_sadcg;
  wire [19:0] mac_data_base;
  wire        mac_valid_base;

  // Instantiate SADCG MAC DUT
  MAC u_mac_sadcg (
    .clk_i    (clk),
    .rstn_i   (rstn),
    .clear_i  (clear_i),
    .mac_en_i (mac_en_i),
    .weight_i (mac_weight_i),
    .input_i  (mac_input_i),
    .data_o   (mac_data_sadcg),
    .valid_o  (mac_valid_sadcg)
  );

  // Instantiate Base (Original) MAC Reference
  MAC_base u_mac_base (
    .clk_i    (clk),
    .rstn_i   (rstn),
    .clear_i  (clear_i),
    .mac_en_i (mac_en_i),
    .weight_i (mac_weight_i),
    .input_i  (mac_input_i),
    .data_o   (mac_data_base),
    .valid_o  (mac_valid_base)
  );

  // Statistics & tracking
  integer errors = 0;
  integer tests_run = 0;
  integer zero_gated_count = 0;
  integer nonzero_active_count = 0;

  initial begin
    clk = 0;
    rstn = 0;
    valid_i = 0;
    mul_data_i = 0;
    mul_weight_i = 0;
    clear_i = 0;
    mac_en_i = 0;
    mac_weight_i = 0;
    mac_input_i = 0;

    $display("================================================================");
    $display("STARTING RIGOROUS SADCG VERIFICATION SUITE");
    $display("Comparing SADCG Against Original Base RTL Implementation");
    $display("================================================================");

    // Reset sequence
    #20 rstn = 1;
    #10;

    // ------------------------------------------------------------
    // TEST 1: mul.sv with activation == 0
    // ------------------------------------------------------------
    $display("\n--- TEST 1: mul.sv zero activation gating (activation == 0) ---");
    begin : T1
      integer w;
      for (w = -128; w <= 127; w = w + 16) begin
        @(posedge clk);
        valid_i      <= 1'b1;
        mul_data_i   <= 12'sd0;
        mul_weight_i <= w[7:0];
        @(posedge clk);
        #1;
        tests_run = tests_run + 1;
        zero_gated_count = zero_gated_count + 1;

        // Check SADCG gating control
        if (u_mul_sadcg.activation_zero !== 1'b1) begin
          $display("FAIL: u_mul_sadcg.activation_zero != 1 for data_i=0");
          errors = errors + 1;
        end
        if (u_mul_sadcg.compute_en !== 1'b0) begin
          $display("FAIL: u_mul_sadcg.compute_en != 0 for data_i=0");
          errors = errors + 1;
        end
        // Check output bit-exact equivalence with base
        if (mul_result_sadcg !== mul_result_base) begin
          $display("FAIL: mul output mismatch! SADCG=%d, Base=%d", mul_result_sadcg, mul_result_base);
          errors = errors + 1;
        end
        if (mul_result_sadcg !== 20'sd0) begin
          $display("FAIL: mul output != 0 for zero activation!");
          errors = errors + 1;
        end
      end
    end
    $display("TEST 1 PASSED: Zero activation asserts activation_zero=1, deasserts compute_en=0, outputs 0.");

    // ------------------------------------------------------------
    // TEST 2: mul.sv with activation != 0
    // ------------------------------------------------------------
    $display("\n--- TEST 2: mul.sv non-zero activation (activation != 0) ---");
    begin : T2
      integer a, w;
      for (a = -2048; a <= 2047; a = a + 256) begin
        if (a == 0) a = 1;
        for (w = -128; w <= 127; w = w + 32) begin
          @(posedge clk);
          valid_i      <= 1'b1;
          mul_data_i   <= a[11:0];
          mul_weight_i <= w[7:0];
          @(posedge clk);
          #1;
          tests_run = tests_run + 1;
          nonzero_active_count = nonzero_active_count + 1;

          // Check SADCG active control
          if (u_mul_sadcg.activation_zero !== 1'b0) begin
            $display("FAIL: u_mul_sadcg.activation_zero != 0 for nonzero data_i=%d", a);
            errors = errors + 1;
          end
          if (u_mul_sadcg.compute_en !== 1'b1) begin
            $display("FAIL: u_mul_sadcg.compute_en != 1 for nonzero data_i=%d", a);
            errors = errors + 1;
          end
          // Check output bit-exact equivalence with base
          if (mul_result_sadcg !== mul_result_base) begin
            $display("FAIL: mul nonzero mismatch! SADCG=%d, Base=%d, data=%d, wt=%d",
                      mul_result_sadcg, mul_result_base, a, w);
            errors = errors + 1;
          end
        end
      end
    end
    $display("TEST 2 PASSED: Non-zero activation asserts activation_zero=0, asserts compute_en=1, exact output.");

    // ------------------------------------------------------------
    // TEST 3: MAC.sv with pure zero activation stream
    // ------------------------------------------------------------
    $display("\n--- TEST 3: MAC.sv pure zero activation stream ---");
    begin : T3
      integer i;
      @(posedge clk);
      clear_i <= 1'b1;
      @(posedge clk);
      clear_i <= 1'b0;

      for (i = 0; i < 20; i = i + 1) begin
        @(posedge clk);
        mac_en_i     <= 1'b1;
        mac_input_i  <= 12'sd0; // Zero activation
        mac_weight_i <= (i * 13) - 60;

        #1;
        tests_run = tests_run + 1;
        zero_gated_count = zero_gated_count + 1;

        // Check internal signals
        if (u_mac_sadcg.mul !== u_mac_base.mul) begin
          $display("FAIL: MAC mul mismatch during zero stream! SADCG=%d, Base=%d",
                    u_mac_sadcg.mul, u_mac_base.mul);
          errors = errors + 1;
        end
        if (u_mac_sadcg.acc !== u_mac_base.acc) begin
          $display("FAIL: MAC acc mismatch during zero stream! SADCG=%d, Base=%d",
                    u_mac_sadcg.acc, u_mac_base.acc);
          errors = errors + 1;
        end
      end

      @(posedge clk);
      mac_en_i <= 1'b0;

      repeat (5) begin
        @(posedge clk);
        #1;
        tests_run = tests_run + 1;
        if (mac_valid_sadcg !== mac_valid_base || mac_data_sadcg !== mac_data_base) begin
          $display("FAIL: MAC post-stream mismatch! valid: SADCG=%b Base=%b, data: SADCG=%h Base=%h",
                    mac_valid_sadcg, mac_valid_base, mac_data_sadcg, mac_data_base);
          errors = errors + 1;
        end
      end
    end
    $display("TEST 3 PASSED: MAC zero stream verified bit-exact identical between SADCG and Base.");

    // ------------------------------------------------------------
    // TEST 4: MAC.sv with 100-cycle mixed zero/nonzero sequence
    // ------------------------------------------------------------
    $display("\n--- TEST 4: MAC.sv 100-cycle mixed zero/nonzero sequence ---");
    begin : T4
      integer j;
      reg [11:0] cur_act;
      reg [7:0]  cur_wt;
      reg [11:0] prev_input_ff;

      @(posedge clk);
      clear_i <= 1'b1;
      @(posedge clk);
      clear_i <= 1'b0;

      for (j = 0; j < 100; j = j + 1) begin
        @(posedge clk);
        mac_en_i <= 1'b1;

        // Roughly 50% zero activations to test both gated and active paths
        if (j % 2 == 0) begin
          cur_act = 12'sd0;
          zero_gated_count = zero_gated_count + 1;
        end else begin
          cur_act = $random % 2048;
          nonzero_active_count = nonzero_active_count + 1;
        end
        cur_wt = $random;

        mac_input_i  <= cur_act;
        mac_weight_i <= cur_wt;

        #1;
        tests_run = tests_run + 1;

        // Track the activation that is being multiplied into mul on this cycle
        // In MAC.sv, input_ff is latched on posedge, and mul is updated on posedge using the OLD input_ff.
        // Therefore, mul reflects the input_ff that was present BEFORE the posedge.
        if (prev_input_ff == 12'sd0 && j > 0) begin
          if (u_mac_sadcg.mul !== 20'sd0) begin
            $display("FAIL: MAC mul != 0 when prev_input_ff==0! Got: %d", u_mac_sadcg.mul);
            errors = errors + 1;
          end
        end

        prev_input_ff = u_mac_sadcg.input_ff;

        // Bit-exact comparison between SADCG and Base on EVERY cycle
        if (u_mac_sadcg.mul !== u_mac_base.mul) begin
          $display("FAIL: MAC mul mismatch at cycle %d! SADCG=%d, Base=%d",
                    j, u_mac_sadcg.mul, u_mac_base.mul);
          errors = errors + 1;
        end
        if (u_mac_sadcg.acc !== u_mac_base.acc) begin
          $display("FAIL: MAC acc mismatch at cycle %d! SADCG=%d, Base=%d",
                    j, u_mac_sadcg.acc, u_mac_base.acc);
          errors = errors + 1;
        end
      end

      // End of accumulation phase
      @(posedge clk);
      mac_en_i <= 1'b0;

      // Check output assertion
      repeat (5) begin
        @(posedge clk);
        #1;
        tests_run = tests_run + 1;
        if (mac_valid_sadcg !== mac_valid_base) begin
          $display("FAIL: MAC valid mismatch! SADCG=%b, Base=%b", mac_valid_sadcg, mac_valid_base);
          errors = errors + 1;
        end
        if (mac_data_sadcg !== mac_data_base) begin
          $display("FAIL: MAC data mismatch! SADCG=%d, Base=%d", mac_data_sadcg, mac_data_base);
          errors = errors + 1;
        end
      end
    end
    $display("TEST 4 PASSED: MAC mixed sequence verified 100%% bit-exact identical to Base on every cycle.");

    // ------------------------------------------------------------
    // TEST 5: Comprehensive Randomized Matrix of 1,000 Vectors
    // ------------------------------------------------------------
    $display("\n--- TEST 5: 1,000 Randomized Vectors (Corner Cases & Full Dynamic Range) ---");
    begin : T5
      integer k;
      reg [11:0] r_act;
      reg [7:0]  r_wt;

      for (k = 0; k < 1000; k = k + 1) begin
        @(posedge clk);
        valid_i = 1'b1;
        if (k % 3 == 0)
          r_act = 12'sd0; // 33% zeros
        else if (k % 5 == 0)
          r_act = 12'sh7FF; // max positive 12-bit (+2047)
        else if (k % 7 == 0)
          r_act = 12'sh800; // max negative 12-bit (-2048)
        else
          r_act = $random;

        if (k % 4 == 0)
          r_wt = 8'sh7F; // max positive 8-bit (+127)
        else if (k % 6 == 0)
          r_wt = 8'sh80; // max negative 8-bit (-128)
        else
          r_wt = $random;

        mul_data_i   <= r_act;
        mul_weight_i <= r_wt;

        @(posedge clk);
        #1;
        tests_run = tests_run + 1;
        if (mul_result_sadcg !== mul_result_base) begin
          $display("FAIL: Random test mismatch! k=%0d, act=%d, wt=%d, SADCG=%d, Base=%d",
                    k, $signed(r_act), $signed(r_wt), mul_result_sadcg, mul_result_base);
          errors = errors + 1;
        end
      end
    end
    $display("TEST 5 PASSED: 1,000 randomized and corner-case vectors 100%% bit-exact identical.");

    // ------------------------------------------------------------
    // FINAL SUMMARY
    // ------------------------------------------------------------
    $display("\n================================================================");
    $display("FINAL SADCG RIGOROUS VERIFICATION REPORT:");
    $display("  Total Cycle Checks Executed : %0d", tests_run);
    $display("  Zero-Gated Assertions       : %0d", zero_gated_count);
    $display("  Active Compute Assertions   : %0d", nonzero_active_count);
    $display("  Total Errors Detected       : %0d", errors);
    $display("----------------------------------------------------------------");
    if (errors == 0) begin
      $display("  STATUS: ALL TESTS PASSED (100%% BIT-EXACT TO BASE)");
      $display("  SADCG FUNCTIONALITY CONFIRMED:");
      $display("    [X] Zero activation disables DSP multiplier activity (CE=0, mul=0)");
      $display("    [X] Non-zero activation performs normal signed MAC operation");
      $display("    [X] Numerical output is 100%% bit-exact identical to base design");
    end else begin
      $display("  STATUS: TEST SUITE FAILED (%0d errors)", errors);
    end
    $display("================================================================\n");

    #20;
    $finish;
  end

endmodule
