# Wonton 官方插件索引

Wonton 核心从这里的 `index.json` 读官方插件。每一项记着插件仓库、版本、提交，以及插件包里每个文件的 sha256。核心按提交取文件并逐个核对。

`index.json` 由 `update.sh` 生成，不手改。收录或更新插件：改 `update.sh` 里的列表，运行它，提 PR。

收录要求：`wonton-core plugin check --official` 通过；申请的权限和插件做的事相符；镜像来自上游官方，或者能从插件仓库复现构建。
