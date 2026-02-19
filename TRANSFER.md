# ClassMate Project Handoff (continue-from-here)

## Repo layout
- `services/pilot_api` = Node/Express backend (Dockerized) serving `/api/*`
- `apps/classmate_mobile` = Flutter mobile app (iOS device testing)

## App goal (ClassMate)
A school platform for grades 7–12 with:
- Schedule, Classrooms, AI Tutor, Insights, Solutions feed
- Drawer grouped into sections (core tabs + LifeDoc + profile/settings)
- Modern “Apple clean” UI with themes/presets, dark/light/system, accent/radius/density knobs
- Admin role (per-school) can manage everything via UI and can act as teacher
- Registration collects grade track/majors + math/English units to auto-join classrooms and drive assignments

## What was fixed/implemented recently (mobile)
### Schedule screen polish
- Added better styling for lesson cards + subject label pills + NOW tag
- Added better day header formatting (day name + date) in schedule header (work-in-progress earlier; later patches landed)
- Added refresh invalidation for a day
- Eliminated PageController.page crash by tracking `_currentIndex` instead of using `.page` before positions exist (earlier incident)
- There was churn: `_DayCard` was introduced then removed; the stable version uses `_DaySchedule` + helper functions inside its build:
  - `subjectName` resolves from `meSubjectsProvider`
  - `t(DateTime)` formats time
  - `isNow` highlights current lesson

### Classrooms navigation crash fix
- Named routes `Navigator.pushNamed("/classrooms/<id>")` crashed because `Navigator.onGenerateRoute` was null.
- Patched to use `MaterialPageRoute` placeholder screen for classroom details (no named routes).

### Solutions typing bug fix
- `SolutionsController.like` had type mismatch (`List<dynamic>` vs `List<Solution>`).
- Fixed using `List<Solution>.from(...)` and `AsyncData<List<Solution>>(list)`.

### Login unmounted context crash
- `_LoginScreenState._login` threw "widget unmounted" after awaits.
- Patched by inserting `if (!mounted) return;` after awaits in `_login()`.

### Tutor: connected to real backend AI + improved UX
- Backend endpoint added: `POST /api/tutor/chat` (auth required).
- Mobile tutor wired to call backend, not static responses.
- Added typing bubble (`…`), `_sending` guard, and disabled send while sending.
- Rewrote tutor `send()` to avoid `setState(async)` error:
  - setState only synchronously updates messages + typing bubble
  - awaits API call outside setState
  - then setState to replace typing bubble with reply or error

## Backend: hardening + AI tutor endpoint
### Security middleware added
Installed:
- `helmet`
- `express-rate-limit`
- `zod`

Added middleware:
- `src/mw/httpError.js` (HttpError with status/code)
- `src/mw/validate.js` (Zod validation -> 400)
- `src/mw/errorHandler.js` (unified JSON error handler)
- `src/mw/asyncWrap.js` (promise catcher)

`src/server.js`:
- `helmet()` + `rateLimit({ windowMs: 60_000, max: 300 })`
- `app.use(errorHandler)` as last middleware
- Mounted: `app.use("/api/tutor", buildTutorRouter({ auth }))`
- Duplicate tutor mount was removed.

### Tutor router
File: `services/pilot_api/src/tutor.js` (router factory)
- Route: `POST /api/tutor/chat`
- Body schema: `{ messages: [{role, content}...] }` via Zod
- Injects a system prompt: “ClassMate AI Tutor… Bagrut-level… short follow-up questions…”
- Calls `ollamaChat({ baseUrl, model, messages })`
- Returns `{ reply }` or throws HttpError 502 if empty

### Ollama config
- Mac has: `phi3:latest` installed (`ollama list` showed only phi3).
- Docker compose for pilot changed to use:
  - `OLLAMA_URL=http://host.docker.internal:11434`
  - `OLLAMA_MODEL=phi3:latest`

### docker-compose.pilot.yml was corrupted then fully rewritten clean
Final working compose (important):
- `db` postgres env only (no OLLAMA there)
- `pilot_api` env includes OLLAMA_URL + OLLAMA_MODEL
- `docker compose -f docker-compose.pilot.yml config` OK

Tutor smoke-test succeeded:
- `curl POST /api/tutor/chat` returned a real response from phi3.

## Known issues right now
1) iOS “Lost connection to device” happens often (wireless debugging idle/background). Re-run `flutter run`.
2) Mobile still has some rough UI: wants “better AI UI”, personalized identity, and founder/about responses.
3) User wants OpenAI engine (ChatGPT) instead of Ollama.

## What user wants next (priorities)
### A) AI Tutor UI upgrade (mobile)
- Make Tutor UI look more like modern chat (bubbles, timestamps optional, better spacing)
- Add greeting/branding: show “Tony Aboud” and personalized info
- When asked “who are you / who is founder / about creator”, it should answer dynamically using a predefined “Tony Aboud” profile, not static text.
- Keep it Bagrut-level, and keep current backend wiring.

### B) Switch backend model provider to OpenAI
- Replace Ollama call with OpenAI Chat Completions (or Responses API) using env:
  - `OPENAI_API_KEY`
  - model like `gpt-4o-mini` / `gpt-4.1-mini` / etc (choose reasonable)
- Keep endpoint contract same: `POST /api/tutor/chat` -> `{ reply }`
- Add safe timeout + error mapping to HttpError
- Ensure Docker secrets/env handling.
- Keep rate limit + helmet + error handler.

### C) Mobile main.dart still might be a temporary pilot health-check
- Need to boot the real router/shell app widget (GoRouter) instead of a FutureBuilder health screen.
- Must not create new architecture; must use the existing router/shell previously generated.

## Helpful commands (dev)
### Backend
- `cd ~/Dev/classmate`
- `docker compose -f docker-compose.pilot.yml up -d --build pilot_api`
- `docker logs -n 80 classmate-pilot_api-1`
- Health: `curl -sS http://localhost:3010/api/health | jq .`
- Tutor: login -> token -> chat
  - `TOKEN="$(curl -sS -X POST http://localhost:3010/api/auth/login -H 'Content-Type: application/json' -d '{"email":"tony+ship4@demo.com","password":"Passw0rd!"}' | jq -r .token)"`
  - `curl -sS -X POST http://localhost:3010/api/tutor/chat -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' -d '{"messages":[{"role":"user","content":"hi"}]}' | jq .`

### Mobile
- `cd ~/Dev/classmate/apps/classmate_mobile`
- `flutter run --dart-define=API_BASE_URL=http://<LAN_IP>:3010`
- Search tutor screen: `rg -n "class Tutor|Ask something|tutor_screen" lib`
- Search app router: `rg -n "GoRouter|MaterialApp\.router|routerConfig" lib`

## Notes about Tony (use for personalization)
- Name: Tony Aboud
- Interests: physics, math, CS/AI, building ClassMate, tennis
- Wants Bagrut-level explanations (not too advanced)
- Wants the tutor to adapt and ask short follow-ups
- Wants the assistant to answer about the “founder” dynamically when asked

