#!/bin/bash
#=- ---------------------------------------------------------------------------
#
#
#   mkIcingaHolidays.sh
#                                           -----------------------------------
#                                           | Creator: bobby.billingsley
#=- ---------------------------------------------------------------------------

yearsDefault=5                              # provide holidays for this many years

# gcal command & longargs                     (short args)
gCalBin="gcal"
gCalArgs+="--disable-highlighting "         # -Hno
gCalArgs+="--suppress-calendar "            # -u
gCalArgs+="--resource-file=/dev/null "      # -f /dev/null
gCalArgs+="--cc-holidays=DK "               # -qDK
gCalArgs+="--include-holidays=short "       # -cE

# have gcal present the info formatted for icinga:
GCAL_DATE_FORMAT+='"%<04#Y'                 # 4-digit year
GCAL_DATE_FORMAT+='-%<02*M'                 # 2-digit month
GCAL_DATE_FORMAT+='-%<02*D"'                # 2-digit day
GCAL_DATE_FORMAT+=' = "00:00-24:00" %1//%2' # duration & comment for icinga
GCAL_DATE_FORMAT+='"'                       # closing quote
export GCAL_DATE_FORMAT

function __MAIN__ () {
    if [ -z "`type ${gCalBin}`" ] ; then
        echo "${gCalBin} not found."        # Can't do without this
        exit 1
    fi


    local years="${1:-$yearsDefault}"

    (( $years < 0 )) && {
                    local pStart=$(date -d "$years years" "+01/%Y");
                    local   pEnd=$(date "+12/%Y");
                } || {
                    local   pEnd=$(date -d "$years years" "+12/%Y");
                    local pStart=$(date "+1/%Y");
                }

    # (( $years > 1 || $years < 0 )) && gCalArgs+="${pStart}-${pEnd}"
    gCalArgs+="${pStart}-${pEnd}"


    local \
        intro+='object TimePeriod "Holidays" {\n'
        intro+='  display_name = "Holidays"\n'
        intro+='  ranges = {\n'

    local \
        outtro+='  }\n'
        outtro+='}\n'

    printf '%b' "${intro}"
    ${gCalBin} ${gCalArgs} | while read calLine; do
            [[ ${calLine:0:1} != $'"' ]] && continue
            printf "%b\n" "${calLine/#\"/    \"/}"
        done
    printf '%b' "${outtro}"
}

__MAIN__ "${@}"

# Modeline for ViM # {{{
# vim:set ts=8 sts=4 sw=4 sr ai et nu rnu:
# vim600:fdm=syntax fdl=0 fdc=0 foldclose=all cms=#\ %s:
# -------------------------------------------------------------------------- }}}
