# Project Idea & Objective

**Audience of this document:** Project team (designers, developers, mentors)  
**Purpose:** Agree on *why* we are building this **before** we build more  
**Status:** Pre-production planning (current build ≈ **0.1%** of the intended product)

---

## 1. The core idea (one paragraph)

We are building a **VR-first educational game** that teaches **programming logic and Data Structures & Algorithms** by turning abstract code ideas into **spaces, objects, and actions** students can see, walk through, and perform.

Students should not only memorize definitions. They should **logically understand** *why* an algorithm works, and **imaginatively feel** how data moves, compares, splits, and sorts — as if the computer’s thinking is a world they can enter.

---

## 2. The objective (what success means)

### Primary objective

> Make DSA / coding concepts **logically clear** and **imaginatively memorable** for students through an interactive VR game experience.

### Broken into measurable goals

| Goal | Meaning for the team |
|------|----------------------|
| **Logical understanding** | Student can explain the steps of an algorithm without looking at notes |
| **Imaginative understanding** | Student can picture the algorithm as a physical process (shelves, paths, swaps, halves) |
| **Code connection** | Student can map each game action to a line of real code (e.g. C / pseudocode) |
| **Active learning** | Student *does* the algorithm (click, choose, swap, decide) — not only watches a video |
| **Motivation** | Student wants to continue because the world + story makes practice feel purposeful |

### What we are NOT trying to be (yet)

- Not a full coding IDE inside VR  
- Not a replacement for textbooks / lectures alone  
- Not an infinite open-world game  
- Not “entertainment first, learning second”

We are an **imagination layer** that makes logic stick.

---

## 3. Problem we are solving

Traditional DSA learning problems:

1. Concepts are invisible (arrays, indexes, midpoints live only in text)  
2. Students memorize Big-O phrases without feeling *why*  
3. Dry slides create fear / boredom around algorithms  
4. Practice is often passive (watch animation → forget next day)

Our answer:

> Put the student **inside** the algorithm.  
> Let imagination carry the logic.  
> Let logic reward the imagination with real code insight.

---

## 4. Product statement (team elevator pitch)

**Working title:** DSA Academy (VR Learning World)

**Pitch:**  
A VR learning game where students enter a living “code world,” meet a guide, and solve archive / system problems by performing algorithms as physical actions — then see how those actions become real code.

**Platform direction:**

- **Primary experience:** VR (immersive imagination)  
- **Secondary access:** Desktop 3D (classroom PCs without headsets)  
- **Engine:** Godot 4.x + OpenXR

---

## 5. Learning design principles (non-negotiable)

These principles should guide every feature decision:

1. **See it** — every concept has a visual metaphor in the world  
2. **Do it** — student performs the critical decision (compare, swap, choose mid, advance index)  
3. **Explain it** — guide character confirms *why* that step was correct  
4. **Code it** — show the matching pseudocode / C fragment after the action is understood  
5. **Retell it** — student should be able to teach the idea to a friend in plain language

If a feature does not support at least one of these, it is optional polish — not core.

---

## 6. Target learners

| Attribute | Target |
|-----------|--------|
| Level | Beginner / early intermediate CS students |
| Prior knowledge | Basic programming helpful, not mandatory for Module 1 |
| Context | College / lab / self-learning |
| Session length | 15–25 minutes per concept chapter |
| Group use | Demoable in class; playable solo |

---

## 7. Current reality check

What exists today is an **early prototype spike** (~0.1%):

- A 3D classroom hub  
- Prototype lessons for Linear Search, Binary Search, Bubble Sort  
- Basic UI + interaction + CODA tutor dialogue drafts  

This is **research / proof-of-direction**, not the finished product.

Therefore the next team action is **not** “add more algorithms immediately.”  
The next action is: **lock the idea, story, scope, and build plan** — then implement in phases.

---

## 8. Decision for the team

Before coding the next big chunk, the team should agree on:

1. Vision & objective (this document)  
2. Comprehensive story world (`02_COMPREHENSIVE_STORY.md`)  
3. Pre-production plan & milestones (`03_PREPRODUCTION_PLAN.md`)

Only after these are agreed do we treat features as “in scope.”

---

## 9. One-line north star

**Turn invisible code logic into a world students can imagine — and actions they can logically master.**
