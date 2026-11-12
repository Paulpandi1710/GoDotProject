# DSA Academy — Glitches & Issues Analysis

Analysis date: 2026-11-12  
Scope: game scripts (excluding addons) — UI, technical, logic, story

Severity legend:

- **P0** — Breaks learning flow / soft-locks / wrong teaching  
- **P1** — Confusing UX or frequent friction  
- **P2** — Polish / consistency / maintainability  

---

## A. UI glitches

### A1. Hub menu screen is built but never shown — **P1**
`game_ui.gd` builds a full hub overlay (`_build_hub_screen`) with sector cards and “ENGAGE PROTOCOL” buttons, but `show_hub()` always sets `_hub_overlay.visible = false`.

**Effect:** Students only use 3D pedestals / hotkeys. The nicer 2D hub UI is dead code. New students may not notice pedestals.

**Fix:** Either enable the overlay on hub enter, or delete unused hub UI and teach “walk to pedestals” clearly on first launch.

---

### A2. Success text lies about “next chapter” — **P1**
`show_success_message()` says: *“Press SPACE to continue to the next chapter.”*

In Linear / Binary guided flow, SPACE actually continues to **reflection / practice inside the same lesson**, not the next chapter.

**Effect:** Students expect a level skip and feel the game “stuck.”

**Fix:** Change copy to “Press SPACE to continue.”

---

### A3. Story panel + mouse capture fights the student — **P1**
Opening a story/quiz panel releases the mouse. Closing re-captures it. Clicking the upper 75% of the screen while free also re-captures.

**Effect:** Trying to click quiz buttons / deck buttons while look-capture flips is frustrating, especially on first play.

**Fix:** While any modal is open, force mouse free and ignore re-capture clicks. Show a clear “ESC = free mouse” tip on first launch.

---

### A4. Duplicate hotkeys fire twice — **P1**
`KEY_B`, `KEY_P`, and `KEY_RIGHT` are handled in both `player.gd` and `game_ui.gd`.

**Effect:** Handbook can toggle twice (open then instantly close). Play/step can double-trigger.

**Fix:** Handle each hotkey in **one** place only (prefer `game_ui` for UI actions, `player` for movement / R / H / hub keys).

---

### A5. Dense HUD during lessons — **P2**
During a lesson, HUD + progress strip + action bar + interactive deck + array ribbon + handbook can all appear together.

**Effect:** Beginners lose focus on CODA’s instruction.

**Fix:** Show deck/ribbon only after “Interactive Lab” phases, or collapse them behind a single “Lab Controls” toggle by default.

---

### A6. CODA avatar is blocky ColorRects — **P2**
Works, but looks unfinished next to the polished 3D lab.

**Fix:** Replace with a simple sprite / animated face, or keep blocks but add blink / mood changes from `coda_mood` in themes (currently unused).

---

### A7. Project display name is still generic — **P2**
`project.godot` → `config/name="New Game Project DSA"`.

**Fix:** Rename to `DSA Academy`.

---

## B. Technical glitches

### B1. Classroom walls / furniture have no collision — **P1**
Only the floor is a `StaticBody3D`. Walls, desks, chairs, bookshelves are meshes only. Player is soft-clamped with `position.x/z` limits.

**Effect:** Player walks through desks and walls (feels broken). Can clip into bookshelves near hub.

**Fix:** Add collision to walls (and ideally desk/bookshelf blockers), or raise invisible wall colliders.

---

### B2. OpenXR enabled in project settings by default — **P1**
`project.godot` has `openxr/enabled=true`. Desktop users without VR get fallback, but startup logs noise and may confuse packaging.

**Fix:** Keep VR optional; default OpenXR off for classroom desktop builds.

---

### B3. `create_array()` frees children then immediately rebuilds — **P1**
Old element bodies are `queue_free()`’d, then new ones created in the same frame. References in trails/tweens may briefly point at freeing nodes.

**Effect:** Occasional flicker, missing hover, or tween errors when rapidly resetting / changing arrays.

**Fix:** Await a frame after free, or reuse element pool instead of destroy/recreate.

---

### B4. `execute_comparison()` uses `await` inside non-async call chain — **P1**
Mismatch path awaits 0.65s before advancing. During that wait, extra clicks can queue odd states because `transition_in_progress` stays true then flips late.

**Effect:** Double-click during comparison can feel “dead” then suddenly advance.

**Fix:** Keep a hard input lock until transition ends; ignore clicks while `transition_in_progress`.

---

### B5. Signals declared but unused — **P2**
`game_ui.gd` declares `action_emitted`, `hub_topic_selected`, `return_to_hub_requested` but `_emit()` talks to `lesson_manager` directly. Signals are mostly unused.

**Effect:** Harder to maintain; false sense of architecture.

**Fix:** Either wire signals properly or remove unused ones.

---

### B6. Giant scripts — **P2**
`game_ui.gd` ~2200 lines, `array_system.gd` ~1165, `dsa_world.gd` ~1395, Linear Search lesson ~1500.

**Effect:** Bugs are hard to fix; students contributing code get lost.

**Fix:** Split UI into HubUI / StoryPanel / Handbook / DeckControl scenes.

---

### B7. No progress persistence — **P1** (product)
Badges (“LINEAR SEARCH EXPLORER”) and chapter completion are not saved.

**Effect:** Restarting the game loses all sense of achievement.

**Fix:** Save completed chapters + badges to `user://progress.cfg`.

---

## C. Logic / teaching glitches

