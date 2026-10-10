`timescale 1ns/1ps

module uart_loopback_tb;

    logic clk;
    logic reset;
    logic [7:0] data_in;
    logic start;

    logic tx;
    logic [7:0] data_out;
    logic done;

    logic done_seen;

    uart_tx tx_inst (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .start(start),
        .tx(tx)
    );

    uart_rx rx_inst (
        .clk(clk),
        .reset(reset),
        .rx(tx),
        .data_out(data_out),
        .done(done)
    );

    always #10 clk = ~clk;

    // Capture the DONE event
    always @(posedge done) begin
        done_seen = 1'b1;
    end

    initial begin
        $dumpfile("uart_loopback.vcd");
        $dumpvars(0, uart_loopback_tb);

        clk = 0;
        reset = 1;
        data_in = 8'b01010101;
        start = 0;
        done_seen = 0;

        #100;
        reset = 0;

        #100;
        start = 1;

        #20;
        start = 0;

        // Wait for receiver to complete
        wait(done_seen);

        #1;

        $display("TX Data      = %b", data_in);
        $display("RX Data      = %b", data_out);
        $display("RX Done Seen = %b", done_seen);

        if (data_in == data_out && done_seen == 1'b1)
            $display("UART LOOPBACK TEST PASSED");
        else
            $display("UART LOOPBACK TEST FAILED");

        #100;
        $finish;
    end

endmodule