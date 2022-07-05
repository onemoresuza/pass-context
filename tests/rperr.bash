#!/usr/bin/env bash
# file: tests/rperr.bash

#
# Shellcheck Global Directives
#
# Suppress warnings about following file paths.
# shellcheck source=/dev/null
#

oneTimeSetUp() {
  mkdir -p "${TARGET_TESTS_DIR}"
  randstr="$(tr -dc '[:alnum:]' </dev/urandom | dd count=1 bs=16 2>/dev/null)"
  TMP_SOURCE_FILE="${TARGET_TESTS_DIR}/TMP_SOURCE_FILE.${randstr}"
  #
  # It's a grep pattern not an expression.
  # shellcheck disable=SC2016
  #
  grep -v '^\(main "${@}"$\|#!\)' "${EXTENSION}" 1>"${TMP_SOURCE_FILE}"
  source "${TMP_SOURCE_FILE}"
  export PROGRAM="pass"
  export COMMAND="context"
}

oneTimeTearDown() {
  rm -f "${TMP_SOURCE_FILE}"
}

testTty() {
  stderr="$(rperr "Message on a tty" 2>&1)"
  assertTrue " rperr() failed" "${?}"

  assertTrue " Stderr is empty" "[ -n \"${stderr}\" ]"
}

source shunit2
