## Process this file with automake to produce Makefile.in

## Created by Anjuta



AM_CPPFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	$(THUNDERBOLT_CFLAGS)

AM_CFLAGS =\
	 -Wall\
	 -g

VALAFLAGS =  --pkg gio-2.0 --pkg glib-2.0 --pkg gdk-pixbuf-2.0 --pkg gtk+-3.0 \
	--pkg webkitgtk-3.0 --pkg libsoup-2.4 --pkg gdk-3.0 --pkg gtk+-3.0 \
	--pkg config --pkg gnome-keyring-1 --vapidir .

bin_PROGRAMS = thunderbolt

thunderbolt_SOURCES = \
	browser-tab.vala \
	browser-window.vala \
	main.vala \
	tabbed-browser.vala \
	tab-label.vala \
	toolbar.vala \
	utils.vala \
	find-bar.vala \
	download.vala \
	cache.vala \
	overlay.vala \
	browser-menu.vala \
	webview.vala

thunderbolt_LDFLAGS = \
	-Wl,--export-dynamic

thunderbolt_LDADD = $(THUNDERBOLT_LIBS)

