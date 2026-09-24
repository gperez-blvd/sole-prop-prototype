import type { AppointmentId, ChartId, FormId, ServiceId } from "../ids.js";

export type FormType = "intake" | "medical_history" | "consent" | "post_care_acknowledgment";
export type FormStatus = "not_sent" | "sent" | "overdue" | "complete" | "expired" | "waived";
export type FormRequiredFor = "this_appointment" | "this_service" | "annually";
export type FormSource = "client_completed" | "on_paper" | "filled_by_operator";

/**
 * FORM — "Neurotoxin consent · Intake — medical history."
 * Source: object-map.json → objects[].name === "FORM"
 *
 * Open item from the handoff: "FORM TEMPLATE is probably a real object...
 * currently metadata on FORM." Kept as metadata (`templateAndVersion`)
 * here per instructions not to add objects — flagged in the report.
 */
export interface FormRow {
  /** INFRASTRUCTURE: primary key. */
  id: FormId;

  // core_content
  formName: string;
  responses: Record<string, string>;
  signature?: string;

  // metadata
  type: FormType;
  status: FormStatus;
  templateAndVersion: string;
  sentAt?: Date;
  completedAt?: Date;
  expires?: Date;
  flagsRaised: string[];
  requiredFor: FormRequiredFor;
  source: FormSource;

  // relationships
  chartId: ChartId;
  appointmentId?: AppointmentId;
  serviceId?: ServiceId;

  // has 0-many SIGNAL (it generated) -> Signal.formId (reverse)
  // has 0-many CUE (it prompted)      -> Cue.formId (reverse)
}
