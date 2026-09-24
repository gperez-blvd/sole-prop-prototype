# OBJECTS.md — the Object Guide

**Generated. Do not edit by hand** — run `python3 build_object_guide.py` instead.

Source of truth: `object-map.json` (structure, definitions) and `cta-matrix.json` (actions). This file exists so an agent can answer *what is this object and how does it relate* without reading the whole map.

**34 objects.** `△` marks a proposal rather than a settled decision.

Surface classes: **Subject** gets a detail page · **Ambient** appears only nested on other objects · **Pull-only** is reachable but never pushed. See `CLAUDE.md` — object count is not screen count.

## Index

**Subject** (17) — [OPERATOR](#operator) · [BUSINESS](#business) · [DETAIL](#detail) · [DAY](#day) · [PROPOSAL](#proposal) · [CLIENT](#client) · [CHART](#chart) · [FORM](#form) · [APPOINTMENT](#appointment) · [SERVICE](#service) · [PRODUCT](#product) · [ORDER](#order) · [OPENING](#opening) · [WAITLIST REQUEST](#waitlist-request) · [CAMPAIGN](#campaign) · [SEGMENT](#segment) · [REVIEW](#review)

**Ambient** (16) — [PERSONA](#persona) · [PATTERN](#pattern) · [THRESHOLD](#threshold) · [SIGNAL](#signal) · [CUE DECISION](#cue-decision) · [CUE](#cue) · [BRIEFING](#briefing) · [ACTION](#action) · [CHART ENTRY](#chart-entry) · [PRODUCT USAGE RULE](#product-usage-rule) · [PRODUCT USAGE](#product-usage) · [PRODUCT CREDIT](#product-credit) · [ORDER LINE ITEM](#order-line-item) · [PAYMENT](#payment) · [PAYOUT](#payout) · [MESSAGE](#message)

**Pull-Only** (1) — [CAPABILITY](#capability)

---

## OPERATOR

**Subject** — has its own detail page

The person doing the work. For Jazz that means owner, provider, front desk and entire staff at once. The human DETAIL serves.

**Purpose.** Anchors everything: whose day it is, whose thresholds govern, whose signature goes on a chart entry.

**Also called.** provider, staff, injector

**Appears nested on (9).** BUSINESS *(working in it)*, DETAIL *(it serves)*, DAY *(whose day it is)*, BRIEFING *(it's for)*, CHART ENTRY *(who authored it)*, APPOINTMENT *(performing)*, SERVICE *(qualified to perform)*, ORDER *(who closed it)*, REVIEW *(it's about)*

### Core content

- `Full Name` — *Jazz Bennett*
- `Mobile` — *(615) 555-0142*
- `Photo` — *<headshot>*

### Metadata

- `Role` — *owner / provider / front desk*
- `Licenses & Certifications` — *injector, esthetics, laser*
- `Tenure on Boulevard` — *Day 0 → Year 2*
- `Timezone` — *America/Chicago*

### Relationships

- has 1 **DETAIL** personal operator
- has 1 **BUSINESS** works in
- has 0-many **APPOINTMENT** performing
- has 0-many **SERVICE** qualified for
- has 0-many **CLIENT** serving
- has 0-many **DAY** worked
- has 0-many **CHART ENTRY** authored
- has 0-many **ORDER** closed

### Actions — OPERATOR

- Edit profile
- Add a credential
- Set working hours
- Pause my day

---

## BUSINESS

**Subject** — has its own detail page

The commercial entity — brand, hours, address, menu, booking link. Owns the clients, services, products, days and campaigns.

**Purpose.** The top-level container, and the boundary for what DETAIL knows.

**Also called.** location, practice, medspa

**Appears nested on (17).** OPERATOR *(works in)*, PATTERN *(it's about)*, SIGNAL *(it's about)*, DAY *(it belongs to)*, CAPABILITY *(△ it belongs to)*, CLIENT *(client of)*, APPOINTMENT *(booked at)*, SERVICE *(offered by)*, PRODUCT *(stocked by)*, ORDER *(rung up at)*, PAYOUT *(paid out to)*, OPENING *(belongs to)*, WAITLIST REQUEST *(asked of)*, MESSAGE *(sent from)*, CAMPAIGN *(sent from)*, SEGMENT *(belongs to)*, REVIEW *(it's about)*

### Core content

- `Business Name` — *Jazz Aesthetics*
- `Logo` — *<from Instagram>*
- `Brand Palette & Voice` — *<from Instagram>*
- `Booking Link` — *book.blvd.co/jazz*

### Metadata

- `Category` — *Medical aesthetics*
- `Address` — *Suite 204 · Nashville, TN*
- `Hours` — *Tue–Sat · 9 to 6*
- `Star Rating` — *4.9*
- `Review Count` — *38*
- `△ Activation Stage` — *onboarded / activating / steady*

### Relationships

- has 1-many **OPERATOR** working in it
- has 0-many **SERVICE** offered
- has 0-many **CLIENT** on file
- has 0-many **APPOINTMENT** booked
- has 0-many **CAPABILITY** △ available to it
- has 0-many **SIGNAL** generated
- has 0-many **DAY** of operation
- has 0-many **CAMPAIGN** sent
- has 0-many **SEGMENT** defined
- has 0-many **PATTERN** observed in it
- has 0-many **REVIEW** received
- has 0-many **OPENING** unfilled
- has 0-many **MESSAGE** exchanged
- has 0-many **WAITLIST REQUEST** outstanding
- has 0-many **PRODUCT** stocked
- has 0-many **ORDER** rung up
- has 0-many **PAYOUT** received

### Actions — OPERATOR

- Edit brand
- Edit hours
- Add a service
- Close for a day
- Share booking link

### Actions — DETAIL

- Refresh brand from Instagram — `~` must ask first
- Update hours from observed pattern — `~` must ask first

---

## DETAIL

**Subject** — has its own detail page

The operator's personal assistant: one per operator, the voice in her ear. Holds almost no content of its own — its substance is the THRESHOLDs it has learned and the PATTERNs it has observed.

**Purpose.** The product. Decides what reaches her, when, and in what voice.

**Also called.** assistant, operator, the voice

**Appears nested on (9).** OPERATOR *(personal operator)*, PERSONA *(based on it)*, PATTERN *(that observed it)*, THRESHOLD *(belongs to)*, CUE DECISION *(that decided)*, CUE *(delivered by)*, BRIEFING *(delivered by)*, ACTION *(that took it)*, PROPOSAL *(that raised it)*

### Core content

- `Name / Codename` — *Fixer*

### Metadata

- `Voice — Calm ↔ Energetic` — *slider position*
- `Voice — Facts ↔ Conversational` — *slider position*
- `Voice — Professional ↔ Playful` — *slider position*
- `Voice — Humor` — *none ↔ dry*
- `Tenure` — *Day 0 / Week 2 / Year 1*
- `Knowledge Level` — *8 → 32 → 62 → 82 → 92*
- `Avg Cues per Day` — *5*
- `Status` — *active / paused*

### Relationships

- has 1 **OPERATOR** it serves
- has 1 **PERSONA** based on
- has 0-many **THRESHOLD** learned
- has 0-many **CUE** delivered
- has 0-many **ACTION** taken
- has 0-many **PROPOSAL** pending
- has 0-many **CUE DECISION** made
- has 0-many **CAMPAIGN** drafted
- has 0-many **PATTERN** observed

### Actions — OPERATOR

- Rename
- Switch persona
- Tune voice
- Mute for an hour
- Mute for the day
- Pause entirely
- Wake

### Actions — DETAIL

- Change my own voice — `x` **never, by design**
- Expand my own autonomy — `x` **never, by design**

---

## PERSONA

**Ambient** — no page of its own; appears nested on other objects

A preset voice DETAIL can be configured from — Concierge, Fixer, Shadow, Hype. Changes delivery, never capability.

**Purpose.** Lets every operator have a different voice over identical intelligence.

**Also called.** voice, tone preset

**Appears nested on (1).** DETAIL *(based on)*

### Core content

- `Persona Name` — *Concierge / Fixer / Shadow / Hype*
- `Description` — *the one who just handles it*
- `Sample Cue Phrasing` — *"1:30 ran twelve late. Handled."*

### Metadata

- `Default Tone Positions` — *4 slider defaults*
- `Adoption Rate` — *% of operators who pick it*

### Relationships

- has 0-many **DETAIL** based on it

### Actions — OPERATOR

- Audition
- Select

### Actions — DETAIL

- Recommend one — `~` must ask first

---

## PATTERN

**Ambient** — no page of its own; appears nested on other objects

A confident, evidenced generalisation about how the business behaves — 'Thursdays book out three weeks ahead'. A pattern describes the world; a THRESHOLD constrains DETAIL.

**Purpose.** The evidence layer beneath every proposal. Gives findings a citable source instead of free text.

**Also called.** rhythm, trend, observation

**Appears nested on (9).** BUSINESS *(observed in it)*, DETAIL *(observed)*, THRESHOLD *(derived from)*, DAY *(it evidences)*, BRIEFING *(announced)*, PROPOSAL *(it cites)*, CLIENT *(about her)*, SERVICE *(about it)*, SEGMENT *(about it)*

### Core content

- `Observation` — *“Your Thursdays book out three weeks ahead”*
- `Value Implication` — *one more half day ≈ $1,800 a month*

### Metadata

- `Unit` — *weekday / time-of-day / seasonal / weather / cohort / service*
- `Evidence Count` — *4 weeks running*
- `Confidence` — *high*
- `First Observed` — *Year 1, Month 8*
- `Last Confirmed` — *this Thursday*
- `Direction` — *strengthening / stable / decaying*
- `Estimated Value` — *$1,800 / month*
- `Status` — *watching / announced / confirmed / dismissed*

### Relationships

- has 1 **BUSINESS** it's about
- has 1 **DETAIL** that observed it
- has 0-many **DAY** evidencing it
- has 0-many **PROPOSAL** it generated
- has 0-many **THRESHOLD** derived from it
- has 0-1 **SERVICE** it concerns
- has 0-1 **SEGMENT** it concerns
- has 0-1 **CLIENT** it concerns
- has 0-many **BRIEFING** that announced it

### Actions — OPERATOR

- Confirm
- “That’s not true”
- Ask for the evidence
- Act on it
- Mute

### Actions — DETAIL

- Observe — `*` acts without asking
- Strengthen — `*` acts without asking
- Let it decay — `*` acts without asking
- Cite in a proposal — `*` acts without asking
- Announce once — `~` must ask first

---

## THRESHOLD

**Ambient** — no page of its own; appears nested on other objects

A rule governing what DETAIL may do and when — 'lateness under 15 minutes: handle it, don't ask'. Learned from observed behaviour rather than set in a settings screen.

**Purpose.** The autonomy contract. What compounds with tenure, and what makes restraint possible.

**Also called.** rule, preference, boundary

**Appears nested on (8).** DETAIL *(learned)*, PATTERN *(derived from it)*, SIGNAL *(evaluated against)*, CUE DECISION *(consulted)*, ACTION *(authorized by)*, PROPOSAL *(would create or tune)*, CAPABILITY *(△ it enables)*, SERVICE *(governed by)*

### Core content

- `Rule Statement` — *lateness under 15 min: handle it, don't ask*
- `Observed Behavior` — *41 of 41 small shifts approved*

### Metadata

- `Type` — *speaking window / autonomy grant / decision boundary*
- `Boundary Value` — *15 min · 2nd offense · after 3pm Fri*
- `Permitted Action` — *handle / ask first / stay silent*
- `Mechanics` — *△ inherited / declared / inferred-and-confirmed / inferred-silently*
- `Evidence Count` — *41*
- `Confidence` — *high*
- `Learned Date` — *Month 1, Week 3*
- `Last Confirmed` — *9 months ago*
- `△ Resolution Timing` — *ask-now / ask-at-debrief / infer-silently*

### Relationships

- has 1 **DETAIL** belongs to
- has 0-many **SIGNAL** evidenced by
- has 0-1 **PROPOSAL** created or tuned by
- has 0-many **CUE DECISION** consulted in
- has 0-1 **CAPABILITY** △ enabled by
- has 0-1 **PATTERN** derived from
- has 0-many **ACTION** it authorized

### Actions — OPERATOR

- Confirm
- Adjust
- Tighten
- Loosen
- Decline
- Revert this instance
- Pause
- Delete

### Actions — DETAIL

- Apply — `*` acts without asking
- Infer silently — `*` acts without asking
- Propose a change — `~` must ask first
- Retire a stale one — `~` must ask first

---

## SIGNAL

**Ambient** — no page of its own; appears nested on other objects

One raw event the system observed, or one derived absence. Hundreds a day. Individually meaningless to Jazz.

**Purpose.** The raw material. Collectively, the evidence that DETAIL is working — 407 handled without her.

**Also called.** event, notification source

**Appears nested on (11).** BUSINESS *(generated)*, THRESHOLD *(evidenced by)*, CUE DECISION *(it resolved)*, DAY *(processed)*, ACTION *(triggered by)*, CLIENT *(about her)*, FORM *(it generated)*, APPOINTMENT *(generated)*, PRODUCT *(it generated)*, PAYMENT *(it generated)*, MESSAGE *(it generated)*

### Core content

- `Payload / Raw Event` — *check-in: 1:30 client arrived 12 min late*

### Metadata

- `Timestamp` — *1:42:10*
- `Source` — *check-in / payment / DM / review / weather / stock / △ form / △ chart / API / △ derived*
- `Domain` — *scheduling / payments / messaging / inventory / external*
- `Disposition` — *handled-silently / suppressed / deferred / escalated-to-cue / awaiting-approval*
- `Materiality` — *does it matter? — ladder step 2*
- `Auto-actionable?` — *yes — ladder step 3*

### Relationships

- has 1 **BUSINESS** it's about
- has 0-1 **CLIENT** it concerns
- has 0-1 **APPOINTMENT** it concerns
- has 0-many **THRESHOLD** evaluated against
- has 0-many **ACTION** triggered
- has 0-1 **CUE DECISION** resolved by
- has 1 **DAY** processed on
- has 0-1 **FORM** it's about
- has 0-1 **PRODUCT** it's about
- has 0-1 **PAYMENT** it's about

### Actions — OPERATOR

- “Should have told me”
- “Didn’t need this”
- Escalate to a cue

### Actions — DETAIL

- Evaluate against thresholds — `*` acts without asking
- Suppress — `*` acts without asking
- Defer — `*` acts without asking
- Escalate — `*` acts without asking

---

## CUE DECISION

**Ambient** — no page of its own; appears nested on other objects

The junction where many SIGNALs resolve into at most one CUE. Holds the reasoning, the timing call, and what was suppressed alongside.

**Purpose.** Answers 'why did you tell me that?' — and 'why didn't you?'

**Also called.** the ladder, disposition

**Appears nested on (4).** DETAIL *(made)*, THRESHOLD *(consulted in)*, SIGNAL *(resolved by)*, CUE *(produced by)*

### Core content

- `Reasoning` — *she should know her next client moved. One sentence. Wait for the gap.*

### Metadata

- `Ladder Stop` — *step 1–5 (where the signal stopped)*
- `Outcome` — *handled-silently / suppressed / deferred / escalated*
- `Timing Decision` — *speak now / wait for gap / hold for debrief*
- `Suppressed Alongside` — *3 marketing notices, 1 stock alert, 2 payout confirmations*
- `Decided At` — *1:44:54*

### Relationships

- has 1-many **SIGNAL** it resolved
- has 0-1 **CUE** it produced
- has 0-many **THRESHOLD** consulted
- has 1 **DETAIL** that decided

### Actions — OPERATOR

- Disagree with this call

### Actions — DETAIL

- Decide — `*` acts without asking
- Reverse a decision — `~` must ask first

---

## CUE

**Ambient** — no page of its own; appears nested on other objects

One thing DETAIL said. Its core content is a single sentence; everything else about it is relationship.

**Purpose.** The entire user-facing surface of the intelligence. Five a day.

**Also called.** what DETAIL said

**Appears nested on (9).** DETAIL *(delivered)*, CUE DECISION *(it produced)*, DAY *(spoken during it)*, ACTION *(reported in)*, PROPOSAL *(delivered in)*, CLIENT *(about her)*, FORM *(it prompted)*, APPOINTMENT *(about it)*, PAYMENT *(it prompted)*

### Core content

- `Spoken Text` — *"Your 1:30 is running 12 minutes late. I moved your cleanup window and texted your 2:30. Nothing you need to do."*
- `Operator Response` — *"Do it."*

### Metadata

- `Timestamp` — *1:38 PM*
- `Type` — *interstitial / △ milestone / △ capability / △ clinical-flag*
- `△ Intent` — *inform / decide / demonstrate / request*
- `Channel` — *in-ear / CarPlay / watch / phone*
- `Delivery Window` — *between clients / commute / after hours*
- `Word Count` — *21*
- `Requires Decision?` — *no*
- `Status` — *queued / delivered / acknowledged / expired*
- `Persona Voice Used` — *Fixer*
- `△ Clinical Override` — *yes — ignores speaking windows, cannot be suppressed*

### Relationships

- has 1 **DETAIL** delivered by
- has 1 **CUE DECISION** produced by
- has 0-many **ACTION** it reports
- has 0-1 **PROPOSAL** it carries
- has 0-1 **CLIENT** it concerns
- has 0-1 **APPOINTMENT** it concerns
- has 0-1 **CAPABILITY** △ it concerns
- has 1 **DAY** spoken on
- has 0-1 **FORM** it concerns
- has 0-1 **PAYMENT** it concerns

### Actions — OPERATOR

- Answer
- Acknowledge
- Defer
- Dismiss
- Replay
- Act on it in-app
- “Too late”

### Actions — DETAIL

- Compose — `*` acts without asking
- Speak — `*` acts without asking
- Queue — `*` acts without asking
- Withhold — `*` acts without asking
- Expire — `*` acts without asking
- Suppress a clinical flag — `x` **never, by design**

---

## DAY

**Subject** — has its own detail page

A Container Object for one working day — its appointments, cues, actions, orders and openings — plus rollups derived from them. The app's homescreen is a DAY.

**Purpose.** The unit Jazz thinks in. 'Seven today.' 'That's the day.' The subject of the home screen.

**Also called.** today, tomorrow

**Appears nested on (14).** OPERATOR *(worked)*, BUSINESS *(of operation)*, PATTERN *(evidencing it)*, SIGNAL *(processed on)*, CUE *(spoken on)*, BRIEFING *(it's about)*, ACTION *(taken on)*, PROPOSAL *(surfaced on)*, APPOINTMENT *(scheduled on)*, ORDER *(rung up on)*, PAYOUT *(initiated on)*, OPENING *(it sits in)*, CAMPAIGN *(sent on)*, REVIEW *(arrived on)*

### Core content

- `Date` — *September 23, 2026*
- `Day Label` — *Tuesday the 23rd*
- `△ Day Note` — *first day back after being out sick*

### Metadata

- `Weekday` — *Tuesday*
- `Status` — *upcoming / in-progress / complete*
- `Appointment Count` — *7 scheduled*
- `Clients Seen` — *7*
- `Collected` — *$3,180 — derived from closed ORDERS*
- `vs. Weekday Average` — *$2,940 — up $240*
- `Rebooked in Room` — *2*
- `Utilization` — *88% booked*
- `Cues Spoken` — *5*
- `Signals Processed` — *412*
- `Actions Taken Without Her` — *407*
- `Weather` — *rain from 3 PM*

### Relationships

- has 1 **OPERATOR** whose day it is
- has 1 **BUSINESS** it belongs to
- has 0-many **BRIEFING** that bracket it
- has 0-many **APPOINTMENT** scheduled
- has 0-many **OPENING** unfilled
- has 0-many **CUE** spoken during it
- has 0-many **ACTION** taken during it
- has 0-many **SIGNAL** processed
- has 0-many **PROPOSAL** surfaced
- has 0-many **REVIEW** arrived
- has 0-many **CAMPAIGN** sent
- has 0-many **PATTERN** it evidences
- has 0-many **ORDER** rung up
- has 0-many **PAYOUT** initiated

### Actions — OPERATOR

- Add a note
- Block time
- Close early
- Reopen

### Actions — DETAIL

- Compile the brief — `*` acts without asking
- Compile the debrief — `*` acts without asking
- Flag a conflict — `*` acts without asking

---

## BRIEFING

**Ambient** — no page of its own; appears nested on other objects

A spoken summary bracketing a day: morning (brief) or evening (debrief), set by Type. Composed rather than queued; has a duration and a play status that a DAY does not.

**Purpose.** The two moments she listens rather than looks.

**Also called.** brief, debrief, your morning

**Appears nested on (2).** PATTERN *(that announced it)*, DAY *(that bracket it)*

### Core content

- `Headline` — *“Morning, Jazz.” / “That’s the day.”*
- `Spoken Script` — *“Seven today. Your 11:00 is Maya, first-time tox…”*

### Metadata

- `Type` — *brief (morning) / debrief (evening)*
- `Delivered At` — *7:42 AM · 6:20 PM*
- `Duration` — *0:38 · 40 sec*
- `Item Count` — *4 · 6*
- `Channel` — *CarPlay*
- `Status` — *played / skipped / replayed*

### Relationships

- has 1 **DAY** it's about
- has 1 **DETAIL** delivered by
- has 1 **OPERATOR** it's for
- has 0-many **CLIENT** flagged
- has 0-many **OPENING** it covers
- has 0-many **PROPOSAL** carried
- has 0-many **ACTION** summarized
- has 0-many **REVIEW** new today
- has 0-many **PATTERN** announced

### Actions — OPERATOR

- Play
- Replay
- Skip
- Act on an item
- Move delivery time

### Actions — DETAIL

- Compose — `*` acts without asking
- Deliver — `*` acts without asking

---

## ACTION

**Ambient** — no page of its own; appears nested on other objects

Something DETAIL did on her behalf against a Boulevard primitive. Counterpart to CUE: a cue is what was said, an action is what was done.

**Purpose.** The reversible record of delegated work. Undo lives here.

**Also called.** handled, what I did

**Appears nested on (8).** DETAIL *(taken)*, THRESHOLD *(it authorized)*, SIGNAL *(triggered)*, CUE *(it reports)*, DAY *(taken during it)*, BRIEFING *(summarized)*, APPOINTMENT *(applied to it)*, MESSAGE *(that sent it)*

### Core content

- `Description` — *moved cleanup window 2:27 → 2:40*
- `Outcome` — *Sent. Delivered.*

### Metadata

- `Timestamp` — *1:42:13*
- `Target Primitive` — *calendar / messaging / payments / inventory / forms*
- `Reversible?` — *yes*
- `Authorized By` — *threshold / operator approval / △ inherited default*
- `Status` — *executed / failed / reverted*
- `Visible to Operator?` — *reported in cue / audit only*

### Relationships

- has 1 **DETAIL** that took it
- has 0-1 **SIGNAL** triggered by
- has 0-1 **THRESHOLD** authorized by
- has 0-1 **CUE** reported in
- has 0-1 **APPOINTMENT** acted on
- has 0-1 **MESSAGE** it sent
- has 1 **DAY** taken on

### Actions — OPERATOR

- Undo
- Approve
- Reject

### Actions — DETAIL

- Execute — `*` acts without asking
- Queue for approval — `~` must ask first
- Revert on failure — `*` acts without asking

---

## PROPOSAL

**Subject** — has its own detail page

Something DETAIL recommends but will not do alone, arriving with its math and its evidence source. Covers growth opportunities, threshold tuning, capability activation and marketing.

**Purpose.** How the business grows without DETAIL ever deciding. Always her call.

**Also called.** opportunity, worth your time

**Appears nested on (10).** DETAIL *(pending)*, PATTERN *(it generated)*, THRESHOLD *(created or tuned by)*, CUE *(it carries)*, DAY *(surfaced)*, BRIEFING *(carried)*, CAPABILITY *(△ surfaced by)*, OPENING *(surfaced in)*, CAMPAIGN *(that raised it)*, SEGMENT *(about it)*

### Core content

- `Finding` — *Tox clients are rebooking 18 days later than six months ago*
- `The Math` — *120 clients × 0.77 fewer visits × $450 ≈ $41,000*
- `Recommended Action` — *Build a re-engagement plan*
- `Spoken Framing` — *"Want me to build a re-engagement plan?"*

### Metadata

- `Type` — *growth-opportunity / threshold-tuning / △ capability-activation / △ marketing*
- `△ Evidence Source` — *observed-behavior / cohort-prior / domain-knowledge / declared*
- `Estimated Value` — *$41,000 / year*
- `Confidence` — *medium*
- `Status` — *pending / accepted / declined / expired*
- `Rollback Available?` — *yes — price test*
- `Surfaced At` — *8:05, Year 2*

### Relationships

- has 1 **DETAIL** that raised it
- has 0-1 **THRESHOLD** would create or tune
- has 0-1 **CAPABILITY** △ would activate
- has 0-1 **CUE** delivered in
- has 0-1 **OPENING** it would fill
- has 0-1 **SERVICE** it concerns
- has 0-many **CLIENT** affected
- has 0-1 **DAY** surfaced on
- has 0-1 **CAMPAIGN** it would send
- has 0-1 **SEGMENT** it targets
- has 0-1 **PATTERN** it cites
- has 0-many **WAITLIST REQUEST** it would fulfil

### Actions — OPERATOR

- Accept
- Decline
- Snooze
- Ask for the math
- Run as a test
- Roll back

### Actions — DETAIL

- Raise — `~` must ask first
- Withdraw — `*` acts without asking
- Re-raise with new evidence — `~` must ask first

---

## CAPABILITY

**Pull-only** — reachable on demand, never pushed

Something DETAIL cannot do yet because setup is missing. Named for what it unlocks, not for the task.

**Purpose.** The activation surface. Dominant content while the object graph is thin.

**Also called.** setup, integration, connection

**Appears nested on (5).** BUSINESS *(△ available to it)*, THRESHOLD *(△ enabled by)*, CUE *(△ it concerns)*, PROPOSAL *(△ would activate)*, CAPABILITY *(△ it depends on)*

### Core content

- `△ Name` — *Payouts*
- `△ What It Unlocks` — *"I can move money for you"*
- `△ Completion Surface` — *<link sent to her phone>*

### Metadata

- `△ Status` — *unavailable / available / proposed / declined / active*
- `△ Type` — *integration / data import / policy / first-time action*
- `△ Effort` — *2 min*
- `△ Estimated Value` — *unlocks same-day payouts*
- `△ Declined At` — *never ask unprompted again*

### Relationships

- has 1 **BUSINESS** △ it belongs to
- has 0-many **PROPOSAL** △ surfaced by
- has 0-many **THRESHOLD** △ it enables
- has 0-many **CAPABILITY** △ it depends on

### Actions — OPERATOR

- Activate
- Connect
- Disconnect
- Decline

### Actions — DETAIL

- Detect availability — `*` acts without asking
- Propose activation — `~` must ask first

---

## CLIENT

**Subject** — has its own detail page

A person who books. The commercial relationship — contact, preferences, cadence, marketing consent. Deliberately holds no clinical data; that lives on CHART.

**Purpose.** Who the business is for. The source of most signals.

**Also called.** customer, patient, guest

**Appears nested on (19).** OPERATOR *(serving)*, BUSINESS *(on file)*, PATTERN *(it concerns)*, SIGNAL *(it concerns)*, CUE *(it concerns)*, BRIEFING *(flagged)*, PROPOSAL *(affected)*, CHART *(it documents)*, APPOINTMENT *(booked by)*, SERVICE *(who've had it)*, PRODUCT CREDIT *(who bought it)*, ORDER *(who paid — 0 for a retail walk-in)*, PAYMENT *(who paid)*, OPENING *(offered to)*, OPENING *(filled by)*, WAITLIST REQUEST *(who asked)*, MESSAGE *(with)*, SEGMENT *(matching)*, REVIEW *(who wrote it)*

### Core content

- `Full Name` — *Maya Okafor*
- `Photo` — *<optional>*
- `Mobile` — *(615) 555-0188*
- `Notes` — *nervous about bruising*

### Metadata

- `Client Since` — *Year 1, Month 4*
- `Visit Count` — *6*
- `Lifetime Value` — *$2,700*
- `Rebooking Cadence` — *84 days*
- `No-show Count` — *1*
- `Preferred Channel` — *text*
- `Referred By` — *Dani*
- `Tags` — *first-time, tox*
- `Marketing Consent — SMS` — *granted Mar 2026 at booking*
- `Marketing Consent — Email` — *granted / denied / withdrawn*
- `Unsubscribed At` — *—*
- `Last Marketing Contact` — *9 days ago*

### Relationships

- has 1 **BUSINESS** client of
- has 0-many **APPOINTMENT** booked
- has 0-many **SERVICE** received
- has 0-many **MESSAGE** exchanged
- has 0-many **REVIEW** written
- has 0-many **SEGMENT** she belongs to
- has 0-many **CAMPAIGN** received
- has 0-many **PATTERN** about her
- has 0-many **CUE** about her
- has 0-many **SIGNAL** about her
- has 0-many **OPENING** offered to her
- has 0-many **WAITLIST REQUEST** she's made
- has 1 **CHART** hers
- has 0-many **PRODUCT CREDIT** prepaid units
- has 0-many **ORDER** paid
- has 0-many **PAYMENT** made

### Actions — OPERATOR

- Add
- Edit
- Add a note
- Merge duplicates
- Message
- Charge a fee
- Waive a fee
- Block

### Actions — DETAIL

- Create from a booking — `*` acts without asking
- Update from intake — `*` acts without asking
- Message in her voice — `*` acts without asking
- Merge duplicates — `~` must ask first
- Charge a fee — `x` **never, by design**
- Offer a discount — `x` **never, by design**

### Actions — CLIENT

- Edit own details
- Fill intake form

---

## CHART

**Subject** — has its own detail page

The clinical record for one client: history, allergies, medications, contraindications, photos. One per client, and a separate access and retention boundary from CLIENT because it holds PHI.

**Purpose.** What keeps treatment safe, and what the law requires. Reviewed before every treatment.

**Also called.** client profile, patient record

**Appears nested on (4).** CLIENT *(hers)*, CHART ENTRY *(it's filed in)*, FORM *(it's filed in)*, APPOINTMENT *(being documented)*

### Core content

- `Medical History` — *free text + structured history*
- `Allergies` — *“lidocaine sensitivity”*
- `Medications` — *“low-dose aspirin”*
- `Contraindication Notes` — *“no tox — pregnancy, cleared Mar 2027”*
- `Baseline Photos` — *<before set>*

### Metadata

- `Status` — *open / current / locked*
- `Last Reviewed` — *Sept 23, before the 11:00*
- `Last Updated` — *Sept 23, 11:52 PM*
- `Open Flags` — *1 — blood thinner*
- `Entry Count` — *14*
- `Retention Until` — *per state rule*
- `△ Contains PHI` — *yes — access and disclosure restricted*

### Relationships

- has 1 **CLIENT** it documents
- has 0-many **CHART ENTRY** filed in it
- has 0-many **FORM** filed in it
- has 0-many **APPOINTMENT** it covers

### Actions — OPERATOR

- Open
- Review before treatment
- Amend
- Export
- Share with a provider
- Lock

### Actions — DETAIL

- Surface it before a treatment — `*` acts without asking
- Flag a contraindication — `*` acts without asking
- Summarize for her eyes — `*` acts without asking
- Read clinical detail aloud — `x` **never, by design**
- Disclose to a third party — `x` **never, by design**

### Actions — CLIENT

- Request a copy

---

## CHART ENTRY

**Ambient** — no page of its own; appears nested on other objects

One piece of clinical documentation — what was done, observations, products and lots used — authored during or after a service and signed.

**Purpose.** The legal record of each treatment. Signing is hers alone.

**Also called.** note, treatment note, SOAP note

**Appears nested on (7).** OPERATOR *(authored)*, CHART *(filed in it)*, CHART ENTRY *(it amends)*, APPOINTMENT *(documenting it)*, SERVICE *(documenting it)*, PRODUCT *(recording lot & dose)*, PRODUCT USAGE *(documented in)*

### Core content

- `What Was Done` — *“20 units, glabella and crow’s feet”*
- `Observations` — *“mild erythema, no bruising at 10 min”*
- `Photos` — *<after set>*
- `Products & Lots` — *Botox, lot 4471C, exp 03/27*

### Metadata

- `Type` — *treatment note / consult note / photo / phone note / amendment*
- `Units / Dosage` — *20 units*
- `Sites Treated` — *glabella, lateral canthus*
- `Authored At` — *Sept 23, 11:48 AM*
- `Signed At` — *— unsigned*
- `Status` — *draft / signed / amended*
- `Authored By` — *her / △ DETAIL from dictation*
- `Amends` — *entry #11*

### Relationships

- has 1 **CHART** it's filed in
- has 1 **OPERATOR** who authored it
- has 0-1 **APPOINTMENT** it documents
- has 0-1 **SERVICE** performed
- has 0-1 **CHART ENTRY** it amends
- has 0-many **PRODUCT USAGE** it documents
- has 0-many **PRODUCT** recorded by lot

### Actions — OPERATOR

- Create
- Dictate
- Attach a photo
- Sign
- Amend
- Discard a draft

### Actions — DETAIL

- Transcribe from her dictation — `*` acts without asking
- Pre-fill from the service — `*` acts without asking
- Remind her to sign — `*` acts without asking
- Sign on her behalf — `x` **never, by design**

---

## FORM

**Subject** — has its own detail page

An intake, medical history, consent or post-care document sent to a client, completed and signed. Expires, and may raise flags.

**Purpose.** Gates whether a treatment can safely and lawfully happen.

**Also called.** intake, consent, paperwork

**Appears nested on (5).** SIGNAL *(it's about)*, CUE *(it concerns)*, CHART *(filed in it)*, APPOINTMENT *(required)*, SERVICE *(consents for it)*

### Core content

- `Form Name` — *Neurotoxin consent · Intake — medical history*
- `Responses` — *<the client's answers>*
- `Signature` — *<client signature, Sept 22 11:52 PM>*

### Metadata

- `Type` — *intake / medical history / consent / post-care acknowledgment*
- `Status` — *not sent / sent / overdue / complete / expired / waived*
- `Template & Version` — *Boulevard tox consent v3*
- `Sent At` — *Sept 20, at booking*
- `Completed At` — *Sept 22, 11:52 PM*
- `Expires` — *12 months from signature*
- `Flags Raised` — *1 — anticoagulant*
- `Required For` — *this appointment / this service / annually*
- `Source` — *client-completed / on paper / filled by her*

### Relationships

- has 1 **CHART** it's filed in
- has 0-1 **APPOINTMENT** required for
- has 0-1 **SERVICE** consent for
- has 0-many **SIGNAL** it generated
- has 0-many **CUE** it prompted

### Actions — OPERATOR

- Send
- Resend
- Mark complete on paper
- Fill on her behalf
- Waive
- Review the flags

### Actions — DETAIL

- Send at booking — `*` acts without asking
- Remind the client — `*` acts without asking
- Flag a contraindication — `*` acts without asking
- Mark complete — `*` acts without asking
- Waive a required form — `x` **never, by design**
- Answer for the client — `x` **never, by design**

### Actions — CLIENT

- Fill
- Sign
- Update
- Request a copy

---

## APPOINTMENT

**Subject** — has its own detail page

A booked slot: a client, an operator, one or more services, at a time. The spine of the day.

**Purpose.** The transaction everything else hangs off — charting, checkout, cues, revenue.

**Also called.** booking, visit, session

**Appears nested on (19).** OPERATOR *(performing)*, BUSINESS *(booked)*, SIGNAL *(it concerns)*, CUE *(it concerns)*, DAY *(scheduled)*, ACTION *(acted on)*, CLIENT *(booked)*, CHART *(it covers)*, CHART ENTRY *(it documents)*, FORM *(required for)*, SERVICE *(performed in)*, PRODUCT USAGE *(consumed during)*, ORDER *(it settles)*, ORDER LINE ITEM *(it bills)*, OPENING *(vacated by)*, WAITLIST REQUEST *(it became)*, MESSAGE *(it's about)*, CAMPAIGN *(booked from it)*, REVIEW *(it follows)*

### Core content

- `Confirmation Number` — *BLVD-4471*
- `Notes` — *second tox session, forehead only*

### Metadata

- `Start Time` — *1:30 PM*
- `Duration` — *45 min*
- `Status` — *booked / confirmed / checked-in / completed / cancelled / no-show*
- `Check-in Time` — *1:42 PM*
- `Lateness` — *12 min*
- `Price` — *$650*
- `Deposit Taken?` — *yes*
- `Room / Device` — *Suite 204 · laser 1*
- `△ Readiness` — *ready / forms outstanding / consent expired / blocked*

### Relationships

- has 1 **CLIENT** booked by
- has 1 **OPERATOR** performing
- has 1-many **SERVICE** being performed
- has 1 **BUSINESS** booked at
- has 0-many **SIGNAL** generated
- has 0-many **ACTION** applied to it
- has 1 **DAY** scheduled on
- has 0-1 **CAMPAIGN** booked from
- has 0-many **CUE** about it
- has 0-many **MESSAGE** about it
- has 0-1 **REVIEW** it produced
- has 0-1 **WAITLIST REQUEST** it came from
- has 0-many **FORM** required
- has 0-many **CHART ENTRY** documenting it
- has 1 **CHART** being documented
- has 0-many **PRODUCT USAGE** consumed during it
- has 0-1 **ORDER** that settles it
- has 0-many **ORDER LINE ITEM** billing it

### Actions — OPERATOR

- Book
- Reschedule
- Cancel
- Check in
- Complete
- Charge
- Add a note
- Rebook in the room

### Actions — DETAIL

- Confirm — `*` acts without asking
- Send a reminder — `*` acts without asking
- Check in — `*` acts without asking
- Reschedule inside threshold — `*` acts without asking
- Reschedule beyond threshold — `~` must ask first
- Cancel — `x` **never, by design**
- Charge — `x` **never, by design**

### Actions — CLIENT

- Book
- Reschedule
- Cancel
- Confirm
- Check in

---

## SERVICE

**Subject** — has its own detail page

Something the business sells and performs, with a duration, a price and a price model.

**Purpose.** The menu. Defines what can be booked and what it costs.

**Also called.** treatment, offering

**Appears nested on (15).** OPERATOR *(qualified for)*, BUSINESS *(offered)*, PATTERN *(it concerns)*, PROPOSAL *(it concerns)*, CLIENT *(received)*, CHART ENTRY *(performed)*, FORM *(consent for)*, APPOINTMENT *(being performed)*, PRODUCT USAGE RULE *(it configures)*, PRODUCT USAGE *(performed)*, ORDER LINE ITEM *(sold)*, OPENING *(suited to)*, WAITLIST REQUEST *(wanted)*, CAMPAIGN *(it promotes)*, SEGMENT *(defined by)*

### Core content

- `Service Name` — *Lip filler*
- `Description` — *<from Linktree>*
- `Photo` — *<optional>*

### Metadata

- `Duration` — *45 min*
- `Price` — *$650*
- `Price Model` — *flat / per-unit (from $13/unit)*
- `Category` — *injectable / laser / facial / peel*
- `Processing Time` — *tox: 10–14 days*
- `Requires Consent Form?` — *yes*
- `Discountable?` — *no — never discount tox*

### Relationships

- has 1 **BUSINESS** offered by
- has 0-many **APPOINTMENT** performed in
- has 0-many **OPERATOR** qualified to perform
- has 0-many **THRESHOLD** governed by
- has 0-many **CAMPAIGN** promoting it
- has 0-many **SEGMENT** defined by it
- has 0-many **PATTERN** about it
- has 0-many **CLIENT** who've had it
- has 0-many **WAITLIST REQUEST** requesting it
- has 0-many **CHART ENTRY** documenting it
- has 0-many **FORM** consents for it
- has 0-many **PRODUCT USAGE RULE** its usage config
- has 0-many **PRODUCT USAGE** consumed performing it
- has 0-many **ORDER LINE ITEM** sold as

### Actions — OPERATOR

- Add
- Edit
- Set price
- Set consent requirement
- Mark non-discountable
- Retire

### Actions — DETAIL

- Import at onboarding — `~` must ask first
- Propose a price test — `~` must ask first
- Change price — `x` **never, by design**

---

## PRODUCT

**Subject** — has its own detail page

A physical good — sellable as retail, usable during a service, or both. One object with two independent flags, per Boulevard's model.

**Purpose.** Consumables to track and retail to sell, in one place.

**Also called.** inventory, stock, retail item

**Appears nested on (8).** BUSINESS *(stocked)*, SIGNAL *(it's about)*, CHART ENTRY *(recorded by lot)*, PRODUCT USAGE RULE *(it consumes)*, PRODUCT USAGE *(consumed)*, PRODUCT CREDIT *(it's for)*, ORDER LINE ITEM *(sold)*, CAMPAIGN *(it promotes)*

### Core content

- `Product Name` — *Botox 100u vial · Vitamin C serum*
- `Description` — *<optional>*
- `Brand` — *Allergan · SkinCeuticals*
- `Photo` — *<retail shelf image>*

### Metadata

- `SKU / UPC` — *12-digit barcode*
- `Category` — *Retail / back bar — only “Retail” appears at checkout*
- `Sellable as Retail?` — *yes*
- `Usable in a Service?` — *yes — independent of retail*
- `Retail Price` — *$96*
- `Default Unit Cost` — *$4.10 · FIFO on depletion*
- `Taxable?` — *yes*
- `Supplier` — *<optional>*
- `Size / Color` — *100u · 30ml*
- `Quantity on Hand` — *2 vials*
- `Reorder Point` — *3*
- `Active at Location?` — *off by default on create*
- `△ Expiry` — *NOT tracked by Boulevard today — see handoff note*

### Relationships

- has 1 **BUSINESS** stocked by
- has 0-many **PRODUCT USAGE RULE** configured for services
- has 0-many **PRODUCT USAGE** consumed in appointments
- has 0-many **PRODUCT CREDIT** pre-sold as units
- has 0-many **CHART ENTRY** recording lot & dose
- has 0-many **SIGNAL** it generated
- has 0-many **CAMPAIGN** promoting it
- has 0-many **ORDER LINE ITEM** sold as

### Actions — OPERATOR

- Add
- Edit
- Set retail price
- Set unit cost
- Adjust quantity
- Receive stock
- Sell at checkout
- Deactivate

### Actions — DETAIL

- Track depletion — `*` acts without asking
- Flag low stock — `*` acts without asking
- Recommend at checkout — `~` must ask first
- Queue a reorder — `~` must ask first
- Change retail price — `x` **never, by design**
- Place a purchase order — `x` **never, by design**

### Actions — CLIENT

- Buy

---

## PRODUCT USAGE RULE

**Ambient** — no page of its own; appears nested on other objects

Junction on SERVICE x PRODUCT: which product a service consumes, at what price per unit, with what default quantity. Configuration, not event.

**Purpose.** Makes usage-based pricing possible. Its default quantity drives self-booking price, deposits and cancellation fees.

**Also called.** product usage config

**Appears nested on (2).** SERVICE *(its usage config)*, PRODUCT *(configured for services)*

### Core content

- `Rule Label` — *Lip filler → Juvederm Ultra*

### Metadata

- `Price Per Item` — *$13 per unit*
- `Default Quantity` — *2 syringes — drives the self-booking display price*
- `Active?` — *yes*

### Relationships

- has 1 **SERVICE** it configures
- has 1 **PRODUCT** it consumes

### Actions — OPERATOR

- Create
- Set price per item
- Set default quantity
- Deactivate
- Remove

### Actions — DETAIL

- Suggest a default from history — `~` must ask first
- Change price per item — `x` **never, by design**

---

## PRODUCT USAGE

**Ambient** — no page of its own; appears nested on other objects

Junction on APPOINTMENT x PRODUCT: units expected versus units actually used. Resolves at checkout and depletes stock.

**Purpose.** How injectables get priced and inventory stays honest.

**Also called.** units used

**Appears nested on (6).** CHART ENTRY *(it documents)*, APPOINTMENT *(consumed during it)*, SERVICE *(consumed performing it)*, PRODUCT *(consumed in appointments)*, PRODUCT CREDIT *(redeemed against it)*, ORDER LINE ITEM *(it bills)*

### Core content

- `Usage Record ID` — *BLVD-PU-8841*

### Metadata

- `Quantity Expected` — *20 units — set at booking, editable*
- `Quantity Used` — *24 units — actual*
- `Price Per Item Applied` — *$13*
- `Amount Charged` — *$312 — folded into the service price*
- `Prepaid Units Redeemed` — *12*
- `Recorded At` — *Sept 23, 11:48 AM*

### Relationships

- has 1 **APPOINTMENT** consumed during
- has 1 **PRODUCT** consumed
- has 0-1 **SERVICE** performed
- has 0-1 **CHART ENTRY** documented in
- has 0-1 **PRODUCT CREDIT** redeemed against
- has 0-1 **ORDER LINE ITEM** billed as

### Actions — OPERATOR

- Record units used
- Adjust units
- Dictate
- Redeem prepaid units
- Correct after checkout

### Actions — DETAIL

- Pre-fill from the default — `*` acts without asking
- Transcribe from her dictation — `*` acts without asking
- Deplete stock — `*` acts without asking
- Flag a variance — `*` acts without asking
- Charge for units — `x` **never, by design**
- Disclose unit counts to the client — `x` **never, by design**

---

## PRODUCT CREDIT

**Ambient** — no page of its own; appears nested on other objects

Units a client pre-bought in bulk, held as a balance and redeemed at checkout.

**Purpose.** Money already collected. A liability, and a reason to remind her at checkout.

**Also called.** prepaid units, credits, wallet

**Appears nested on (4).** CLIENT *(prepaid units)*, PRODUCT *(pre-sold as units)*, PRODUCT USAGE *(redeemed against)*, ORDER LINE ITEM *(bought as)*

### Core content

- `Credit Label` — *20 prepaid tox units*

### Metadata

- `Units Purchased` — *20*
- `Units Remaining` — *8*
- `Purchased At` — *Jun 14, at checkout*
- `Discount Applied` — *10% bulk rate*
- `Amount Paid` — *$234*
- `Status` — *active / depleted / refunded*

### Relationships

- has 1 **CLIENT** who bought it
- has 1 **PRODUCT** it's for
- has 0-many **PRODUCT USAGE** redeemed against it
- has 0-1 **ORDER LINE ITEM** bought as

### Actions — OPERATOR

- Sell prepaid units
- Apply a bulk discount
- Redeem
- Refund
- Adjust the balance

### Actions — DETAIL

- Surface the balance before checkout — `*` acts without asking
- Remind her at checkout — `*` acts without asking
- Redeem without asking — `x` **never, by design**
- Sell prepaid units — `x` **never, by design**

### Actions — CLIENT

- Buy prepaid units
- Request a refund

---

## ORDER

**Subject** — has its own detail page

The transaction settling an appointment or a retail sale. Opens at check-in, closes on payment.

**Purpose.** Where revenue becomes real. The source of DAY.Collected.

**Also called.** checkout, ticket, the bill

**Appears nested on (7).** OPERATOR *(closed)*, BUSINESS *(rung up)*, DAY *(rung up)*, CLIENT *(paid)*, APPOINTMENT *(that settles it)*, ORDER LINE ITEM *(it's on)*, PAYMENT *(it settles)*

### Core content

- `Order Number` — *BLVD-O-9912*

### Metadata

- `Status` — *open / closed / voided / refunded / partially refunded*
- `Subtotal` — *$650*
- `Discounts` — *—*
- `Tax` — *$0 — services untaxed in TN*
- `Gratuity` — *$0*
- `Total` — *$650*
- `Opened At` — *Sept 23, 1:42 PM · at check-in*
- `Closed At` — *Sept 23, 2:31 PM*
- `Line Count` — *2*

### Relationships

- has 1 **BUSINESS** rung up at
- has 0-1 **CLIENT** who paid — 0 for a retail walk-in
- has 0-1 **APPOINTMENT** it settles
- has 0-1 **OPERATOR** who closed it
- has 1-many **ORDER LINE ITEM** on it
- has 0-many **PAYMENT** tendered against it
- has 0-1 **DAY** rung up on

### Actions — OPERATOR

- Open
- Add a line item
- Apply a discount
- Take payment
- Close
- Void
- Refund
- Reopen
- Email a receipt

### Actions — DETAIL

- Open it at check-in — `*` acts without asking
- Pre-fill from the appointment — `*` acts without asking
- Flag an unclosed order — `*` acts without asking
- Take a payment — `x` **never, by design**
- Apply a discount — `x` **never, by design**
- Close it — `x` **never, by design**
- Void or refund — `x` **never, by design**

### Actions — CLIENT

- Pay
- Tip
- Request a receipt

---

## ORDER LINE ITEM

**Ambient** — no page of its own; appears nested on other objects

One line on an order, of exactly one kind — service, retail product, prepaid units or fee — at its price at the time of sale.

**Purpose.** Makes an order itemisable, refundable and commissionable.

**Also called.** line, ticket item

**Appears nested on (6).** APPOINTMENT *(billing it)*, SERVICE *(sold as)*, PRODUCT *(sold as)*, PRODUCT USAGE *(billed as)*, PRODUCT CREDIT *(bought as)*, ORDER *(on it)*

### Core content

- `Line Label` — *Lip filler · 2 syringes*

### Metadata

- `Kind` — *service / retail product / prepaid units / fee — discriminated union*
- `Quantity` — *2*
- `Unit Price at Sale` — *$325 — snapshot, not a live lookup*
- `Line Discount` — *—*
- `Line Total` — *$650*
- `Commission Basis` — *total after product usage is folded in*

### Relationships

- has 1 **ORDER** it's on
- has 0-1 **SERVICE** sold
- has 0-1 **PRODUCT** sold
- has 0-1 **PRODUCT USAGE** it bills
- has 0-1 **PRODUCT CREDIT** bought as
- has 0-1 **APPOINTMENT** it bills

### Actions — OPERATOR

- Add
- Edit quantity
- Adjust price
- Discount
- Remove

### Actions — DETAIL

- Add from product usage — `*` acts without asking
- Adjust price — `x` **never, by design**
- Discount — `x` **never, by design**

---

## PAYMENT

**Ambient** — no page of its own; appears nested on other objects

One tender against an order. An order may take several — card plus prepaid credit plus cash.

**Purpose.** Whether she actually got paid. A decline is the one payment event worth interrupting for.

**Also called.** tender, transaction

**Appears nested on (5).** SIGNAL *(it's about)*, CUE *(it concerns)*, CLIENT *(made)*, ORDER *(tendered against it)*, PAYOUT *(settled in it)*

### Core content

- `Payment Reference` — *ch_3Q7f…*

### Metadata

- `Method` — *card / cash / prepaid credit / gift card*
- `Amount` — *$650*
- `Card Last Four` — *6411*
- `Status` — *pending / succeeded / declined / refunded*
- `Processed At` — *Sept 23, 2:31 PM*
- `Decline Reason` — *—*

### Relationships

- has 1 **ORDER** it settles
- has 0-1 **CLIENT** who paid
- has 0-1 **PAYOUT** settled in
- has 0-many **SIGNAL** it generated
- has 0-many **CUE** it prompted

### Actions — OPERATOR

- Take
- Split the tender
- Retry
- Refund
- Void

### Actions — DETAIL

- Flag a decline — `*` acts without asking
- Take a payment — `x` **never, by design**
- Retry a payment — `x` **never, by design**
- Refund — `x` **never, by design**

### Actions — CLIENT

- Pay
- Retry
- Dispute

---

## PAYOUT

**Ambient** — no page of its own; appears nested on other objects

Money moving from Boulevard to her bank account.

**Purpose.** Her actual income, and what 'connect payouts' unlocks.

**Also called.** deposit, settlement

**Appears nested on (3).** BUSINESS *(received)*, DAY *(initiated)*, PAYMENT *(settled in)*

### Core content

- `Payout Reference` — *po_1M4k…*

### Metadata

- `Amount` — *$2,420*
- `Initiated At` — *Sept 23, 2:10 PM*
- `Expected Arrival` — *Thursday*
- `Destination` — *bank •••• 2208*
- `Status` — *initiated / in transit / paid / failed*
- `Payment Count` — *7*

### Relationships

- has 1 **BUSINESS** paid out to
- has 0-many **PAYMENT** settled in it
- has 0-1 **DAY** initiated on

### Actions — OPERATOR

- Connect a bank account
- Change the destination
- Change the schedule

### Actions — DETAIL

- Report the timing — `*` acts without asking
- Flag a failure — `*` acts without asking
- Change the destination — `x` **never, by design**
- Initiate — `x` **never, by design**

---

## OPENING

**Subject** — has its own detail page

Bookable empty time with a value attached. Not a cancelled appointment — negative space that can be sold.

**Purpose.** Revenue at risk. The thing DETAIL fills.

**Also called.** gap, availability, open slot

**Appears nested on (7).** BUSINESS *(unfilled)*, DAY *(unfilled)*, BRIEFING *(it covers)*, PROPOSAL *(it would fill)*, CLIENT *(offered to her)*, WAITLIST REQUEST *(offered to her)*, CAMPAIGN *(it's filling)*

### Core content

- `Slot Label` — *Tomorrow 2:30, 90 minutes*

### Metadata

- `Start Time` — *2:30 PM*
- `Date` — *Wed 24*
- `Duration` — *90 min*
- `Estimated Value` — *$650*
- `Origin` — *cancellation / never-booked / schedule gap*
- `Status` — *open / offered / filled / expired*
- `Offer Order` — *waitlist → Instagram*

### Relationships

- has 1 **BUSINESS** belongs to
- has 0-1 **APPOINTMENT** vacated by
- has 0-1 **SERVICE** suited to
- has 0-many **CLIENT** offered to
- has 0-1 **CLIENT** filled by
- has 0-1 **PROPOSAL** surfaced in
- has 1 **DAY** it sits in
- has 0-1 **CAMPAIGN** promoting it
- has 0-many **WAITLIST REQUEST** matched to it

### Actions — OPERATOR

- Offer to waitlist
- Post publicly
- Fill manually
- Block

### Actions — DETAIL

- Detect — `*` acts without asking
- Hold — `*` acts without asking
- Offer to waitlist — `~` must ask first
- Post publicly — `~` must ask first

### Actions — CLIENT

- Claim
- Join waitlist

---

## WAITLIST REQUEST

**Subject** — has its own detail page

Demand that exists before supply: a client who wants a window that isn't available yet.

**Purpose.** Turns an opening into a booking in minutes instead of a blast to everyone.

**Also called.** waitlist, request

**Appears nested on (6).** BUSINESS *(outstanding)*, PROPOSAL *(it would fulfil)*, CLIENT *(she's made)*, APPOINTMENT *(it came from)*, SERVICE *(requesting it)*, OPENING *(matched to it)*

### Core content

- `Request ID` — *BLVD-WL-0312*
- `Request Note` — *“wants anything Thursday afternoon”*

### Metadata

- `Desired Window` — *Thursday afternoons*
- `Flexibility` — *specific date / any Thursday / any time*
- `Created` — *Mon 12:40 PM*
- `Expires` — *end of month*
- `Status` — *waiting / offered / booked / expired / withdrawn*
- `Queue Order` — *2 of 3*
- `Times Offered` — *1*
- `Times Declined` — *0*

### Relationships

- has 1 **CLIENT** who asked
- has 1 **BUSINESS** asked of
- has 0-1 **SERVICE** wanted
- has 0-many **OPENING** offered to her
- has 0-1 **APPOINTMENT** it became

### Actions — OPERATOR

- Add for a client
- Edit
- Offer a slot
- Fulfil manually
- Re-rank
- Expire
- Remove

### Actions — DETAIL

- Create from a DM or call — `*` acts without asking
- Match to an opening — `*` acts without asking
- Re-rank the queue — `*` acts without asking
- Expire a stale one — `*` acts without asking
- Offer — `~` must ask first

### Actions — CLIENT

- Request
- Update
- Withdraw
- Accept an offer
- Decline an offer

---

## MESSAGE

**Ambient** — no page of its own; appears nested on other objects

One communication with one client, inbound or outbound, across SMS, DM or email. May have been generated by a CAMPAIGN.

**Purpose.** The conversation. Showing campaign sends inline is how over-messaging becomes visible.

**Also called.** text, DM, email

**Appears nested on (6).** BUSINESS *(exchanged)*, ACTION *(it sent)*, CLIENT *(exchanged)*, APPOINTMENT *(about it)*, CAMPAIGN *(sent from it)*, REVIEW *(the reply)*

### Core content

- `Body` — *"Running about 10 behind, see you at 2:40?"*

### Metadata

- `Timestamp` — *1:42:15*
- `Direction` — *inbound / outbound*
- `Channel` — *SMS / Instagram DM / email*
- `Status` — *draft / sent / delivered / replied*
- `Authored By` — *operator / DETAIL in her voice / template*
- `Tone Read` — *fine*

### Relationships

- has 0-1 **CLIENT** with
- has 1 **BUSINESS** sent from
- has 0-1 **APPOINTMENT** it's about
- has 0-1 **ACTION** that sent it
- has 0-1 **SIGNAL** it generated
- has 0-1 **CAMPAIGN** sent from

### Actions — OPERATOR

- Send
- Draft
- Edit a draft
- Approve
- Reply
- Delete

### Actions — DETAIL

- Draft in her voice — `*` acts without asking
- Send inside threshold — `*` acts without asking
- Auto-reply an FAQ — `*` acts without asking
- Send outside threshold — `~` must ask first

### Actions — CLIENT

- Send
- Reply

---

## CAMPAIGN

**Subject** — has its own detail page

One send to an audience, with copy, a schedule and measured performance. Produces MESSAGEs.

**Purpose.** Marketing. The fallback when targeting a few named clients won't fill a gap.

**Also called.** blast, promo, email send

**Appears nested on (11).** BUSINESS *(sent)*, DETAIL *(drafted)*, DAY *(sent)*, PROPOSAL *(it would send)*, CLIENT *(received)*, APPOINTMENT *(booked from)*, SERVICE *(promoting it)*, PRODUCT *(promoting it)*, OPENING *(promoting it)*, MESSAGE *(sent from)*, SEGMENT *(sent to it)*

### Core content

- `Campaign Name` — *March filler promo*
- `Subject Line` — *Your lips, before spring*
- `Body / Copy` — *<written in her voice>*
- `Offer` — *optional — $50 off, expires Friday*

### Metadata

- `Type` — *fill-a-gap / re-engagement / lapsed-winback / promotion / seasonal*
- `Channel` — *SMS / email*
- `Status` — *draft / proposed / scheduled / sending / sent / cancelled*
- `Scheduled For` — *Thu 9:00 AM*
- `Audience Size` — *120 matching*
- `Reachable Size` — *94 with SMS consent*
- `Opens` — *61%*
- `Clicks` — *18%*
- `Bookings Attributed` — *7*
- `Revenue Attributed` — *$3,150*
- `Unsubscribes` — *2*
- `Authored By` — *her / DETAIL in her voice*

### Relationships

- has 1 **BUSINESS** sent from
- has 1 **SEGMENT** its audience
- has 0-many **MESSAGE** sent from it
- has 0-1 **PROPOSAL** that raised it
- has 0-1 **OPENING** it's filling
- has 0-1 **SERVICE** it promotes
- has 0-many **APPOINTMENT** booked from it
- has 0-1 **DAY** sent on
- has 0-1 **PRODUCT** it promotes

### Actions — OPERATOR

- Create
- Edit the copy
- Approve
- Schedule
- Send now
- Pause
- Cancel
- Duplicate

### Actions — DETAIL

- Draft in her voice — `*` acts without asking
- Measure — `*` acts without asking
- Stop on an unsubscribe spike — `*` acts without asking
- Propose — `~` must ask first
- Send to a matched shortlist — `*` acts without asking
- Send to a segment — `~` must ask first
- Send without consent — `x` **never, by design**
- Discount to fill a gap — `x` **never, by design**

### Actions — CLIENT

- Book from it
- Reply
- Unsubscribe

---

## SEGMENT

**Subject** — has its own detail page

A named, reusable audience defined entirely by CLIENT metadata. Its reachable size is always the consented subset, never the match count.

**Purpose.** Who a campaign goes to, and the ceiling on targeting precision.

**Also called.** audience, list, cohort

**Appears nested on (6).** BUSINESS *(defined)*, PATTERN *(it concerns)*, PROPOSAL *(it targets)*, CLIENT *(she belongs to)*, SERVICE *(defined by it)*, CAMPAIGN *(its audience)*

### Core content

- `Segment Name` — *Tox clients overdue*
- `Definition` — *had tox, no visit in 100+ days — in her words*

### Metadata

- `Size` — *120 matching*
- `Reachable — SMS` — *94*
- `Reachable — Email` — *112*
- `Last Sent` — *9 days ago*
- `Send Frequency` — *3 sends / 90 days*
- `△ Fatigue` — *fresh / warm / over-messaged*
- `Created By` — *her / DETAIL*
- `Auto-updating?` — *yes — membership recalculates*

### Relationships

- has 1 **BUSINESS** belongs to
- has 0-many **CLIENT** matching
- has 0-many **CAMPAIGN** sent to it
- has 0-1 **SERVICE** defined by
- has 0-many **PROPOSAL** about it
- has 0-many **PATTERN** about it

### Actions — OPERATOR

- Create
- Name
- Edit criteria
- Exclude a client
- Delete

### Actions — DETAIL

- Refresh membership — `*` acts without asking
- Exclude the unreachable — `*` acts without asking
- Flag fatigue — `*` acts without asking
- Propose a segment — `~` must ask first

### Actions — CLIENT

- Opt out of marketing
- Update contact preferences

---

## REVIEW

**Subject** — has its own detail page

Public feedback about the business, operator or an appointment, with a drafted reply awaiting her nod.

**Purpose.** Reputation, and evidence for pricing proposals.

**Also called.** rating, feedback

**Appears nested on (5).** BUSINESS *(received)*, DAY *(arrived)*, BRIEFING *(new today)*, CLIENT *(written)*, APPOINTMENT *(it produced)*

### Core content

- `Review Body` — *"She didn't rush me."*
- `Reviewer Name` — *M. Rivera — may be unmatched to a CLIENT*
- `Reply Text` — *<drafted, awaiting her nod>*

### Metadata

- `Star Rating` — *5*
- `Date` — *11:30 AM, Tue 23*
- `Source` — *Google / Instagram*
- `Reply Status` — *drafted / sent / none*
- `Tagged Themes` — *strength: didn't rush me*

### Relationships

- has 0-1 **CLIENT** who wrote it
- has 1 **BUSINESS** it's about
- has 0-1 **OPERATOR** it's about
- has 0-1 **APPOINTMENT** it follows
- has 0-1 **MESSAGE** the reply
- has 1 **DAY** arrived on

### Actions — OPERATOR

- Reply
- Approve a drafted reply
- Flag
- Share

### Actions — DETAIL

- Draft a reply — `*` acts without asking
- Tag themes — `*` acts without asking
- Flag — `*` acts without asking
- Send a reply — `~` must ask first

### Actions — CLIENT

- Write
- Edit own
