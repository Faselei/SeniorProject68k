#game makefile
68KASM=vasmm68k_mot
68KASMFLAGS=-chklabels -quiet -nowarn=62 -L $(ERR)/$(notdir $(basename $<)).txt -Felf -o $(OBJ)/$(notdir $(basename $<)).elf $<
68KCC=vbccm68k
68KCCFLAGS=-c99 -cpu=68000 -use-framepointer -quiet -O=3 -I$(CLIBRARY) -o=$(dir $<)$(TMP)/$(notdir $(basename $<)).asm $<
VLINK=vlink
VLINKFLAGS= -T ../$(LIB)/LinkerScript -b rawbin1 -o $(BIN)/$(notdir $(patsubst %/,%,$(CURDIR))).md

#final binary?
#VLINKFLAGS=-F %Library%\libElf -F tmp\gameElf -o %gamename%.md -T %Library%\LinkerScript -b rawbin1

SRC=src
TMP=tmp
OBJ=obj
ERR=err
BIN=bin
LIB=lib
LIBRUNTIME=..\$(LIB)\$(BIN)\Library.elf

CLIBRARY=..\$(LIB)\headers

# all handwritten .asm files
SRCS=$(wildcard $(SRC)/*.asm)

# all handwritten .c files
CSRCS=$(wildcard $(SRC)/*.c)

# all .c -> .asm files
TSRCS=$(patsubst $(SRC)/%.c,$(SRC)/$(TMP)/%.asm,$(CSRCS))

#all objects made from the above 3 types of files
OBJS=$(patsubst $(SRC)/$(TMP)/%.asm,$(OBJ)/%.elf,$(TSRCS)) $(patsubst $(SRC)/%.asm,$(OBJ)/%.elf,$(SRCS))

all: Game

$(SRC)/$(TMP)/%.asm: $(SRC)/%.c
	$(68KCC) $(68KCCFLAGS)

$(OBJ)/%.elf: $(SRC)/%.asm
	$(68KASM) $(68KASMFLAGS)

$(OBJ)/%.elf: $(SRC)/$(TMP)/%.asm
	$(68KASM) $(68KASMFLAGS)
	
Game: $(OBJS) $(LIBRUNTIME)
	$(VLINK) $(VLINKFLAGS) $^
	
clean:
	del /q .\$(ERR)\*.txt 2> nul
	del /q .\$(SRC)\$(TMP)\* .asm 2> nul
	del /q .\$(OBJ)\*.elf 2> nul
	del /q .\$(BIN)\*.md 2> nul
	