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
# Suppress warnings about not being able to follow files.
# shellcheck source=/dev/null
#

CONTEXTS_FILE="${PASSWORD_STORE_CONTEXTS_FILE}"
XMENU="${PASSWORD_STORE_XMENU:-dmenu}"
XMENU_FLAGS="${PASSWORD_STORE_XMENU_FLAGS}"

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
  -x, --use-xmenu           Prompt the user to pick a context with the xmenu.
  -X, --xmenu=XMENU         Use XMENU as the xmenu program (implies
                            -x/--use-xmenu).
  -q, --quiet               Suppress context info.
  -h, --help                Print this help message.
EOF
}

#
# Prints to stdout the variables to be sourced.
# Globals:
#   CONTEXTS_FILE
# Arguments:
#   1: context name.
# Outputs:
#   Stdout:
#     The the variables to be sourced.
# Returns:
# 0 on sucess, or 1, when the context is not found.
#
get_context() {
  local variables
  variables="$(
    sed "/\[${1}\]/,/\(^$\|\[.*\]\)/!d
      /^\[.*\]$/d
      s/^/export /" "${CONTEXTS_FILE}"
  )"

  [ -z "${variables}" ] && return 1

  printf "%s\n" "${variables}"
}

main() {
  sopts="hqc:C:v:xX:"
  lopts="help,quiet,change-to:,config:,variable:,use-xmenu,xmenu:"
  argv="$(POSIXLY_CORRECT=1 getopt \
    -l "${lopts}" -o "${sopts}" -- "${@}" 2>&1)" || {
    argv="${argv%[[:space:]]*}"
    argv="${argv%%[[:cntrl:]]*}"
    rperr "${argv#*[[:space:]]}"
    exit 1
  }

  eval set -- "${argv}"

  declare -A args
  args["vars_count"]=0
  while true; do
    case "${1}" in
      "-c" | "--change-to")
        shift
        args["context"]="${1}"
        ;;
      "-C" | "--config")
        shift
        CONTEXTS_FILE="${1}"
        ;;
      "-v" | "--variable")
        shift
        [[ "${1}" =~ ^[^[:digit:]][_[:alnum:]]*=.*$ ]] || {
          rperr "Invalid format for -v/--variable.\n"
          rperr "Format is \"var=value\", being \"var\" a mostly alphanumeric\n"
          rperr "string ('_' is allowed) that does not start with a number."
          exit 1
        }
        args["vars", "${args["vars_count"]}"]="${1}"
        ((args["vars_count"] += 1))
        ;;
      "-x" | "--use-xmenu")
        args["use_xmenu"]=true
        ;;
      "-X" | "--xmenu")
        shift
        XMENU="${1}"
        args["use_xmenu"]=true
        ;;
      "-q" | "--quiet")
        args["quiet"]=true
        ;;
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

  [ "${#}" -eq 0 ] && {
    rperr "No Pass command given.\n"
    exit 1
  }

  if [[ -n "${args["context"]}" || "${args["use_xmenu"]}" == true ]]; then
    [ -r "${CONTEXTS_FILE}" ] || {
      rperr "Couldn't read context file: \"%s\".\n" "${CONTEXTS_FILE}"
      exit 1
    }

    [ "${args["use_xmenu"]}" = true ] && {
      if ! command -v "${XMENU}" 1>/dev/null 2>&1 && [ ! -x "${XMENU}" ]; then
        rperr "\"${XMENU}\" not on path or lacks exec permission.\n"
        exit 1
      fi

      args["context"]="$(
        sed '/^\[.*\]$/!d
          s/\(^\[\|\]$\)//g' "${CONTEXTS_FILE}" \
          | "${XMENU}" ${XMENU_FLAGS}
      )" || {
        rperr "Failed to pick a context from \"%s\".\n" "${XMENU} ${XMENU_FLAGS}"
        exit 1
      }
    }

    local source_content
    source_content="$(get_context "${args["context"]}")" || {
      rperr "Context \"%s\" not found in \"%s\".\n" \
        "${args["context"]}" "${CONTEXTS_FILE}"
      exit 1
    }

    source <(printf "%s\n" "${source_content}")
  fi

  local i
  i=0
  while [ "${i}" -lt "${args["vars_count"]}" ]; do
    eval "export ${args["vars", "${i}"]}"
    ((i++))
  done

  "${PROGRAM}" "${@}" && exit 0 || exit 1
}

main "${@}"
