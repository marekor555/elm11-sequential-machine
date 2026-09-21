module top(
    input  logic pad_clk_27Mhz,
    input  logic button,
    output logic [5:0] pad_leds
);
    initial begin
        pad_leds =  6'b111111;
    end

    // logic [27:0] counter = 0;
    logic [5:0] counter = 0;

    logic btn = 0;


    // 011 -> set 001 -> toggle 010 -> OR 111 -> jmp 000 -> noop
    logic [8:0] commands[40] = '{
        0: 9'b011_101010, // set leds to 101010
        1: 9'b001_111111, // toggle all
        2: 9'b001_111111, // toggle all
        3: 9'b001_111111, // toggle all
        4: 9'b010_101010, // switch on 101010
        5: 9'b001_111111, // toggle all
        6: 9'b001_111111, // toggle all 
        7: 9'b001_111111, // toggle all 
        8: 9'b111_000000, // jump to start, useless because it requires if statements to be usefull
        default: 9'b00_000000
    };

    logic [24:0] clk = 0;

    logic [1:0] doop = 0;

    always_ff @(posedge pad_clk_27Mhz) begin
        btn <= button;
        clk <= clk+1;
        if ((btn == 1 && clk > 25'd6_750_000) || doop == 1) begin // if button isnt pressed and clock ticks (every 0.25s)
            clk <= 0;
            doop <= 0;
            if (counter != 39) begin 
                counter <= counter + 1;
            end
            case (commands[counter][8:6]) // check commands and execute the command
                3'b011: pad_leds <= ~(commands[counter][5:0]);
                3'b001: pad_leds <= ~(~pad_leds ^ commands[counter][5:0]);
                3'b010: pad_leds <= ~(~pad_leds | commands[counter][5:0]);
                3'b111: begin
                    counter <= commands[counter][5:0];
                    doop <= 1; // doop is made so jmp doesnt make execution wait a cycle to execute next command(it flows through)
                end
                default: pad_leds <= pad_leds;
            endcase
        end
    end
    
endmodule