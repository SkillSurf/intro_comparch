module state_machine(
    input logic clk, rst_n, start,
    input logic signed [15:0] x_in,
    output logic signed [31:0] y_out,
    output logic done
    );
    
    typedef enum logic [2:0] {S_IDLE,S_ADD5, S_MUL3,S_SUB7,S_DONE} state_t;
    state_t state, next_state;
    logic signed [31:0] temp;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // state machine logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            temp  <= 0;
            y_out  <= 0;
        end else begin
            case (state)
                S_IDLE: temp <= start ? x_in : temp;
                S_ADD5: temp <= temp + 5;
                S_MUL3: temp <= temp * 3;
                S_SUB7: y_out <= temp - 7;
                default: ;
            endcase
        end
    end

    // Controlling the state transitions
    always_comb begin
        next_state = state;
        done = 1'b0;
        case (state)
            S_IDLE:  next_state = start ? S_ADD5 : S_IDLE;
            S_ADD5:  next_state = S_MUL3;
            S_MUL3:  next_state = S_SUB7;
            S_SUB7:  next_state = S_DONE;
            S_DONE: begin
                done = 1'b1;
                next_state = S_IDLE;
            end
            default: next_state = S_IDLE;
        endcase
    end
endmodule
