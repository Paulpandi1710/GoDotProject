# DSA Academy — Project Overview

**Working title in code:** DSA Academy / The Quantum Classroom  
**Engine:** Godot 4.7 (3D + optional OpenXR)  
**Audience:** Students learning Data Structures & Algorithms for the first time  
**Type:** Interactive 3D educational game (desktop primary, VR optional)

---

## What this project is

This is a **3D classroom lab** where a student walks around, talks to a robot tutor named **CODA**, and **physically practices** algorithms on glowing archive shelves (array elements).

Instead of only reading slides, the student:

1. Walks into a virtual computer lab
2. Chooses a lesson from three pedestals
3. Clicks array “shelves” in 3D (or uses STEP / PLAY)
4. Answers quizzes and sees C code mapped to what they just did

---

## Current learning content (3 chapters)

| Chapter | Algorithm | Core idea taught | Complexity |
|--------|-----------|------------------|------------|
| 1 | Linear Search | Check every element from index 0 | O(n) |
| 2 | Binary Search | Halve a **sorted** search space | O(log n) |
| 3 | Bubble Sort | Swap adjacent out-of-order pairs | O(n²) |

Each lesson roughly follows:

Intro concepts → Guided practice → Independent practice → Quiz → Pseudocode → C code → Complexity → Level complete

---

## Main systems (code map)

| File | Role |
|------|------|
| `dsa_world.gd` | Builds classroom, lights, pedestals, wires systems |
| `player.gd` | Desktop / VR movement + hotkeys |
| `interaction_system.gd` | Raycast click / hover on shelves & pedestals |
| `array_system.gd` | 3D array shelves, search/sort visuals |
| `game_ui.gd` | HUD, story panel, quizzes, handbook, deck controls |
| `lesson_manager.gd` | Hub + lesson playlist + chapter transitions |
| `lessons/*.gd` | Per-algorithm teaching state machines |
| `audio_manager.gd` | SFX |
| `ui/ui_theme.gd` | Colors / glass UI per algorithm |

---

## How a session works today

1. Game starts in the **hub** (classroom with 3 pedestals).
2. Student aims crosshair / presses **1 / 2 / 3** / clicks a pedestal.
3. Pedestals hide; the **array** appears; CODA’s story panel teaches.
4. Student interacts until the lesson finishes.
5. Next chapter transition plays (if playing in order), or they press **H** to return to hub.

**Useful hotkeys**

| Key | Action |
|-----|--------|
| WASD + Mouse | Move / look |
| Left click | Interact (when mouse free or crosshair aim) |
| SPACE / ENTER | Continue dialogue / confirm |
| 1 / 2 / 3 | Quiz choices or hub lesson select |
| ESC | Free / capture mouse |
| R | Restart current lesson |
| H | Return to hub |
| B | Toggle handbook / code guide |
| P | Play / pause interactive lab |
| Right Arrow | Step algorithm |

---

## Documents in this folder

1. `01_STORY_FOR_STUDENTS.md` — clear story / pitch students can understand  
2. `02_GLITCHES_AND_ISSUES.md` — UI, technical, logic, and story problems found in analysis  
3. `03_IMPROVEMENT_ROADMAP.md` — prioritized fixes and story upgrades  

---

## Snapshot of project health

**Strengths**

- Strong teaching structure (guided → practice → quiz → code)
- Clear visual metaphor (archive shelves = array)
- Good algorithm coverage for a first DSA module
- Hybrid desktop + VR path already sketched

**Gaps**

- Story identity is mixed (Academy / Nexus / Quantum / Sector)
- Hub UI screen is built but not shown
- Several input / progression glitches can confuse learners
- No save / badge persistence / locked chapter order
- Walls & furniture lack real collision (player only soft-clamped)

See `02_GLITCHES_AND_ISSUES.md` for the full list.
