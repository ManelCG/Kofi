BASENAME = kofi
VERSION = "0.1.0"

SDIR = src

IDIR = include
LOCALENAME = $(BASENAME)
CCCMD = gcc
CFLAGS = -I$(IDIR) `pkg-config --cflags --libs gtk+-3.0` -lcrypto -Wall -Wno-deprecated-declarations -DLOCALE_=\"$(LOCALENAME)\"

debug: CC = $(CCCMD) -DDEBUG_ALL -DVERSION=\"$(VERSION)_DEBUG\"
debug: BDIR = build

release: CC = $(CCCMD) -O2 -DVERSION=\"$(VERSION)\"
release: BDIR = build

windows: CC = $(CCCMD) -O2 -DVERSION=\"$(VERSION)\" -mwindows
windows: BDIR = build
windows_GTKENV: BDIR = build

install: CC = $(CCCMD) -O2	-DMAKE_INSTALL -DVERSION=\"$(VERSION)\"
install: PROGDIR = /usr/lib/$(BASENAME)
install: BDIR = $(PROGDIR)/bin

archlinux: CC = $(CCCMD) -O2 -DMAKE_INSTALL -DVERSION=\"$(VERSION)\"

locale: LOCALEDIR = locale

ODIR=.obj/linux
WODIR=.obj/win
DODIR=.obj/debug
LDIR=lib

LIBS = -lm -lpthread

_DEPS = kofi_constants.h kofi_parser.h
DEPS = $(patsubst %,$(IDIR)/%,$(_DEPS))

_OBJ = main.o kofi_parser.o
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))
WOBJ = $(patsubst %,$(WODIR)/%,$(_OBJ))
DOBJ = $(patsubst %,$(DODIR)/%,$(_OBJ))

$(ODIR)/%.o: $(SDIR)/%.c $(DEPS)
	mkdir -p $(ODIR)
	$(CC) -c -o $@ $< $(CFLAGS)

$(WODIR)/%.o: $(SDIR)/%.c $(DEPS)
	mkdir -p $(WODIR)
	$(CC) -c -o $@ $< $(CFLAGS)

$(DODIR)/%.o: $(SDIR)/%.c $(DEPS)
	mkdir -p $(DODIR)
	$(CC) -c -o $@ $< $(CFLAGS)

release: $(OBJ)
	mkdir -p $(BDIR)
	mkdir -p $(ODIR)
	$(CC) -o $(BDIR)/$(BASENAME) $^ $(CFLAGS) $(LIBS)

windows: $(WOBJ)
	mkdir -p $(WODIR)
	windres __windows__/my.rc -O coff $(WODIR)/my.res
	windres __windows__/appinfo.rc -O coff $(WODIR)/appinfo.res
	mkdir -p $(BDIR)
	$(CC) -o $(BDIR)/$(BASENAME) $^ $(CFLAGS) $(LIBS) $(WODIR)/my.res $(WODIR)/appinfo.res

windows_GTKENV: windows
	ldd $(BDIR)/$(BASENAME).exe | grep '\/mingw.*\.dll' -o | xargs -I{} cp "{}" $(BDIR)/
	cp -ru __windows__/windows_assets/* $(BDIR)/
	cp -ru assets $(BDIR)/
	cp -ru locale/ $(BDIR)/
	cp LICENSE $(BDIR)/


debug: $(DOBJ)
	mkdir -p $(BDIR)
	mkdir -p $(DODIR)
	$(CC) -o $(BDIR)/$(BASENAME)_DEBUG $^ $(CFLAGS) $(LIBS)

install: $(OBJ)
	mkdir -p $(PROGDIR)
	mkdir -p $(BDIR)
	mkdir -p $(ODIR)
	mkdir -p /usr/lib/$(BASENAME)
	$(CC) -o $(BDIR)/$(BASENAME) $^ $(CFLAGS) $(LIBS)
	ln -sf $(BDIR)/$(BASENAME) /usr/bin/$(BASENAME)
	cp -ru assets/ /usr/lib/$(BASENAME)
	cp -ru locale/ /usr/lib/$(BASENAME)
	cp LICENSE /usr/lib/$(BASENAME)
	cp assets/$(BASENAME).desktop /usr/share/applications/
	cp assets/app_icon/256.png /usr/share/pixmaps/$(BASENAME).png

archlinux: $(OBJ) $(OBJ_GUI)
	mkdir -p $(BDIR)/usr/lib/$(BASENAME)
	mkdir -p $(BDIR)/usr/share/applications
	mkdir -p $(BDIR)/usr/share/pixmaps
	mkdir -p $(BDIR)/usr/bin/
	mkdir -p $(ODIR)
	$(CC) -o $(BDIR)/usr/bin/$(BASENAME) $^ $(CFLAGS) $(LIBS)
	cp -ru assets/ $(BDIR)/usr/lib/$(BASENAME)/
	cp -ru locale/ $(BDIR)/usr/lib/$(BASENAME)/
	cp LICENSE $(BDIR)/usr/lib/$(BASENAME)/
	cp assets/$(BASENAME).desktop $(BDIR)/usr/share/applications/
	cp assets/app_icon/256.png $(BDIR)/usr/share/pixmaps/$(BASENAME).png

locale: $(LOCALEDIR)/es/LC_MESSAGES/$(LOCALENAME).mo $(LOCALEDIR)/ru/LC_MESSAGES/$(LOCALENAME).mo $(LOCALEDIR)/ca/LC_MESSAGES/$(LOCALENAME).mo

$(LOCALEDIR)/%/LC_MESSAGES/$(LOCALENAME).mo: $(LOCALEDIR)/%/$(LOCALENAME).po
	msgfmt --output-file=$(LOCALEDIR)/$*/LC_MESSAGES/$(LOCALENAME).mo $(LOCALEDIR)/$*/$(LOCALENAME).po
$(LOCALEDIR)/%/$(LOCALENAME).po: $(LOCALEDIR)/$(LOCALENAME).pot
	msgmerge --update $(LOCALEDIR)/$*/$(LOCALENAME).po $(LOCALEDIR)/$(LOCALENAME).pot
	mkdir -p $(LOCALEDIR)/$*/LC_MESSAGES
$(LOCALEDIR)/$(LOCALENAME).pot: $(SDIR)/*
	xgettext --keyword=_ --language=C --from-code=UTF-8 --add-comments --sort-output -o $(LOCALEDIR)/$(LOCALENAME).pot $(SDIR)/*.c

.PHONY: clean
clean:
	rm -f $(ODIR)/*.o $(WODIR)/*.o $(DODIR)/*.o *~ core $(INCDIR)/*~

.PHONY: all
all: release clean
