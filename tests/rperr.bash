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
  export XMENU="/usr/bin/env false"
  export PROGRAM="pass"
  export COMMAND="context"
}

oneTimeTearDown() {
  rm -f "${TMP_SOURCE_FILE}"
}

testTty() {
  ls -lh "${TARGET_TESTS_DIR}"
  rperr "TEST"
  stderr="$(rperr "Message on a tty" 2>&1)"
  assertTrue " rperr() failed" "${?}"

  assertTrue " Stderr is empty" "[ -n \"${stderr}\" ]"
}

testNoTty() {
  #
  # It's very uncommon to have an available x-server on CI/CD platforms; for
  # that reason, an error may be forced by using `false` as `XMENU`.
  #
  # Realize that this test only verifies if the if-statement is correct, since
  # no xmenu is actually called.
  #

  exec <&-
  rperr "Message not on a tty" 1>/dev/null 2>&1
  assertFalse " Success with \`false\` as \`XMENU\`" "${?}"
}

source shunit2
