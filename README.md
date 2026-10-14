# @deepwhale-cn/dsh-agent-scope

**Agent 权限边界** —— 查 agent 的工具/文件/网络权限有没有声明、是不是过宽。

## 不装它会怎样

你的 MCP 配置长这样：

```json
"filesystem": { "command": "npx", "args": ["-y", "@modelcontextprotocol/server-filesystem", "/"] },
"everything": { "command": "npx", "args": ["-y", "mcp-everything"], "allowedTools": ["*"] }
```

**看起来是「配置齐全」，实际上：**

```
① 文件访问路径是 /       → agent 能读写你所有文件（含 ~/.ssh、~/.aws）
② allowedTools: ["*"]    → agent 能调用所有工具（读文件、执行命令、发请求）
③ allowedDomains: "*"    → 被注入后能把数据发到任意地址
```

**Agent 的权限就是它的爆炸半径。** 一旦被提示注入控制，
它能做的事 = **你给它的全部权限**。

OWASP 把这归为 **LLM06 Excessive Agency**。

## 关键词
**关键词**：Agent 权限 · 工具权限 · 权限边界 · 最小权限 · MCP 权限 · 沙箱 · 白名单 · 爆炸半径
**Keywords**: agent scope · tool permissions · least privilege · MCP security · excessive agency · sandbox

## 它查什么

| 级别 | 内容 | 依据 |
|---|---|---|
| 🔴 高 | 工具权限用通配符 `*` | 最小权限（NIST SP 800-53 AC-6）|
| 🔴 高 | 文件访问是 `/` / `~` / 整个用户目录 | MCP 文档 · 目录限制建议 |
| 🟡 中 | 网络访问无限制 | OWASP **LLM06 Excessive Agency** |
| 🟡 中 | 配置里**找不到任何权限声明** | 最小权限 · 权限应显式声明 |

## 「没有声明」为什么危险

**没有声明通常等于默认全开** —— 而用户看到的只是一个「很干净」的配置文件，
不会意识到 agent 能做所有事。

## 安装

```bash
dsh plugin --profile web add @deepwhale-cn/dsh-agent-scope
# 或纯 CLI
npx @deepwhale-cn/dsh-agent-scope
```

## 用法

```bash
dsh-agent-scope --demo
dsh-agent-scope --list-rules
dsh-agent-scope --html r.html
```

## 边界

- **只审配置，不审 agent 实现** —— agent 代码里怎么用这些权限，本工具看不到。
- **不判断「给得够不够」** —— 只查「有没有声明、有没有明显过宽」。
  权限偏大但没用通配符的情况需要人工评审。
- **配置位置各客户端不同** —— 按常见路径找（mcp.json / .mcp.json / settings.json / claude_desktop_config.json）。
- **沙箱是否真生效** 需要运行时验证，不在范围内。
- 与 [dsh-mcp-audit](https://github.com/feely0208/dsh-mcp-audit) 分工：
  那个查 MCP **服务来源**（未锁版本/明文端点），这个查 MCP **权限边界**。
- 与 [dsh-least-privilege](https://github.com/feely0208/dsh-least-privilege) 分工：
  那个查**容器/云/Web** 权限，这个查 **agent** 权限。

本插件是一个工具。使用者必须遵守所在地区法律法规，**对使用本项目造成的任何后果自行承担责任。**

## License

MIT © 深鲸 DeepWhale
