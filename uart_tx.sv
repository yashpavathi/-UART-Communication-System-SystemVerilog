module uart_tx #(parameter CLKS_PER_BIT = 5208) (
    input logic clk,
    input logic reset,
    input logic [7:0] data_in,
    input logic start,
    output logic tx
);
logic [1:0] state;

localparam IDLE = 2'b00;
localparam START = 2'b01;
localparam DATA = 2'b10;
localparam STOP = 2'b11;

logic [12:0] baud_counter;
logic [2:0] bit_counter;
logic [7:0] data_reg;

always_ff @(posedge clk) begin
   
   if (reset) begin
       state <=IDLE;
       baud_counter <= 13'd0;
       bit_counter <= 3'd0;
       data_reg <= 8'd0;
       tx <= 1'b1;
   end

   else begin
        case (state)
      
            IDLE:begin
                tx <= 1'b1;
      
                if(start) begin
                  data_reg <= data_in;
                  state <= START;
                  baud_counter <= 13'd0;
         end
      end
      
      START: begin
           tx <=1'b0;
           if(baud_counter == CLKS_PER_BIT - 1)
      begin
              baud_counter <= 13'd0;
              bit_counter <=3'd0;
              state <= DATA;
          end
          else begin
               baud_counter <= baud_counter + 1'b1;
          end
      end
      DATA: begin
         tx <= data_reg[bit_counter];

         if(baud_counter == CLKS_PER_BIT - 1)
      begin
            baud_counter <= 13'd0;
            if(bit_counter ==3'd7)
      begin
                state <=STOP;
            end
            else begin
                 bit_counter <= bit_counter + 1'b1;
            end
          end
          else begin
              baud_counter <= baud_counter + 1'b1;
          end
        end

        STOP: begin
            tx <= 1'b1;

            if (baud_counter ==CLKS_PER_BIT - 1)
        begin
                baud_counter <= 13'd0;
                state <= IDLE;
            end
            else begin
                 baud_counter <= baud_counter +1'b1;
            end
        end
        
        default: begin
            state <= IDLE;
            tx <= 1'b1;
        end
    endcase
   end
end
endmodule