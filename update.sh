#!/usr/bin/env bash
# 重新生成 index.json：按下面列的 tag 取每个插件仓库，用 `wonton-core plugin index-entry` 写进来。
# 要有 Git、Python 3、Docker Compose 和 wonton-core 命令，或者用 WONTON_CORE 指定核心路径。
#
#   ./update.sh
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
core="${WONTON_CORE:-wonton-core}"
plugins=(
  geraldpeng6/wonton-plugin-navidrome@v0.1.1
  geraldpeng6/wonton-plugin-paperless-ngx@v0.1.2
  geraldpeng6/wonton-plugin-immich@v0.3.0
  geraldpeng6/wonton-plugin-syncthing@v0.1.1
  geraldpeng6/wonton-plugin-samba@v0.1.2
  geraldpeng6/wonton-plugin-files@v0.2.3
  geraldpeng6/wonton-plugin-browser@v0.1.1
  geraldpeng6/wonton-plugin-memos@v0.1.2
  geraldpeng6/wonton-plugin-miniflux@v0.1.2
  geraldpeng6/wonton-plugin-filebrowser@v0.1.3
  geraldpeng6/wonton-plugin-actual@v0.1.2
  geraldpeng6/wonton-plugin-uptime-kuma@v0.2.0
  geraldpeng6/wonton-plugin-open-webui@v0.1.3
  geraldpeng6/wonton-plugin-vane@v0.1.1
  geraldpeng6/wonton-plugin-ollama@v0.1.0
  geraldpeng6/wonton-plugin-hermes@v0.5.5
  geraldpeng6/wonton-plugin-openclaw@v0.1.1
  geraldpeng6/wonton-plugin-omp@v0.1.1
  geraldpeng6/wonton-plugin-codex@v0.1.1
  geraldpeng6/wonton-plugin-proxy@v0.1.0
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
  geraldpeng6/wonton-plugin-audiobookshelf@v0.1.0
  geraldpeng6/wonton-plugin-romm@v0.1.0
  geraldpeng6/wonton-plugin-prowlarr@v0.1.0
  geraldpeng6/wonton-plugin-tubearchivist@v0.1.0
)

work="$(mktemp -d "$here/.update.XXXXXX")"
trap 'rm -rf "$work"' EXIT
mkdir "$work/manifests"
for plugin in "${plugins[@]}"; do
  name="${plugin%@*}"
  tag="${plugin#*@}"
  git clone -q -c advice.detachedHead=false --depth 1 --branch "$tag" "https://github.com/$name.git" "$work/$name"
  commit="$(git -C "$work/$name" rev-parse HEAD)"
  "$core" plugin check "$work/$name" --official >/dev/null
  "$core" plugin index-entry "$work/$name" "github:$name" "$commit" --index "$work/index"
  # 核心 CLI 不输出 kind；由 Compose 解析扩展字段，不展开变量或补齐宿主路径。
  docker compose -p wonton-store -f "$work/$name/docker-compose.yml" config \
    --format json --no-interpolate --no-normalize --no-consistency \
    --no-env-resolution --no-path-resolution --output "$work/manifests/${name##*/}.json"
  echo "$name $tag → $commit"
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
    "https://github.com/geraldpeng6/wonton-docs.git", str(docs),
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
    "source": "github:geraldpeng6/wonton-docs",
    "commit": commit,
    "min_core": "0.1.0-beta.1",
    "files": files,
}
index_path.write_text(json.dumps(index, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"wonton-docs main → {commit}（{len(files)} 个文件）")
PY
"$core" plugin check-index "$work/index/index.json"
mv "$work/index/index.json" "$here/index.json"
