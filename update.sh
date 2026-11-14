#!/usr/bin/env bash
# 重新生成 index.json：按下面列的 tag 取每个插件仓库，用 `wonton-core plugin index-entry` 写进来。
# 要有 Git、Python 3、Docker Compose 和 wonton-core 命令，或者用 WONTON_CORE 指定核心路径。
#
#   ./update.sh
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
core="${WONTON_CORE:-wonton-core}"
plugins=(
  wontonapp/wonton-plugins/autobangumi@autobangumi/v0.1.1
  wontonapp/wonton-plugins/vllm@vllm/v0.1.1
  wontonapp/wonton-plugins/radarr@radarr/v0.1.1
  wontonapp/wonton-plugin-minecraft@v0.1.0
  wontonapp/wonton-plugins/bazarr@bazarr/v0.1.1
  wontonapp/wonton-plugins/lidarr@lidarr/v0.1.1
  wontonapp/wonton-plugins/sonarr@sonarr/v0.1.1
  wontonapp/wonton-plugins/n8n@n8n/v0.1.2
  wontonapp/wonton-plugins/sillytavern@sillytavern/v0.1.1
  wontonapp/wonton-plugins/node-red@node-red/v0.1.1
  wontonapp/wonton-plugins/qinglong@qinglong/v0.1.1
  wontonapp/wonton-plugins/open-notebook@open-notebook/v0.1.1
  wontonapp/wonton-plugins/astrbot@astrbot/v0.1.1
  wontonapp/wonton-plugins/searxng@searxng/v0.1.1
  wontonapp/wonton-plugins/navidrome@navidrome/v0.1.2
  wontonapp/wonton-plugins/paperless-ngx@paperless-ngx/v0.1.3
  geraldpeng6/wonton-plugin-immich@v0.3.6
  wontonapp/wonton-plugins/syncthing@syncthing/v0.1.2
  wontonapp/wonton-plugins/samba@samba/v0.1.3
  geraldpeng6/wonton-plugin-files@v0.2.3
  geraldpeng6/wonton-plugin-browser@v0.1.1
  wontonapp/wonton-plugins/memos@memos/v0.1.5
  wontonapp/wonton-plugins/miniflux@miniflux/v0.1.3
  wontonapp/wonton-plugins/filebrowser@filebrowser/v0.1.4
  wontonapp/wonton-plugins/actual@actual/v0.1.5
  wontonapp/wonton-plugins/uptime-kuma@uptime-kuma/v0.2.1
  wontonapp/wonton-plugins/open-webui@open-webui/v0.2.2
  wontonapp/wonton-plugins/vane@vane/v0.2.1
  wontonapp/wonton-plugins/ollama@ollama/v0.1.2
  wontonapp/wonton-plugin-hermes@v0.7.4
  wontonapp/wonton-plugin-openclaw@v0.2.1
  geraldpeng6/wonton-plugin-zcode@v0.1.3
  wontonapp/wonton-agents/agents/omp@omp/v0.1.5
  wontonapp/wonton-agents/agents/codex@codex/v0.1.2
  wontonapp/wonton-agents/agents/claude-code@claude-code/v0.1.2
  wontonapp/wonton-agents/agents/dsh@dsh/v0.1.3
  wontonapp/wonton-agents/agents/opencode@opencode/v0.1.2
  wontonapp/wonton-agents/agents/qwen-code@qwen-code/v0.1.2
  wontonapp/wonton-plugins/proxy@proxy/v0.1.3
  wontonapp/wonton-plugins/excalidraw@excalidraw/v0.1.1
  wontonapp/wonton-plugins/penpot@penpot/v0.1.1
  wontonapp/wonton-plugins/homebox@homebox/v0.2.0
  wontonapp/wonton-plugins/gitea@gitea/v0.2.0
  wontonapp/wonton-plugins/copyparty@copyparty/v0.1.1
  wontonapp/wonton-plugins/changedetection@changedetection/v0.1.1
  wontonapp/wonton-plugins/bookstack@bookstack/v0.1.1
  wontonapp/wonton-plugins/cloudreve@cloudreve/v0.1.1
  wontonapp/wonton-plugins/kavita@kavita/v0.1.1
  wontonapp/wonton-plugins/koel@koel/v0.2.0
  wontonapp/wonton-plugins/sftpgo@sftpgo/v0.2.0
  wontonapp/wonton-plugins/trilium@trilium/v0.1.1
  wontonapp/wonton-plugins/home-assistant@home-assistant/v0.2.1
  wontonapp/wonton-plugins/audiobookshelf@audiobookshelf/v0.2.0
  wontonapp/wonton-plugins/romm@romm/v0.2.0
  wontonapp/wonton-plugins/prowlarr@prowlarr/v0.2.0
  wontonapp/wonton-plugins/tubearchivist@tubearchivist/v0.2.0
  wontonapp/wonton-plugins/flood@flood/v0.1.1
  wontonapp/wonton-plugins/komga@komga/v0.1.1
  wontonapp/wonton-plugins/openlist@openlist/v0.1.1
  wontonapp/wonton-plugins/frigate@frigate/v0.1.1
  wontonapp/wonton-plugins/siyuan@siyuan/v0.1.1
  wontonapp/wonton-plugins/karakeep@karakeep/v0.1.1
  wontonapp/wonton-plugins/qbittorrent@qbittorrent/v0.3.1
  wontonapp/wonton-plugins/librephotos@librephotos/v0.1.2
  wontonapp/wonton-plugins/stirling-pdf@stirling-pdf/v0.2.0
  wontonapp/wonton-plugins/vikunja@vikunja/v0.3.0
  wontonapp/wonton-plugins/seerr@seerr/v0.2.0
  wontonapp/wonton-plugins/nextcloud@nextcloud/v0.2.1
  wontonapp/wonton-plugins/ente@ente/v0.1.1
  wontonapp/wonton-plugins/radicale@radicale/v0.1.1
  wontonapp/wonton-plugins/drawio@drawio/v0.1.1
  geraldpeng6/wonton-plugin-kiwix@v0.1.1
  wontonapp/wonton-plugins/music-assistant@music-assistant/v0.1.1
  wontonapp/wonton-plugins/calibre-web-automated@calibre-web-automated/v0.1.3
  wontonapp/wonton-plugins/mosquitto@mosquitto/v0.1.1
  wontonapp/wonton-plugins/homebridge@homebridge/v0.1.1
  wontonapp/wonton-plugins/grocy@grocy/v0.1.1
  wontonapp/wonton-plugins/donetick@donetick/v0.1.1
  wontonapp/wonton-plugins/ghostfolio@ghostfolio/v0.1.1
  wontonapp/wonton-plugins/wallos@wallos/v0.1.1
  wontonapp/wonton-plugins/gramps-web@gramps-web/v0.1.1
  wontonapp/wonton-plugins/reactive-resume@reactive-resume/v0.1.2
  wontonapp/wonton-plugins/luanti@luanti/v0.1.1
  wontonapp/wonton-plugins/halo@halo/v0.1.1
  wontonapp/wonton-plugins/esphome@esphome/v0.1.1
  wontonapp/wonton-plugins/dawarich@dawarich/v0.1.1
  geraldpeng6/wonton-plugin-mtranserver@v0.1.1
  wontonapp/wonton-plugins/grist@grist/v0.1.1
  wontonapp/wonton-plugins/glance@glance/v0.1.2
  wontonapp/wonton-plugins/ezbookkeeping@ezbookkeeping/v0.1.2
  wontonapp/wonton-plugins/convertx@convertx/v0.1.1
  wontonapp/wonton-plugins/razzia@razzia/v0.1.1
  wontonapp/wonton-plugins/spliit@spliit/v0.1.2
  wontonapp/wonton-plugins/wger@wger/v0.1.1
  wontonapp/wonton-plugins/babybuddy@babybuddy/v0.1.1
  wontonapp/wonton-plugins/traccar@traccar/v0.1.3
  wontonapp/wonton-plugins/scanservjs@scanservjs/v0.1.1
  wontonapp/wonton-plugins/rsshub@rsshub/v0.1.1
  wontonapp/wonton-plugins/neko@neko/v0.1.0
  geraldpeng6/wonton-plugin-agent-orchestrator@v0.1.2
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
