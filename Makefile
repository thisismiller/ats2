.SILENT:

ifeq (${V},1)
	AT :=
else
	AT := @
endif

.PHONY: all clean toolchain

all: bin/demo bin/helloworld

UNLIT ?= unlit
PATSOPT ?= patsopt
PATSCC ?= patscc
PATS_CFLAGS ?= -I${PATSHOME} -I${PATSHOME}/ccomp/runtime/ -I .
PATS_LDFLAGS ?= -L${PATSHOME}/ccomp/atslib/lib/ -latslib

clean:
	rm -fr bin/
	mkdir bin
	touch bin/.keep

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
	${AT}$(PATSOPT) --output $@ --static $*.sats
bin/%_sats.c: %.sats
	@echo -e "\tSATS\t$*.sats"
	${AT}$(PATSOPT) --output $@ --static $*.sats

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
