# Wonton 官方插件索引

Wonton 核心从这里的 `index.json` 读官方插件。每一项记着插件仓库、版本、提交，以及插件包里每个文件的 sha256。核心按提交取文件并逐个核对。

`index.json` 由 `update.sh` 生成，不手改。收录或更新插件：改 `update.sh` 里的列表，运行它，提 PR。

几个 PR 同时改索引时，各自整份重写的 `index.json` 会互相覆盖，所以 CI（`.github/workflows/index.yml`）兜两道：PR 上在“合进最新 `main`”的结果上重跑 `update.sh`，提交的 `index.json` 和它不一致、或 `update.sh` 的列表里删了插件就失败（确实要下架的打 `remove-plugin` 标签）；合进 `main` 后再重跑一次，有差异由 CI 自动提交。

修改推荐清单：编辑 `onboarding.json` 后运行 `./update.sh`，插件 ID 必须在同一份索引里，`agents` 只能引用 `kind: agent` 的插件。

修改镜像加速名单：编辑 `registry-mirrors.json` 后运行 `./update.sh`。名单按仓库主机分（`docker.io`、`ghcr.io`、`quay.io`），每项是这个仓库的加速地址主机名，按顺序试，一个不行换下一个，拉镜像时仍逐一核对摘要。`docker.io` 的名单在设置里列出，主人自己填或者选的那个排在最前面；ghcr、quay 不经设置。只写标签的镜像不走加速。

运行 `update.sh` 需要 Git、Python 3（PSF-2.0）、Docker Compose（Apache-2.0）和 `wonton-core`（可用 `WONTON_CORE` 指定路径）；它同时固定 `wonton-docs` 的 `main` 提交和 `user/<语言>/` 下文档页的 sha256，任一步失败都保留原索引。

收录要求：`wonton-core plugin check --official` 通过；申请的权限和插件做的事相符；镜像来自上游官方，或者能从插件仓库复现构建。
