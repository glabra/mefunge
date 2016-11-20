#!/bin/sh
set -ue
umask 0027
export LANG='C'
IFS='
'
Q_S='{-'
Q_E='-}'

[ -z "${1:-}" ] && \
    printf 'Usage: ./%s [befunge source file]' "$0" && \
    exit 1

egrep -q '[?]' "${1}" && \
    printf 'Not Implemented operations are found. Exiting.\n' && \
    exit 1

prglist="$(mktemp)"

width=$(wc -L < "${1}")
height=$(wc -l < "${1}")

(cat "${1}" | \
    tr ',' ';' | \
    sed "s/^/pushdef(${Q_S}prg${Q_E},${Q_S}/" | \
    sed "s/$/${Q_E})/" \
) > "${prglist}"

printf \
    "stack_reverse(${Q_S}prg${Q_E}, ${Q_S}program${Q_E})\n" >> "${prglist}"
printf \
    "start_program(${Q_S}program${Q_E}, %d, %d)\n" "${width}" "${height}" >> "${prglist}"

m4 ./lib.m4 "${prglist}"

rm -f "${prglist}"

