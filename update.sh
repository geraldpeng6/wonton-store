#!/usr/bin/env bash
# 重新生成 index.json：按下面列的 tag 取每个插件仓库，用 `wonton-core plugin index-entry` 写进来。
# 要有 Git、Python 3、Docker Compose 和 wonton-core 命令，或者用 WONTON_CORE 指定核心路径。
#
#   ./update.sh
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
core="${WONTON_CORE:-wonton-core}"
plugins=(
  geraldpeng6/wonton-plugin-autobangumi@v0.1.0
  geraldpeng6/wonton-plugin-vllm@v0.1.0
  geraldpeng6/wonton-plugin-radarr@v0.1.0
  wontonapp/wonton-plugin-minecraft@v0.1.0
  geraldpeng6/wonton-plugin-bazarr@v0.1.0
  geraldpeng6/wonton-plugin-lidarr@v0.1.0
  geraldpeng6/wonton-plugin-sonarr@v0.1.0
  geraldpeng6/wonton-plugin-n8n@v0.1.1
  geraldpeng6/wonton-plugin-sillytavern@v0.1.0
  geraldpeng6/wonton-plugin-node-red@v0.1.0
  geraldpeng6/wonton-plugin-qinglong@v0.1.0
  geraldpeng6/wonton-plugin-open-notebook@v0.1.0
  geraldpeng6/wonton-plugin-astrbot@v0.1.0
  geraldpeng6/wonton-plugin-searxng@v0.1.0
  geraldpeng6/wonton-plugin-navidrome@v0.1.1
  geraldpeng6/wonton-plugin-paperless-ngx@v0.1.2
  geraldpeng6/wonton-plugin-immich@v0.3.6
  geraldpeng6/wonton-plugin-syncthing@v0.1.1
  geraldpeng6/wonton-plugin-samba@v0.1.2
  geraldpeng6/wonton-plugin-files@v0.2.3
  geraldpeng6/wonton-plugin-browser@v0.1.1
  geraldpeng6/wonton-plugin-memos@v0.1.2
  geraldpeng6/wonton-plugin-miniflux@v0.1.2
  geraldpeng6/wonton-plugin-filebrowser@v0.1.3
  geraldpeng6/wonton-plugin-actual@v0.1.2
  geraldpeng6/wonton-plugin-uptime-kuma@v0.2.0
  geraldpeng6/wonton-plugin-open-webui@v0.2.1
  geraldpeng6/wonton-plugin-vane@v0.2.0
  geraldpeng6/wonton-plugin-ollama@v0.1.1
  geraldpeng6/wonton-plugin-hermes@v0.6.8
  geraldpeng6/wonton-plugin-openclaw@v0.1.4
  wontonapp/wonton-agents/agents/omp@omp/v0.1.4
  wontonapp/wonton-agents/agents/codex@codex/v0.1.1
  wontonapp/wonton-agents/agents/claude-code@claude-code/v0.1.1
  wontonapp/wonton-agents/agents/dsh@dsh/v0.1.2
  geraldpeng6/wonton-plugin-proxy@v0.1.2
  geraldpeng6/wonton-plugin-excalidraw@v0.1.0
  geraldpeng6/wonton-plugin-homebox@v0.1.1
  geraldpeng6/wonton-plugin-gitea@v0.1.0
  geraldpeng6/wonton-plugin-copyparty@v0.1.0
  geraldpeng6/wonton-plugin-changedetection@v0.1.0
  geraldpeng6/wonton-plugin-bookstack@v0.1.0
  geraldpeng6/wonton-plugin-cloudreve@v0.1.0
  geraldpeng6/wonton-plugin-kavita@v0.1.0
  geraldpeng6/wonton-plugin-koel@v0.1.0
  geraldpeng6/wonton-plugin-sftpgo@v0.1.0
  geraldpeng6/wonton-plugin-trilium@v0.1.0
  geraldpeng6/wonton-plugin-home-assistant@v0.2.0
  geraldpeng6/wonton-plugin-audiobookshelf@v0.1.0
  geraldpeng6/wonton-plugin-romm@v0.1.0
  geraldpeng6/wonton-plugin-prowlarr@v0.1.0
  geraldpeng6/wonton-plugin-tubearchivist@v0.1.0
  geraldpeng6/wonton-plugin-flood@v0.1.0
  geraldpeng6/wonton-plugin-komga@v0.1.0
  geraldpeng6/wonton-plugin-openlist@v0.1.0
  geraldpeng6/wonton-plugin-frigate@v0.1.0
  geraldpeng6/wonton-plugin-siyuan@v0.1.0
  geraldpeng6/wonton-plugin-karakeep@v0.1.0
  geraldpeng6/wonton-plugin-qbittorrent@v0.3.0
  geraldpeng6/wonton-plugin-librephotos@v0.1.1
  geraldpeng6/wonton-plugin-stirling-pdf@v0.1.1
  geraldpeng6/wonton-plugin-vikunja@v0.2.0
  geraldpeng6/wonton-plugin-seerr@v0.1.0
  geraldpeng6/wonton-plugin-nextcloud@v0.2.0
  geraldpeng6/wonton-plugin-ente@v0.1.0
  geraldpeng6/wonton-plugin-radicale@v0.1.0
  geraldpeng6/wonton-plugin-drawio@v0.1.0
  geraldpeng6/wonton-plugin-kiwix@v0.1.0
  geraldpeng6/wonton-plugin-music-assistant@v0.1.0
  geraldpeng6/wonton-plugin-calibre-web-automated@v0.1.2
  geraldpeng6/wonton-plugin-mosquitto@v0.1.0
  geraldpeng6/wonton-plugin-homebridge@v0.1.0
  geraldpeng6/wonton-plugin-grocy@v0.1.0
  geraldpeng6/wonton-plugin-donetick@v0.1.0
  geraldpeng6/wonton-plugin-ghostfolio@v0.1.0
  geraldpeng6/wonton-plugin-wallos@v0.1.0
  geraldpeng6/wonton-plugin-gramps-web@v0.1.0
  geraldpeng6/wonton-plugin-reactive-resume@v0.1.1
  geraldpeng6/wonton-plugin-luanti@v0.1.0
  geraldpeng6/wonton-plugin-halo@v0.1.0
  geraldpeng6/wonton-plugin-esphome@v0.1.0
  geraldpeng6/wonton-plugin-dawarich@v0.1.0
  geraldpeng6/wonton-plugin-mtranserver@v0.1.0
  geraldpeng6/wonton-plugin-grist@v0.1.0
  geraldpeng6/wonton-plugin-glance@v0.1.1
  geraldpeng6/wonton-plugin-ezbookkeeping@v0.1.0
  geraldpeng6/wonton-plugin-convertx@v0.1.0
  geraldpeng6/wonton-plugin-razzia@v0.1.0
  geraldpeng6/wonton-plugin-spliit@v0.1.1
  geraldpeng6/wonton-plugin-wger@v0.1.0
  geraldpeng6/wonton-plugin-babybuddy@v0.1.0
  geraldpeng6/wonton-plugin-traccar@v0.1.2
  geraldpeng6/wonton-plugin-scanservjs@v0.1.0
  geraldpeng6/wonton-plugin-rsshub@v0.1.0
)

