module shiftRegRev(CLK,RSTna,ENA,Q,TC);
	 parameter N = 8;
    input  wire            CLK;
    input  wire            RSTna;   // Reset asíncrono activo bajo
    input  wire            ENA;   // Habilitador síncrono activo alto
    output reg  [N-1:0]    Q;     // Registro one-hot
    output reg             TC;       // Terminal Count (pulso al llegar a LSB)

    // Dirección de desplazamiento:
    // 1 => desplazamiento a la derecha
    // 0 => desplazamiento a la izquierda
    reg direction;

    // Variables “next” para la lógica combinacional
    reg [N-1:0] nextQ;
    reg         nextDir;
    reg         nextTC;

    // Lógica combinacional
    always @* begin
        // Por defecto, mantenemos valores
        nextQ   = Q;
        nextDir = direction;
        nextTC  = 1'b0;

        if (ENA) begin
            // Desplazamos según la dirección actual
            if (direction)
                nextQ = Q >> 1;    // Desplazar a derechas
            else
                nextQ = Q << 1;    // Desplazar a izquierdas

            // Si el registro actual está en LSB = 1, hay que invertir dirección para la siguiente vez
            // (Ojo: Q == 1 implica el bit '1' ya en LSB)
            if (Q == 1) begin
                nextDir = 1'b0;   // cambiar a desplazamiento a izquierdas
                nextTC  = 1'b1;   // pulso TC de un ciclo
            end
            // Si el registro actual está en MSB = '1000...0'
            else if (Q == (1 << (N-1))) begin
                nextDir = 1'b1;   // cambiar a desplazamiento a derechas
            end
        end
        // Si ENA=0, no cambia nada, se mantiene el estado.
    end

    // Lógica secuencial síncrona al flanco de subida y RST asíncrono
    always @(posedge CLK or negedge RSTna) begin
        if (!RSTna) begin
            // Reset asíncrono: Q = 100...0, dirección = derecha, TC=0
            Q         <= (1 << (N-1));
            direction <= 1'b1;    // iniciamos desplazando a derechas
            TC        <= 1'b0;
        end
        else begin
            // Actualizamos registros con la lógica combinacional
            Q         <= nextQ;
            direction <= nextDir;
            TC        <= nextTC;
        end
    end

endmodule