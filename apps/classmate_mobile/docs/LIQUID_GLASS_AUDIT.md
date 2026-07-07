# Liquid Glass Refactor — Final Report & Per-Screen Checklist

Branch: `liquid-glass`. Goal: adopt Apple's iOS 26 Liquid Glass look and physics
across the whole app, adapted to Flutter (SwiftUI's `.glassEffect`,
`.buttonStyle(.glass)`, `.tabBarMinimizeBehavior`, `.scrollEdgeEffectStyle`,
`ToolbarItemGroup`, `ConcentricRectangle` have no Flutter equivalent, so we
built a small system that reproduces their behavior).

Verification: `flutter analyze lib` → **0 errors, 0 warnings**. `flutter build
web --release` → **success**. ~100 files changed, net **negative** line count
(the refactor removed more duplicated chrome than it added).

---

## 1. The Liquid Glass system (`lib/ui/glass/`)

| File | Provides | SwiftUI analogue |
| --- | --- | --- |
| `glass_tokens.dart` | `GlassTokens` — blur sigmas, tint recipe (lifted from the proven pill-nav values), specular hairline, shadows, press constants. `CMRadii` — concentric radius scale derived from the user's theme radius. | Material constants + `ConcentricRectangle` |
| `cm_glass.dart` | `CMGlass` (inline blur glass) / `CMGlass.floating` (real `UIVisualEffectView` on iOS via `NativeGlassView`; `BackdropFilter` fallback elsewhere; **solid fill under high-contrast / Reduce Transparency**). `GlassPressable` — press scale + spring + haptic, **skipped under Reduce Motion**. | `.glassEffect(.regular, in:)`, `.glassEffect(.regular.interactive())` |
| `glass_group.dart` | `GlassCapsuleGroup` / `GlassCapsuleAction` — actions sharing one capsule with hairline splits + fluid width morph. `GlassMorph` — hero-based glass morphing across transitions. | `GlassEffectContainer`, `ToolbarItemGroup` + `ToolbarSpacer`, `.glassEffectID(_:in:)` |
| `scroll_edge_effect.dart` | `ScrollEdgeEffect` — soft/hard scrims where content scrolls under floating chrome, fading in only past the edge. | `.scrollEdgeEffectStyle(.soft/.hard, for:)` |
| `native_glass_view.dart` | (pre-existing) real iOS `UIVisualEffectView` platform view. | `UIVisualEffectView` / `UIGlassEffect` |

Shared chrome widgets built on the system:

- `ui/nav/glass_back_button.dart` → `GlassBackButton` (glass capsule chevron,
  press physics, RTL-aware, 44pt, localized semantics) + `GlassDetailHeader`.
  Replaced the system back button pattern and ~30 hand-rolled back chevrons.
- `ui/widgets/glass_search_field.dart` → `GlassSearchField` (native glass
  search capsule + auto clear). Replaced ~30 hand-rolled search recipes.

## 2. Layering rules enforced (Apple HIG)

- Glass = the **floating functional layer only** (bars, pills, overlays,
  floating controls, field triggers). Content (cards, lists, bubbles) stays
  opaque — `LiquidGlassCard` is intentionally solid.
- **Never glass-on-glass**: one `CMGlass.floating` per surface; grouped
  actions share one capsule via `GlassCapsuleGroup`.
- **Tint sparingly**: prominence comes from `prominent`/shape, not color.
- Real material comes from **standard components + the system** — no
  `.ultraThinMaterial` imitations remain; the 4 copies of the fake
  alpha-gradient "glass" are gone.

## 3. Global behaviors now active app-wide

| Behavior | How |
| --- | --- |
| Real glass top bar with scroll-under | `_TopBar` is a transparent AppBar over a `NativeGlassView` slab + bottom hairline; shell Scaffold uses `extendBodyBehindAppBar`; content scrolls under and blurs through. |
| Glass bottom pill on **all** platforms | The M3 `NavigationBar` Android fallback was removed — every platform now gets the floating glass pill (real glass on iOS, blur fallback on Android/web) with the same slide-to-switch, rubber-band, spring, and haptic physics. |
| Shrink-on-scroll pill | Existing auto-hide (scale 0.86 / fade) — the `tabBarMinimizeBehavior(.onScrollDown)` analogue. |
| Bottom scroll-edge scrim | Shell wraps scrollable bodies in `ScrollEdgeEffect(showTop: false)` so the last row stays legible under the pill. |
| Glass buttons/dialogs/sheets/snackbars/menus | Theme now defines dialog (r24, no tint), bottomSheet (r24 + drag handle), floating snackbar, textButton, chip, segmented, divider themes; menus normalized to the concentric chain. |
| Concentric radii | One token (`ThemeState.radius`, default 18) drives `rOuter 24 · rCard 18 · rField 14 · rChip 10`; ~90 one-off radii normalized to the chain. |
| Reduce Motion | Press scale + morph auto-skip via `MediaQuery.disableAnimations` (already plumbed); router/pill already honored it. |
| Reduce Transparency / high contrast | `CMGlass` renders a solid themed fill instead of blur. |
| Dynamic Type | Unchanged existing plumbing (OS scale × in-app slider, clamped 200%). |

