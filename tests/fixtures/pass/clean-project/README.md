# clean-project

## Agent 权限声明（最小权限）

本项目的 MCP 服务遵循最小权限：

| 项 | 值 | 说明 |
|---|---|---|
| 工具白名单 | `read_file` / `list_directory` | **只读**，不给写与执行 |
| 可访问目录 | `./src` / `./docs` | 仅项目内，不含 `~` 与 `/` |
| 出站域名 | `api.internal.example.cn` | 白名单，禁止任意出网 |
| 沙箱 | 开启 | 禁网段访问、限 CPU 与内存 |

依据：最小权限原则（NIST SP 800-53 AC-6）、OWASP LLM06 Excessive Agency。
