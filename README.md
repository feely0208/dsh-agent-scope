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

![dsh-agent-scope 检查报告示例](https://www.deepwhale.org.cn/plugin-assets/dsh-agent-scope/report.png)

![dsh-agent-scope 演示模式输出](https://www.deepwhale.org.cn/plugin-assets/dsh-agent-scope/demo.png)

![dsh-agent-scope 规则与依据](https://www.deepwhale.org.cn/plugin-assets/dsh-agent-scope/rules.png)

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


---

## 深鲸网安守护系列（共 22 个）

> 一个插件做一件事。**安全问题是链式的** —— 配套用才完整。

**国内合规** ｜ [等保对照](https://github.com/feely0208/dsh-cn-mlps) · [日志留存](https://github.com/feely0208/dsh-cn-log-retention) · [备案公示](https://github.com/feely0208/dsh-cn-filing) · [用户同意](https://github.com/feely0208/dsh-consent-guard) · [个人信息权利](https://github.com/feely0208/dsh-data-rights) · [未成年人保护](https://github.com/feely0208/dsh-minor-guard) · [影响评估](https://github.com/feely0208/dsh-pipia) · [数据分类分级](https://github.com/feely0208/dsh-data-classify) · [算法备案](https://github.com/feely0208/dsh-algorithm-filing) · [数据出境](https://github.com/feely0208/dsh-cn-data-export)

**AI 与 Agent 治理** ｜ [AI 输出信任](https://github.com/feely0208/dsh-ai-output-trust) · [外部内容信任](https://github.com/feely0208/dsh-content-trust) · [MCP 安全](https://github.com/feely0208/dsh-mcp-audit) · [**Agent 权限**](https://github.com/feely0208/dsh-agent-scope)

**数据与凭据** ｜ [敏感数据](https://github.com/feely0208/dsh-data-scan) · [密钥轮换](https://github.com/feely0208/dsh-key-rotate)

**供应链与构建** ｜ [开源许可](https://github.com/feely0208/dsh-license-guard) · [依赖投毒](https://github.com/feely0208/dsh-dep-audit) · [CI 安全](https://github.com/feely0208/dsh-ci-guard)

**权限与应急** ｜ [最小权限](https://github.com/feely0208/dsh-least-privilege) · [告警外发](https://github.com/feely0208/dsh-alert-relay) · [应急证据包](https://github.com/feely0208/dsh-incident-package)

都在 DSH 插件市场（dsh-plugin.org）和 npm 上，`dsh plugin --profile web add <包名>` 即可安装。

## License

MIT © 深鲸 DeepWhale
