import type {
  CapabilityId,
  DayId,
  DetailId,
  OpeningId,
  PatternId,
  ProposalId,
  SegmentId,
  ServiceId,
} from "../ids.js";

/** "capability_activation" and "marketing" are the map's own △ values. */
export type ProposalType =
  | "growth_opportunity"
  | "threshold_tuning"
  | "capability_activation"
  | "marketing";
export type EvidenceSource = "observed_behavior" | "cohort_prior" | "domain_knowledge" | "declared";
export type ProposalStatus = "pending" | "accepted" | "declined" | "expired";

/**
 * PROPOSAL — "Tox clients are rebooking 18 days later than six months ago."
 * Source: object-map.json → objects[].name === "PROPOSAL"
 */
export interface ProposalRow {
  /** INFRASTRUCTURE: primary key. */
  id: ProposalId;

  // core_content
  finding: string;
  theMath: string;
  recommendedAction: string;
  spokenFraming: string;

  // metadata
  type: ProposalType;
  /** △ UNRATIFIED — whole field, "△ Evidence Source" in the map. */
  evidenceSource?: EvidenceSource;
  estimatedValue: number;
  confidence: "low" | "medium" | "high";
  status: ProposalStatus;
  rollbackAvailable: boolean;
  surfacedAt: Date;

  // relationships
  detailId: DetailId;
  /** △ UNRATIFIED relation — "△ would activate" CAPABILITY. */
  capabilityId?: CapabilityId;
  openingId?: OpeningId;
  serviceId?: ServiceId;
  dayId?: DayId;
  segmentId?: SegmentId;
  patternId?: PatternId;

  // Reverse/join, not stored here:
  //   - has 0-1 THRESHOLD (would create or tune) -> Threshold.createdOrTunedByProposalId (reverse)
  //   - has 0-1 CUE (delivered in)                -> Cue.proposalId (reverse)
  //   - has 0-many CLIENT (affected)               -> join table proposal_affected_clients
  //   - has 0-1 CAMPAIGN (it would send)           -> Campaign.raisedByProposalId (reverse)
  //   - has 0-many WAITLIST REQUEST (it would fulfil) -> join table proposal_fulfills_waitlist_requests
}
