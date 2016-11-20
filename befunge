#!/bin/sh
set -ue
umask 0027
export LANG='C'
IFS='
'

Q_S='{-'
Q_E='-}'

prglist="$(mktemp)"

width=0
height=0

[ -f "${prglist}" ] && rm -f "${prglist}"

while read line; do
    line_m4="$(printf '%s' "${line}" | tr ',' ';')"
    printf "pushdef(${Q_S}program_rev${Q_E}, ${Q_S}%s${Q_E})\n" "${line_m4}" >> "${prglist}"

    printf '%s' "${line_m4}" | egrep -q '[&~?]' && unsupported='true'

    line_width="$(printf '%s' "${line_m4}" | wc -c)"
    [ "${line_width:-0}" -gt "${width}" ] && width="${line_width}"

    height=$(expr ${height} + 1)
done
unset line
unset line_m4

printf "stack_reverse(${Q_S}program_rev${Q_E}, ${Q_S}program${Q_E})\n" >> "${prglist}"
printf "start_program(${Q_S}program${Q_E}, %d, %d)\n" "${width}" "${height}" >> "${prglist}"

if [ -n "${unsupported:-}" ]; then
    printf '%s\n' 'Not Implemented operations are found. Exiting.'
else
    m4 ./lib.m4 "${prglist}"
fi

rm -f "${prglist}"

