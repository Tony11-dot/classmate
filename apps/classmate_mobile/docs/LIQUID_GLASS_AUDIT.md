# Liquid Glass Refactor — Audit & Progress Checklist

Branch: `liquid-glass`. Goal: iOS 26 Liquid Glass look & physics across the app,
adapted to Flutter (no SwiftUI APIs — see `lib/ui/glass/` for the system).

## The system (Phase 1 — DONE)

| File | Provides |
|---|---|
| `lib/ui/glass/glass_tokens.dart` | `GlassTokens` (blur sigmas, tint, hairline, shadows, press constants) + `CMRadii` concentric radius scale |
| `lib/ui/glass/cm_glass.dart` | `CMGlass` / `CMGlass.floating` (real UIVisualEffectView on iOS via NativeGlassView, BackdropFilter elsewhere; solid under high-contrast) + `GlassPressable` press physics |
| `lib/ui/glass/glass_group.dart` | `GlassCapsuleGroup`/`GlassCapsuleAction` (shared toolbar capsules) + `GlassMorph` (hero-based glass morphing) |
| `lib/ui/glass/scroll_edge_effect.dart` | `ScrollEdgeEffect` (.soft/.hard scrims under floating chrome) |
| `lib/ui/glass/native_glass_view.dart` | (pre-existing) real iOS glass platform view |
| Theme (`theme_controller.dart`) | Concentric chain rOuter/rCard/rField/rChip; NEW dialog/bottomSheet/snackBar/textButton/chip/segmentedButton/divider themes; menus normalized to rCard |

## Layering rules
- Glass = floating functional layer ONLY (bars, pills, overlays, floating controls). Content stays opaque.
- Never glass-on-glass. One `CMGlass.floating` per surface; segments via `GlassCapsuleGroup`.
- High contrast → solid fallback (automatic in CMGlass). Reduce Motion → no press scale / no morph (automatic).

## Audit findings (2026-07-07)

### Real vs fake glass today
- REAL: iOS pill bottom nav (NativeGlassView + springs/haptics) — the reference component.
- FAKE (alpha-gradient, no blur) in 4 shared places: `liquid_glass_dropdown.dart:72,185`, `grade_multi_select_field.dart:72`, `main_drawer.dart:777` (_ParentChildDropdown).
- GUTTED: `LiquidGlassCard` renders SOLID (deliberately stripped; name is a lie).
- Android pill fallback: plain M3 NavigationBar (no glass at all).
- `_TopBar`: flat opaque AppBar + fake-translucent title chip; no scroll-under treatment anywhere (no edge fades in the app).

### Duplicated custom chrome to consolidate
- `_DetailTopBar` back-chevron header duplicated in lifedoc ×4 (announcements/assignments/meetings/exam_detail).
- Headerless "Row + back chevron" pattern ×11 (admin/teacher, e.g. admin_people AddUser, admin_edit_user, teacher_grades…).
- Search-field recipe duplicated ×7+ (messages_inbox, students_hub, new_chat, new_group, classrooms_home, solutions, tutor_home).
- Custom AppBar leading back (`arrow_back_ios_new`) across ~20 screens.

### Priority screens (most custom chrome)
Student/shared: message_thread, assignments, meetings, announcements, practice_setup, profile, tutor_home, classroom_detail, solutions_books_admin, chat_thread_view(+composer).
Teacher/admin: admin_schedule, teacher_classroom_detail, teacher_add_grade, admin_people, admin_import_users (hard edge), teacher_new_announcement, admin_export, teacher_add_material, teacher_meetings, admin_cohorts.

### Hard-edge (data-dense) surfaces — use ScrollEdgeStyle.hard
admin_import_users grid, teacher_exam_grades / teacher_add_grade entry grids, admin_dashboard stat grids, secretary_home / parent_home tile boards.

## Refactor checklist (updated as work lands)

Phase 2 — theme: [x] dialogs [x] sheets [x] snackbars [x] textButton [x] chips [x] segmented [x] menus radius [x] concentric chain
Phase 3 — shell: [ ] _TopBar glass + scroll-under [ ] Android pill via CMGlass [ ] drawer surfaces [ ] parent switcher bar
Phase 4 — shared primitives: [ ] LiquidGlassCard→real glass where floating [ ] dropdown triggers → CMGlass+GlassPressable [ ] picker sheets [ ] shared GlassBackButton + GlassSearchField [ ] _DetailTopBar unification
Phase 5 — screens: [ ] lifedoc ×4 [ ] messages [ ] chat [ ] practice [ ] tutor [ ] profile/settings [ ] schedule [ ] solutions [ ] teacher (17) [ ] admin (15) [ ] parent/secretary/certificates
Phase 6 — [ ] hard edges on dense grids [ ] radius normalization sweep [ ] a11y (high-contrast/reduce-motion/text-scale) [ ] light+dark verify [ ] final per-screen behavior table
