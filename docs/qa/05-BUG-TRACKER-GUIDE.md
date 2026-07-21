# Consolidated bug tracker — how to run it

**Setup (2 minutes):** import `05-bug-tracker.csv` into Google Sheets (File → Import). Delete the two example rows once you've seen the format. Share view-only with testers if you want them to check for duplicates; otherwise you paste their reports in yourself.

## Columns

| Column | Rule |
|---|---|
| ID | `BUG-###`, sequential across BOTH tracks — one numbering for everything |
| Source | `Fiverr` / `Testeum` / `Internal` |
| Feature area | Use the checklist section names (Chat, Grades, Auth, Localization, …) |
| Steps to reproduce | Numbered, from app launch, including which account/role |
| Severity | Critical / High / Medium / Low — definitions in `01-FEATURE-SCOPE.md` §8. YOU own the final severity, not the tester |
| Test case ID | e.g. `CHT-16`, or `EXP` for exploratory finds |
| Evidence link | Screenshot/recording (Drive folder link works well) |
| Status | `Open` → `Confirmed` → `Fixed (build N)` → `Retested-Pass` / `Retested-Fail` → `Closed` (or `Duplicate` / `Won't fix` / `Known`) |

## Working rules

1. **Triage daily** during the campaign: confirm you can reproduce (or mark `Cannot reproduce` and ask the tester once), set final severity, mark duplicates (`Duplicate of BUG-###`).
2. **Merge Testeum UX feedback** too: questionnaire answers that describe a concrete problem become rows with Severity `Low` (or higher) and Feature area `UX` — so the Experis-prep picture lives in ONE sheet.
3. **Fix order:** all Critical → all High → Medium that touch security/privacy/data → the rest as time allows. Anything security-adjacent (role boundaries, other-school data, drafts visible) gets fixed before Experis regardless of count.
4. **Retest** every Critical/High with the tester who found it (Fiverr re-test round) before marking Closed.
5. Before submitting to Experis, export the sheet: it doubles as evidence of an independent QA round — reviewers like seeing a disciplined bug process.
