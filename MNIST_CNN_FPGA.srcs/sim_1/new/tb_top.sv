`timescale 1ns / 1ps

module tb_top();

    reg clk;
    reg rstn;
    reg start_i;

    wire done_intr_o;
    wire done_led_o;
    wire y_buf_en;
    wire y_buf_wr_en;
    wire [31:0] y_buf_addr;
    wire [31:0] y_buf_data;

    // SADCG statistics
    integer result_count;
    reg [31:0] results [0:99];

    // Instantiate DUT
    top #(
        .IN_IMG_NUM(10),
        .X_BUF_DATA_WIDTH(8),
        .X_BUF_DEPTH(7840),
        .W_BUF_DATA_WIDTH(40),
        .W_BUF_DEPTH(20),
        .Y_BUF_DATA_WIDTH(32),
        .Y_BUF_ADDR_WIDTH(32),
        .Y_BUF_DEPTH(400)
    ) top_dut (
        .clk_i          (clk),
        .rstn_i         (rstn),
        .start_i        (start_i),
        .done_intr_o    (done_intr_o),
        .done_led_o     (done_led_o),
        .y_buf_en       (y_buf_en),
        .y_buf_wr_en    (y_buf_wr_en),
        .y_buf_addr     (y_buf_addr),
        .y_buf_data     (y_buf_data)
    );

    // Clock generation
    always #5 clk = ~clk; // 100MHz clock (period = 10ns)

    // ============================================================
    // SADCG Activity Monitoring
    // ============================================================
    integer sadcg_conv_zero_count;
    integer sadcg_conv_total_count;
    integer sadcg_fc_zero_count;
    integer sadcg_fc_total_count;

    // Monitor Conv PE input for zero activations
    always @(posedge clk) begin
      if (rstn && top_dut.PE_en && top_dut.PE_valid_i) begin
        sadcg_conv_total_count = sadcg_conv_total_count + 6;
        if (top_dut.PE_data_in[0] == 12'sd0) sadcg_conv_zero_count = sadcg_conv_zero_count + 1;
        if (top_dut.PE_data_in[1] == 12'sd0) sadcg_conv_zero_count = sadcg_conv_zero_count + 1;
        if (top_dut.PE_data_in[2] == 12'sd0) sadcg_conv_zero_count = sadcg_conv_zero_count + 1;
        if (top_dut.PE_data_in[3] == 12'sd0) sadcg_conv_zero_count = sadcg_conv_zero_count + 1;
        if (top_dut.PE_data_in[4] == 12'sd0) sadcg_conv_zero_count = sadcg_conv_zero_count + 1;
        if (top_dut.PE_data_in[5] == 12'sd0) sadcg_conv_zero_count = sadcg_conv_zero_count + 1;
      end
    end

    // Monitor FC input for zero activations
    always @(posedge clk) begin
      if (rstn && top_dut.fc_en) begin
        sadcg_fc_total_count = sadcg_fc_total_count + 1;
        if (top_dut.FC_data == 12'sd0)
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

        // SADCG Report
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

        // Report results
        $display("");
        $display("  Classification Results:");
        begin : RESULT_REPORT
          integer k;
          for (k = 0; k < result_count; k = k + 1)
            $display("    Image[%0d] -> predicted class: %0d", k, results[k]);
        end
        $display("  Total results: %0d", result_count);
        $display("==========================================================");

        #30;
        $finish;
    end

    // Monitor y_buf_data output
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
