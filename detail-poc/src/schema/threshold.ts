import type {
  CapabilityId,
  DetailId,
  PatternId,
  ProposalId,
  ThresholdId,
} from "../ids.js";

export type ThresholdType = "speaking_window" | "autonomy_grant" | "decision_boundary";
export type PermittedAction = "handle" | "ask_first" | "stay_silent";
/** "inherited" is the map's own △ value on this enum — see handoff note. */
export type ThresholdMechanics =
  | "inherited"
  | "declared"
  | "inferred_and_confirmed"
  | "inferred_silently";
export type ResolutionTiming = "ask_now" | "ask_at_debrief" | "infer_silently";

/**
 * THRESHOLD — "lateness under 15 min: handle it, don't ask."
 * Source: object-map.json → objects[].name === "THRESHOLD"
 *
 * This is the table the ladder simulation reads at every step: each SIGNAL
 * is evaluated against the THRESHOLD rows that apply to it (see
 * signal_threshold_evaluations in joinTables.ts and src/ladder/ladder.ts).
 */
export interface ThresholdRow {
  /** INFRASTRUCTURE: primary key. */
  id: ThresholdId;

  // core_content
  ruleStatement: string;
  observedBehavior: string;

  // metadata
  type: ThresholdType;
  boundaryValue: string;
  permittedAction: PermittedAction;
  mechanics: ThresholdMechanics;
  evidenceCount: number;
  confidence: "low" | "medium" | "high";
  learnedDate: Date;
  lastConfirmed: Date;
  /** △ UNRATIFIED — "△ Resolution Timing" in the map. */
  resolutionTiming?: ResolutionTiming;

  // relationships
  detailId: DetailId;
  /**
   * Owning side of the symmetric "has 0-1" pair between THRESHOLD and
   * PROPOSAL ("created or tuned by" / "would create or tune"). We store it
   * here rather than on Proposal — an arbitrary but necessary pick, since
   * the map declares both sides as 0-1 without saying which owns the FK.
   */
  createdOrTunedByProposalId?: ProposalId;
  /** △ UNRATIFIED relation — "△ enabled by" CAPABILITY. */
  enabledByCapabilityId?: CapabilityId;
  patternId?: PatternId;

  // Reverse/join, not stored here:
  //   - has 0-many SIGNAL (evidenced by)      -> join table signal_threshold_evaluations
  //   - has 0-many CUE DECISION (consulted in)-> join table cue_decision_threshold_consultations
  //   - has 0-many ACTION (it authorized)     -> Action.thresholdId (reverse)
  //
  // SERVICE declares "has 0-many THRESHOLD (governed by)" with no reverse
  // slot on THRESHOLD's own list — realized via join table
  // service_governing_thresholds (see joinTables.ts).
}
