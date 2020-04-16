BIN ?= notes
PREFIX ?= /usr/local

install:
	install $(BIN) $(PREFIX)/bin
	./notes completions install

uninstall:
	rm -f $(PREFIX)/bin/$(BIN)
	./notes completions uninstall
