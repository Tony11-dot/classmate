# ClassMate — Golden Commands

## Monorepo
- `git status`
- `git pull --rebase`
- `git checkout -b <branch>`

## Backend (Nest API)
- `cd services/api`
- `cp .env.example .env`
- `npm i`
- `npx prisma generate`
- `npx prisma migrate dev`
- `npm run start:dev`

## Mobile (Flutter)
- `cd apps/classmate_mobile`
- `flutter clean`
- `flutter pub get`
- `flutter run -d macos --dart-define=CM_API_BASE_URL=http://127.0.0.1:3000`
