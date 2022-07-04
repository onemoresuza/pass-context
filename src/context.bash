#!/usr/bin/env bash

CONTEXTS_FILE="${PASSWORD_CONTEXTS_FILE:-"${XDG_CONFIG_HOME}/pass/extensions/contexts.cfg"}"

#
# Prints an error message to stderr.
# Globals:
#   PROGRAM
#   COMMAND
# Arguments:
#   1: format string, 2-n: variables for the format string.
# Outputs:
#   Stderr:
#     An error message.
#
rperr() {
  local fmtstr="${1}"
  shift
  #
  # The format string as a variable is desired behavior.
  # shellcheck disable=SC2059
  #
  printf "%s: ${fmtstr}" "${PROGRAM} ${COMMAND}" "${@}" 1>&2
}

main() {
  sopts="hqCc:v:"
  lopts="help,quiet,current,config:,variable:"
  argv="$(getopt -l "${lopts}" -o "${sopts}" -- "${@}" 2>&1)" || {
    argv="${argv%[[:space:]]*}"
    argv="${argv%%[[:cntrl:]]*}"
    rperr "${argv#*[[:space:]]}"
    exit 1
  }

}

main "${@}"
