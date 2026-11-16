# DSA Academy — Code Analysis & Development Plan

**Date:** 2026-11-12  
**Engine:** Godot 4.7 (Forward Plus) + OpenXR  
**Project status:** Early prototype spike (~**0.1%** of intended product)  
**Audience:** Project team  

This document is the **current code analysis + recommended plan**.  
Use it with the team pack in `docs/team/` (vision, story, pre-production).

---

## 0. Module 1 boundary (locked for current build)

**We separate modules.** Right now we only finish **Module 1**. Module 2+ wait.

| | Module 1 — Foundations |
|--|------------------------|
| **Platform** | Desktop / laptop first (OpenXR off). VR later. |
| **Chapters** | 1 Linear Search → 2 Binary Search → 3 Bubble Sort |
| **Story end** | Archive restored + Module 1 clearance (Rank 1) |
| **Does NOT include** | Stacks, queues, lists, trees, graphs, more sorts |
| **Done when** | Student can retell the golden rule; bugs above are fixed; progress saves |

**Ending of Module 1 (the “bend” / stop line):**  
Trainee completes Bubble Sort → Archive Core stable → CODA awards Rank 1 → hub free-roam of the 3 chapters → **stop**. No Module 2 content yet.

---

## 1. What this project is

**DSA Academy** is a **VR-capable 3D learning simulation** that helps students understand **programming logic and C / DSA concepts** by *doing* them in a virtual lab — not only reading slides.

| Layer | Meaning |
|-------|---------|
| **World** | DSA Academy classroom + Quantum Archive (glowing shelves = array) |
| **Guide** | CODA — robot tutor |
| **Player** | Trainee who performs algorithm steps |
| **Learning loop** | See → Do → Explain → Map to C / pseudocode → Retell |
| **Platform** | VR primary vision; desktop 3D for classroom PCs |

**One-sentence pitch:**  
Students enter a living archive world, restore scrambled knowledge with CODA, and learn search/sort logic by physically performing the steps — then see how those steps become real C code.

---

## 2. Honest status (what “0.1% done” means)

### Already built (prototype spike)

| Area | What exists |
|------|-------------|
| World | Procedural 3D classroom (walls, desks, windows, core hologram, 3 pedestals) |
| Player | Desktop WASD + mouse; OpenXR VR rig + controller ray |
| Interaction | Raycast hover/click on shelves and pedestals |
| Content | Linear Search, Binary Search, Bubble Sort lesson state machines |
| UI | HUD, CODA story panel, quizzes, handbook with C snippets, step/play deck |
| Systems | Array visualization, lesson playlist, chapter transitions, SFX |

### Not built (the real product)

- Locked, consistent student-facing story everywhere  
- Safe teaching flow (no auto-answering quizzes, locked chapter order)  
- Comfortable VR learning verbs (select / confirm / continue)  
- Save / badges / assessment for teachers  
- Collision-solid world, polished hub onboarding  
- Evidence that students actually learn better  
- Clean modular architecture for many future chapters  
- Full C-programming curriculum beyond search/sort metaphors  

**Conclusion:** Current code is a **direction proof**, not a finished education product. Next work is **plan → fix blockers → one excellent vertical slice** — not “add 10 more algorithms.”

---

## 3. Code map (what each part does)

```
Main.tscn
  └── dsa_world.gd          Builds room, pedestals, wires all systems
        ├── player.gd       Desktop / VR movement + hotkeys
        │     └── interaction_system.gd   Ray pick shelves / pedestals
        ├── array_system.gd 3D archive shelves (array elements)
        ├── game_ui.gd      All HUD / story / quiz / handbook / deck
        ├── lesson_manager.gd  Hub + playlist + chapter transitions
        └── lessons/
              ├── lesson.gd                 Base class
              ├── linear_search_lesson.gd
              ├── binary_search_lesson.gd
              └── bubble_sort_lesson.gd
```

| File | ~Lines | Role | Health |
|------|--------|------|--------|
| `game_ui.gd` | ~1900 | Entire UI surface | Too large; hard to maintain |
| `linear_search_lesson.gd` | ~1300 | Chapter 1 teaching SM | Feature-rich; messy |
| `dsa_world.gd` | ~1180 | World + hub setup | Visual spike OK; no wall collision |
| `array_system.gd` | ~1010 | Array 3D visuals | Core metaphor works |
| `bubble_sort_lesson.gd` | ~920 | Chapter 3 | Pedagogy bug on shelf click |
| `binary_search_lesson.gd` | ~830 | Chapter 2 | Missing not-found practice |
| `player.gd` | ~280 | Hybrid controls | Duplicate hotkeys with UI |
| `lesson_manager.gd` | ~230 | Orchestration | Hub finish → always advances playlist |
| Others | smaller | Audio, search FX, tests, theme | Supportive |

