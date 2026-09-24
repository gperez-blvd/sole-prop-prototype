# DETAIL / CUE proof-of-concept

A typed, relational, in-memory data layer plus a runnable simulation for
DETAIL — Boulevard's voice-first operator assistant. No database, no UI
framework, no auth. Built from the OOUX artifacts in [`data/`](data/)
(`object-map.json` — 26 objects, source of truth for the schema;
`cta-matrix.json` — 265 CTAs across 3 roles, source of truth for
permissions; `object-map.html` / `cta-matrix.html` / `object-map.mmd` —
human-readable renderings, reference only; `build_cta_matrix.py` —
re-renders the CTA matrix from its JSON) per the original handoff prompt
in [`data/HANDOFF.md`](data/HANDOFF.md).

## Run it

```bash
npm install
npm run sim        # seeds one day, runs the ladder, prints the hand-back report
npm test           # the 15 hard-rule tests (one per `x`-marked DETAIL CTA)
npm run typecheck  # tsc --noEmit, strict
```

`npm run sim` seeds Tuesday, September 23 — Jazz Bennett at Jazz
Aesthetics, seven appointments, 212 clients on file — generates ~400
SIGNAL rows, runs every one through the five-step ladder, and prints:
signal count in, CUE DECISION and CUE counts out, the disposition
breakdown, the three required hand-back lists (△ unratified items,
stubbed dependency rules, things invented to make it run), and the 15
hard rules.

## Layout

```
src/
  ids.ts                 branded id types, one per table
  schema/                one file per object (26) + join tables — the "typed table per object"
  store/
    Table.ts              generic in-memory table (insert/get/update/find/delete)
    relationships.ts       relationship registry, derived FROM data/object-map.json directly
    hardRules.ts            the 15 `x`-marked DETAIL CTAs, made structurally unreachable
    RelationalStore.ts       composes all 26 tables + joins; FK integrity; guarded mutators; derived rollups
  ladder/
    thresholds.ts           THRESHOLD row data + the matcher that decides which signals they govern
    ladder.ts                the five-step ladder itself
  seed/
    seed.ts                  the day's fixtures (business, operator, clients, appointments, ...)
    signals.ts                the ~400 SIGNAL rows: 5 curated escalation clusters + filler
    rng.ts                    deterministic PRNG so a run is reproducible
  report.ts                formats the hand-back report
  run.ts                   entry point
tests/
  hardRules.test.ts         one test per hard rule
```

## Design choices worth knowing before reading the code

**Relationships are FKs, not nested objects.** Every `nested_objects`
entry in the map became either an owning foreign key (the "many" or
"1" side points at the "1" side), a join table (genuine many:many, or a
relationship declared on only one side with no natural owner), or —
for a handful of cases the map itself calls "derived" — a computed
traversal. Each schema file's trailing comments say which, and cite the
exact map entry.

**Cardinality is enforced where TypeScript can, and at the store's write
path everywhere else.** `has 1` is a required field; `has 0-1` is
optional; `has 1-many` is checked non-empty on write (e.g. an
APPOINTMENT needs at least one SERVICE, a CUE DECISION needs at least
one SIGNAL).

**Derived rollups are computed, never stored.** DAY, CHART, SEGMENT,
CAMPAIGN and APPOINTMENT all have metadata the map itself describes as
rollups of nested rows. `RelationalStore.dayStats()` /
`chartStats()` / `segmentReach()` / `campaignReach()` /
`appointmentReadiness()` compute these on read; there is no column that
can drift out of sync with what it's summarizing.

**Cascade behavior is stubbed, not guessed.** The map never says what
happens to nested rows when a host is archived or deleted, for any of
the ~200 declared relationships. `Table#delete()` refuses to guess: it
throws unless the caller explicitly passes `onDependents: 'cascade' |
'restrict'`, so any future cascade choice is visible at the call site,
not buried in the schema. `relationships.ts` derives the full list
directly from `object-map.json` rather than a hand-maintained copy.

**The hard rules are enforced inside the only mutators that could reach
them**, not bolted on beside them — see `hardRules.ts` and
`RelationalStore.ts`'s guarded mutators. Two of the fifteen (clinical
suppression, clinical detail read aloud) are checked unconditionally,
regardless of actor, because the map says clinical cues are not
threshold-governed like everything else.

**The ladder's cue count is controlled by construction, not luck.**
Five narratively-scripted escalation clusters (tagged in their payload)
and the structural clinical-flag path are the only ways a SIGNAL can
produce a CUE. Every other signal — however "material" — resolves to
`handled_silently`, `suppressed`, or `deferred`. This is what keeps
"~400 in, ~5 out" true on every run rather than approximately true on
this one.

## The three required lists

Rather than a hand-maintained markdown list that can drift from the
code, the △ unratified attributes/relationships and the stubbed
dependency rules are **derived directly from `data/object-map.json`** at
run time (`src/store/relationships.ts`) and printed by `npm run sim`.
The one list that can't be derived from the JSON — things invented with
no counterpart in the map at all (join tables, infrastructure FKs, the
`id` fields themselves) — is hand-maintained in
`src/report.ts`'s `INVENTED_TO_MAKE_IT_RUN`, with each item cross-referenced
to the schema file comment that introduces it.

## Known deviations from a literal reading of the map

- **PATTERN's own "has 0-1 SERVICE/SEGMENT/CLIENT it concerns"** and
  several other 0-1 relations are stored as a single FK even though the
  underlying real-world relationship might eventually need to be
  many — kept literal to the declared cardinality, not the imagined
  future one, per the handoff's "don't invent" instruction.
- **SEGMENT membership is a static snapshot** (`segment_members`), not a
  live criteria evaluation — the map describes segments as
  "auto-updating," which would need a rules engine this POC doesn't
  build. Flagged in the invented-items list.
- **CLIENT's "has 0-many SERVICE (received)" and SERVICE's "has 0-many
  CLIENT (who've had it)"** are computed by joining through
  `appointment_services`, not stored directly — there's no world where
  they could disagree with the appointment history, so storing them
  separately would only add a way to drift.
