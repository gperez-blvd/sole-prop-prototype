import type {
  AppointmentId,
  BusinessId,
  ClientId,
  CueDecisionId,
  DayId,
  FormId,
  SignalId,
} from "../ids.js";

/** "form", "chart" and "derived" are the map's own △ values on this enum. */
export type SignalSource =
  | "check_in"
  | "payment"
  | "dm"
  | "review"
  | "weather"
  | "stock"
  | "form"
  | "chart"
  | "api"
  | "derived";
export type SignalDomain = "scheduling" | "payments" | "messaging" | "inventory" | "external";
export type SignalDisposition =
  | "handled_silently"
  | "suppressed"
  | "deferred"
  | "escalated_to_cue"
  | "awaiting_approval";

/**
 * SIGNAL — "check-in: 1:30 client arrived 12 min late."
 * Source: object-map.json → objects[].name === "SIGNAL"
 *
 * This is the ladder's input row. `materiality` and `autoActionable` are the
 * map's own ladder-step-2 / ladder-step-3 fields; `disposition` is the
 * ladder's final answer, written by src/ladder/ladder.ts.
 */
export interface SignalRow {
  /** INFRASTRUCTURE: primary key. */
  id: SignalId;
  /** INFRASTRUCTURE: deterministic ordering tie-breaker within the day. */
  sequence: number;

  // core_content
  payload: string;

  // metadata
  timestamp: Date;
  source: SignalSource;
  domain: SignalDomain;
  /** Set by the ladder (step 2: does it matter?). Starts undefined. */
  materiality?: boolean;
  /** Set by the ladder (step 3: can Boulevard handle it?). Starts undefined. */
  autoActionable?: boolean;
  /** Set by the ladder once resolved. Starts undefined ("unprocessed"). */
  disposition?: SignalDisposition;

  // relationships
  businessId: BusinessId;
  clientId?: ClientId;
  appointmentId?: AppointmentId;
  dayId: DayId;
  formId?: FormId;
  /** Owning side of "has 0-1 CUE DECISION (resolved by)". Set by the ladder. */
  cueDecisionId?: CueDecisionId;

  // Reverse/join, not stored here:
  //   - has 0-many THRESHOLD (evaluated against) -> join table signal_threshold_evaluations
  //   - has 0-many ACTION (triggered)             -> Action.signalId (reverse)
}