**Architecture smell:** Almost everything is created in code (`new()` + mesh building). Few `.tscn` scenes. That made the spike fast, but future modules will hurt unless you split scenes and scripts.

---

## 4. Learning design already present (keep this)

Each lesson roughly follows a strong pattern:

1. Intro concepts (array / index / target)  
2. Guided practice (student decides with CODA)  
3. Independent practice  
4. Quiz  
5. Pseudocode + **C code** mapping in handbook / panels  
6. Complexity (Big-O)  
7. Level complete + badge text  

This matches the product goal: **logic + imagination + code transfer**.

**Do not throw away this loop.** Fix it, then clone it.

---

## 5. Glitches & risks (priority)

Severity: **P0** breaks learning · **P1** frequent friction · **P2** polish

### P0 — fix before any student demo

| ID | Issue | Where |
|----|-------|-------|
| L1 | Any chapter can start first; story assumes order | `lesson_manager` + pedestals / keys 1–2–3 |
| L2 | PLAY / `step_interactive` can auto-answer guided quizzes | All three lesson scripts |
| L3 | Bubble Sort shelf click auto-swaps without YES/NO | `bubble_sort_lesson.gd` → `element_selected` |
| S1 | Conflicting names: SECTOR / Nexus / Protocol / Academy | Hub UI + handbook titles + completion text |

### P1 — fix for classroom comfort

| ID | Issue |
|----|-------|
| U1 | Hub 2D overlay built but `show_hub()` keeps it hidden |
| U2 | Success text says “next chapter” when it means “continue” |
| U3 | Duplicate hotkeys (`B`/`P`/Right) in `player.gd` and `game_ui.gd` |
| U4 | Mouse capture fights quiz / panel clicks |
| T1 | Walls / desks have no collision (player soft-clamped only) |
| T2 | OpenXR enabled by default — noisy for desktop labs |
| T3 | No save of chapter completion / badges |
| L4 | Finishing one hub-picked lesson still advances playlist / auto-next |

### P2 — polish later

- Dense HUD (deck + ribbon + handbook all at once)  
- Blocky CODA ColorRect avatar  
- Project display name still `"New Game Project DSA"`  
- Giant scripts need split  
- Binary Search missing “not found” practice  
- Target cycle values not always in the active array  

Full checklist: `docs/02_GLITCHES_AND_ISSUES.md`

---

## 6. Idea direction (what to build toward)

You said you are lagging for ideas. Here is a **locked idea set** so the team stops inventing in random directions.

### Core idea (locked)

> VR learning world where **archive shelves = data**, student actions = algorithm steps, and CODA maps each action to **C logic**.

### Module 1 only (scope lock)

| Chapter | Algorithm | C concept mapped | Archive story |
|---------|-----------|------------------|---------------|
| 1 | Linear Search | `for` loop, index `i`, compare, return / `-1` | Find lost file in unsorted shelves |
| 2 | Binary Search | `left` / `right` / `mid` while loop | Fast find in sorted wing |
| 3 | Bubble Sort | nested loops + `temp` swap | Restore scrambled lane so Binary Search works again |

**Golden rule students should leave with:**  
*Search power depends on data order. Sorting creates that order.*

### Future modules (ideas only — do not build yet)

| Module | Wing idea | Concepts |
|--------|-----------|----------|
| 2 | Sorting Foundry | Selection / Insertion / Merge intro |
| 3 | Flow Terminals | Stack / Queue + call order |
| 4 | Chain District | Linked lists |
| 5 | Canopy | Trees / BST |
| 6 | Metro Graph | Graphs / BFS / DFS |
| 7 | Complexity Observatory | Big-O prediction missions |

### C-programming expansion ideas (after Module 1)

Keep C as a **reveal**, not an IDE:

- Highlight the exact C line that matches the last shelf action  
- Side panel: “What this loop does in English”  
- Tiny “predict the next line” quizzes  
- Optional later: type a missing token (`i++`, `temp = a[j]`) — still not a full compiler  

---

## 7. Recommended plan (build in this order)

### Phase A — Alignment (this week)

1. Team agrees: objective = logical + imaginative understanding of code  
2. Naming lock: **DSA Academy / Quantum Archive / Hub / CODA / Trainee / Scramble Fault**  
3. Scope lock: Module 1 = 3 algorithms only  
4. Approve story bible: `docs/team/02_COMPREHENSIVE_STORY.md`

**Exit:** Everyone can pitch the project in one sentence the same way.

### Phase B — Demo-safe prototype (1–2 days)

Fix P0/P1 blockers listed in Section 5:

