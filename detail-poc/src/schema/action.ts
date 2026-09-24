import type {
  ActionId,
  AppointmentId,
  CueId,
  DayId,
  DetailId,
  SignalId,
  ThresholdId,
} from "../ids.js";

export type TargetPrimitive = "calendar" | "messaging" | "payments" | "inventory" | "forms";
/** "inherited_default" is the map's own △ value on this enum. */
export type AuthorizedBy = "threshold" | "operator_approval" | "inherited_default";
export type ActionStatus = "executed" | "failed" | "reverted";
export type VisibleToOperator = "reported_in_cue" | "audit_only";

/**
 * ACTION — "moved cleanup window 2:27 → 2:40."
 * Source: object-map.json → objects[].name === "ACTION"
 *
 * Open item from the handoff: ACTION is a "broken object" in the OOUX
 * sense (few operator-facing actions relative to how widely it appears;
 * its Undo CTA has no natural home). Kept as-is, flagged in the report.
 */
export interface ActionRow {
  /** INFRASTRUCTURE: primary key. */
  id: ActionId;

  // core_content
  description: string;
  outcome: string;

  // metadata
  timestamp: Date;
  targetPrimitive: TargetPrimitive;
  reversible: boolean;
  authorizedBy: AuthorizedBy;
  status: ActionStatus;
  visibleToOperator: VisibleToOperator;

  // relationships
  detailId: DetailId;
  signalId?: SignalId;
  thresholdId?: ThresholdId;
  cueId?: CueId;
  appointmentId?: AppointmentId;
  dayId: DayId;

  // has 0-1 MESSAGE (it sent) is realized on the MESSAGE side
  // (Message.sentByActionId), resolved by reverse lookup here.
}
