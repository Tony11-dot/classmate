# ClassMate Architecture

## Product execution order
1. Student app
2. Parent app
3. Admin app
4. Teacher app
5. Secretary app

## Current priority
Student app messaging stack first:
- DM should feel like WhatsApp
- Classroom chat should feel like WhatsApp groups
- NOVA should feel like ChatGPT
- Composer / attachments / voice flows should align across DM, Classroom, NOVA

## Engineering principles
- Surgical edits only
- No broad refactors
- No architecture rewrites
- No renames unless required for exact fix
- Respect existing routing
- Respect existing design system
- Preserve existing UX unless fixing a broken part
- Touch minimum files possible
- Assume hidden dependencies exist
- Always analyze after patching

## Current mobile areas of interest
- apps/classmate_mobile/lib/features/messages/*
- apps/classmate_mobile/lib/features/classrooms/*
- apps/classmate_mobile/lib/features/chat_core/*
- apps/classmate_mobile/lib/core/*
