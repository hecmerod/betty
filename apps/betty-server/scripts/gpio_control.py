#!/usr/bin/env python3
"""
Simple GPIO control script using gpiod library (v2 API).
Usage: 
  python gpio_control.py set <pin> <1|0>
  python gpio_control.py get <pin>
  python gpio_control.py configure <pin> <input|output> [initial_value]
  python gpio_control.py info <pin>
  python gpio_control.py release <pin>
  python gpio_control.py watch <pin>
"""
import sys
import gpiod
from gpiod.line import Direction, Value, Edge, Bias

CHIP_PATH = '/dev/gpiochip0'

def set_pin(pin: int, value: int):
    """Set GPIO pin to HIGH (1) or LOW (0)"""
    with gpiod.request_lines(
        CHIP_PATH,
        consumer="betty-server",
        config={pin: gpiod.LineSettings(direction=Direction.OUTPUT, output_value=Value(value))}
    ) as request:
        print(f"Pin {pin} set to {'HIGH' if value else 'LOW'}")

def get_pin(pin: int):
    """Read GPIO pin state"""
    with gpiod.request_lines(
        CHIP_PATH,
        consumer="betty-server",
        config={pin: gpiod.LineSettings(direction=Direction.INPUT)}
    ) as request:
        value = request.get_value(pin)
        print(1 if value == Value.ACTIVE else 0)

def configure_pin(pin: int, direction: str, initial_value: int = 0):
    """Configure GPIO pin direction and initial value"""
    dir_enum = Direction.OUTPUT if direction.lower() == 'output' else Direction.INPUT
    
    if dir_enum == Direction.OUTPUT:
        with gpiod.request_lines(
            CHIP_PATH,
            consumer="betty-server",
            config={pin: gpiod.LineSettings(direction=dir_enum, output_value=Value(initial_value))}
        ) as request:
            print(f"Pin {pin} configured as OUTPUT with initial value {'HIGH' if initial_value else 'LOW'}")
    else:
        with gpiod.request_lines(
            CHIP_PATH,
            consumer="betty-server",
            config={pin: gpiod.LineSettings(direction=dir_enum)}
        ) as request:
            print(f"Pin {pin} configured as INPUT")

def get_pin_info(pin: int):
    """Get GPIO pin information"""
    chip = gpiod.Chip(CHIP_PATH)
    info = chip.get_line_info(pin)
    
    direction = "OUTPUT" if info.direction == Direction.OUTPUT else "INPUT"
    consumer = info.consumer if info.consumer else "None"
    used = "used" if info.used else "free"
    
    print(f"{direction}|{consumer}|{used}")

def release_pin(pin: int):
    """Release GPIO pin (free it from any consumer)"""
    # En gpiod v2, los pines se liberan automáticamente cuando se cierra el request
    # No hay una forma directa de "forzar" la liberación de un pin usado por otro proceso
    # Pero podemos verificar si está en uso
    chip = gpiod.Chip(CHIP_PATH)
    info = chip.get_line_info(pin)
    
    if info.used:
        print(f"Warning: Pin {pin} is currently in use by '{info.consumer}'. Cannot force release from another process.")
        print(f"The pin will be automatically released when the consumer process ends.")
        sys.exit(1)
    else:
        print(f"Pin {pin} is already free (not in use)")

def watch_pin(pin: int):
    """Watch for changes on a GPIO input pin"""
    with gpiod.request_lines(
        CHIP_PATH,
        consumer="betty-server-watch",
        config={
            pin: gpiod.LineSettings(
                direction=Direction.INPUT,
                edge_detection=Edge.BOTH,  # Detectar tanto rising como falling edges
                bias=Bias.PULL_UP  # Activar pull-up resistor interno
            )
        }
    ) as request:
        # Leer el valor inicial para evitar eventos falsos
        initial_value = request.get_value(pin)
        last_value = initial_value
        
        print(f"READY|Watching pin {pin} for changes (initial state: {'HIGH' if initial_value == Value.ACTIVE else 'LOW'})... (Press Ctrl+C to stop)")
        sys.stdout.flush()
        
        while True:
            # Wait for edge events (timeout en segundos, None = esperar indefinidamente)
            if request.wait_edge_events(timeout=None):
                for event in request.read_edge_events():
                    # Leer el valor actual del pin para confirmar el cambio
                    current_value = request.get_value(pin)
                    
                    # Solo reportar si el valor realmente cambió
                    if current_value != last_value:
                        event_type = "RISING" if current_value == Value.ACTIVE else "FALLING"
                        value = 1 if current_value == Value.ACTIVE else 0
                        print(f"EVENT|{event_type}|{value}")
                        sys.stdout.flush()
                        last_value = current_value

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: gpio_control.py [set|get|configure|info|release] <pin> [args...]")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == 'release':
        if len(sys.argv) < 3:
            print("Usage: gpio_control.py release <pin>")
            sys.exit(1)
        pin = int(sys.argv[2])
        release_pin(pin)
        sys.exit(0)
    
    if command == 'watch':
        if len(sys.argv) < 3:
            print("Usage: gpio_control.py watch <pin>")
            sys.exit(1)
        pin = int(sys.argv[2])
        try:
            watch_pin(pin)
        except KeyboardInterrupt:
            print("\nStopped watching pin")
            sys.exit(0)
        sys.exit(0)
    
    if len(sys.argv) < 3:
        print("Usage: gpio_control.py [set|get|configure|info|release] <pin> [args...]")
        sys.exit(1)
    
    pin = int(sys.argv[2])
    
    if command == 'set':
        if len(sys.argv) < 4:
            print("Usage: gpio_control.py set <pin> <1|0>")
            sys.exit(1)
        value = int(sys.argv[3])
        set_pin(pin, value)
    elif command == 'get':
        get_pin(pin)
    elif command == 'configure':
        if len(sys.argv) < 4:
            print("Usage: gpio_control.py configure <pin> <input|output> [initial_value]")
            sys.exit(1)
        direction = sys.argv[3]
        initial_value = int(sys.argv[4]) if len(sys.argv) > 4 else 0
        configure_pin(pin, direction, initial_value)
    elif command == 'info':
        get_pin_info(pin)
    else:
        print(f"Unknown command: {command}")
        sys.exit(1)