1. Lock chapter order for new players  
2. Disable PLAY during quiz / choice states  
3. Bubble shelf click must not auto-decide  
4. Fix success copy + duplicate hotkeys  
5. Rename project to **DSA Academy**  
6. Rewrite pedestal / hub labels to official names  

**Exit:** A classmate can finish Chapter 1 without asking “what do I click?” more than once.

### Phase C — Design freeze for Linear Search vertical slice

Write a one-page design sheet before more coding:

- Learning objectives (3–5)  
- Exact player verbs each step  
- Hint / fail rules  
- Where C code appears  
- Badge criteria  

### Phase D — Vertical slice rebuild / cleanup

Make **Chapter 1 Linear Search** excellent end-to-end (~15–20 min):

- Clear opening CODA monologue  
- Guided → practice → quiz → C mapping  
- Hub return + save progress  
- Wall/furniture collision  
- First-run 60–90s tutorial  

Playtest with **3 students**, no developer hints.  
Fix top 5 confusions. **Only then** upgrade Chapters 2 and 3 to the same pattern.

### Phase E — Module 1 complete

- Chapters 2 + 3 polished to the same loop  
- Opening + Module 1 ending  
- Desktop + VR parity for core verbs  
- Teacher-facing outcomes list  

### Phase F — Classroom evidence & packaging

- Pilot in a real lab  
- Survey: clarity, enjoyment, confidence  
- Demo build for faculty  

### Phase G — Expand (only after Module 1 works)

Start Module 2+ from the saga map. Prefer clean modular lesson scenes over growing `game_ui.gd`.

---

## 8. What NOT to do yet

- Do not add many new algorithms before Module 1 teaches well  
- Do not chase heavy VR art polish before desktop classroom flow is solid  
- Do not keep both a dead 2D hub overlay and unclear 3D pedestals — pick one primary hub UX  
- Do not turn this into a full C IDE inside VR  
- Do not treat current giant scripts as final architecture  

---

## 9. Suggested near-term team agenda (2 weeks)

### Week 1 — Plan lock + safety fixes

| Day focus | Work |
|-----------|------|
| 1–2 | Read/approve team docs; freeze Module 1 scope |
| 3–4 | Implement Phase B P0 fixes (order lock, PLAY, bubble click, naming) |
| 5 | Internal smoke test of Chapter 1 flow |

### Week 2 — Vertical slice prep

| Day focus | Work |
|-----------|------|
| 1 | Linear Search design sheet |
| 2 | Hub onboarding + official names everywhere |
| 3 | Collision + mouse/modal UX fix |
| 4–5 | Start Chapter 1 cleanup against design sheet; prepare 3-student playtest |

---

## 10. Definition of done — Module 1

A student finishes Module 1 and can say:

> “An array is like archive shelves. Linear Search checks one by one. Binary Search needs sorted shelves and cuts the search in half. Bubble Sort fixes order by swapping neighbors. That’s why sorting matters before smart searching — and those steps match C loops and swaps.”

Checklist:

- [ ] Story names consistent everywhere  
- [ ] Chapters locked in order for new players  
- [ ] No auto-answering quizzes via PLAY  
- [ ] No wall/desk clipping  
- [ ] Progress saved between sessions  
- [ ] 3 classmates playtest without developer help  
- [ ] Teacher can state learning outcomes clearly  

---

## 11. Related documents

| Doc | Purpose |
|-----|---------|
| `docs/team/00_START_HERE.md` | Team reading order |
| `docs/team/01_PROJECT_IDEA_AND_OBJECTIVE.md` | Why we build this |
| `docs/team/02_COMPREHENSIVE_STORY.md` | Full story bible |
| `docs/team/03_PREPRODUCTION_PLAN.md` | Production phases |
| `docs/00_PROJECT_OVERVIEW.md` | Prototype overview |
| `docs/01_STORY_FOR_STUDENTS.md` | Student-facing story |
| `docs/02_GLITCHES_AND_ISSUES.md` | Detailed bug list |
| `docs/03_IMPROVEMENT_ROADMAP.md` | Older prioritized roadmap |

**When docs conflict:** team planning docs (`docs/team/`) win for product direction; this analysis wins for **current code reality**.

---

## 12. Bottom line

You already have a **real teaching loop** and a **usable 3D lab spike**.  
You do **not** have a finished VR education platform yet — and that is normal at 0.1%.

**The plan is not “invent more features.”**  
The plan is:

1. Lock the idea and story  
2. Make Module 1 demo-safe  
3. Perfect Linear Search as the vertical slice  
4. Clone that quality to Binary Search and Bubble Sort  
5. Expand only after students can retell the logic in their own words  

**North star:**  
Turn invisible code logic into a world students can imagine — and actions they can logically master.
