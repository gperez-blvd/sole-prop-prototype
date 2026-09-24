import type { LadderRunResult } from "./ladder/ladder.js";
import type { RelationalStore } from "./store/RelationalStore.js";
import { HARD_RULES } from "./store/hardRules.js";
import {
  RELATIONSHIP_DESCRIPTORS,
  TIGHTENED_CARDINALITIES,
  UNRATIFIED_ATTRIBUTES,
  UNRATIFIED_RELATIONSHIPS,
} from "./store/relationships.js";
import type { DayId } from "./ids.js";

/** Things invented to make the POC run that have no counterpart in the map. */
export const INVENTED_TO_MAKE_IT_RUN: string[] = [
  "id fields on every table (the map describes attributes, not storage keys).",
  "Signal.sequence — a deterministic ordering tie-breaker within a day (the map's Timestamp is descriptive text, not guaranteed-sortable/unique).",
  "Cue.onScreenDetail — the map's CUE core_content only has Spoken Text and Operator Response; the clinical non-disclosure rule needs a second field to structurally separate what's spoken from what's shown.",
  "Campaign.draftedByDetailId and Detail's reverse traversal to it — DETAIL has 0-many CAMPAIGN (drafted) declared, but Campaign's only related field is an 'Authored By' string, no FK.",
  "Message.generatedSignalId — MESSAGE has 0-1 SIGNAL (it generated) declared, with no reverse slot on SIGNAL.",
  "campaign_recipients join table — not in the map, but without a record of who a campaign actually reached (vs. who merely matched the segment), 'Reachable is always the consented subset' can't be enforced or tested.",
  "segment_members as a static snapshot — the map describes SEGMENT membership as criteria-based and auto-updating; live criteria evaluation is out of scope for this POC, so membership is seeded once and not recalculated.",
  "WaitlistRequest.requestDisplayId — kept alongside the infrastructure `id` because the map's own core_content field 'Request ID' (e.g. BLVD-WL-0312) is a human-facing identifier distinct from a storage key.",
];

export function printHandBackReport(store: RelationalStore, dayId: DayId, ladder: LadderRunResult): void {
  const line = (s = "") => console.log(s);
  const rule = "─".repeat(72);

  line(rule);
  line("DETAIL / CUE proof-of-concept — hand-back report");
  line(rule);

  line();
  line("1. RUN — signal count in, cue count out, dispositions in between");
  line(`   Signals in:            ${ladder.totalSignals}`);
  line(`   CUE DECISIONs created: ${ladder.cueDecisionsCreated}`);
  line(`   CUEs spoken:           ${ladder.cuesProduced}`);
  line(`   Actions auto-executed: ${ladder.actionsCreated}`);
  line(`   Ladder stop, by step:`);
  for (const step of [1, 2, 3, 4, 5] as const) {
    line(`     step ${step}: ${ladder.ladderStopCounts[step]}`);
  }
  line(`   Disposition breakdown:`);
  for (const [disposition, count] of Object.entries(ladder.dispositionCounts)) {
    line(`     ${disposition.padEnd(20)} ${count}`);
  }
  const stats = store.dayStats(dayId);
  line(`   DAY rollups (computed, not stored): ${JSON.stringify(stats)}`);

  line();
  line("2. △ UNRATIFIED — proposals, not decisions (implemented, flagged, pullable)");
  line(`   Attributes (${UNRATIFIED_ATTRIBUTES.length}):`);
  for (const a of UNRATIFIED_ATTRIBUTES) line(`     ${a.object}.${a.field} (${a.section})`);
  line(`   Relationships (${UNRATIFIED_RELATIONSHIPS.length}):`);
  for (const r of UNRATIFIED_RELATIONSHIPS) {
    line(`     ${r.fromObject} ${r.cardinality} ${r.toObject} (${r.nature})`);
  }

  line();
  line("3. Dependency rules stubbed as UNSPECIFIED (every declared relationship — the");
  line("   map never says what happens to nested rows on delete/archive):");
  line(`   ${RELATIONSHIP_DESCRIPTORS.length} relationships total, all onDelete: 'UNSPECIFIED'.`);
  line(`   RelationalStore.Table#delete() refuses to guess: it throws unless the`);
  line(`   caller passes onDependents: 'cascade' | 'restrict' explicitly.`);
  line(`   Additionally tightened at runtime (declared cardinality looser than reality):`);
  for (const t of TIGHTENED_CARDINALITIES) line(`     ${t.fromObject} → ${t.toObject}: ${t.note}`);

  line();
  line("4. Invented to make it run (no counterpart in the map):");
  for (const item of INVENTED_TO_MAKE_IT_RUN) line(`   - ${item}`);

  line();
  line(`5. Hard rules (${HARD_RULES.length}) — see tests/hardRules.test.ts for one test per rule:`);
  for (const r of HARD_RULES) line(`   [${r.id}] ${r.ctaObject} — "${r.cta}": ${r.description}`);

  line();
  line(rule);
}
