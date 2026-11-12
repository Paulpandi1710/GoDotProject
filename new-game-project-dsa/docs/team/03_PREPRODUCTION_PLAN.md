# Pre-Production Plan

**Audience:** Project team  
**Purpose:** Plan before building — convert the idea into phased work  
**Honest status:** Prototype exists (~**0.1%** of intended product). Treat current code as a spike, not final architecture.

---

## 1. Why plan first

If we keep adding algorithms / UI / VR features without a locked idea, we will get:

- inconsistent story and naming  
- features that look cool but don’t teach  
- rework loops that waste team time  

So the production rule is:

> **Agree → Design → Prototype small → Test with 3 students → Then expand**

---

## 2. What “0.1% done” means

### Already explored (prototype spike)
- Godot 3D classroom hub shell  
- Pedestal lesson select  
- Draft lessons: Linear Search, Binary Search, Bubble Sort  
- Draft tutor (CODA) dialogue + quizzes  
- Desktop movement + experimental OpenXR path  
- Early HUD / handbook / step controls  

### Not done (the real product)
- Locked vision approved by whole team  
- Final story + chapter scripts  
- VR interaction design that feels natural for learning  
- Art / audio direction  
- Progression, saves, assessment  
- Classroom deployment package  
- Playtested learning effectiveness evidence  
- Clean architecture for many future modules  

**Conclusion:** We are at **discovery**, not content production at scale.

---

## 3. Production pillars

Every milestone must protect these four pillars:

1. **Learning clarity** — student understands the logic  
2. **Imagination** — student can picture the process  
3. **Agency** — student performs key decisions  
4. **Code transfer** — game action maps to real code  

---

## 4. Phased roadmap (plan → build)

### Phase A — Alignment (now)
**Output:** team documents approved  
**Docs:**
- `01_PROJECT_IDEA_AND_OBJECTIVE.md`
- `02_COMPREHENSIVE_STORY.md`
- `03_PREPRODUCTION_PLAN.md` (this file)

**Exit criteria:**
- [ ] Team agrees on objective statement  
- [ ] Team agrees on story world + naming lock  
- [ ] Team agrees Module 1 scope only (3 algorithms)

---

### Phase B — Design freeze for Module 1
**Output:** design sheets (still mostly docs / wireframes)

Create for each chapter:
1. Learning objectives (3–5 bullets)  
2. Interaction script (what player does each step)  
3. Failure / hint rules  
4. Code reveal moments  
5. Success checklist / badge criteria  

Also design:
- VR control scheme for “select element / confirm choice / continue”  
- Desktop fallback scheme (same verbs)  
- First-time tutorial flow (60–90 seconds)

**Exit criteria:**
- [ ] No chapter starts coding until its design sheet exists  
- [ ] Metaphors are consistent (shelves = array)

---

### Phase C — Vertical slice (the real first build)
**Goal:** one excellent chapter, not three average ones.

**Recommended slice:** Chapter 1 Linear Search (complete teaching loop)

Must include:
- Problem intro (lost file)  
- Guided perform steps  
- Independent practice  
- Quiz  
- Pseudocode + short C mapping  
- Clear success feedback  

**Exit criteria:**
- [ ] 3 target students complete without developer help  
- [ ] 2/3 can explain Linear Search in their own words afterward  
- [ ] Session fits ~15–20 minutes  

Only then clone the pattern to Binary Search and Bubble Sort.

---

### Phase D — Module 1 completion
- Chapter 2 + Chapter 3 using the proven pattern  
- Hub progression (unlock order)  
- Save / resume  
- Opening + ending sequences  
- Desktop + VR parity for core verbs  

**Exit criteria:**
- [ ] Full Module 1 playable end-to-end  
- [ ] Story names consistent  
- [ ] Teacher can state learning outcomes clearly  

---

### Phase E — Evidence & packaging
- Classroom pilot  
- Feedback survey (clarity, enjoyment, confidence)  
- Bugfix + performance pass  
- Demo build for faculty / showcase  

---

### Phase F — Future modules (only after Module 1 works)
Use saga map from story bible (Sorting Foundry, Stack/Queue, Lists, Trees, Graphs).

---

## 5. Scope control (what we refuse early)

Do **not** prioritize these before Module 1 vertical slice is proven:

- Many new algorithms at once  
- Complex multiplayer  
- Full voice acting  
- Huge open campus exploration  
- Custom advanced rendering flexing  
- AI-generated endless questions without pedagogy review  

---

## 6. Team roles (suggested)

Even if one person wears many hats, name ownership:

| Role | Owns |
|------|------|
| Vision lead | Objective + scope decisions |
| Learning designer | Objectives, quiz quality, code mapping |
| Narrative designer | Story consistency + dialogue length |
| VR/interaction designer | Comfortable controls + verbs |
| Gameplay engineer | Lesson state machines / systems |
| UI engineer | HUD clarity, accessibility |
| Playtest lead | Recruit students, write findings |

If team is small: assign **Vision**, **Learning**, **Build**, **Playtest** as minimum four hats.

---

## 7. Playtest protocol (mandatory each phase)

For every vertical slice:

1. Give headset/desktop with **no verbal hints** from developers  
2. Observe where students hesitate  
3. Ask after session:  
   - What was the algorithm doing?  
   - Why does it work?  
   - What would you tell a friend?  
4. Log top 5 confusions  
5. Fix those before adding new content  

---

## 8. Definition of “ready to build next feature”

A feature enters sprint only if:

1. It supports a Module 1 learning objective, **or**  
2. It unblocks VR/desktop playability for that objective, **and**  
3. It has a short acceptance test written first  

No “cool idea” without an acceptance test.

---

## 9. Near-term team agenda (next 2 weeks)

### Week 1 — Plan lock
- Read & approve Idea/Objective doc  
- Read & approve Story bible  
- Freeze Module 1 scope  
- Write Linear Search design sheet  

### Week 2 — Slice prep
- Simplify hub onboarding copy to official names  
- Define VR + desktop verbs  
- List prototype bugs that block learning (ignore cosmetic ones)  
- Start rebuilding Linear Search against the design sheet (not against old accidental complexity)

---

## 10. Relationship to existing prototype code

Use current code as:

- interaction experiments  
- reference for what feels fun  
- a list of what to redesign  

Do **not** treat current giant scripts as final.  
After design freeze, prefer clean modular rebuild of lesson flow if needed.

Related analysis of current spike issues (optional reading):  
`../02_GLITCHES_AND_ISSUES.md`

---

## 11. Success picture (end of Module 1)

A student finishes Module 1 and can say:

> “An array is like archive shelves. Linear Search checks one by one. Binary Search needs sorted shelves and cuts the search in half. Bubble Sort fixes order by swapping neighbors. That’s why sorting matters before smart searching.”

If students can say that from the VR experience, the project objective is working.

---

## 12. Final planning rule

**We plan the imagination and the logic first.  
Then we build the VR world to carry both.**
