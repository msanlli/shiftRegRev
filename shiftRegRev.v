module shiftRegRev #(
    parameter N = 8,
    parameter COUNTER_WIDTH = 8
)(
    input  wire clk,
    input  wire rstna,    // Reset asíncrono activo en bajo
    input  wire ena,      // Habilita desplazamiento
    output reg  [N-1:0] Q,
    output reg           TC,          // Pulso cuando el '1' llega al LSB
    output reg  [COUNTER_WIDTH-1:0] period_count
);

    // Dirección del desplazamiento: 1 => derecha, 0 => izquierda
    reg dir;

    always @(posedge clk or negedge rstna) begin
        if (!rstna) begin
            // --- ASYNC RESET ---
            Q             <= {1'b1, {N-1{1'b0}}}; // 1000...0
            dir           <= 1'b1;               // Empezar moviendo a la derecha
            TC            <= 1'b0;
            period_count  <= {COUNTER_WIDTH{1'b0}};
        end
        else begin
            // Por defecto, cada ciclo ponemos TC = 0, a menos que lo vayamos a activar
            TC <= 1'b0;

            if (ena) begin
                // 1) Primero: Checamos si estamos en un extremo para “rebotar”
                //    Si Q[1] == 1'b1 y dir == 1'b1 => llegamos a LSB en el próximo desplazamiento
                if (Q[1] == 1'b1 && dir == 1'b1) begin
                    dir <= 1'b0;           // Rebota a la izquierda
                    TC  <= 1'b1;          // Activa pulso de un ciclo
                    period_count <= period_count + 1'b1;  // Incrementa contador de periodos
                end
                //    Si Q[N-2] == 1 y dir == 0 => estamos en la posición MSB-1 yendo a la izquierda
                else if (Q[N-2] == 1'b1 && dir == 1'b0) begin
                    dir <= 1'b1;           // Rebota a la derecha
                end

                // 2) Segundo: Realizamos el desplazamiento con la dirección actualizada
                if (dir) begin
                    // Desplazamiento a la derecha
                    Q <= Q >> 1;
                end
                else begin
                    // Desplazamiento a la izquierda
                    Q <= Q << 1;
                end
            end
            // Si ena=0, se congela el contenido
        end
    end

endmodule
