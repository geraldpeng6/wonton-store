#!/usr/bin/env bash
# 重新生成 index.json：按下面列的 tag 取每个插件仓库，用 `wonton-core plugin index-entry` 写进来。
# 要有 wonton-core 命令，或者用 WONTON_CORE 指定它的路径。
#
#   ./update.sh
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
core="${WONTON_CORE:-wonton-core}"
plugins=(
  geraldpeng6/wonton-plugin-navidrome@store-bridge
  geraldpeng6/wonton-plugin-paperless-ngx@store-bridge
  geraldpeng6/wonton-plugin-immich@store-bridge
  geraldpeng6/wonton-plugin-syncthing@store-bridge
  geraldpeng6/wonton-plugin-samba@store-bridge
  geraldpeng6/wonton-plugin-files@store-bridge
  geraldpeng6/wonton-plugin-browser@store-bridge
  geraldpeng6/wonton-plugin-memos@store-bridge
  geraldpeng6/wonton-plugin-miniflux@store-bridge
  geraldpeng6/wonton-plugin-filebrowser@store-bridge
  geraldpeng6/wonton-plugin-actual@store-bridge
  geraldpeng6/wonton-plugin-uptime-kuma@store-bridge
  geraldpeng6/wonton-plugin-open-webui@store-bridge
  geraldpeng6/wonton-plugin-vane@store-bridge
  geraldpeng6/wonton-plugin-hermes@v0.5.3
)

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
rm -f "$here/index.json"
for plugin in "${plugins[@]}"; do
  name="${plugin%@*}"
  tag="${plugin#*@}"
  git clone -q -c advice.detachedHead=false --depth 1 --branch "$tag" "https://github.com/$name.git" "$work/$name"
  commit="$(git -C "$work/$name" rev-parse HEAD)"
  "$core" plugin check "$work/$name" >/dev/null
  "$core" plugin index-entry "$work/$name" "github:$name" "$commit" --index "$work/index"
  echo "$name $tag → $commit"
done
cp "$work/index/index.json" "$here/index.json"
