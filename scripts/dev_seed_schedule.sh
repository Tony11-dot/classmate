#!/usr/bin/env bash
set -euo pipefail

API="${API:-http://127.0.0.1:3001}"
COHORT_ID="${COHORT_ID:?set COHORT_ID}"
COURSE_ID="${COURSE_ID:?set COURSE_ID}"

curl -sS -i -X POST "$API/api/admin/schedule/bulk" \
  -H "authorization: Bearer dev-token-admin@example.com" \
  -H "x-school-id: demo-school" \
  -H "content-type: application/json" \
  -d "$(node -e '
const cohortId=process.env.COHORT_ID;
const courseId=process.env.COURSE_ID;
const periods=[1,2,3,4];
const slots=[];
for (let day=0; day<=6; day++){
  for (const p of periods) slots.push({dayOfWeek:day,period:p,courseId});
}
process.stdout.write(JSON.stringify({cohortId,slots}));
')" | sed -n '1,40p'

echo
echo "=== template rows ==="
curl -sS "$API/api/admin/schedule/cohort/$COHORT_ID" \
  -H "authorization: Bearer dev-token-admin@example.com" \
  -H "x-school-id: demo-school" \
| node -e '
let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{
  const j=JSON.parse(s); const arr=Array.isArray(j)?j:(j.items||j.template||j.slots||[]);
  const g=new Map();
  for (const r of arr){ const k=String(r.dayOfWeek); g.set(k,(g.get(k)||0)+1); }
  console.log("total:",arr.length);
  console.log("by dayOfWeek:", Object.fromEntries([...g.entries()].sort((a,b)=>Number(a[0])-Number(b[0]))));
});
'

echo
echo "=== student today ==="
curl -sS "$API/api/student/schedule/today" \
  -H "authorization: Bearer dev-token-student@example.com" \
  -H "x-school-id: demo-school" \
| node -e '
let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{
  const j=JSON.parse(s); const arr=Array.isArray(j)?j:(j.items||[]);
  console.log("items:",arr.length);
  console.log(JSON.stringify(arr,null,2));
});
'
