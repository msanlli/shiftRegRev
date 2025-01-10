module shiftRegRev #(
    parameter N = 8,                // número de bits del registro
    parameter COUNTER_WIDTH = 8     // ancho del contador de periodos
)(
    input  wire clk,
    input  wire rstna,    // Reset asíncrono activo en bajo
    input  wire ena,      // Habilita desplazamiento
    output reg  [N-1:0]   Q,
    output reg            TC,       // Pulso cuando el '1' llega al LSB
    output reg  [COUNTER_WIDTH-1:0] period_count // Contador de rebotes
);

    // Dirección del desplazamiento: 1 => derecha, 0 => izquierda
    reg dir;

    // Bloque principal: controla registro Q, dirección y TC
    always @(posedge clk or negedge rstna) begin
        if (!rstna) begin
            // Reset asíncrono
            Q             <= {1'b1, {N-1{1'b0}}}; // 1000...0
            dir           <= 1'b1;               // empezar moviendo a la derecha
            TC            <= 1'b0;
            period_count  <= {COUNTER_WIDTH{1'b0}};
        end
        else begin
            // En cada flanco de subida del reloj
            // primero desactivamos TC (para que sea pulso de 1 ciclo)
            TC <= 1'b0;

            if (ena) begin
                // Verificamos si estamos en MSB o LSB para cambiar la dirección
                if (Q[N-1] == 1'b1 && dir == 1'b0) begin
                    // Si estamos en el MSB y vamos a la izquierda, rebota y va a la derecha
                    dir <= 1'b1;
                end
                else if (Q[0] == 1'b1 && dir == 1'b1) begin
                    // Si llegamos al LSB y estamos yendo a la derecha, rebota a la izquierda
                    dir <= 1'b0;

                    // Activamos TC en este ciclo
                    TC <= 1'b1;

                    // Cada vez que TC se active, incrementamos el contador de periodos
                    period_count <= period_count + 1'b1;
                end

                // Desplazamiento según dir
                if (dir) begin
                    // A la derecha
                    Q <= Q >> 1;
                end
                else begin
                    // A la izquierda
                    Q <= Q << 1;
                end
            end
            // Si ena=0, no hacemos nada, se queda quieto
        end
    end

endmodule
