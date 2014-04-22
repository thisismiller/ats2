.SILENT:

ifeq (${V},1)
	AT :=
else
	AT := @
endif

.PHONY: all clean toolchain

all: bin/demo bin/helloworld bin/echoserver

UNLIT ?= unlit
PATSOPT ?= patsopt
PATSCC ?= patscc
PATS_CFLAGS ?= -I${PATSHOME} -I${PATSHOME}/ccomp/runtime/ -I . -DATS_MEMALLOC_LIBC
PATS_LDFLAGS ?= -L${PATSHOME}/ccomp/atslib/lib/ -latslib

clean:
	rm -fr bin/
	mkdir bin
	mkdir bin/lib
	touch bin/.keep
	touch bin/lib/.keep

bin/%.dats: %.datslit
	@echo -e "\tUNLIT\t$^"
	${AT}${UNLIT} $^ -o $@
bin/%.sats: %.satslit
	@echo -e "\tUNLIT\t$^"
	${AT}${UNLIT} $^ -o $@
bin/%.cats: %.catslit
	@echo -e "\tUNLIT\t$^"
	${AT}${UNLIT} $^ -o $@

%_sats.c: %.sats
	@echo -e "\tSATS\t$*.sats"
	${AT}$(PATSOPT) --output $@ --static $^
bin/%_sats.c: %.sats
	@echo -e "\tSATS\t$*.sats"
	${AT}$(PATSOPT) --output $@ --static $^

%_dats.c: %.dats
	@echo -e "\tDATS\t$^"
	${AT}$(PATSOPT) --output $@ --dynamic $^
bin/%_dats.c: %.dats
	@echo -e "\tDATS\t$^"
	${AT}$(PATSOPT) --output $@ --dynamic $^

%.o %.d: %.c
	@echo -e "\tCC\t$*.o"
	${AT}gcc -MMD ${PATS_CFLAGS} -c $*.c -o $*.o

source_to_obj = $(patsubst %.datslit,bin/%_dats.o,$(patsubst %.dats,bin/%_dats.o,$(patsubst %.sats,bin/%_sats.o,$(1))))


-include $(shell find bin/ -name "*.d")

DEMO_SRCS := demo.dats
bin/demo: $(call source_to_obj,${DEMO_SRCS})
	@echo -e "\tLD\t$@"
	${AT}gcc ${PATS_CFLAGS} $^ ${PATS_LDFLAGS} -o $@

HELLOWORLD_SRCS := helloworld.datslit
bin/helloworld: $(call source_to_obj,${HELLOWORLD_SRCS})
	@echo -e "\tLD\t$@"
	${AT}gcc ${PATS_CFLAGS} $^ ${PATS_LDFLAGS} -o $@

ECHOSERVER_SRCS := echoserver.dats lib/either.sats lib/either.dats lib/errno.sats lib/errno.dats lib/socket.sats lib/socket.dats
bin/echoserver: $(call source_to_obj,${ECHOSERVER_SRCS})
	@echo -e "\tLD\t$@"
	${AT}gcc ${PATS_CFLAGS} $^ ${PATS_LDFLAGS} -o $@
