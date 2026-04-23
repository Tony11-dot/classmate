Task: finish end-to-end forwarding parity between DM and Classroom chat.

Goal:
Make forwarding work fully and consistently for:
- DM -> DM
- DM -> Classroom
- Classroom -> DM
- Classroom -> Classroom

Non-negotiables:
- Surgical changes only.
- No broad refactor.
- Preserve architecture, routing, providers, and existing UX unless directly related to forwarding.
- Reuse existing repository/provider/model contracts wherever possible.
- Do not break:
  - pending request logic
  - classroom custom ordering
  - DM recency ordering
  - reply / reactions / pin / media / voice / scroll behavior

Selection-mode requirements:
- Long-press Forward enters selection mode.
- Tap toggles selected messages.
- Top bar changes into selection state.
- Shared forward target picker opens from selection mode.
- Composer actions are disabled during selection mode.
- Swipe actions must not interfere while selection mode is active.

Picker requirements:
- Show Classrooms section first, using the SAME classroom custom order that already exists in the app.
- Show Direct messages section second, ordered by recency like current DM logic.
- Exclude current thread.
- Exclude blocked and pending request targets.
- Allow multi-select targets.

Implementation guidance:
- Inspect first.
- Patch minimally.
- Prefer shared helper logic only if truly surgical and low-risk.
- If classroom currently has placeholder / duplicate / partial forwarding logic, consolidate to one working path without broad cleanup.

After patch:
1. Run:
   cm-analyze-file lib/features/messages/ui/message_thread_screen.dart
   cm-analyze-file lib/features/classrooms/ui/classroom_detail_screen.dart
   cma
2. Fix analyzer issues caused by your patch.
3. Report:
   - changed files
   - what now works
   - remaining manual QA checklist

Current repo context:
- DM forwarding and DM selection mode are already partially implemented in:
  lib/features/messages/ui/message_thread_screen.dart
- Classroom forwarding hooks exist in:
  lib/features/classrooms/ui/classroom_detail_screen.dart
  lib/features/classrooms/data/classrooms_repository.dart
- Classroom custom order exists in:
  lib/features/classrooms/providers/classroom_order_prefs.dart
  lib/features/classrooms/providers/classrooms_providers.dart

Do not stop at partial UI. Make the end-to-end forwarding flow actually work.
