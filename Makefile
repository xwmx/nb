BIN ?= nb
BIN_BOOKMARK ?= bookmark
BIN_NOTES ?= notes
PREFIX ?= /usr/local

debs: tmp ver
	$(eval DEB_ROOT := $(TMP)/DEBIAN)
	mkdir -p $(TMP)/usr/local/bin
	cp $(BIN) $(TMP)/usr/local/bin/
	mkdir -p $(DEB_ROOT)
	cat etc/DEBIAN/control | sed s/{{VERSION}}/$(VERSION)/ > $(DEB_ROOT)/control
	dpkg-deb -Zgzip -b $(TMP) nb_$(VERSION)_amd64.deb
	rm -rf $(TMP)

install:
	install $(BIN) $(PREFIX)/bin
	install bin/$(BIN_BOOKMARK) $(PREFIX)/bin
	install bin/$(BIN_NOTES) $(PREFIX)/bin
	./$(BIN) completions install

uninstall:
	rm -f $(PREFIX)/bin/$(BIN)
	rm -f $(PREFIX)/bin/$(BIN_BOOKMARK)
	rm -f $(PREFIX)/bin/$(BIN_NOTES)
	./$(BIN) completions uninstall

tmp:
	$(eval TMP := $(shell mktemp -d -t nb.XXXXX))

ver:
	$(eval VERSION := $(shell ./$(BIN) --version))
