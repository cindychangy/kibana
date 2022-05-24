#!/usr/bin/env bash

set -euo pipefail

# $1 file name, ex: "target/dir-listing-jest.txt"
# $2 directory to be listed, ex: target/kibana-coverage/jest
dirListing() {
  local fileName=$1
  local dir=$2

  ls -l "$dir" >"$fileName"

  printf "\n### %s \n\tlisted to: %s\n" "$dir" "$fileName"
  buildkite-agent artifact upload "$fileName"

  printf "\n### %s Uploaded\n" "$fileName"
}

replacePaths() {
  for x in $(ls "$1"); do
    echo "### KIBANA_DIR: $KIBANA_DIR"
    node .buildkite/scripts/steps/code_coverage/clean_coverage_paths.js "$1/$x"
  done
}

header() {
  local fileName=$1

  echo "" >"$fileName"

  echo "### File Name:" >>"$fileName"
  printf "\t%s\n" "$fileName" >>"$fileName"
}

fileHeads() {
  local fileName=$1
  local dir=$2

  header "$fileName"

  while read -r x; do
    printf "\n### BEGIN %s\n\n" "$x" >>"$fileName"
    head -2 "$x" >>"$fileName"
    printf "\n### END %s\n\n" "$x" >>"$fileName"
  done <<<"$(find "$dir" -maxdepth 1 -type f -name '*.json')"

  buildkite-agent artifact upload "$fileName"

  printf "\n### %s Uploaded\n" "$fileName"
}

collectAndUpload() {
  local fileName=$1
  local dir=$2

  tar -czf "$fileName" "$dir"

  buildkite-agent artifact upload "$fileName"

  printf "\n### %s Uploaded\n" "$fileName"
}
