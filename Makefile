BIN ?= nb
BIN_BOOKMARK ?= bookmark
PREFIX ?= /usr/local

install:
	install $(BIN) $(PREFIX)/bin
	install bin/$(BIN_BOOKMARK) $(PREFIX)/bin
	./$(BIN) env install

uninstall:
	rm -f $(PREFIX)/bin/$(BIN)
	rm -f $(PREFIX)/bin/$(BIN_BOOKMARK)
	./$(BIN) env uninstall
