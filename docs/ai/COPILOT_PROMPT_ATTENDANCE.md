
Task: polish the Attendance feature end-to-end in ClassMate student app.

Context:

- Messaging / classroom chat / DM system is considered done.

- Attendance polishing is the next priority.

- Work surgically.

- No broad refactors.

- Preserve architecture, routing, providers, and design system.

- Reuse existing repository/provider/model contracts where possible.

- Keep Apple-clean / polished UX.

- Maintain consistency with the rest of the student app.

Goal:

Take Attendance from “works / mostly there” to “launch-polished”.

Inspect current attendance flow first, then patch minimally until the feature feels complete, predictable, and visually clean.

Primary expectations:

1. Audit current Attendance feature fully.

2. Find all files involved in Attendance UI, data, providers, models, routing, empty/loading/error states.

3. Fix gaps, rough edges, and inconsistencies.

4. Keep changes incremental and low-risk.

5. Run analyzer after patching and fix any issues caused by your work.

What Attendance polishing should cover:

- loading state polish

- empty state polish

- error state polish

- refresh / retry behavior

- stable layout spacing and typography

- dark mode correctness

- list/card consistency

- labels / status chips clarity

- date formatting consistency

- no awkward overflow / clipped text

- safe handling of null / partial backend data

- obvious and trustworthy attendance summary presentation

- proper alignment with app shell / top spacing / scrolling behavior

- polished visual hierarchy

- no janky state transitions

- preserve existing business logic unless clearly broken

Also inspect for these likely weak points:

- confusing status wording

- inconsistent present/absent/late/excused rendering

- duplicated logic that can be consolidated surgically

- weak summary row / totals presentation

- poor empty messaging

- poor handling when there are no records for a range

- inconsistent pull-to-refresh or retry

- fragile sorting/grouping by date

- cards that do not feel production-ready

- mismatched colors in dark mode

- sticky or broken scrolling inside nested layouts

- any obvious mismatch with the rest of ClassMate’s current UI quality

Non-negotiables:

- surgical changes only

- no broad cleanup pass

- no unrelated refactors

- do not break routing

- do not break auth/session assumptions

- do not break schedule/classrooms/grades/alerts/features outside attendance

- do not change architecture unless absolutely required for a direct bug fix

- preserve current API contracts unless clearly broken and patching is minimal

Process:

1. Inspect first.

2. Identify exact attendance files to patch.

3. Patch minimally.

4. Run:

   cm-analyze-file lib/features/lifedoc/attendance_screen.dart

   cma

5. Fix analyzer issues caused by your patch.

6. Report:

   - changed files

   - what was improved

   - remaining manual QA checklist

Quality bar:

Attendance should feel launch-ready, polished, predictable, and visually aligned with the rest of the student app.

Do not stop at surface cosmetics only.

If there are obvious UX or state-management gaps inside Attendance, fix them too, but stay surgical.

