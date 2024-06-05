COMPILER=D:\asm\Asm32\nasm.exe
LINKER=D:\asm\Asm32\link.exe
LIB=D:\asm\Asm32\libcmt.lib
KERNEL=D:\asm\Asm32\kernel32.lib

BUILD_DIR=build

.PHONY = all makeDIr

all: makeDirs main.exe
	@echo Everything Compiled

makeDirs:
ifeq (,$(wildcard ./$(BUILD_DIR)))
	mkdir $(BUILD_DIR)
endif


main.exe: $(BUILD_DIR)/main.obj
	@echo Compiling main.exe
	@echo ------------------
	@$(LINKER) $< $(KERNEL) /subsystem:console


$(BUILD_DIR)/main.obj: main.asm
	@echo Compiling main.o
	@echo ----------------
	@$(COMPILER) $^ -f win32 -o $@
