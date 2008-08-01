#!/bin/sh

info()
{
  /bin/echo -en $1
}

output()
{
  echo $1 >> $OUTPUT_FILE
}

if [ $# -lt 1 ]; then
  echo "Usage: $0 <output file>"
  exit 1
fi

OUTPUT_FILE=$1
rm -f $OUTPUT_FILE

output "MAKEFILE_CONFIG_INCLUDED = 1"

# Check if the "-h" switch may be used with the chgrp command
info "--- Checking if chgrp understand the -h switch..."
ln -s . chgrp_test-$$.tmp
if chgrp -h `id -gn` chgrp_test-$$.tmp 2> /dev/null; then
  info "yes\n"
  output "CHGRP_H=chgrp -h"
else
  info "no\n"
  output "CHGRP_H=chgrp"
fi
rm -f chgrp_test-$$.tmp

# Check if the "-h" switch may be used with the chown command
info "--- Checking if chown understand the -h switch..."
ln -s . chown_test-$$.tmp
if chown -h `id -un` chown_test-$$.tmp 2> /dev/null; then
  info "yes\n"
  output "CHOWN_H=chown -h"
else
  info "no\n"
  output "CHOWN_H=chown"
fi
rm -f chown_test-$$.tmp

# Check if echo reacts to "--" as "stop processing arguments"
info "--- Checking if echo parses --..."
if [ -z "$(/bin/echo -ne --)" ]; then
  info "yes\n"
  output "ECHO=/bin/echo -e --"
else
  info "no\n"
  output "ECHO=/bin/echo -e"
fi

# Check for KDE
#info "--- Checking for KDE..."
#if [ "${KDEDIR}" != "" ]; then
#  if [ -r "${KDEDIR}/include/kde/kdeversion.h" ]; then
#    KDEINC=${KDEDIR}/include/kde
#    KDE_VERSION_INC=${KDEINC}/kdeversion.h
#  elif [ -r "${KDEDIR}/include/kapp.h" ]; then
#    KDEINC=${KDEDIR}/include
#    KDE_VERSION_INC=${KDEINC}/kapp.h
#  elif [ -r "${KDEDIR}/include/kde/kapp.h" ]; then
#    KDEINC=${KDEDIR}/include/kde
#    KDE_VERSION_INC=${KDEINC}/kapp.h
#  fi
#  if [ "${KDEINC}" != "" ]; then
#    KDE_VERSION_MAJOR=$(awk '/#define KDE_VERSION_MAJOR/ { print $3; }' ${KDE_VERSION_INC})
#    output "KDE_VERSION_MAJOR=$KDE_VERSION_MAJOR"
#    output "CFLAGS_DEFINES+=-DKDE_VERSION_MAJOR=$KDE_VERSION_MAJOR"
#    info "yes (version=$KDE_VERSION_MAJOR)\n"
#  else
#    info "no\n"
#  fi
#else
#  info "no\n"
#fi

# Checking for QT
info "--- Checking for QT..."
if which pkg-config > /dev/null 2>&1; then
  if pkg-config qt; then
    info "yes (pkg-config qt)\n"
    output "QT_LIBPATH=$(pkg-config qt --libs-only-L)"
    output "QT_LIBS=$(pkg-config qt --libs-only-l)"
    output "QT_INCPATH=$(pkg-config qt --cflags-only-I)"
    output "QT_CFLAGS=$(pkg-config qt --cflags-only-other)"
    QT_PREFIX=$(pkg-config qt --variable=prefix)
  elif pkg-config qt-mt; then
    info "yes (pkg-config qt-mt)\n"
    output "QT_LIBPATH=$(pkg-config qt-mt --libs-only-L)"
    output "QT_LIBS=$(pkg-config qt-mt --libs-only-l)"
    output "QT_INCPATH=$(pkg-config qt-mt --cflags-only-I)"
    output "QT_CFLAGS=$(pkg-config qt-mt --cflags-only-other)"
    QT_PREFIX=$(pkg-config qt-mt --variable=prefix)
  fi
fi
if [ -z "$QT_PREFIX" -a -n "$QTDIR" ]; then
  info "yes (QTDIR)\n"
  output "QT_LIBPATH=-L${QTDIR}/lib"
  if [ -n "$(ls ${QTDIR}/lib/libqt-mt* 2> /dev/null)" ]; then
    output "QT_LIBS=-lqt-mt"
  else
    output "QT_LIBS=-lqt"
  fi
  output "QT_INCPATH=-I${QTDIR}/include"
  output "QT_CFLAGS="
  QT_PREFIX=${QTDIR}
fi
if [ -n "$QT_PREFIX" ]; then
  QT_BIN="${QT_PREFIX}/bin"
  output "QT_BIN=${QT_BIN}"
  output "QT_MOC=${QT_BIN}/moc"
  output "QT_UIC=${QT_BIN}/uic"
else
  info "no\n"
fi

# Checking for libsigc++
sigc_version=1.2
info "--- Checking for sigc++ $sigc_version..."
if which pkg-config > /dev/null 2>&1; then
  if pkg-config sigc++-$sigc_version; then
    info "yes\n"
    output "SIGC_LIBPATH=$(pkg-config sigc++-$sigc_version --libs-only-L)"
    output "SIGC_LIBS=$(pkg-config sigc++-$sigc_version --libs-only-l)"
    output "SIGC_INCPATH=$(pkg-config sigc++-$sigc_version --cflags-only-I)"
  else
    info "no\n"
    exit 1
  fi
else
  info "no\n"
  exit 1
fi

# Checking for tcl development library
info "--- Checking for TCL development library..."
tclConfig=$(ls /usr/lib/tclConfig.sh /usr/lib/tcl8.*/tclConfig.sh 2>/dev/null \
            | cut -f1)
if [ -n "$tclConfig" -a -r $tclConfig ]; then
  . $tclConfig
  info "${TCL_VERSION}\n"
  output "TCL_LIBS=-ltcl${TCL_VERSION}"
else
  info "no\n"
  exit 1
fi

exit 0

