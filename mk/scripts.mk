# Install rules for our scripts
# Copyright 2007-2008 Roy Marples <roy@marples.name>

include ${MK}/sys.mk
include ${MK}/os.mk

OBJS+=	${SRCS:.in=}

_SED_PREFIX_SH=		if test "${PREFIX}" = "${PKG_PREFIX}"; then echo "-e 's:@PKG_PREFIX@::g'"; else echo "-e 's:@PKG_PREFIX@:${PKG_PREFIX}:g'"; fi
_SED_PREFIX!=		${_SED_PREFIX_SH}
SED_REPLACE=		-e 's:@SHELL@:${SH}:g' -e 's:@LIB@:${LIBNAME}:g' -e 's:@SYSCONFDIR@:${SYSCONFDIR}:g' -e 's:@PREFIX@:${PREFIX}:g' ${_SED_PREFIX}$(shell ${_SED_PREFIX_SH})  -e 's:@LOCAL_PREFIX@:${LOCAL_PREFIX}:g'	

# Tweak our shell scripts
.SUFFIXES:	.sh.in .in
.sh.in.sh:
	sed ${SED_REPLACE} $< > $@

.in:
	sed ${SED_REPLACE} $< > $@

all: ${OBJS}

realinstall: ${BIN} ${CONF} ${CONF_APPEND}
	if test -n "${DIR}"; then ${INSTALL} -d ${DESTDIR}/${PREFIX}${DIR} || exit $$?; fi
	if test -n "${BIN}"; then ${INSTALL} -m ${BINMODE} ${BIN} ${DESTDIR}/${PREFIX}${DIR} || exit $$?; fi
	if test -n "${INC}"; then ${INSTALL} -m ${INCMODE} ${INC} ${DESTDIR}/${PREFIX}${DIR} || exit $$?; fi
	for x in ${CONF}; do \
	 	if ! test -e ${DESTDIR}/${PREFIX}${DIR}/$$x; then \
			${INSTALL} -m ${CONFMODE} $$x ${DESTDIR}/${PREFIX}${DIR} || exit $$?; \
		fi; \
	done
	for x in ${CONF_APPEND}; do \
		if test -e ${DESTDIR}/${PREFIX}${DIR}/$$x; then \
			cat $$x >> ${DESTDIR}/${PREFIX}${DIR}/$$x || exit $$?; \
		else \
	   		${INSTALL} -m ${CONFMODE} $$x ${DESTDIR}/${PREFIX}${DIR} || exit $$?; \
		fi; \
	done

install: all realinstall ${INSTALLAFTER}

# A lot of scripts don't have anything to clean
# Also, some rm implentation require a file argument regardless of error
# so we ensure that it has a bogus argument
CLEANFILES+=	${OBJS}
clean:
	@if test -n "${CLEANFILES}"; then echo "rm -f ${CLEANFILES}"; rm -f ${CLEANFILES}; fi 

include ${MK}/gitignore.mk
