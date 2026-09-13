`timescale 1ns / 1ps

module tb_top_cnn;

  // parameters for DUT
  localparam IN_IMG_NUM       = 10;
  localparam Y_BUF_DATA_WIDTH = 32;
  localparam Y_BUF_ADDR_WIDTH = 32;
  localparam RBAW             = $clog2(IN_IMG_NUM * 10);

  // testbench signals
  reg                        clk;
  reg                        rstn;
  reg                        start_i;
  wire                       done_intr_o;
  wire                       done_led_o;
  wire                       y_buf_en;
  wire                       y_buf_wr_en;
  wire [Y_BUF_ADDR_WIDTH-1:0] y_buf_addr;
  wire [Y_BUF_DATA_WIDTH-1:0] y_buf_data;

  // SADCG statistics
  integer result_count;
  reg [31:0] results [0:99]; // Store up to 100 results

  // Instantiate the DUT
  top_cnn dut (
    .clk           (clk),         // system clock
    .rst_n         (rstn),       // active-low reset
    .start_i       (start_i),     // start pulse

    .done_intr_o   (done_intr_o), // interrupt
    .done_led_o    (done_led_o),  // latched "all done"

    .y_buf_en      (y_buf_en),    // buffer enable pulse
    .y_buf_wr_en   (y_buf_wr_en), // buffer write enable
    .y_buf_addr    (y_buf_addr),  // aligned address
    .y_buf_data    (y_buf_data)   // classification result (0-9)
  );

  // Clock generation
  always #5 clk = ~clk; // 100MHz clock (period = 10ns)

  // ============================================================
  // SADCG Activity Monitoring
  // ============================================================
  // Count zero activations at the PE input (observable at top level)
  integer sadcg_conv_zero_count;
  integer sadcg_conv_total_count;
  integer sadcg_fc_zero_count;
  integer sadcg_fc_total_count;

  // Monitor Conv PE input for zero activations
  always @(posedge clk) begin
    if (rstn && dut.cnn_core.PE_en && dut.cnn_core.PE_valid_i) begin
      sadcg_conv_total_count = sadcg_conv_total_count + 6; // 6 rows per cycle
      if (dut.cnn_core.PE_data_in[0] == 12'sd0) sadcg_conv_zero_count = sadcg_conv_zero_count + 1;
      if (dut.cnn_core.PE_data_in[1] == 12'sd0) sadcg_conv_zero_count = sadcg_conv_zero_count + 1;
      if (dut.cnn_core.PE_data_in[2] == 12'sd0) sadcg_conv_zero_count = sadcg_conv_zero_count + 1;
      if (dut.cnn_core.PE_data_in[3] == 12'sd0) sadcg_conv_zero_count = sadcg_conv_zero_count + 1;
      if (dut.cnn_core.PE_data_in[4] == 12'sd0) sadcg_conv_zero_count = sadcg_conv_zero_count + 1;
      if (dut.cnn_core.PE_data_in[5] == 12'sd0) sadcg_conv_zero_count = sadcg_conv_zero_count + 1;
    end
  end

  // Monitor FC input for zero activations
  always @(posedge clk) begin
    if (rstn && dut.cnn_core.fc_en) begin
      sadcg_fc_total_count = sadcg_fc_total_count + 1;
      if (dut.cnn_core.FC_data == 12'sd0)
        sadcg_fc_zero_count = sadcg_fc_zero_count + 1;
    end
  end

  // Test sequence
  initial begin
      clk <= 1'b0;
      rstn <= 1'b1;
      start_i <= 1'b0;
      result_count = 0;
      sadcg_conv_zero_count = 0;
      sadcg_conv_total_count = 0;
      sadcg_fc_zero_count = 0;
      sadcg_fc_total_count = 0;

      // Reset
      #15 rstn <= 1'b0;
      #10 rstn <= 1'b1;

      // Start pulse
      #10 start_i <= 1'b1;
      #10 start_i <= 1'b0;

      // Wait until done_led_o is asserted
      wait(done_led_o == 1'b1);
      $display("==========================================================");
      $display("%% Simulation: processed all %0d images at time %0t ns", 10, $time);
      $display("==========================================================");

      // ========================================================
      // SADCG Results Report
      // ========================================================
      $display("");
      $display("============ SADCG STATISTICS ============");
      $display("  Conv PE activations checked : %0d", sadcg_conv_total_count);
      $display("  Conv PE zero activations    : %0d", sadcg_conv_zero_count);
      if (sadcg_conv_total_count > 0)
        $display("  Conv zero ratio             : %0d%%", (sadcg_conv_zero_count * 100) / sadcg_conv_total_count);
      $display("  FC   activations checked    : %0d", sadcg_fc_total_count);
      $display("  FC   zero activations       : %0d", sadcg_fc_zero_count);
      if (sadcg_fc_total_count > 0)
        $display("  FC   zero ratio             : %0d%%", (sadcg_fc_zero_count * 100) / sadcg_fc_total_count);
      $display("==========================================");
      $display("");

      // Report classification results
      $display("  Classification Results:");
      $display("  -----------------------");
      begin : RESULT_REPORT
        integer k;
        for (k = 0; k < result_count; k = k + 1)
          $display("    Image[%0d] -> predicted class: %0d", k, results[k]);
      end
      $display("");
      $display("  Total results captured: %0d", result_count);
      $display("==========================================================");

      #30;
      $finish;
  end

  // Monitor y_buf_data output and capture results
  always @(posedge clk) begin
      if (y_buf_en && y_buf_wr_en) begin
          $display("%% y_buf: addr=%0d, data=%0d at time %0t ns",
                    y_buf_addr, y_buf_data, $time);
          if (result_count < 100) begin
              results[result_count] = y_buf_data;
              result_count = result_count + 1;
          end
      end
  end

endmodule
