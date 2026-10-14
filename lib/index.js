import { createPlugin, pkgRootFrom } from '@deepwhale-cn/dsh-guard-core/plugin';

export const { name, inject, apply } = createPlugin({
  name: 'agent-scope',
  pkgRoot: pkgRootFrom(import.meta.url),
  skillFile: 'skill/agent-scope.md',
  binFile: 'bin/cli.mjs',
  description: '查 agent 的工具/文件/网络权限有没有声明、是不是过宽 —— agent 的权限就是它的爆炸半径',
  whenToUse: 'TODO：写清什么时候该用（用户会说的话也列上）',
});
