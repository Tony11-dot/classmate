# QA pack update — build 254 + 400 ILS budget

The rest of this folder was written for **build 233**. The app is now **build 254**
and the budget for this round is **400 ILS (~$107)**. Read this file first; it
overrides the stale bits of `00-README` and `03-FIVERR-BRIEF` without changing
the ~140-case checklist, which is still valid.

## 1. What changed since the pack was written (233 → 254)

Give testers build **254** (not 233). New/changed since the pack:

- **ClassNotes** — a new tool in the School Tools menu for students, teachers,
  and parents. It is a notebook library synced from the ClassNotes iPad app.
  Add the cases in §3 below.
- **Themes** — the appearance picker is now a gallery of **20 built-in themes**
  (System + 9 light + 10 dark) plus **user-created custom themes** (Add theme →
  pick a colour; long-press a custom theme to delete). Test switching several,
  incl. a dark one, and RTL + a custom theme.
- **Menu reordering** — in the side menu you **press-and-hold a School Tools row
  and drag** to reorder it; the order should persist after restart.
- **Support NOVA** — the Support screen's "Ask AI" now answers detailed how-to
  questions about the whole app. Worth a few sanity questions ("how do I reset
  my password?", "what is ClassNotes?") — it should answer helpfully and stay in
  character as NOVA.

## 2. Security regression spot-checks (do these — they matter most)

Four authorization holes were just fixed. Ask testers to actively try each and
report **as Critical** if it works:

- **Cross-school group join:** with the two student accounts (same school),
  create a group, copy its invite code, and confirm a user can join with it.
  There is no second school in the sandbox, so the tester can't fully prove the
  cross-school block — but confirm join-by-code works and history loads.
- **Tutor privacy:** each account's NOVA (study tutor) chat history must show
  ONLY that account's own conversations — never another user's.
- **People directory:** the "new chat" people list must show only same-school
  people, never strangers from other schools.
- **General rule (already in the Fiverr brief):** if a tester ever sees data
  from outside their school, or does an action their role shouldn't allow →
  **Critical, report immediately.**

## 3. ClassNotes test cases (append to `02-TEST-CASES.md`)

The sandbox accounts won't have real notebooks unless synced from an iPad, so
most testers will see the **empty state** — that is expected and testable.

| ID | Steps | Expected |
|----|-------|----------|
| CN-01 | Student → side menu → School Tools → **ClassNotes** | Opens; if no notebooks, a clean "No notebooks yet" empty state (not an error/spinner-forever) |
| CN-02 | Same, as **teacher** and as **parent** | ClassNotes appears in their menu too and opens the same way |
| CN-03 | Admin / secretary menu | ClassNotes is **absent** for admin/secretary (correct) |
| CN-04 | Pull down to refresh the library | Refreshes without error |
| CN-05 | Sign out, reopen ClassNotes | Shows "Sign in to see your notebooks" (not a crash) |
| CN-06 | Switch theme, reopen ClassNotes | Monogram/'+'/chips follow the theme colour |

(If you have an iPad with the ClassNotes app on the same account, also test: open
a notebook → read pages → pinch/double-tap zoom → ⋮ or long-press a cover →
Rename/Move/Download/Delete → "Arrange" to drag-reorder. Cross-device delete
should propagate to the iPad on its next launch.)

## 4. Hiring shape for 400 ILS (~$107) — the real plan

The `03-FIVERR-BRIEF` recommends **3 testers at $100–200 each** — that is
$300–600 and **does not fit 400 ILS**. Pick ONE of these instead:

- **Option A — 2 Fiverr testers, ~$45–55 each (recommended).** Tester 1:
  Android + a full **Hebrew/RTL** pass. Tester 2: iOS (iPhone, iPad a plus).
  Use the same `03` brief and screening questions; just say "2 testers." Skip
  the per-bug bonus (no budget for it) — or offer a single small +$10 for the
  worst confirmed Critical.
- **Option B — 1 strong Fiverr tester, ~$90–100.** One experienced seller does
  the full checklist + RTL + exploratory on the devices they own. Less device
  spread, but deepest single pass. Good if you find one great seller.
- **Option C — Testeum crowdtest** (brief in `04-TESTEUM-BRIEF.md`). Their
  crowd model can be cheaper per-tester for shallow coverage; use it to
  supplement Option A if it fits under the remaining budget.

To stretch the budget: **the web build (classmate-f17d6.web.app) is free to
test** and needs no device provisioning — you or a friend can run the checklist
there at zero cost, saving the paid testers for real iOS/Android device bugs.

If you must trim the ~140 cases for a cheaper/faster pass, prioritise:
**AUTH (login/reset), Chat (voice notes + receipts), Grades, Attendance,
Classrooms, ClassNotes (§3), the security spot-checks (§2), and one full RTL
session.** Those are the highest-traffic, highest-risk areas.

## 5. The one blocker before you can hire anyone

Testers need working logins. Run, from the repo root:

```bash
bash docs/qa/setup-qa-school.sh
```

⚠ The owner (manager) password on file may be stale — if the script's login
step fails, that's why (mind the 5-attempts-per-15-min auth rate limit). Once it
succeeds it writes `docs/qa/QA-CREDENTIALS.txt` with every role's login. **Nothing
testers do works without this.** If the owner password is dead, reset it first
(or tell me and I'll walk you through re-seeding the accounts another way).
