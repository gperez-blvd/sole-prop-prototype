import type {
  AppointmentId,
  BusinessId,
  ClientId,
  DayId,
  OpeningId,
  ServiceId,
} from "../ids.js";

export type OpeningOrigin = "cancellation" | "never_booked" | "schedule_gap";
export type OpeningStatus = "open" | "offered" | "filled" | "expired";

/**
 * OPENING — "Tomorrow 2:30, 90 minutes."
 * Source: object-map.json → objects[].name === "OPENING"
 *
 * Open item from the handoff: OPENING is missing CTAs (Split, Extend,
 * Discount to fill) that the map's authors flagged as not yet built.
 * Not added here — flagged in the report per "do not add... CTAs."
 */
export interface OpeningRow {
  /** INFRASTRUCTURE: primary key. */
  id: OpeningId;

  // core_content
  slotLabel: string;

  // metadata
  startTime: Date;
  durationMinutes: number;
  estimatedValue: number;
  origin: OpeningOrigin;
  status: OpeningStatus;
  offerOrder: string[];

  // relationships
  businessId: BusinessId;
  vacatedByAppointmentId?: AppointmentId;
  serviceId?: ServiceId;
  /** Owning side of "has 0-1 CLIENT (filled by)". */
  filledByClientId?: ClientId;
  dayId: DayId;

  // Reverse/join, not stored here:
  //   - has 0-many CLIENT (offered to)        -> join table opening_offers
  //   - has 0-1 PROPOSAL (surfaced in)         -> Proposal.openingId (reverse)
  //   - has 0-1 CAMPAIGN (promoting it)        -> Campaign.openingId (reverse)
  //   - has 0-many WAITLIST REQUEST (matched)  -> join table opening_waitlist_matches
}
