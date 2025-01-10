module shiftRegRev #(
    parameter N = 8
)(
    input  wire clk,
    input  wire rstna,   // reset asíncrono activo en bajo
    input  wire ena,     // habilita desplazamiento
    output reg  [N-1:0] Q,
    output reg  TC       // pulso de 1 ciclo cuando Q llega a LSB
);

    // Dirección de desplazamiento: 1 => derecha, 0 => izquierda
    reg dir;
    always @(posedge clk or negedge rstna) begin
        if (!rstna) begin
            // Reset asíncrono
            // Registro inicializado a 1000...0 (bit MSB=1)
            Q   <= {1'b1, {N-1{1'b0}}};
            dir <= 1'b1;     // Suponemos que arrancamos moviéndonos a la derecha
            TC  <= 1'b0;
        end else begin
            // En cada flanco de subida del reloj
            // primero limpiamos TC (para que sea pulso)
            TC <= 1'b0;
            if (ena) begin
                // Revisamos si estamos en alguno de los extremos
                // para cambiar la dirección
                if (Q[N-1] == 1'b1 && dir == 1'b0) begin
                    // Si al movernos a la izquierda llegamos al MSB
                    // cambiamos dir a derecha
                    dir <= 1'b1;
                end else if (Q[0] == 1'b1 && dir == 1'b1) begin
                    // Si al movernos a la derecha llegamos al LSB
                    // cambiamos dir a izquierda
                    dir <= 1'b0;
                    // Señal TC se activa aquí
                    TC  <= 1'b1;
                end
                // Ahora desplazamos
                if (dir) begin
                    // Desplazamiento a la derecha
                    Q <= Q >> 1;
                end else begin
                    // Desplazamiento a la izquierda
                    Q <= Q << 1;
                end
            end
            // Si ena=0, no hacemos nada
        end
    end
    reg [15:0] contadorPeriodos; // ancho a convenir
    always @(posedge clk or negedge rstna) begin
        if (!rstna) begin
            contadorPeriodos <= 16'd0;
        end else begin
            if (TC) begin
                contadorPeriodos <= contadorPeriodos + 1;
            end
        end
    end

endmodule
