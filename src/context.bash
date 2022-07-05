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

#
# Prints the help message to stdout.
# Globals:
#   PROGRAM
#   COMMAND
#   XMENU
# Arguments:
#   NONE
# Outputs:
#   Stdout:
#     The help message.
#
help_msg() {
  cat <<EOF
  Usage: ${PROGRAM} ${COMMAND} [OPTION]... PASS_CMD [PASS_CMD_OPTION]...
  Run Pass with the given context.

  -c, --change-to=CONTEXT   Use CONTEXT instead of the current one.
  -v, --variable=VAR=VALUE  Set value VALUE the variable VAR.
  -C, --config=PATH         Use the cfg file specified in PATH.
  -q, --quiet               Suppress context info.
  -h, --help                Print this help message.
EOF
}

main() {
  sopts="hqc:C:v:"
  lopts="help,quiet,change-to:,config:,variable:"
  argv="$(POSIXLY_CORRECT=1 getopt -l "${lopts}" -o "${sopts}" -- "${@}" 2>&1)" || {
    argv="${argv%[[:space:]]*}"
    argv="${argv%%[[:cntrl:]]*}"
    rperr "${argv#*[[:space:]]}"
    exit 1
  }

  while true; do
    case "${1}" in
      "-h" | "--help")
        help_msg
        exit 0
        ;;
      "--")
        shift
        break
        ;;
    esac
    shift
  done

}

main "${@}"
