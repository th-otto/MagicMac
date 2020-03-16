ifeq ($(UDO),)
UDO = udo
endif
ifeq ($(HCP),)
HCP = hcp
endif

.PHONY: all

all: magiccfg.hyp magiccfg.txt

magiccfg.txt: magiccfg.u
	@if $(UDO) --version >/dev/null 2>&1; then \
		echo $(UDO) --asc -o $@ $<; \
		$(UDO) --asc -o $@ $<; \
	else \
		echo "UDO not found, help file not compiled" >&2; \
	fi

magiccfg.stg: magiccfg.u
	@if $(UDO) --version >/dev/null 2>&1; then \
		echo $(UDO) --stg -o $@ $<; \
		$(UDO) --stg --no-hypfile -o $@ $<; \
		sed -i 's/e@gmx/e@@gmx/' $@; \
	else \
		echo "UDO not found, help file not compiled" >&2; \
	fi

magiccfg.hyp: magiccfg.stg
	@if $(HCP) --version >/dev/null 2>&1 && test -f $<; then \
		echo $(HCP) -o $@ $<; \
		$(HCP) -o $@ $<; \
	else \
		echo "HCP not found, help file not compiled" >&2; \
	fi

clean::
	$(RM) *.hyp *.ref *.stg *.uls *.ulh *.uhs *.ula *.uha udo*.gif magiccfg.txt
