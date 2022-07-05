#!/usr/bin/env bash

#
# Shellcheck Global Directives
#
#
# Suppress warnings about using a variable as printf's format string.
# shellcheck disable=SC2059
#
# Suppress warnings about globing and word splitting in unquoted variables.
# shellcheck disable=SC2086
#

CONTEXTS_FILE="${PASSWORD_CONTEXTS_FILE:-"${XDG_CONFIG_HOME}/pass/extensions/contexts.cfg"}"
XMENU="${PASSWORD_CONTEXTS_XMENU:-dmenu}"
XMENU_FLAGS="${PASSWORD_CONTEXTS_XMENU_FLAGS}"

#
# Prints an error message to stderr.
# Globals:
#   PROGRAM
#   COMMAND
#   XMENU
# Arguments:
#   1: format string, 2-n: variables for the format string.
# Outputs:
#   Stderr:
#     An error message.
#
rperr() {
  local fmtstr="${1}"
  shift
  if tty 1>/dev/null 2>&1; then
    printf "%s: ${fmtstr}" "${PROGRAM} ${COMMAND}" "${@}" 1>&2
  else
    printf "Exit 1" \
      | "${XMENU}" ${XMENU_FLAGS} -p "$(printf "${fmtstr}" "${@}")"
  fi
}

main() {
  sopts="hqc:C:v:"
  lopts="help,quiet,change-to:,config:,variable:"
  argv="$(getopt -l "${lopts}" -o "${sopts}" -- "${@}" 2>&1)" || {
    argv="${argv%[[:space:]]*}"
    argv="${argv%%[[:cntrl:]]*}"
    rperr "${argv#*[[:space:]]}"
    exit 1
  }

}

main "${@}"
