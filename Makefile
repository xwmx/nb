BIN ?= notes
BIN2 ?= bookmark
PREFIX ?= /usr/local

install:
	install $(BIN) $(PREFIX)/bin
	install bin/$(BIN2) $(PREFIX)/bin
	./notes completions install

uninstall:
	rm -f $(PREFIX)/bin/$(BIN2)
	rm -f $(PREFIX)/bin/$(BIN)
	./notes completions uninstall
