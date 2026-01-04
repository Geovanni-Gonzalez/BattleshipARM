# Detalles de Diseño - Batalla Naval ARM

## Arquitectura Modular

El proyecto está dividido en módulos para facilitar el mantenimiento en ensamblador:

- `main.s`: Controla el flujo principal, menús y bucle de juego.
- `board.s`: Maneja el renderizado dinámico del tablero (soporta 10x10 a 20x20).
- `ships.s`: Lógica de colocación (H/V), detección de hundimiento y condiciones de victoria.
- `io.s`: Abstracción de syscalls de Linux (EABI).
- `utils.s`: Generador de números aleatorios (LCG) y persistencia de configuración.
- `data.s`: Estructuras de datos y buffers de tableros.

## Algoritmos Clave

### Colocación Vertical

Para la colocación vertical, el "salto" entre celdas no es `1`, sino el `current_map_size`. Esto permite que el mismo bucle de marcado funcione para ambas orientaciones simplemente cambiando el registro del paso.

### Persistencia (I/O de Archivos)

Se utilizan los syscalls `sys_open`, `sys_read` y `sys_write` para gestionar el archivo `config.bin`. Esto permite que el tamaño del mapa seleccionado perdure entre ejecuciones del programa.

### Notificación de Hundimiento

Cada celda del tablero almacena el ID del barco (1 a 5). Al atacar, se obtiene el ID de la celda. Si es un acierto, se marca como `50` (Hit) y se escanea el tablero buscando si aún queda el ID original. Si no quedan celdas con ese ID, se dispara la notificación de hundimiento.

### Condición de Victoria

Se realiza un escaneo exhaustivo de los tableros buscando cualquier valor en el rango `[1, 5]`. Si un tablero no posee ningún valor en ese rango, se declara la derrota de ese jugador.