## 4. Per-screen checklist

Legend — **G**: real glass surface · **B**: GlassBackButton · **S**:
GlassSearchField · **P**: shell scroll-under padding · **H**: hard scroll edge ·
**R**: radii normalized · **X**: removed redundant button shapes.

### Shell & core

- App shell top bar — G (glass slab + hairline), scroll-under
- Bottom pill nav — G (all platforms now), physics, shrink-on-scroll, bottom scrim
- Top-bar title chip — G (capsule)
- Drawer — opaque (content layer, per HIG); parent-child dropdown → G
- Dropdown / select / grade-multi triggers — G + press physics

### lifedoc (10)

announcements P R, B×3 · assignments P R, B×4 (`GlassDetailHeader`) · attendance
P R · exams P R · grades P · meetings P R, B×3 · notifications P R ·
student_materials P · exam_detail B×4 R · form_detail B×3 R · (all four
duplicated `_DetailTopBar` classes deleted)

### messages / chat / cmail / students_hub / users

message_thread B S R · messages_inbox S×2 (dead `_bottomNavCover` removed) ·
new_chat B S · new_group S · blocked_people B · students_hub S ·
chat_message_info B · chat_message_bubble (media viewer) B · user_profile_sheet R
· cmail unchanged (already SafeArea, no custom chrome)

### practice / tutor / solutions / schedule / insights / account / classrooms / support / billing

practice_history B · practice_history_review B R · practice_session R ·
practice_setup S · saved_questions P R · mode_common R · tutor_home S P X×3 ·
nova_chat R · solutions S P R · solutions_books B S R · solutions_pages B ·
solutions_questions B R · solutions_books_admin B · schedule P R + day-nav
chevrons → G · insights P R · forgot_password B · drawer_tools_order B · login X
· phone_link X · profile P · settings P R · classrooms_home S R ·
classroom_detail B · support P (×2) · plans P X

### teacher_mobile (34)

20× B, 19× S, 12× P, **2× H** (teacher_add_grade + teacher_exam_grades
grade-entry grids), 8× X, 13× R. Highlights: teacher_classroom_detail floating
B, teacher_attendance hero B + S, teacher_grades hub S×2 + B, all add/create
form AppBars → B. Left intentionally: create_classroom close-X (dismiss, not
back), cohorts PopupMenuButton (themed, nothing to strip).

### admin / secretary / parent / certificates

admin_dashboard P · admin_people P S B (`GlassDetailHeader`) · admin_cohorts P
B×2 S · admin_schedule P B S×3 R · admin_settings P · admin_school_settings P ·
admin_insights P S B · admin_reports (SafeArea) · admin_grade_scales P ·
admin_bell_schedule P · admin_export B S X + hardcoded `0xFF7C3AED` → theme
primary · admin_import_users **H** (import grid) S · admin_edit_user B ·
admin_subject_detail B · secretary_home P · secretary_students P S · parent_home
P · parent_notifications P R · certificates_home P · student_certificates P

## 5. Deliberately left custom (with reason)

- `LiquidGlassCard` stays solid — content layer must not be glass (HIG).
- Chat composer `chevron_left` = slide-to-cancel recording affordance, not back.
- Chat composer / context-overlay `BackdropFilter` = dismiss-barrier scrims, not surfaces.
- Prev/next question paginators, "Back to setup" labeled button, modal close-X
  buttons — different semantics than a nav back; `GlassBackButton` would mislead.
- Full-screen media/PDF viewers — default AppBar / custom close pill; glass capsule would clash over media.
- Aurora login background, NovaAvatar sphere — decorative, not chrome.
- `NotificationDetailScreen` bare `AppBar()` — system default back (consistent enough).
- PDF generators (`pw.Table`, `certificate_pdf`, export PDF colors) — print output, not UI.

## 6. Accessibility

- **Reduce Motion**: `GlassPressable` and `GlassMorph` skip animation; pill,
  router transitions, and selection capsule already honored `disableAnimations`.
- **Reduce Transparency / high contrast**: `CMGlass` falls back to a solid
  `surfaceContainerHigh` fill — legibility never depends on the blur.
- **Dynamic Type**: unchanged (OS scale × in-app multiplier, clamped to 200%).
- **RTL**: `GlassBackButton` chevron and detail headers are direction-aware.
- **Semantics**: back buttons announce as buttons with the localized label.

## 7. Notes for QA

- Test light + dark, and in-app dark-on-light-OS (native glass trait is pinned
  to the app brightness via `NativeGlassView`).
- Verify scroll-under legibility on the busiest lists (schedule, admin_schedule,
  message_thread) and hard edges on the two grade-entry grids + import grid.
- Android now shows the glass pill (blur fallback) instead of the old M3 bar —
  confirm it reads well over varied page backgrounds.
</content>
