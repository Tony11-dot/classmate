# ClassMate Dev Commands

## Start the API

```bash
cd services/api
pnpm dev
```

## Run the app (login screen)

```bash
cd apps/classmate_mobile
flutter run
```

Add this alias to `~/.zshrc` for a shorter command:

```bash
cmr() { cd ~/Dev/classmate/apps/classmate_mobile && flutter run --dart-define=CM_CLEAR_SESSION=true "$@"; }
```

Then: `cmr` from anywhere clears the session and opens the login screen.

## Reset all data

```bash
cd services/api
pnpm db:reseed
```

## Credentials

| Role    | Name            | Email                     | Password    |
|---------|-----------------|---------------------------|-------------|
| Teacher | Rokny Kawar     | `rokny@classmate.app`     | `Rokny123`  |
| Teacher | Eman Lahham     | `eman@classmate.app`      | `Eman123`   |
| Student | Tony Aboud      | `tony@classmate.app`      | `Tony123`   |
| Student | Sally Ashkar    | `sally@classmate.app`     | `Sally123`  |
| Student | Mayar Awoayed   | `mayar@classmate.app`     | `Mayar123`  |
| Student | Joseph Jabaly   | `joseph@classmate.app`    | `Joseph123` |

**School:** ClassMate Academy · **Cohort:** Grade 10  
**Math** (Rokny) — periods 1 & 3 every weekday  
**English** (Eman) — period 2 every weekday  
Students are in the cohort but **not enrolled** in either course (test the add-student flow).
