import type { CueDecisionId, DetailId, SignalId } from "../ids.js";

export type LadderStop = 1 | 2 | 3 | 4 | 5;
export type CueDecisionOutcome = "handled_silently" | "suppressed" | "deferred" | "escalated";
export type TimingDecision = "speak_now" | "wait_for_gap" | "hold_for_debrief";

/**
 * CUE DECISION — a junction, not a detail table: many SIGNALs resolve into
 * one CUE DECISION, and it carries its own attributes.
 * Source: object-map.json → objects[].name === "CUE DECISION"
 */
export interface CueDecisionRow {
  /** INFRASTRUCTURE: primary key. */
  id: CueDecisionId;

  // core_content
  reasoning: string;

  // metadata
  ladderStop: LadderStop;
  outcome: CueDecisionOutcome;
  timingDecision: TimingDecision;
  /** Short descriptions of what else was suppressed alongside this decision. */
  suppressedAlongside: string[];
  decidedAt: Date;

  // relationships
  detailId: DetailId;

  // "has 1-many SIGNAL (it resolved)" is realized on the SIGNAL side
  // (Signal.cueDecisionId) rather than as an array here, so a signal can
  // never point at a decision that doesn't list it back. RelationalStore
  // enforces "1-many" by refusing to create a CueDecision with zero
  // signals attached.
  //
  // "has 0-1 CUE (it produced)" is resolved by reverse lookup on
  // Cue.cueDecisionId (unique).
  //
  // "has 0-many THRESHOLD (consulted)" -> join table
  // cue_decision_threshold_consultations.
}