### C1. Hub allows any chapter first — breaks story order — **P0**
Pedestals / keys 1–2–3 launch any lesson immediately. Binary Search dialogue assumes Linear Search already happened (“Linear Search was okay…”). Bubble Sort assumes Binary Search need for sorted data.

**Effect:** Student can start Chapter 3 first and the story / prerequisites make no sense.

**Fix:** Lock chapters until previous is complete (free roam unlock after finishing all, or after teacher toggle).

---

### C2. Auto-Play can answer quizzes for the student — **P0**
In Linear / Binary / Bubble lessons, `step_interactive()` during guided states auto-sends correct `FIRST` / `MIDDLE` answers.

**Effect:** Pressing PLAY during guided teaching **plays the lesson for them**, skipping thinking. Undermines pedagogy.

**Fix:** Disable PLAY during quiz / choice states; only allow STEP/PLAY in sandbox / independent lab phases.

---

### C3. Bubble Sort: clicking shelves bypasses YES/NO decision — **P0**
In `bubble_sort_lesson.gd` → `element_selected()`, clicking either compared shelf automatically swaps or keeps based on truth — **without** checking the student’s YES/NO answer.

**Effect:** Student can “succeed” without understanding the decision.

**Fix:** Shelf click should only focus the pair / show hint; require YES/NO (or 1/2) for the decision.

---

### C4. Linear Search guided success → reflection flow is easy to mis-read — **P1**
After finding the target, state becomes `REFLECT_QUIZ`, but first SPACE only *opens* the reflection question (`_p3_show_reflection`), second interaction answers it.

**Effect:** Feels like an extra empty step.

**Fix:** Jump straight into the reflection question after success, or auto-open it.

---

### C5. Completing a single chapter from hub still advances playlist index — **P1**
`_on_lesson_finished()` always does `current_lesson_index += 1` and may auto-start the next chapter transition even if the student picked Chapter 3 from hub.

**Effect:** Unexpected jump into another lesson; or “all complete” screen at wrong time.

**Fix:** Track completion flags per chapter. Hub launches should return to hub on finish unless “Story Mode” is active.

---

### C6. Binary Search has no dedicated “not found” practice — **P2**
Linear Search includes a not-found scenario. Binary Search does not.

**Effect:** Incomplete parallel curriculum; student may not learn `left > right → -1`.

**Fix:** Add a short not-found practice (target missing from sorted array).

---

### C7. Interactive target cycle includes values not in current array — **P2**
Deck target button cycles `[10, 25, 40, 15, 30, 99]` even during Binary / Bubble contexts.

**Effect:** “Not found” loops that look like bugs during Binary sandbox.

**Fix:** Target picker should use values from the active interactive array (+ optional “missing” target).

---

### C8. R restarts lesson even in hub — **P2**
Restart while `in_hub` can load a lesson index unexpectedly depending on `current_lesson_index`.

**Fix:** Disable R in hub; only restart when a lesson is active.

---

## D. Story / content glitches

### D1. Conflicting world names — **P0** (clarity)
The project mixes:

- DSA Academy  
- Quantum Classroom  
- Nexus Hub / Nexus Terminal  
- Quantum Archive  
- SECTOR 01 / 02 / 03  
- “Engage Protocol”

**Effect:** Students don’t know what the game is about in 10 seconds.

**Fix:** Adopt the single story in `01_STORY_FOR_STUDENTS.md` and rewrite pedestal / hub / intro copy.

---

### D2. Missing “why” — **P1**
Current intros say a file is lost / archive scrambled, but never explain:

- Who scrambled it?  
- Why does the Academy need the student?  
- What changes in the world when they finish?

**Effect:** Feels like disconnected mini-demos, not one adventure.

**Fix:** Use the surge / restore-Archive arc from the story bible.

---

### D3. Tone mismatch (military sci-fi vs classroom tutor) — **P1**
Pedestals say “SECTOR / ENGAGE”; CODA says “Hello! I’m your personal Archive Robot.”

**Effect:** Brand confusion; teachers may think it’s too “gamey” or too vague.

**Fix:** Keep neon lab visuals; make all student-facing text classroom-friendly.

---

### D4. Ending promises content that doesn’t exist — **P2**
Completion text: *“You’re ready to tackle the pending algorithms…”* — but no further lessons exist.

**Fix:** Say “Module 1 complete” and tease future modules without promising buttons that don’t exist.

---

### D5. Element numbering in dialogue can confuse beginners — **P2**
Linear intro says “Element 1 → value 10” while index is 0.

**Effect:** Mixes human counting with zero-based indexing before the zero-index lesson lands.

**Fix:** Always show both: “1st element (index 0) = 10”.

---

## E. Quick reproduction checklist (for testers)

1. Start game → can you tell what to do in 5 seconds without reading code?  
2. Press **2** first → does Binary Search story still assume Linear done?  
3. In Linear guided compare quiz, press **PLAY** → does it auto-answer?  
4. In Bubble guided pair, click a glowing shelf → does it skip YES/NO?  
5. Walk into a desk / wall → do you clip through?  
6. Open handbook with **B** once → does it stay open or flicker?  
7. Finish only Bubble Sort from hub → do you get thrown into “all complete” / wrong transition?  
8. Read success popup → does it wrongly say “next chapter”?

---

## Summary table

| Area | P0 | P1 | P2 |
|------|----|----|----|
| UI | 0 | 4 | 3 |
| Technical | 0 | 4 | 2 |
| Logic | 3 | 3 | 2 |
| Story | 1 | 2 | 2 |

**Highest priority fixes for student demos:** C1, C2, C3, D1, A2, A4, B1.
