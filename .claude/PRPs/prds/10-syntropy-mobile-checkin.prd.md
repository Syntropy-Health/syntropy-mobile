# Syntropy Mobile - Check-in & Chat Polish for Beta

## Problem Statement

Syntropy Mobile (Flutter) has the core infrastructure — voice notes, offline-first sync, Supabase integration, and a product catalog skeleton — but the check-in flow (the primary use case for mobile) isn't polished for beta users. The app needs to deliver a frictionless daily check-in experience: quick voice or tap-based logging of meals, supplements, symptoms, and mood, with the results syncing to Syntropy-Journal. Chat functionality (conversational health queries) is partially built but not connected to the OpenClaw agent (PRD-11). For beta, the mobile app should nail the check-in loop and prepare the chat interface for OpenClaw integration.

## Evidence

- Voice note capture and transcription (Whisper) are implemented
- Offline-first sync with Supabase is implemented
- Check-in flow is functional but not refined for daily habit formation
- Chat feature exists but is not connected to a backend agent
- Mobile is the natural device for quick daily check-ins (not desktop)
- Competitor apps (Levels, Noom) confirm mobile is primary for daily logging

## Proposed Solution

Polish the check-in flow for daily use: streamline voice-to-journal pipeline, add tap-based quick logging (supplement taken, meal logged, symptom reported), implement streak/consistency tracking, and prepare the chat interface for OpenClaw integration. Focus on speed and reliability — a check-in should take <30 seconds.

## Key Hypothesis

We believe a frictionless mobile check-in (<30 seconds) will increase daily logging consistency.
We'll know we're right when >60% of mobile users check in 5+ days per week after first week.

## What We're NOT Building

- Full Journal feature parity on mobile — Journal is the power tool
- Nutrition data display (macros, analysis) — that's Journal dashboard
- Mobile-only features not in Journal — keep data model consistent
- Push notifications for mobile (separate from PRD-06 — Flutter handles its own via flutter_local_notifications)
- OpenClaw chat backend — PRD-11 handles that; mobile just prepares the UI

## Success Metrics

| Metric | Target | How Measured |
|--------|--------|--------------|
| Daily check-in completion rate | >60% of users, 5+ days/week | Supabase analytics |
| Check-in time | <30 seconds | Client-side timing |
| Voice note success rate | >90% transcription accuracy | QA sample |
| Data sync reliability | >99% entries synced within 1 hour | Sync queue monitoring |

## Open Questions

- [ ] What does "check-in" include? Just supplements + meals? Or also mood, sleep, exercise?
- [ ] Should mobile have its own onboarding or rely on Journal onboarding?
- [ ] Notification strategy for check-in reminders (time-of-day, frequency)?
- [ ] How to handle first-time users who haven't set up Journal profile?
- [ ] Data conflict resolution when same entry is edited on both mobile and web?

---

## Users & Context

**Primary User**
- **Who**: Biohacker who already uses Syntropy-Journal on desktop, wants quick mobile logging
- **Current behavior**: Forgets to log meals/supplements when away from computer
- **Trigger**: Takes a supplement, eats a meal, feels a symptom — while on-the-go
- **Success state**: Opens app → quick voice note or 3-tap log → done in <30s → syncs to Journal

**Job to Be Done**
When I take my supplements or eat a meal while on-the-go, I want to log it in seconds on my phone, so I can maintain my tracking streak without interrupting my day.

**Non-Users**
- Users who prefer desktop-only workflows
- Users who want full analysis on mobile (use Journal instead)
- New users who haven't created a Syntropy account yet

---

## Solution Detail

### Core Capabilities (MoSCoW)

