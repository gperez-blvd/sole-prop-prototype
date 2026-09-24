import type {
  AppointmentId,
  CapabilityId,
  ClientId,
  CueDecisionId,
  CueId,
  DayId,
  DetailId,
  FormId,
  ProposalId,
} from "../ids.js";

/** "milestone", "capability" and "clinical_flag" are the map's own △ values. */
export type CueType = "interstitial" | "milestone" | "capability" | "clinical_flag";
export type CueIntent = "inform" | "decide" | "demonstrate" | "request";
export type CueChannel = "in_ear" | "carplay" | "watch" | "phone";
export type DeliveryWindow = "between_clients" | "commute" | "after_hours";
export type CueStatus = "queued" | "delivered" | "acknowledged" | "expired";

/**
 * CUE — "Your 1:30 is running 12 minutes late. I moved your cleanup window
 * and texted your 2:30. Nothing you need to do."
 * Source: object-map.json → objects[].name === "CUE"
 *
 * `spokenText` vs `onScreenDetail` is the structural split the handoff
 * requires for the clinical hard rule: a clinical cue's spoken text must
 * never carry the clinical detail that its on-screen counterpart may.
 */
export interface CueRow {
  /** INFRASTRUCTURE: primary key. */
  id: CueId;

  // core_content
  spokenText: string;
  operatorResponse?: string;
  /**
   * INFRASTRUCTURE ADDITION: the map's core_content only lists "Spoken
   * Text" and "Operator Response" — no on-screen counterpart. The clinical
   * hard rule ("cannot read clinical detail aloud... model spoken text and
   * on-screen detail as separate fields so this is structural") needs
   * somewhere for that detail to live that isn't spokenText. Added here and
   * called out as infrastructure, not a modeled attribute.
   */
  onScreenDetail?: string;

  // metadata
  timestamp: Date;
  type: CueType;
  /** △ UNRATIFIED — whole field, "△ Intent" in the map. */
  intent?: CueIntent;
  channel: CueChannel;
  deliveryWindow: DeliveryWindow;
  wordCount: number;
  requiresDecision: boolean;
  status: CueStatus;
  personaVoiceUsed: string;
  /**
   * △ UNRATIFIED — whole field, "△ Clinical Override" in the map. When
   * true: bypasses every speaking-window/quiet-hours threshold, and can
   * never be suppressed, deferred, or expired (see hardRules.ts).
   */
  clinicalOverride: boolean;

  // relationships
  detailId: DetailId;
  cueDecisionId: CueDecisionId;
  proposalId?: ProposalId;
  clientId?: ClientId;
  appointmentId?: AppointmentId;
  /** △ UNRATIFIED relation — "△ it concerns" CAPABILITY. */
  capabilityId?: CapabilityId;
  dayId: DayId;
  formId?: FormId;

  // has 0-many ACTION (it reports) -> Action.cueId (reverse).
}
