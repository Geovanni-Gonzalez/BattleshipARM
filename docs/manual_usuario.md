# Manual de Usuario - Batalla Naval ARM

## Introducción

Este es un juego de Batalla Naval desarrollado íntegramente en Ensamblador ARM. Permite jugar contra la IA o contra otro jugador en la misma consola.

## Requisitos

- Emulador QEMU (para ARM) o una Raspberry Pi.
- Herramientas `as` y `ld` (cross-compiler `arm-linux-gnueabihf` recomendado).

## Ejecución

1. **Compilar**:

   ```bash
   arm-linux-gnueabihf-as -o main.o main.s board.s ships.s io.s utils.s data.s
   ```

2. **Enlazar**:

   ```bash
   arm-linux-gnueabihf-ld -o battleship main.o
   ```

3. **Correr**:

   ```bash
   qemu-arm -L /usr/arm-linux-gnueabihf ./battleship
   ```

## Cómo Jugar

1. **Configuración de Mapa**:
   - Selecciona entre el mapa estándar (10x10) o uno personalizado (hasta 20x20).
   - El tamaño se guardará automáticamente para futuras partidas.
2. **Selección de Modo**:
   - **[1] Jugador Vs IA**: Compite contra la computadora.
   - **[2] Jugador vs Jugador**: Turnos manuales en la misma pantalla.
3. **Colocación de Barcos**:
   - Ingresa la coordenada (ej. `B4`).
   - Elige orientación: `H` para Horizontal, `V` para Vertical.
4. **Fase de Ataque**:
   - Ingresa la coordenada de tu ataque.
   - Si aciertas un barco enemigo, verás una `X` en el tablero de rastreo.
   - Si fallas, verás un `*`.
   - El juego te notificará cuando hundas un barco específico (ej. "¡HUNDIDO! Portaaviones").
5. **Victoria**: El juego termina cuando un bando pierde todos sus barcos.
