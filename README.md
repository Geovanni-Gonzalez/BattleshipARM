# Battleship ARM

Proyecto de Batalla Naval desarrollado en Lenguaje Ensamblador ARM para Raspberry Pi (Raspbian).

## Descripción

Este programa implementa el clásico juego de mesa "Batalla Naval" (Battleship) en una interfaz de consola. El usuario compite contra una IA básica en un tablero de 10x10. Se incluye soporte para la colocación de barcos y un sistema de turnos.

## Requerimientos

- Hardware: Raspberry Pi o Emulador QEMU para ARM.
- SO: Linux (Raspbian recomendado).
- Herramientas: Ensamblador GNU (`as`) y Enlazador (`ld`).

## Estructura del Proyecto

- `start.s`: Punto de entrada (`_start`).
- `board.s`: Lógica del tablero.
- `ships.s`: Definición y gestión de barcos.
- `io.s`: Rutinas de entrada/salida (Syscalls).
- `data.s`: Secciones de datos y constantes.

## Compilación y Ejecución

1. Ensamblar: `as -o main.o start.s board.s ships.s io.s data.s`
2. Enlazar: `ld -o battleship main.o`
3. Ejecutar: `./battleship`
