#!/usr/bin/env bash
# file: tests/rperr.bash

#
# Shellcheck Global Directives
#
# Suppress warnings about following file paths.
# shellcheck source=/dev/null
#

oneTimeSetUp() {
  #
  # It's a grep pattern not an expression.
  # shellcheck disable=SC2016
  #
  source <(grep -v '^\(main "${@}"$\|#!\)' "${EXTENSION}")
  export XMENU="/usr/bin/env false"
  export PROGRAM="pass"
  export COMMAND="context"
}

testTty() {
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
