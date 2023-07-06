#!/bin/bash

ALL=0
OK=0
FAIL=0

function check() {
  ALL=$(( ALL + 1 ))
  EXPECTED="$1 " # note the space after the variable
  RESULT="$2"    # but here no space
  if [ "$EXPECTED" == "$OUTPUT" ]; then
    echo "OK: $OUTPUT;"
    OK=$(( OK + 1 ))
  else
    echo "FAIL:     $OUTPUT;"
    echo "      VS: $EXPECTED;"
    FAIL=$(( FAIL + 1 ))
  fi
}

function test_cjs() {
  OUTPUT=$(node test.cjs 2>&1 | tail -n 2 | tr '\n' ' ')
  check "$1" "$OUTPUT"
}
function test_mjs() {
  OUTPUT=$(node test.mjs 2>&1 | tail -n 2 | tr '\n' ' ')
  check "$1" "$OUTPUT"
}

function test_mjs_loader() {
  OUTPUT=$(node --loader=./loader.mjs test.mjs 2>&1 | tail -n 2 | tr '\n' ' ')
  check "$1" "$OUTPUT"
}

function run_test_v6() {
  nvm use v6 &> /dev/null
  test_cjs "v6 cjs { hasAwait: false, kind: 'cjs' } awaitHack === false"
}

function run_test_v7() {
  nvm use v7 &> /dev/null
  test_cjs "v7 cjs { hasAwait: true, kind: 'cjs' } awaitHack === false"
}

function run_test_v20() {
  nvm use v20 &> /dev/null
  test_cjs "v20 cjs { hasAwait: true, kind: 'cjs' } awaitHack === false"
  test_mjs "v20 esm { hasAwait: true, kind: 'cjs' } awaitHack === true"
  test_mjs_loader "v20 esm { hasAwait: true, kind: 'esm' } awaitHack === true"
}

function nvm_current_use() {
  nvm ls --no-colors | grep "^->" | xargs echo -n | cut -f2 -d' '
}

function nvm_ls_trimmed() {
  nvm ls --no-colors "$1" | xargs echo -n | grep -oP 'v[^ ]+'
}

function uninstalled_node_version() {
  if [ -z "$(nvm_ls_trimmed $1)" ]; then
    echo $1
  fi
}

function install_node_version() {
  echo "Installing Node version $1..."
  nvm install $1 &> /dev/null
  echo "Node version $(nvm_ls_trimmed $1) installed"
}

# This script only works from the directory it is in
cd "$(dirname "$0")"

if ! [ -f ~/.nvm/nvm.sh ]; then
  echo "The Node Version Manager (nvm) is needed for the Node test"
  echo "You can install it from https://github.com/nvm-sh/nvm"
  exit 1
fi

. ~/.nvm/nvm.sh

V6=$(uninstalled_node_version v6)
V7=$(uninstalled_node_version v7)
V20=$(uninstalled_node_version v20)

if ! [ -z "$V6" ]; then VERSIONS="$V6"; fi
if ! [ -z "$V7" ]; then VERSIONS="$VERSIONS $V7"; fi
if ! [ -z "$V20" ]; then VERSIONS="$VERSIONS $V20"; fi
VERSIONS="$(echo "$VERSIONS" | xargs echo -n)"

if ! [ -z "$VERSIONS" ]; then
  echo "Node version(s) $VERSIONS need to be installed"
  echo "These versions will be uninstalled after the test run"
  
  read -p "Proceed? (y|N) " ANSWER
  [ "$ANSWER" == "y" ] || kill $$
fi

trap uninstall EXIT

CURRENT_USE=$(nvm_current_use)
#echo "Current nvm use: $CURRENT_USE"

if ! [ -z "$V6" ]; then install_node_version "$V6"; fi
if ! [ -z "$V7" ]; then install_node_version "$V7"; fi
if ! [ -z "$V20" ]; then install_node_version "$V20"; fi

echo "Testing with Node versions $(nvm_ls_trimmed v6), $(nvm_ls_trimmed v7) \
and $(nvm_ls_trimmed v20)..."

run_test_v6
run_test_v7
run_test_v20

echo "Tests run:    $ALL"
echo "Tests ok:     $OK"
echo "Tests failed: $FAIL"

function uninstall() {
  echo "Cleaning up nvm"
  nvm use "$CURRENT_USE" &> /dev/null

  if ! [ -z "$V6" ]; then nvm uninstall v6; fi
  if ! [ -z "$V7" ]; then nvm uninstall v7; fi
  if ! [ -z "$V20" ]; then nvm uninstall v20; fi

  nvm use "$CURRENT_USE" &> /dev/null
}