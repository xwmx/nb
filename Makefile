BIN ?= notes
PREFIX ?= /usr/local

install:
	install $(BIN) $(PREFIX)/bin
	./scripts/notes-completion install

uninstall:
	rm -f $(PREFIX)/bin/$(BIN)
	./scripts/notes-completion uninstall
