import type {
  AppointmentId,
  BusinessId,
  CampaignId,
  ChartId,
  ClientId,
  DayId,
  OperatorId,
} from "../ids.js";

export type AppointmentStatus = "booked" | "confirmed" | "checked_in" | "completed" | "cancelled" | "no_show";
export type AppointmentReadiness = "ready" | "forms_outstanding" | "consent_expired" | "blocked";

/**
 * APPOINTMENT — BLVD-4471, 1:30 PM.
 * Source: object-map.json → objects[].name === "APPOINTMENT"
 *
 * `readiness` is marked △ AND is a derived rollup per the handoff
 * ("APPOINTMENT.△ Readiness is derived from its FORM rows") — it is
 * intentionally NOT a stored field here; RelationalStore.appointmentReadiness()
 * computes it from this appointment's required FORM rows.
 */
export interface AppointmentRow {
  /** INFRASTRUCTURE: primary key. */
  id: AppointmentId;

  // core_content
  confirmationNumber: string;
  notes?: string;

  // metadata (readiness deliberately excluded — see class doc)
  startTime: Date;
  durationMinutes: number;
  status: AppointmentStatus;
  checkInTime?: Date;
  latenessMinutes?: number;
  price: number;
  depositTaken: boolean;
  roomOrDevice: string;

  // relationships
  clientId: ClientId;
  operatorId: OperatorId;
  businessId: BusinessId;
  dayId: DayId;
  campaignId?: CampaignId;
  chartId: ChartId;

  // "has 1-many SERVICE (being performed)" is a genuine many:many — join
  // table appointment_services, enforced non-empty at write time.
  //
  // Reverse, not stored here:
  //   - has 0-many SIGNAL (generated)          -> Signal.appointmentId
  //   - has 0-many ACTION (applied to it)      -> Action.appointmentId
  //   - has 0-many CUE (about it)               -> Cue.appointmentId
  //   - has 0-many MESSAGE (about it)           -> Message.appointmentId
  //   - has 0-1 REVIEW (it produced)            -> Review.appointmentId
  //   - has 0-1 WAITLIST REQUEST (it came from) -> WaitlistRequest.becameAppointmentId
  //   - has 0-many FORM (required)              -> Form.appointmentId
  //   - has 0-many CHART ENTRY (documenting it) -> ChartEntry.appointmentId
}
