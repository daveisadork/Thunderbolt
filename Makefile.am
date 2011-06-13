## Process this file with automake to produce Makefile.in
## Created by Anjuta

SUBDIRS = src 

thunderboltdocdir = ${prefix}/doc/thunderbolt
thunderboltdoc_DATA = \
	README\
	COPYING\
	AUTHORS\
	ChangeLog\
	INSTALL\
	NEWS


EXTRA_DIST = $(thunderboltdoc_DATA)


# Remove doc directory on uninstall
uninstall-local:
	-rm -r $(thunderboltdocdir)
