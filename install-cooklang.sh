#!/usr/bin/env bash

set -euo pipefail

COOK_VERSION="0.8.0"
BASE_COOK_DIST="https://github.com/cooklang/CookCLI/releases/download/v${COOK_VERSION}"

_install_cook() {
  if ! command -v curl tar &>/dev/null; then
    echo "install: curl and tar" >&2
    return 1
  fi

  local dl_path=".cook_${RANDOM}.tar.gz"
  curl -L "$1" --output "$dl_path"
  tar -zxvf "$dl_path" "cook"
  chmod +x cook
  if ! mv cook /usr/local/bin/cook; then
    sudo mv cook /usr/local/bin/cook
  fi
  rm -rf "$dl_path"
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
    _install_cook "${BASE_COOK_DIST}/cook-x86_64-apple-darwin.tar.gz"
    return $?
  fi

  case "$(uname -m)" in
  x86_64 | amd64)
    _install_cook "${BASE_COOK_DIST}/cook-x86_64-unknown-linux-gnu.tar.gz"
    return $?
    ;;
  arm64)
    # cook-arm-unknown-linux-musleabihf.tar.gz
    _install_cook "${BASE_COOK_DIST}/cook-arm-unknown-linux-musleabihf.tar.gz"
    return $?
    ;;
  esac

  return 1
}

main
exit $?
