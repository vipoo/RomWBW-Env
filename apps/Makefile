.PHONY: all
.PHONY: hbios
.PHONY: inttest
.PHONY: driver-fn
.PHONY: extromldr

all: hbios inttest driver-fn extromldr hello

extromldr:
	$(MAKE) --directory extromldr

driver-fn:
	$(MAKE) --directory driver-fn

hbios:
	$(MAKE) --directory hbios

inttest:
	$(MAKE) --directory inttest

hello:
	$(MAKE) --directory hello-world-cpm
