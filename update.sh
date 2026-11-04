#!/usr/bin/env bash
# 重新生成 index.json：按下面列的 tag 取每个插件仓库，用 `wonton-core plugin index-entry` 写进来。
# 要有 wonton-core 命令，或者用 WONTON_CORE 指定它的路径。
#
#   ./update.sh
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
core="${WONTON_CORE:-wonton-core}"
plugins=(
  geraldpeng6/wonton-plugin-navidrome@v0.1.0
  geraldpeng6/wonton-plugin-paperless-ngx@v0.1.0
  geraldpeng6/wonton-plugin-immich@v0.1.0
  geraldpeng6/wonton-plugin-syncthing@v0.1.0
  geraldpeng6/wonton-plugin-samba@v0.1.0
  geraldpeng6/wonton-plugin-files@v0.2.0
  geraldpeng6/wonton-plugin-browser@v0.1.0
  geraldpeng6/wonton-plugin-memos@v0.1.0
  geraldpeng6/wonton-plugin-miniflux@v0.1.0
  geraldpeng6/wonton-plugin-filebrowser@v0.1.0
  geraldpeng6/wonton-plugin-actual@v0.1.0
  geraldpeng6/wonton-plugin-uptime-kuma@v0.1.0
  geraldpeng6/wonton-plugin-open-webui@v0.1.1
  geraldpeng6/wonton-plugin-vane@v0.1.0
)

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
rm -f "$here/index.json"
for plugin in "${plugins[@]}"; do
  name="${plugin%@*}"
  tag="${plugin#*@}"
  git clone -q -c advice.detachedHead=false --depth 1 --branch "$tag" "https://github.com/$name.git" "$work/$name"
  commit="$(git -C "$work/$name" rev-parse HEAD)"
  "$core" plugin check "$work/$name" --official >/dev/null
  "$core" plugin index-entry "$work/$name" "github:$name" "$commit" --index "$work/index"
  echo "$name $tag → $commit"
done
cp "$work/index/index.json" "$here/index.json"
