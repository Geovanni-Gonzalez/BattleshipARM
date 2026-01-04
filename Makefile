# Makefile for BattleshipARM

# Directories
SRC_DIR = src
OBJ_DIR = obj
DOC_DIR = docs

# Toolchain
AS = arm-linux-gnueabihf-as
LD = arm-linux-gnueabihf-ld
QEMU = qemu-arm
QEMU_FLAGS = -L /usr/arm-linux-gnueabihf

# Files
SRCS = $(wildcard $(SRC_DIR)/*.s)
OBJS = $(patsubst $(SRC_DIR)/%.s, $(OBJ_DIR)/%.o, $(SRCS))
TARGET = battleship

# Build Rules
all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) -o $@ $^

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.s
	@mkdir -p $(OBJ_DIR)
	$(AS) -g -o $@ $<

# Run
run: $(TARGET)
	$(QEMU) $(QEMU_FLAGS) ./$(TARGET)

# Clean
clean:
	rm -rf $(OBJ_DIR) $(TARGET) main.o utils.o *.o

.PHONY: all clean run
