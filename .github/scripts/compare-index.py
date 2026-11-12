"""对比提交的 index.json 和在最新 main 上重新生成的结果，并检查列表有没有被删掉的插件。

用法：compare-index.py <基准 update.sh> <本次 update.sh> <提交的 index.json> <重新生成的 index.json>
环境变量 ALLOW_REMOVAL=1 时允许删插件（PR 打了 remove-plugin 标签）。

docs 一项固定的是 wonton-docs main 的当前提交，随时会变，不参与对比。
"""
import json
import os
import re
import sys
from pathlib import Path

base_sh, head_sh, committed, generated = map(Path, sys.argv[1:])


def listed(path):
    text = path.read_text(encoding="utf-8")
    block = re.search(r"^plugins=\(\n(.*?)^\)", text, re.S | re.M)
    if not block:
        sys.exit(f"{path} 里找不到 plugins=( … ) 列表")
    return {line.strip().rsplit("@", 1)[0] for line in block.group(1).splitlines() if line.strip()}


failed = False
removed = sorted(listed(base_sh) - listed(head_sh))
if removed and os.environ.get("ALLOW_REMOVAL") != "1":
    failed = True
    print("::error::这个 PR 从 update.sh 的列表里删掉了插件：" + "、".join(removed))
    print("多半是基于旧的 main 解决冲突时覆盖了别人刚收录的插件。先合并最新的 main，保留两边的行，再重跑 ./update.sh。")
    print("确实要下架的，给 PR 打上 remove-plugin 标签。")


def strip(index):
    index = dict(index)
    index.pop("docs", None)
    return index


want = strip(json.loads(generated.read_text(encoding="utf-8")))
have = strip(json.loads(committed.read_text(encoding="utf-8")))
if want != have:
    failed = True
    want_ids = {p.get("source"): p.get("commit") for p in want.get("plugins", [])}
    have_ids = {p.get("source"): p.get("commit") for p in have.get("plugins", [])}
    for source in sorted(set(want_ids) | set(have_ids), key=str):
        if want_ids.get(source) != have_ids.get(source):
            print(f"  {source}: 提交的 {have_ids.get(source)} ≠ 重新生成的 {want_ids.get(source)}")
    print("::error::提交的 index.json 和在最新 main 上重跑 update.sh 的结果不一致。合并最新的 main 后重跑 ./update.sh 再提交。")

sys.exit(1 if failed else 0)
