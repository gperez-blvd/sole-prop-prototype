import type {
  BusinessId,
  ClientId,
  DetailId,
  PatternId,
  SegmentId,
  ServiceId,
} from "../ids.js";

export type PatternUnit =
  | "weekday"
  | "time_of_day"
  | "seasonal"
  | "weather"
  | "cohort"
  | "service";
export type Confidence = "low" | "medium" | "high";
export type PatternDirection = "strengthening" | "stable" | "decaying";
export type PatternStatus = "watching" | "announced" | "confirmed" | "dismissed";

/**
 * PATTERN — "Your Thursdays book out three weeks ahead."
 * Source: object-map.json → objects[].name === "PATTERN"
 */
export interface PatternRow {
  /** INFRASTRUCTURE: primary key. */
  id: PatternId;

  // core_content
  observation: string;
  valueImplication: string;

  // metadata
  unit: PatternUnit;
  evidenceCount: number;
  confidence: Confidence;
  firstObserved: Date;
  lastConfirmed: Date;
  direction: PatternDirection;
  estimatedValue: number;
  status: PatternStatus;

  // relationships (owning FKs)
  businessId: BusinessId;
  detailId: DetailId;
  serviceId?: ServiceId;
  segmentId?: SegmentId;
  clientId?: ClientId;

  // Reverse/join, not stored here:
  //   - has 0-many DAY (evidencing it)       -> join table day_pattern_evidence
  //   - has 0-many PROPOSAL (it generated)   -> Proposal.patternId (reverse)
  //   - has 0-many THRESHOLD (derived from)  -> Threshold.patternId (reverse)
  //   - has 0-many BRIEFING (that announced) -> join table briefing_pattern_announcements
}
