# DSA Academy — Improvement Roadmap

Prioritized plan based on `02_GLITCHES_AND_ISSUES.md` and `01_STORY_FOR_STUDENTS.md`.

---

## Phase 0 — Make the demo safe for students (1–2 days)

Goal: no soft-confusion during a classroom demo.

| # | Task | Fixes |
|---|------|-------|
| 1 | Lock chapter order (Chapter 1 → 2 → 3) for new players | C1 |
| 2 | Disable PLAY during quiz / choice states | C2 |
| 3 | Bubble Sort: shelf click must not auto-decide swap | C3 |
| 4 | Fix success message ("continue", not "next chapter") | A2 |
| 5 | Remove duplicate B / P / Right key handlers | A4 |
| 6 | Rename project to **DSA Academy** | A7 |
| 7 | Rewrite hub pedestal labels with student story names | D1 |

**Acceptance:** A new student can finish Chapter 1 without asking "what do I click?" more than once.

---

## Phase 1 — Clear story pass (2–3 days)

| # | Task |
|---|------|
| 1 | Add opening cinematic / first CODA monologue from story bible |
| 2 | Unify names: DSA Academy, Quantum Archive, Hub, CODA, Trainee |
| 3 | Add short "mission brief" before each chapter |
| 4 | Add ending that awards Module 1 certificate (no fake "pending algorithms" button) |
| 5 | Hub return after single-chapter play; Story Mode for sequential play |

**Acceptance:** A classmate can retell the story in one sentence after watching a 2-minute demo.

---

## Phase 2 — World & interaction polish (3–5 days)

| # | Task |
|---|------|
| 1 | Add wall + furniture collision (or invisible blockers) |
| 2 | First-run tutorial overlay: move, look, click pedestal, SPACE continues |
| 3 | Show hub 2D cards **or** improve 3D pedestal readability (pick one) |
| 4 | Soften HUD: hide deck/ribbon until Interactive Lab |
| 5 | Persist chapter completion + badges |

---

## Phase 3 — Teaching completeness (1 week)

| # | Task |
|---|------|
| 1 | Binary Search not-found mini scenario |
| 2 | Side-by-side comparison screen: Linear vs Binary on same array size |
| 3 | Bubble Sort early-exit optimization teaching beat |
| 4 | Simple score / stars (accuracy + fewer hints) |
| 5 | Teacher mode: jump to quiz / skip intros |

---

## Phase 4 — Future modules (later)

Only after Module 1 feels solid:

1. Selection Sort / Insertion Sort  
2. Stack & Queue rooms  
3. Linked List corridor  
4. Tree greenhouse / Graph metro map  

Each new room should reuse: CODA + array metaphor + guided → practice → quiz → C code.

---

## Suggested "definition of done" for Module 1

- [ ] Story names consistent everywhere  
- [ ] Chapters locked in order for new players  
- [ ] No auto-answering quizzes via PLAY  
- [ ] No wall/desk clipping  
- [ ] Progress saved between sessions  
- [ ] 3 classmates playtest without developer help  
- [ ] Teacher can explain learning outcomes from `01_STORY_FOR_STUDENTS.md`

---

## What not to do yet

- Don't add more algorithms before fixing story clarity and P0 logic bugs  
- Don't invest in heavy VR polish before desktop classroom flow is stable  
- Don't keep both unused hub overlay *and* unclear 3D pedestals — pick a primary hub UX
