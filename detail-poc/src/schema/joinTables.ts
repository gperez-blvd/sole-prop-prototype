/**
 * Join tables for every nested_objects relationship that is genuinely
 * many:many, or that is declared on only one side with no natural owning
 * FK on either row. Each comment cites the object-map.json entries it
 * realizes.
 */
import type {
  ActionId,
  AppointmentId,
  BriefingId,
  CampaignId,
  CapabilityId,
  ChartEntryId,
  ClientId,
  CueDecisionId,
  DayId,
  OpeningId,
  OperatorId,
  PatternId,
  ProductId,
  ProposalId,
  ReviewId,
  SegmentId,
  ServiceId,
  SignalId,
  ThresholdId,
  WaitlistRequestId,
} from "../ids.js";

/** OPERATOR "has 0-many SERVICE (qualified for)" ↔ SERVICE "has 0-many OPERATOR (qualified to perform)". */
export interface OperatorQualifiedServiceRow {
  operatorId: OperatorId;
  serviceId: ServiceId;
}

/** APPOINTMENT "has 1-many SERVICE (being performed)" ↔ SERVICE "has 0-many APPOINTMENT (performed in)". */
export interface AppointmentServiceRow {
  appointmentId: AppointmentId;
  serviceId: ServiceId;
}

/** PATTERN "has 0-many DAY (evidencing it)" ↔ DAY "has 0-many PATTERN (it evidences)". */
export interface DayPatternEvidenceRow {
  dayId: DayId;
  patternId: PatternId;
}

/** PATTERN "has 0-many BRIEFING (that announced it)" ↔ BRIEFING "has 0-many PATTERN (announced)". */
export interface BriefingPatternAnnouncementRow {
  briefingId: BriefingId;
  patternId: PatternId;
}

/**
 * SIGNAL "has 0-many THRESHOLD (evaluated against)" ↔ THRESHOLD "has 0-many
 * SIGNAL (evidenced by)". Doubles as the ladder's audit trail: one row per
 * (signal, threshold) evaluation at a given ladder step.
 */
export interface SignalThresholdEvaluationRow {
  signalId: SignalId;
  thresholdId: ThresholdId;
  step: 1 | 2 | 3 | 4 | 5;
  result: string;
}

/** CUE DECISION "has 0-many THRESHOLD (consulted)" ↔ THRESHOLD "has 0-many CUE DECISION (consulted in)". */
export interface CueDecisionThresholdConsultationRow {
  cueDecisionId: CueDecisionId;
  thresholdId: ThresholdId;
}

/** △ UNRATIFIED — CAPABILITY "has 0-many CAPABILITY (△ it depends on)", self-referential. */
export interface CapabilityDependencyRow {
  capabilityId: CapabilityId;
  dependsOnCapabilityId: CapabilityId;
}

/**
 * CLIENT "has 0-many SEGMENT (she belongs to)" ↔ SEGMENT "has 0-many CLIENT
 * (matching)". INVENTED SIMPLIFICATION: a static snapshot standing in for
 * live criteria evaluation — see client.ts / segment.ts class docs.
 */
export interface SegmentMemberRow {
  segmentId: SegmentId;
  clientId: ClientId;
}

/**
 * CLIENT "has 0-many CAMPAIGN (received)". INVENTED: not in the map as a
 * table, but required to enforce "never messages without consent" —
 * without a record of who a campaign actually reached, `SEGMENT.Reachable`
 * can't be checked against real sends. `consentVerified` is written at
 * send time and is what the hard-rule tests assert on.
 */
export interface CampaignRecipientRow {
  campaignId: CampaignId;
  clientId: ClientId;
  channel: "sms" | "email";
  consentVerified: boolean;
}

/** OPENING "has 0-many CLIENT (offered to)". */
export interface OpeningOfferRow {
  openingId: OpeningId;
  clientId: ClientId;
}

/** OPENING "has 0-many WAITLIST REQUEST (matched to it)" ↔ WAITLIST REQUEST "has 0-many OPENING (offered to her)". */
export interface OpeningWaitlistMatchRow {
  openingId: OpeningId;
  waitlistRequestId: WaitlistRequestId;
}

/** BRIEFING "has 0-many CLIENT (flagged)" — one-directional, no reverse slot on CLIENT. */
export interface BriefingFlaggedClientRow {
  briefingId: BriefingId;
  clientId: ClientId;
}

/** BRIEFING "has 0-many OPENING (it covers)" — one-directional. */
export interface BriefingCoveredOpeningRow {
  briefingId: BriefingId;
  openingId: OpeningId;
}

/** BRIEFING "has 0-many PROPOSAL (carried)" — one-directional. */
export interface BriefingCarriedProposalRow {
  briefingId: BriefingId;
  proposalId: ProposalId;
}

/** BRIEFING "has 0-many ACTION (summarized)" — one-directional. */
export interface BriefingSummarizedActionRow {
  briefingId: BriefingId;
  actionId: ActionId;
}

/** BRIEFING "has 0-many REVIEW (new today)" — one-directional. */
export interface BriefingNewReviewRow {
  briefingId: BriefingId;
  reviewId: ReviewId;
}

/** PROPOSAL "has 0-many CLIENT (affected)" — one-directional. */
export interface ProposalAffectedClientRow {
  proposalId: ProposalId;
  clientId: ClientId;
}

/** PROPOSAL "has 0-many WAITLIST REQUEST (it would fulfil)" — one-directional. */
export interface ProposalFulfillsWaitlistRequestRow {
  proposalId: ProposalId;
  waitlistRequestId: WaitlistRequestId;
}

/** SERVICE "has 0-many THRESHOLD (governed by)" — one-directional, no reverse slot on THRESHOLD. */
export interface ServiceGoverningThresholdRow {
  serviceId: ServiceId;
  thresholdId: ThresholdId;
}

/**
 * CHART ENTRY "has 0-many PRODUCT (recorded by lot)" — one-directional,
 * no reverse slot on PRODUCT. Deliberately carries no lot/expiry fields:
 * PRODUCT doesn't track expiry (△ Expiry, not tracked by Boulevard —
 * ADDENDUM_01.md), and lot/expiry for what was actually injected stays on
 * CHART ENTRY's own free-text "Products & Lots" field, as specified.
 */
export interface ChartEntryProductRow {
  chartEntryId: ChartEntryId;
  productId: ProductId;
}
