# ClassMate Messaging Rules

## UX targets
- DM = WhatsApp-quality 1:1 chat
- Classroom chat = WhatsApp-quality group chat
- NOVA = ChatGPT-quality conversation UI

## Must preserve
- correct sort order
- date chips
- reply flow
- pinning
- reactions
- voice notes
- media sending
- scroll behavior
- pending request boundaries
- delivery / seen / deleted states

## Forwarding requirements
- DM -> DM
- DM -> Classroom
- Classroom -> DM
- Classroom -> Classroom

## Forward picker requirements
- exactly 2 sections:
  - Classrooms
  - Direct messages
- classrooms ordered by existing classroom custom order
- DMs ordered by existing recency logic
- only approved targets
- no pending/block targets

## Selection mode requirements
- forward should enter selection mode like delete mode
- selection mode required in DM thread
- selection mode required in Classroom thread
- tap toggles selected message
- top bar switches into forward-selection state
- forward action opens shared picker
- conflicting composer actions disabled while in selection mode

## Do not break
- request approval logic
- classroom ordering logic
- existing DM forwarding if already working
- media / voice / reactions / reply / pin flows
