# Handoff prompt — DETAIL / CUE proof-of-concept

Paste the block below into Claude Code, in a directory containing:

- `object-map.json` — 26 objects, source of truth for the schema
- `cta-matrix.json` — 265 CTAs across 3 roles, source of truth for permissions
- `object-map.html` / `cta-matrix.html` — human-readable renderings, reference only
- `build_cta_matrix.py` — re-renders the CTA matrix from its JSON

---

## The prompt

We're building a proof-of-concept for a voice-first operator assistant called DETAIL, for
Boulevard (salon/medspa software). The domain model is already done as OOUX artifacts. Your
job is to turn it into a typed, relational, in-memory data layer plus a runnable simulation —
no database, no UI framework, no auth.

**Read `object-map.json` and `cta-matrix.json`. Do not parse the HTML files** — they're
renderings of the same data for humans. Read them only if you want to see the visual.

### What the model is

`object-map.json` has 26 objects. Each has:

- `core_content` — attributes unique to an instance (free text, media, identifiers)
- `metadata` — attributes used to sort/filter/group
- `nested_objects` — relationships, each with a cardinality (`has 1`, `has 0-1`, `has 1-many`,
  `has 0-many`), a target object, and a `nature` describing the relationship

`cta-matrix.json` has the actions each of three roles may take on each object:
**OPERATOR** (Jazz, a solo provider), **DETAIL** (the system/AI role), **CLIENT** (her customer).
CTAs in the DETAIL row carry an `authority` field: `*` act without asking, `~` must ask first,
`x` never.

### Build

1. **A typed table per object.** TypeScript, strict mode. Every `nested_objects` entry becomes
   a foreign key or a join, with the stated cardinality enforced at the type level where
   possible and at runtime where not. Snake-case table names; keep the object names recognizable.
2. **An in-memory store** that behaves relationally — insert, update, lookup by id, and
   traversal along the declared relationships in both directions. Referential integrity
   enforced on write.
3. **Seed data for one coherent day.** Tuesday, September 23: Jazz Bennett at Jazz Aesthetics
   in Nashville, seven appointments, 212 clients on file. Include Maya (11:00, first-time
   neurotoxin, intake complete, no contraindications) and Priya (took a 2:30 opening the next
   day). Generate roughly 400 SIGNAL rows across the day from plausible sources.
4. **The ladder, as a runnable pass.** This is what the POC exists to prove, and it matters more
   than the schema. Each SIGNAL walks five steps: what happened → does it matter → can
   Boulevard handle it → does the operator need to know → what should she do next. THRESHOLD
   rows govern each step. The output is a CUE DECISION per signal, and only a few of those
   produce a CUE. **Target: ~400 signals in, about 5 cues spoken.** Silence is the dominant,
   correct outcome — if your run produces dozens of cues, the thresholds aren't being applied.

### Things the map deliberately does not decide — flag, don't invent

- **`△` marks a proposal, not a decision.** 25 attributes and nesties are marked this way,
  including the entire CAPABILITY object. Implement them, but list them in your output as
  unratified so they can be pulled.
- **Dependency rules are undecided.** What happens to nested rows when a host is archived or
  deleted has not been specified for any relationship. Stub cascade behavior explicitly
  (`onDelete: 'UNSPECIFIED'` or equivalent) and list every place you had to guess. Do not
  silently pick cascade or restrict.
- **Some `has 0-many` are narrower in reality.** `DAY has 0-many BRIEFINGS` is really 0–2 (one
  morning brief, one evening debrief, distinguished by `BRIEFING.Type`). Where a bound is
  obviously tighter than the declared cardinality, add a runtime check and flag it.
- **Derived vs. stored.** DAY, SEGMENT and CHART are Container Objects whose metadata is almost
  entirely rollups of their nested rows (DAY's Collected, Cues Spoken, Signals Processed;
  SEGMENT's Size and Reachable counts; CHART's Open Flags and Entry Count). `APPOINTMENT.△
  Readiness` is derived from its FORM rows. Compute these; don't store them as independent
  columns that can drift.
- **CUE DECISION is a junction**, not a detail table: many SIGNALs resolve into one CUE, and it
  carries its own attributes (the reasoning, the timing call, what was suppressed alongside).
  Don't flatten it into either side.
