#!/bin/bash
set -uo pipefail
cd "$(dirname "$0")/.."
PASS=0; FAIL=0
ok(){ echo "  ✅ $1"; PASS=$((PASS+1)); }
bad(){ echo "  ❌ $1"; FAIL=$((FAIL+1)); }
echo ""; echo "  @deepwhale-cn/dsh-agent-scope · 双向验证"
echo "  ────────────────────────────────────────────────"
J=$(node bin/cli.mjs --root tests/fixtures/fail/demo-project --json 2>&1)
for rid in SCOPE-WILDCARD-TOOLS SCOPE-FS-ROOT SCOPE-NET-ANY; do
  c=$(echo "$J" | python3 -c "
import json,sys; d=json.load(sys.stdin)
print(len([f for f in d['findings'] if f['ruleId']=='$rid']))" 2>/dev/null)
  [ "${c:-0}" -gt 0 ] && ok "$rid 报出（正例）" || bad "$rid 未报出"
done
A=$(node bin/cli.mjs --root tests/fixtures/absent/minimal --json 2>&1)
c=$(echo "$A" | python3 -c "
import json,sys; d=json.load(sys.stdin)
print(len([f for f in d['findings'] if f['ruleId']=='SCOPE-NO-DECLARATION']))" 2>/dev/null)
[ "${c:-0}" -gt 0 ] && ok "SCOPE-NO-DECLARATION 在空缺样本上报出" || bad "SCOPE-NO-DECLARATION 未报出"
M=$(node bin/cli.mjs --root tests/fixtures/pass/clean-project --quiet 2>&1 | grep -oE '^[0-9]+' | head -1)
[ "${M:-1}" = "0" ] && ok "合规样本 0 命中（白名单 + 限定目录 + 域名白名单）" || bad "误报 ${M} 条"
echo ""; echo "  【能力验证】白名单列表不该被当成通配符"
K=$(echo "$J" | python3 -c "
import json,sys; d=json.load(sys.stdin)
print(len([f for f in d['findings'] if f['ruleId']=='SCOPE-WILDCARD-TOOLS']))" 2>/dev/null)
[ "${K:-0}" = "1" ] && ok "只报真通配的那一条" || bad "SCOPE-WILDCARD-TOOLS 报了 ${K} 条"
echo ""; echo "  【语义一致性 + 判据来源】"
python3 - <<'PY' && ok "4 条规则语义一致且引判据" || bad "有规则不合格"
import json,glob,sys
for f in glob.glob('rules/*.json'):
    r=json.load(open(f,encoding='utf-8')); t=r.get('title',''); s=r.get('source') or ''
    if any(w in t for w in ('找不到','未发现','缺少')) and r['check']['type']!='files-lack':
        print('语义相反:',r.get('id'),file=sys.stderr); sys.exit(1)
    if not any(k in s for k in ('OWASP','NIST','MCP','CIS','第')):
        print('判据可疑:',r.get('id'),file=sys.stderr); sys.exit(1)
PY
echo ""; echo "  ────────────────────────────────────────────────"
echo "  通过 $PASS · 失败 $FAIL"; echo ""
[ "$FAIL" -eq 0 ] || exit 1
