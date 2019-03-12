ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS = -g -O3  -I"$(ERLANG_PATH)" -I"$(LIB_DIR)"
ifeq ($(shell uname),Linux)
	LDFLAGS = -Wl,--no-whole-archive
else
	LDFLAGS =
endif

LIB = poke
LIB_DIR = $(PWD)/priv
OUTPUT = "$(LIB_DIR)"/$(LIB).so

ifneq ($(OS),Windows_NT)
	CFLAGS += -fPIC
endif

ifeq ($(shell uname),Darwin)
	LDFLAGS += -dynamiclib -undefined dynamic_lookup
endif

all:
	@mkdir -p $(LIB_DIR) || :
	@$(CC) $(CFLAGS) $(CFLAGS_ADD) -shared $(LDFLAGS) -o $(OUTPUT) c_src/$(LIB).c

clean:
	@$(RM) -r "$(LIB_DIR)"/$(LIB).so*
