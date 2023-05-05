#!/usr/bin/env bash

set -euo pipefail

main() {
  if ! command -v cook find jq sed nkf &>/dev/null; then
    echo "install: cook find jq sed nkf" >&2
    exit 1
  fi

  find ./recipes -name '*.cook' | while read -r cook_file_path; do
    local cook_file_name="${cook_file_path##*/}"
    local cook_file_dir="${cook_file_path%/*}"
    for output_file_format in json yaml markdown; do
      local output_file_path="${cook_file_dir}/${cook_file_name//.cook/.}${output_file_format/markdown/md}"
      echo "$output_file_path"
      cook recipe read "$cook_file_path" --output-format "$output_file_format" |
        sed 's/\\\u\(....\)/\&#x\1;/g' |
        nkf --numchar-input -w >"$output_file_path"
      if [[ $output_file_format == json ]]; then
        local formatted_json=".json_${RANDOM}"
        jq . "$output_file_path" >"$formatted_json"
        mv "$formatted_json" "$output_file_path"
      fi
    done
  done
}

main
exit $?
