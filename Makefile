BIN ?= notes
PREFIX ?= /usr/local

install:
	install $(BIN) $(PREFIX)/bin
	./scripts/install-completion.bash

uninstall:
	rm -f $(PREFIX)/bin/$(BIN)
	./scripts/uninstall-completion.bash
