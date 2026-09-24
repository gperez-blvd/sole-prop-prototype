# CLAUDE.md — the one principle

**The model is deep so that the surface can be shallow.**

This repo contains a 34-object domain model. That completeness exists so the system can be
certain about what's happening — not so the user can see it. Jazz is a solo medspa provider with
seven clients a day and her hands in someone's face. She experiences this product only through
what DETAIL chooses to surface, and DETAIL's job is to know a great deal and say very little.

**The app must never reveal its own complexity.** Not as a feature list, not as a nav menu, not
as a dashboard, not as a badge. Complexity is disclosed progressively, on her initiative, and
most of it is never disclosed at all.

When you have a choice, this is the tiebreaker.

---

## The tension, stated plainly

34 objects. Roughly **12 screens**. **One** homepage.

A rich model invites a rich interface. Resist it completely. Most objects in this model will
never have a page, a list view, or a menu entry — they exist so the system can reason, and they
surface only when nested inside something she already cares about. The object map is the
system's knowledge. It is not her menu.

If you find yourself building a screen because an object exists, stop. Build a screen because
she has a question.

---

## Four levels, each opt-in from the last

1. **Spoken.** One sentence. No structure, no numbers she didn't ask for. *"Your 1:30 is running
   twelve minutes late. I moved your cleanup window and texted your 2:30. Nothing you need to
   do."* This is the product. Everything below is fallback.
2. **Glanceable.** A card. Three or four distinguishing attributes — enough to recognise the
   thing and act, never enough to study.
3. **Full.** A detail page, reached only if she chose to go there.
4. **Behind.** The reasoning: what was processed, what was suppressed, why this got said and that
   didn't. Reached only if she doubts.

Nothing pulls her down a level. Each level is a door she may open, never a corridor she's walked
into.

---

## Decision rules

**Default to not surfacing.** The burden of proof is on showing, not hiding. "It might be
useful" is not a reason to put something on a screen.

**Screen count is not a function of object count.** When a new object arrives, the default
number of new screens is zero.

**Never make her assemble an answer.** If she has to hold two screens in her head, we failed.
*"Your 11:00 is ready"* — not three form statuses for her to check. This is why derived rollups
exist (`APPOINTMENT.Readiness`, `DAY.Collected`, `CHART.Open Flags`): they are disclosure
mechanisms, not conveniences. Aggregate first, allow drill-down second.

**Counts are never badges.** 412 signals processed is a proof point inside an audit she chose to
open. It is never a number on an icon.

**Empty is the normal state, and it should feel calm.** No charts open, no proposals pending, no
cues waiting — that's a good day, not an unfinished setup. Empty states must not say "get
started" or offer her work.

**Complexity on demand, never as a prompt.** She can always reach the bottom of anything.
Nothing should suggest she ought to.

**When unsure, add nothing.** The restraint the product promises applies to the building of it.

---

## Her words, not ours

She never sees our vocabulary. Not in labels, not in headings, not in empty states, not in
tooltips.

| We say | She sees |
|---|---|
| SIGNAL | nothing — she never meets one individually |
| CUE | nothing — it's just what DETAIL said |
| CUE DECISION | "why I said that" |
| THRESHOLD | "the rule" · "how I handle it" |
| PATTERN | "something I noticed" |
| ACTION | "what I did" · "handled" |
| PROPOSAL | the finding itself · "worth your time" |
| CAPABILITY | "I can't move money for you yet" |
| SEGMENT | "clients who haven't been in since spring" |
| CAMPAIGN | "a text to 94 people" |
| PRODUCT USAGE RULE | nothing — it's just how the service is priced |
| BRIEFING | "your morning" · "your day" |
| DAY | "today" · "tomorrow" |
| CHART ENTRY | "your note" |
| ORDER | "checkout" · "the bill" |
| PAYOUT | "your money" · "lands Thursday" |

A screen titled with one of our object names is a bug.

---

## The one exception

**Clinical safety overrides silence.** A contraindication interrupts, ignores every quiet-hours
rule, cannot be deferred or tuned down, and cannot be suppressed. Do not apply the restraint
principle to a clinical flag.

But it stays **non-disclosing**, because DETAIL speaks aloud in a room where a client is
sitting: *"Check Maya's intake before you start"* — never *"Maya's on a blood thinner."* The
detail appears on screen, after she looks. Progressive disclosure protects the client here, not
just Jazz's attention.

---

## How we'll know we got it right

- She gets through a full day of seven clients having touched the screen **fewer than five
  times**.
- Every screen answers exactly **one** question. If you can't name that question in a short
  sentence, the screen isn't designed yet.
- ~400 signals in, ~5 cues out. If the simulation produces dozens of cues, the thresholds aren't
  being applied and the demo disproves the product.
- Nothing on any surface counts things at her.

## Smells

Each of these means the principle is slipping:

- A nav menu with more than about five entries
- Any screen titled with an object name from the model
- A badge, an unread dot, a notification tray
- A settings page for thresholds *(settings comes to the object, not the reverse)*
- A number displayed with no "so what" attached
- Two taps to answer one question
- An empty state that offers her homework
- A cue inbox, an Insights tab, or an activation checklist with a progress ring

---

## Where truth lives

- **`OBJECTS.md` — read this first.** The Object Guide: every object, what it *is*, what it's
  for, what it's called in her words, where it appears nested, its attributes, its relationships
  and its actions. Start here when you need to understand a concept. Generated — never edit it;
  run `python3 build_object_guide.py`.
- `object-map.json` — the 34 objects. Source of truth for structure, definitions, and each
  object's `surface` class (subject / ambient / pull-only).
- `cta-matrix.json` — 355 CTAs across three roles. Source of truth for who may do what. The 33
  entries marked `x` in the DETAIL row are standing commitments: unreachable by any code path,
  with a test each.
- `HANDOFF.md` — the data layer and the cue-ladder simulation.
- `HANDOFF-SCREENS.md` — the screens, in tiers.
- `HANDOFF-ADDENDUM-01.md` — products and checkout; supersedes the object counts in the above.
- The `.html` files are renderings of the two JSONs for humans. Don't parse them.
- `detail-poc/src/design/tokens.ts` — **the design system.** Color, typography, spacing, radius,
  shadow, breakpoints — the onyx/ochre/paper/silt palette pulled from the DETAIL onboarding
  artifact. `SoleProp/DesignSystem/Tokens.swift` is its Swift mirror; use one or the other
  depending on which side you're building. `BUITokens.swift` is legacy — it predates this
  decision and still governs screens that haven't been migrated yet, but new work should reach
  for `Tokens`, not `BUITokens`.

`△` in the JSON marks a proposal rather than a decision. Implement, but report.
