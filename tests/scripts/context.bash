#!/usr/bin/env bash
# file: tests/scripts/context.bash

#
# Shellcheck Global Directives
#
# Suppress warnings about not being able to follow files.
# shellcheck source=/dev/null
#

oneTimeSetUp() {
  unset PASSWORD_STORE_DIR PASSWORD_STORE_KEY PASSWORD_STORE_GPG_OPTS \
    PASSWORD_STORE_X_SELECTION PASSWORD_STORE_UMASK \
    PASSWORD_STORE_GENERATED_LENGTH PASSWORD_STORE_CHARACTER_SET \
    PASSWORD_STORE_CHARACTER_SET_NO_SYMBOLS PASSWORD_STORE_ENABLE_EXTENSIONS \
    PASSWORD_STORE_EXTENSIONS_DIR PASSWORD_STORE_SIGNING_KEY

  unset PASSWORD_STORE_CONTEXTS_FILE

  export PASSWORD_STORE_ENABLE_EXTENSIONS=true
  export PASSWORD_STORE_EXTENSIONS_DIR="${TARGET_TESTS_DIR}/extensions"
  install -Dm0700 -t "${PASSWORD_STORE_EXTENSIONS_DIR}" "${EXTENSION}"

  unset GNUPGHOME
  export GNUPGHOME="${TARGET_TESTS_DIR}/gnupg"
  install -dm0700 "${GNUPGHOME}"
  gpg2 --yes --batch --pinentry-mode loopback --import "${PGP_KEY}"
  local trust_gpg_cmd="${GNUPGHOME}/trust_gpg_cmd"
  printf "5\ny\n" 1>"${trust_gpg_cmd}"
  gpg2 --command-file "${trust_gpg_cmd}" --expert --edit-key "${PGP_KEY_ID}" trust

  PASS_CMD="$(command -v pass)"

  export PASSWORD_STORE_CONTEXTS_FILE="${TARGET_TESTS_DIR}/contexts.cfg"
  CONTEXT1="CONTEXT1"
  CONTEXT2="CONTEXT2"
  printf "[%s]\nPASSWORD_STORE_DIR=%s\n" \
    "${CONTEXT1}" "${PWD}/${TARGET_TESTS_DIR}/context1" \
    1>"${PASSWORD_STORE_CONTEXTS_FILE}"
  printf "[%s]\nPASSWORD_STORE_DIR=%s\n" \
    "${CONTEXT2}" "${PWD}/${TARGET_TESTS_DIR}/context2" \
    1>>"${PASSWORD_STORE_CONTEXTS_FILE}"
}

oneTimeTearDown() {
  rm -rf "${TARGET_TESTS_DIR:?}/"*
}

testExtensionsWork() {
  ls -lh "${PASSWORD_STORE_EXTENSIONS_DIR}"
  "${PASS_CMD}" context -h
  assertTrue " Extension not recognized" "${?}"

  return 0
}

testInitRepos() {
  "${PASS_CMD}" context --change-to="${CONTEXT1}" \
    init "${PGP_KEY_ID}" 1>/dev/null 2>&1
  assertTrue " Failed to initialize repo for \"${CONTEXT1}\"" "${?}"

  "${PASS_CMD}" context --change-to="${CONTEXT2}" \
    init "${PGP_KEY_ID}" 1>/dev/null 2>&1
  assertTrue " Failed to initialize repo for \"${CONTEXT2}\"" "${?}"

  return 0
}

testGeneratePass() {
  "${PASS_CMD}" context --change-to="${CONTEXT1}" \
    generate "${CONTEXT1}" 1>/dev/null 2>&1
  assertTrue " Failed to generate password file for \"${CONTEXT1}\"" "${?}"

  "${PASS_CMD}" context --change-to="${CONTEXT2}" \
    generate "${CONTEXT2}" 1>/dev/null 2>&1
  assertTrue " Failed to generate password file for \"${CONTEXT2}\"" "${?}"

  return 0
}

testShowPass() {
  "${PASS_CMD}" context --change-to="${CONTEXT1}" \
    show "${CONTEXT2}" 1>/dev/null 2>&1
  assertFalse " Succeed to find password file \"${CONTEXT2}\"" "${?}"

  "${PASS_CMD}" context --change-to="${CONTEXT2}" \
    show "${CONTEXT1}" 1>/dev/null 2>&1
  assertFalse " Succeed to find password file \"${CONTEXT1}\"" "${?}"

  return 0
}

source shunit2
