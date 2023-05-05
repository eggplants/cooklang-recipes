#!/usr/bin/env bash

set -euo pipefail

COOK_VERSION="0.1.5"
BASE_COOK_DIST="https://github.com/cooklang/CookCLI/releases/download/v${COOK_VERSION}"

_install_cook() {
  if ! command -v curl unzip &>/dev/null; then
    echo "install: curl and unzip" >&2
    return 1
  fi

  local dl_zip_path=".cook_${RANDOM}.zip"
  curl -L "$1" --output "$dl_zip_path"
  unzip "$dl_zip_path" "cook" -d "${dl_zip_path//.zip/}"
  if ! mv "${dl_zip_path//.zip//cook}" /usr/local/bin/cook; then
    sudo mv "${dl_zip_path//.zip//cook}" /usr/local/bin/cook
  fi
  rm -rf "$dl_zip_path" "${dl_zip_path//.zip/}"
  echo "installed: $(command -v cook)"
}

main() {
  if command -v cook &>/dev/null; then
    echo "already installed: $(command -v cook)" >&2
    return 0
  fi

  if command -v brew &>/dev/null; then
    brew install cooklang/tap/cook
    return $?
  fi

  if ! command -v uname &>/dev/null; then
    echo "install: uname" >&2
    return 1
  fi

  if [[ "$(uname -s)" == "Darwin" ]]; then
    _install_cook "${BASE_COOK_DIST}/CookCLI_${COOK_VERSION}_darwin_amd64_arm64.zip"
    return $?
  fi

  case "$(uname -m)" in
  x86_64 | amd64)
    _install_cook "${BASE_COOK_DIST}/CookCLI_${COOK_VERSION}_linux_amd64.zip"
    return $?
    ;;
  arm64)
    _install_cook "${BASE_COOK_DIST}/CookCLI_${COOK_VERSION}_linux_arm64.zip"
    return $?
    ;;
  esac

  return 1
}

main
exit $?
