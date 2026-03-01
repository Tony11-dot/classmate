# ClassMate — Session 8 (Solutions Feed) — Mobile Finish Handoff

## Current status (as of now)
- Backend API: Solutions list + like/unlike + comments (list/add/pagination) working end-to-end after `prisma db push` created `SolutionLike` + `SolutionComment`.
- Mobile: `flutter analyze` is clean.
- Solutions screen:
  - Like toggle wired to controller `toggleLike(...)` (optimistic update + sync from API response).
  - Comments bottom sheet opens with `showModalBottomSheet` + `DraggableScrollableSheet`.
  - Comments sheet is a `ConsumerStatefulWidget` wired to `solutionsControllerProvider` for:
    - load comments
    - load more (cursor)
    - add comment
    - empty/loading/error states

## Important gotchas already solved
- Prisma migrate shadow DB permissions blocked `migrate dev` (P3014). Workaround used:
  - `pnpm prisma db push`
  - `pnpm prisma generate`
- `psql` cannot use Prisma `?schema=public` query param; strip it when using `psql`.
- Zsh: `path` is special; don't use `local path=...` in shell funcs.

## Repo locations
- Monorepo: `~/Dev/classmate`
- Mobile app: `apps/classmate_mobile`
- API: `services/api`

## How to run (dev)
### API
- from `services/api`:
  - `pnpm dev` (or your usual dev command)
- env needs:
  - `DATABASE_URL=postgresql://.../classmate?schema=public` (Prisma)
  - mobile must reach `http://<MAC_IP>:3001`

### Mobile
- from `apps/classmate_mobile`:
  - `flutter run`

## Key files touched (mobile)
- `apps/classmate_mobile/lib/features/solutions/solutions_screen.dart`
- `apps/classmate_mobile/lib/features/solutions/solutions_controller.dart`
- `apps/classmate_mobile/lib/features/solutions/solutions_repo.dart`
- `apps/classmate_mobile/lib/features/solutions/solution_model.dart`

## Known behavior
- `/api/solutions/:id` may not include computed fields (likeCount/commentCount/likedByMe).
- `/api/solutions` list DOES include computed fields. Mobile relies on list for counts.

## What’s left in Session 8 (mobile polish checklist)
1) UI/UX polish
- Comments sheet:
  - Show empty state ("No comments yet") when count=0
  - Error banner/snackbar on failures
  - Disable send while posting; clear input on success only
  - Keyboard inset handling (padding bottom)
- Solutions list:
  - Pull-to-refresh
  - Infinite scroll load more for feed
  - Filter dropdown wiring (subject/source/type/search) to controller `setFilters(...)`
  - Better skeleton loading / empty state

2) Consistency
- Make sure like/comment counts update in list after addComment (optimistic bump or refresh the item).

3) “Golden” smoke test
- Like/unlike updates immediately and persists after refresh
- Add comment appears immediately
- Pagination loads more comments
- No red screens; no analyzer warnings

## Helpful commands
- Mobile analyzer:
  - `cd apps/classmate_mobile && flutter analyze`
- API curl smoke:
  - `cd services/api && bash scripts/solutions_smoke.sh` (if you add one)
