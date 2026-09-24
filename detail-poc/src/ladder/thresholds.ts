import type { DetailId, ThresholdId } from "../ids.js";
import type { ThresholdRow } from "../schema/index.js";
import type { RelationalStore } from "../store/RelationalStore.js";
import type { SignalRow } from "../schema/index.js";

/**
 * THRESHOLD rows are pure data (per the schema — no executable field
 * exists on ThresholdRow, matching object-map.json). The *matching logic*
 * that decides whether a given SIGNAL falls inside a threshold is kept
 * here, alongside the data, rather than inside ladder.ts, so the two stay
 * next to each other.
 */
export interface ThresholdDefinition {
  data: Omit<ThresholdRow, "id" | "detailId">;
  /** True if this threshold governs (applies to) the signal at all. */
  matches: (signal: SignalRow) => boolean;
}

export const THRESHOLD_DEFINITIONS: ThresholdDefinition[] = [
  {
    data: {
      ruleStatement: "Lateness under 15 minutes: handle it, don't ask.",
      observedBehavior: "41 of 41 small shifts approved without comment.",
      type: "speaking_window",
      boundaryValue: "15 min",
      permittedAction: "handle",
      mechanics: "inferred_and_confirmed",
      evidenceCount: 41,
      confidence: "high",
      learnedDate: new Date(2026, 0, 15),
      lastConfirmed: new Date(2026, 8, 16),
    },
    matches: (s) => s.domain === "scheduling" && /late/i.test(s.payload),
  },
  {
    data: {
      ruleStatement: "Successful payment collection needs no mention.",
      observedBehavior: "Every routine charge has gone unremarked for 6 months.",
      type: "speaking_window",
      boundaryValue: "n/a",
      permittedAction: "stay_silent",
      mechanics: "inferred_silently",
      evidenceCount: 180,
      confidence: "high",
      learnedDate: new Date(2026, 1, 2),
      lastConfirmed: new Date(2026, 8, 20),
    },
    matches: (s) => s.domain === "payments" && /collected|charged successfully/i.test(s.payload),
  },
  {
    data: {
      ruleStatement: "FAQ-shaped DMs (hours, parking, price) get auto-replied.",
      observedBehavior: "112 auto-replies, zero corrections requested.",
      type: "autonomy_grant",
      boundaryValue: "n/a",
      permittedAction: "handle",
      mechanics: "declared",
      evidenceCount: 112,
      confidence: "high",
      learnedDate: new Date(2026, 2, 1),
      lastConfirmed: new Date(2026, 8, 22),
    },
    matches: (s) => s.domain === "messaging" && /hours\?|parking\?|price\?|address\?/i.test(s.payload),
  },
  {
    data: {
      ruleStatement: "Low stock on a consumable: log it, reorder note only.",
      observedBehavior: "Reorder notes have replaced her manual stock checks.",
      type: "autonomy_grant",
      boundaryValue: "n/a",
      permittedAction: "handle",
      mechanics: "declared",
      evidenceCount: 9,
      confidence: "medium",
      learnedDate: new Date(2026, 4, 10),
      lastConfirmed: new Date(2026, 8, 1),
    },
    matches: (s) => s.domain === "inventory",
  },
  {
    data: {
      ruleStatement: "4-5 star reviews: log and tag themes, no reply drafting prompt.",
      observedBehavior: "Positive reviews have never needed her attention same-day.",
      type: "decision_boundary",
      boundaryValue: "4 stars",
      permittedAction: "handle",
      mechanics: "inferred_and_confirmed",
      evidenceCount: 34,
      confidence: "high",
      learnedDate: new Date(2026, 3, 1),
      lastConfirmed: new Date(2026, 8, 10),
    },
    matches: (s) => s.domain === "external" && s.source === "review" && /star: [45]/i.test(s.payload),
  },
  {
    data: {
      ruleStatement: "Routine weather (no rain, no extreme heat): no mention.",
      observedBehavior: "Clear/mild weather signals have never warranted a cue.",
      type: "speaking_window",
      boundaryValue: "n/a",
      permittedAction: "stay_silent",
      mechanics: "inferred_silently",
      evidenceCount: 60,
      confidence: "high",
      learnedDate: new Date(2026, 0, 1),
      lastConfirmed: new Date(2026, 8, 23),
    },
    matches: (s) => s.domain === "external" && s.source === "weather" && !/rain|storm/i.test(s.payload),
  },
];

/**
 * Seeds THRESHOLD rows into the store for the one DETAIL in this POC and
 * returns them alongside their matcher so ladder.ts can evaluate signals
 * against them.
 */
export function seedThresholds(
  store: RelationalStore,
  detailId: DetailId,
): { row: ThresholdRow; matches: (signal: SignalRow) => boolean }[] {
  return THRESHOLD_DEFINITIONS.map((def) => ({
    row: store.createThreshold({ ...def.data, detailId }),
    matches: def.matches,
  }));
}

export type SeededThreshold = { row: ThresholdRow; matches: (signal: SignalRow) => boolean };
export type { ThresholdId };
