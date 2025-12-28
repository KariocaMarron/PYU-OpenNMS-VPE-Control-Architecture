#!/bin/sh
export JAVA_OPTS="$JAVA_OPTS -Dopennms.minion.icmp.disable=true"
exec /entrypoint.sh "$@"

#Jose Vasconcelos - Dec 2025
#GitHub - KariocaMarron
#acme5bataj10@outlook.com
