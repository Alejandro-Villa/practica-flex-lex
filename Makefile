# CREDIT: This makefile template was taken from https://github.com/TheNetAdmin/Makefile-Templates
# It has been modified to suit the project's needs

# tool macros
CC := g++ # FILL: the compiler
INC_PATH := inc
CCFLAGS := -Wall -Wextra -Wpedantic --std=c++11 -g -I$(INC_PATH) # FILL: compile flags
DBGFLAGS := -g
CCOBJFLAGS := $(CCFLAGS) -c

FLEX := flex
FLEXFLAGS := #-d # FILL: flex++ flags

# path macros
BIN_PATH := bin
OBJ_PATH := obj
SRC_PATH := src
LEX_PATH := src/lex
DBG_PATH := debug
DOC_PATH := doc
TEST_PATH := test

# compile macros
TARGET_NAME := jy-parser # FILL: target name
ifeq ($(OS),Windows_NT)
	TARGET_NAME := $(addsuffix .exe,$(TARGET_NAME))
endif
TARGET := $(BIN_PATH)/$(TARGET_NAME)
TARGET_DEBUG := $(DBG_PATH)/$(TARGET_NAME)

# src files & obj files
LEX := $(foreach x, $(LEX_PATH), $(wildcard $(addprefix $(x)/*,.l)))
INC := $(foreach x, $(INC_PATH), $(wildcard $(addprefix $(x)/*,.h)))
SRC := $(addprefix $(SRC_PATH)/, $(addsuffix .cpp, $(notdir $(basename $(LEX)))))
SRC += $(foreach x, $(SRC_PATH), $(wildcard $(addprefix $(x)/*,.cpp)))
OBJ := $(addprefix $(OBJ_PATH)/, $(addsuffix .o, $(notdir $(basename $(SRC)))))
OBJ_DEBUG := $(addprefix $(DBG_PATH)/, $(addsuffix .o, $(notdir $(basename $(SRC)))))
TEST := $(foreach x, $(TEST_PATH), $(wildcard $(addprefix $(x)/*,.json)))

# clean files list
DISTCLEAN_LIST := $(OBJ) \
                  $(OBJ_DEBUG)
CLEAN_LIST := $(TARGET) \
			  $(TARGET_DEBUG) \
			  $(DISTCLEAN_LIST)

# default rule
default: makedir all

# non-phony targets
$(TARGET): $(OBJ) $(INC)
	$(CC) $(CCFLAGS) -o $@ $(OBJ)

$(OBJ_PATH)/%.o: $(SRC_PATH)/%.cpp
	$(CC) $(CCOBJFLAGS) -o $@ $<

$(SRC_PATH)/%.cpp: $(LEX_PATH)/%.l
	$(FLEX) $(FLEXFLAGS) -o $@ $<

$(DBG_PATH)/%.o: $(SRC_PATH)/%.cpp
	$(CC) $(CCOBJFLAGS) $(DBGFLAGS) -o $@ $<

$(TARGET_DEBUG): $(OBJ_DEBUG)
	$(CC) $(CCFLAGS) $(DBGFLAGS) $(OBJ_DEBUG) -o $@

# phony rules
.PHONY: makedir
makedir:
	@mkdir -p $(BIN_PATH) $(OBJ_PATH) $(DBG_PATH) $(DOC_PATH) $(TEST_PATH)

.PHONY: all
all: $(TARGET)

.PHONY: debug
debug: $(TARGET_DEBUG)

.PHONY: clean
clean:
	@echo CLEAN $(CLEAN_LIST)
	@rm -f $(CLEAN_LIST)

.PHONY: distclean
distclean:
	@echo CLEAN $(DISTCLEAN_LIST)
	@rm -f $(DISTCLEAN_LIST)

.PHONY: test
test: clean all $(TEST)
	@echo "COMENZANDO TESTS"
	-@$(foreach testcase, $(TEST), $(TARGET) $(testcase);)
