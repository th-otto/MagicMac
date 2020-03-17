ifeq ($(UDO),)
UDO = udo
endif
ifeq ($(HCP),)
HCP = hcp
endif

INCLUDES := $(wildcard include/*.ui)

.PHONY: all

all: magiccfg_en.hyp magiccfg_en.txt magiccfg_de.hyp magiccfg_de.txt

magiccfg_en.txt: magiccfg.u $(INCLUDES)
	@if $(UDO) --version >/dev/null 2>&1; then \
		echo $(UDO) --asc -o $@ $<; \
		$(UDO) --asc -o $@ $<; \
	else \
		echo "UDO not found, help file not compiled" >&2; \
	fi

magiccfg_de.txt: magiccfg.u $(INCLUDES)
	@if $(UDO) --version >/dev/null 2>&1; then \
		echo $(UDO) -DGERMAN --asc -o $@ $<; \
		$(UDO) -D GERMAN --asc -o $@ $<; \
	else \
		echo "UDO not found, help file not compiled" >&2; \
	fi

magiccfg_en.stg: magiccfg.u $(INCLUDES)
	@if $(UDO) --version >/dev/null 2>&1; then \
		echo $(UDO) --stg -o $@ $<; \
		$(UDO) --stg --no-hypfile -o $@ $<; \
		sed -i 's/e@gmx/e@@gmx/' $@; \
	else \
		echo "UDO not found, help file not compiled" >&2; \
	fi

magiccfg_en.hyp: magiccfg_en.stg
	@if $(HCP) --version >/dev/null 2>&1 && test -f $<; then \
		echo $(HCP) -o $@ $<; \
		$(HCP) -o $@ $<; \
	else \
		echo "HCP not found, help file not compiled" >&2; \
	fi

magiccfg_de.stg: magiccfg.u $(INCLUDES)
	@if $(UDO) --version >/dev/null 2>&1; then \
		echo $(UDO) -DGERMAN --stg -o $@ $<; \
		$(UDO) -D GERMAN --stg --no-hypfile -o $@ $<; \
		sed -i 's/e@gmx/e@@gmx/' $@; \
	else \
		echo "UDO not found, help file not compiled" >&2; \
	fi

magiccfg_de.hyp: magiccfg_de.stg
	@if $(HCP) --version >/dev/null 2>&1 && test -f $<; then \
		echo $(HCP) -o $@ $<; \
		$(HCP) -o $@ $<; \
	else \
		echo "HCP not found, help file not compiled" >&2; \
	fi

clean::
	$(RM) *.hyp *.ref *.stg *.uls *.ulh *.uhs *.ula *.uha udo*.gif magiccfg.txt magiccfg_de.txt