- **DETAIL and CHART are 1:1 with their parent** (one DETAIL per OPERATOR, one CHART per CLIENT).
  Model them as separate tables anyway — CHART especially, because it's a different access and
  retention boundary from CLIENT.

### Hard rules — must be unimplementable, not merely unimplemented

Fifteen CTAs are marked `x` in DETAIL's row. These aren't unbuilt features; they're standing
commitments. Enforce them so no code path can reach them, and write a test per rule that
asserts the attempt fails:

- Never moves money: cannot charge an APPOINTMENT, charge a CLIENT fee, or offer a discount
- Never changes price: cannot write `SERVICE.Price`; cannot discount a CAMPAIGN to fill a gap
- Never messages without consent: cannot send a CAMPAIGN to a CLIENT lacking marketing consent
  for that channel. `SEGMENT.Reachable` is always the consented subset, never the match count
- Never acts on its own authority: cannot change its own voice or expand its own autonomy
- Never cancels an APPOINTMENT
- Clinical, and the most important of these:
  - **cannot suppress a clinical flag.** A CUE with `△ Clinical Override` bypasses every
    speaking-window and quiet-hours threshold and cannot be deferred, expired, or tuned down.
    Every other cue type is threshold-governed; this one is not.
  - **cannot read clinical detail aloud.** A clinical cue must be non-disclosing —
    "check Maya's intake before you start", never "Maya's on a blood thinner". Model spoken
    text and on-screen detail as separate fields so this is structural.
  - cannot disclose a CHART to a third party, sign a CHART ENTRY on her behalf, waive a
    required FORM, or answer a FORM for the client

### Do not

- Add, rename, merge or split objects. If the model seems wrong, say so in your output and
  leave it alone.
- Add attributes beyond what's in the JSON. If the schema needs a field to function (a
  timestamp, an id), add it and list it separately as infrastructure.
- Build UI. If you build a debug view, do not render CUE, PROPOSAL, PATTERN and CAPABILITY with
  the same card component — they're structurally different and look confusingly alike.
  Same for SIGNAL, ACTION and CUE DECISION in any log view.

### Hand back

- The schema, the store, the seed data, and the ladder simulation
- A run showing signal count in, cue count out, and the dispositions in between
- Tests for the fifteen hard rules
- Three lists: `△` unratified items, dependency rules you had to stub, and anything you had to
  invent to make it run

---

## Known open items (not oversights — decided against, or pending)

- **ACTION and SIGNAL are "broken objects"** in the OOUX sense — few operator-facing actions
  relative to how widely they appear. ACTION's undo has no natural home; SIGNAL's CTAs sit at a
  granularity a human can't navigate. Placement problem, not a missing verb.
- **PERSONA** has only two operator CTAs and is a candidate to become metadata on DETAIL.
- **FORM TEMPLATE** is probably a real object (Boulevard ships pre-built consent forms, and a
  signed form must record which version was agreed to). Currently metadata on FORM.
- **OPENING is missing CTAs:** Split (a 90-minute gap could take two 45s), Extend, Discount to
  fill. Split has real revenue in it.
- **Shapeshifter matrices** not yet built for CLIENT, APPOINTMENT, PROPOSAL, PATTERN, THRESHOLD,
  or for `OPENING nests CLIENT` twice (offered-to vs. filled-by).
- **`CLIENT has 1 CHART`** assumes a chart exists from client creation. The alternative is
  `has 0-1`, created at first clinical contact. Unresolved.
- **REVIEW reaches SERVICE only by proxy** through APPOINTMENT, so reviews with no appointment
  (unmatched Google reviews) can't be attributed to a service.
- **Multi-operator is out of scope.** The model assumes a solo provider. A multi-chair business
  raises unanswered questions: whose thresholds govern a shared APPOINTMENT, and can two
  DETAILs hold contradictory PATTERNs about the same BUSINESS.
- **Compliance framing is unverified.** PHI/HIPAA and TCPA/CAN-SPAM references are flags for
  counsel, not legal advice. `CHART.Retention Until: per state rule` is a placeholder.