work="$(mktemp -d "$here/.update.XXXXXX")"
trap 'rm -rf "$work"' EXIT
mkdir "$work/manifests"
# 列表项写 `owner/repo@tag` 或 `owner/repo/子目录@子目录最后一段/v版本`；子目录可以有多段，同一仓库里最后一段不能重复。
for plugin in "${plugins[@]}"; do
  path="${plugin%@*}"
  tag="${plugin#*@}"
  owner="${path%%/*}"
  rest="${path#*/}"
  name="${rest%%/*}"
  repo="$owner/$name"
  subdir="${rest#*/}"
  # 同一仓库可以有多行（monorepo 里几家各钉各的 tag），克隆目录按「仓库@tag」分开，同一组合只克隆一次。
  src="$work/src/${repo//\//_}_${tag//\//_}"
  if test ! -d "$src/.git"; then
    git clone -q -c advice.detachedHead=false --depth 1 --branch "$tag" "https://github.com/$repo.git" "$src"
  fi
  commit="$(git -C "$src" rev-parse HEAD)"
  if test "$subdir" = "$rest"; then
    dir="$src"
  else
    dir="$src/$subdir"
  fi
  "$core" plugin check "$dir" --official >/dev/null
  "$core" plugin index-entry "$dir" "github:$path" "$commit" --index "$work/index"
  # 核心 CLI 不输出 kind；由 Compose 解析扩展字段，不展开变量或补齐宿主路径。
  docker compose -p wonton-store -f "$dir/docker-compose.yml" config \
    --format json --no-interpolate --no-normalize --no-consistency \
    --no-env-resolution --no-path-resolution --output "$work/manifests/${path##*/}.json"
  echo "$path $tag → $commit"
done
python3 - "$here" "$work" <<'PY'
import hashlib
import json
from pathlib import Path
import subprocess
import sys

here, work = map(Path, sys.argv[1:])
index_path = work / "index/index.json"
index = json.loads(index_path.read_text(encoding="utf-8"))
onboarding = json.loads((here / "onboarding.json").read_text(encoding="utf-8"))
manifests = [
    json.loads(path.read_text(encoding="utf-8"))["x-wonton"]
    for path in sorted((work / "manifests").glob("*.json"))
]
kinds = {manifest["id"]: manifest["kind"] for manifest in manifests}
for plugin_id in onboarding["agents"]:
    if plugin_id not in kinds:
        sys.exit(f"onboarding.agents 的插件不在索引里：{plugin_id}")
    if kinds[plugin_id] != "agent":
        sys.exit(f"onboarding.agents 的插件不是 kind: agent：{plugin_id}")
for need in onboarding["needs"]:
    for plugin_id in need["plugins"]:
        if plugin_id not in kinds:
            sys.exit(f"onboarding.needs[{need['id']}] 的插件不在索引里：{plugin_id}")
index["onboarding"] = onboarding
index["registry_mirrors"] = json.loads((here / "registry-mirrors.json").read_text(encoding="utf-8"))

docs = work / "docs"
subprocess.run([
    "git", "clone", "-q", "--depth", "1", "--branch", "main", "--single-branch",
    "https://github.com/wontonapp/wonton-docs.git", str(docs),
], check=True)
commit = subprocess.check_output(["git", "-C", str(docs), "rev-parse", "HEAD"], text=True).strip()
files = {
    path.relative_to(docs).as_posix(): hashlib.sha256(path.read_bytes()).hexdigest()
    for path in sorted((docs / "user").rglob("*"))
    if path.is_file() and path.parent != docs / "user"
}
if not files:
    sys.exit("wonton-docs 的 user/ 下没有文档页")
index["docs"] = {
    "source": "github:wontonapp/wonton-docs",
    "commit": commit,
    "min_core": "0.1.0-beta.1",
    "files": files,
}
index_path.write_text(json.dumps(index, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"wonton-docs main → {commit}（{len(files)} 个文件）")
PY
"$core" plugin check-index "$work/index/index.json"
mv "$work/index/index.json" "$here/index.json"