| Priority | Capability | Rationale |
|----------|------------|-----------|
| Must | Quick voice check-in (one-tap record → transcribe → log) | Fastest input method |
| Must | Tap-based quick log (supplement taken, meal logged, symptom) | For quiet environments |
| Must | Reliable sync to Syntropy-Journal data | Single source of truth |
| Must | Check-in history (today's entries, recent entries) | Verification and review |
| Should | Streak/consistency tracking (visual indicator) | Habit formation |
| Should | Check-in reminders (morning supplements, meals, evening review) | Consistency driver |
| Should | Chat UI prepared for OpenClaw integration | Ready for PRD-11 |
| Could | Photo-to-meal logging (camera → food recognition) | Future — would use DIET |
| Won't | Full nutrition analysis display — Journal's domain | Keep mobile focused |

### MVP Scope

One-tap voice check-in, tap-based quick log with 3 categories (supplement, meal, symptom), sync to Journal, today's check-in history, simple streak counter.

### User Flow

**Voice Check-in:**
1. Open app → big "Check In" button
2. Tap → recording starts
3. Speak: "Took 2g creatine and 400mg magnesium, had salmon salad for lunch"
4. Tap stop → Whisper transcribes → parsed into structured entries
5. Confirm → synced to Journal → streak updated

**Tap Check-in:**
1. Open app → "Quick Log" section
2. See recent supplements/meals (from profile)
3. Tap to mark as taken/eaten
4. Auto-synced → done

---

## Technical Approach

**Feasibility**: HIGH

**Architecture Notes**
- Flutter + Riverpod state management already in place
- Voice recording via `record` package → OpenAI Whisper API → structured entry
- Offline-first: write to SQLite → sync queue → Supabase when online
- Quick log: pre-populate from user's common supplements/meals (from Journal profile)
- Chat UI: existing chat screen, wire to OpenClaw API endpoint when available

**Technical Risks**

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Voice transcription accuracy for supplement names | MEDIUM | Custom prompt for Whisper with supplement context; user can edit before confirm |
| Sync conflicts with Journal edits | LOW | Last-write-wins already implemented; rare for same entry to be edited on both |
| Battery drain from background sync | LOW | workmanager package handles efficient background tasks |

---

## Implementation Phases

| # | Phase | Description | Status | Parallel | Depends | PRP Plan |
|---|-------|-------------|--------|----------|---------|----------|
| 1 | Check-in UX redesign | New check-in screen, voice + tap flows | pending | - | - | - |
| 2 | Quick log with presets | Tap-based logging with common items | pending | with 1 | - | - |
| 3 | Streak & history | Check-in streak counter, today's history | pending | - | 1 | - |
| 4 | Sync hardening | Ensure reliable sync with Journal data | pending | with 3 | - | - |
| 5 | Chat UI preparation | Update chat screen for OpenClaw readiness | pending | - | - | - |

### Phase Details

**Phase 1: Check-in UX Redesign**
- **Goal**: Frictionless <30s check-in
- **Scope**: New main screen, voice recording flow, structured entry parsing
- **Success signal**: User can complete voice check-in in <30s

**Phase 2: Quick Log Presets**
- **Goal**: Tap-based logging for repeated items
- **Scope**: Pre-populated list from profile, tap-to-log, frequency-based sorting
- **Success signal**: Common supplement logging in 3 taps

**Phase 3: Streak & History**
- **Goal**: Habit formation feedback
- **Scope**: Streak counter, today's entries list, calendar view
- **Success signal**: Users see their consistency visualized

**Phase 4: Sync Hardening**
- **Goal**: Bulletproof data sync
- **Scope**: Edge case handling, conflict resolution, retry logic, sync status indicator
- **Success signal**: >99% entries synced within 1 hour

**Phase 5: Chat UI Preparation**
- **Goal**: Ready for OpenClaw integration
- **Scope**: Chat screen update, message UI, API contract placeholder
- **Success signal**: Chat UI renders, sends/receives messages via placeholder API

---

## Decisions Log

| Decision | Choice | Alternatives | Rationale |
|----------|--------|--------------|-----------|
| Primary check-in method | Voice (with tap fallback) | Tap-only, photo | Voice is fastest for complex entries (multi-supplement stacks) |
| Sync strategy | Offline-first SQLite → Supabase | Online-only, direct to Journal DB | Already implemented; proven pattern; works on flaky connections |
| Chat backend (beta) | Placeholder until OpenClaw | Build custom chat, skip chat | Prepare UI now; connect backend when OpenClaw ready |

---

## Research Summary

**Market Context**
- Levels mobile app: one-tap food photo logging + real-time glucose insight
- Noom: daily check-in with weight + meal logging (30-second target)
- Biohackr app: supplement tracking with streak gamification
- All successful health apps prioritize mobile for daily logging

**Technical Context**
- Flutter app at `apps/syntropymobile/lib/`
- Feature modules: `features/voice_notes/`, `features/health_analysis/`, `features/catalog/`
- Voice: `record` + `audioplayers` packages + OpenAI Whisper
- Sync: SQLite (sqflite) + Supabase + workmanager
- State: Riverpod 2.4.9

---

*Generated: 2026-02-25*
*Status: DRAFT - needs validation*
*Priority: P2 - Satellite / Retention*
*Master PRD: beta-release-master.prd.md*
