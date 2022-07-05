#!/usr/bin/env bash
# file: tests/get_context.bash

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
  randstr="$(tr -dc '[:alnum:]' </dev/urandom | dd count=1 bs=16 2>/dev/null)"
  CONTEXTS_FILE="${TMPDIR:-/dev/shm}/context-file.${randstr}"
  CONTEXT="CONTEXT1"
}

oneTimeTearDown() {
  rm -f "${CONTEXTS_FILE}" "${TMP_SOURCE_FILE}"
}

tearDown() {
  : >"${CONTEXTS_FILE}"
}

testOneContext() {
  local content line1 line2
  line1="var1=val1"
  line2="var2=val2"
  printf -v content "[%s]\n%s\n%s\n" "${CONTEXT}" "${line1}" "${line2}"
  printf "%s" "${content}" 1>"${CONTEXTS_FILE}"

  assertEquals " Failed to get correct variables:" \
    "${line1}"$'\n'"${line2}" "$(get_context "${CONTEXT}")"

  return 0
}

testMultContexts() {
  local content line1 line2
  line1="var1=val1"
  line2="var2=val2"
  printf -v content "[%s]\n%s\n%s\n" "${CONTEXT}" "${line1}" "${line2}"
  printf "%s" "${content}" 1>"${CONTEXTS_FILE}"

  local content2 line1_1 line2_1
  line1_1="var1=val1"
  line2_1="var2=val2"
  printf -v content2 "[%s]\n%s\n%s\n" "${CONTEXT}" "${line1_1}" "${line2_1}"
  printf "%s" "${content2}" 1>>"${CONTEXTS_FILE}"

  assertEquals " Failed to get correct variables:" \
    "${line1}"$'\n'"${line2}" "$(get_context "${CONTEXT}")"

  return 0
}

testEmptyVariables() {
  get_context "${CONTEXTS_FILE}" 1>/dev/null 2>&1
  assertFalse " Success with the variable \"variables\" empty" "${?}"

  return 0
}

source shunit2
