import type { BusinessId, ClientId } from "../ids.js";

export type PreferredChannel = "text" | "email" | "call";
export type ConsentStatus = "granted" | "denied" | "withdrawn";

/**
 * CLIENT — Maya Okafor.
 * Source: object-map.json → objects[].name === "CLIENT"
 *
 * Marketing consent is per-channel and load-bearing: the "never message
 * without consent" hard rule reads `marketingConsentSms` /
 * `marketingConsentEmail` directly (see hardRules.ts and
 * campaign_recipients in joinTables.ts).
 */
export interface ClientRow {
  /** INFRASTRUCTURE: primary key. */
  id: ClientId;

  // core_content
  fullName: string;
  photoUrl?: string;
  mobile: string;
  notes?: string;

  // metadata
  clientSince: Date;
  visitCount: number;
  lifetimeValue: number;
  rebookingCadenceDays?: number;
  noShowCount: number;
  preferredChannel: PreferredChannel;
  referredBy?: string;
  tags: string[];
  marketingConsentSms: ConsentStatus;
  marketingConsentEmail: ConsentStatus;
  unsubscribedAt?: Date;
  lastMarketingContact?: Date;

  // relationships
  businessId: BusinessId;

  // Reverse/derived/join, not stored here:
  //   - has 0-many APPOINTMENT (booked)      -> Appointment.clientId (reverse)
  //   - has 0-many SERVICE (received)        -> DERIVED via appointment_services
  //                                             joined through this client's
  //                                             appointments. Not a stored edge;
  //                                             invented traversal.
  //   - has 0-many MESSAGE (exchanged)        -> Message.clientId (reverse)
  //   - has 0-many REVIEW (written)           -> Review.clientId (reverse)
  //   - has 0-many SEGMENT (she belongs to)   -> join table segment_members
  //     (INVENTED SIMPLIFICATION: segments are described as criteria-based
  //      and "auto-updating" — we snapshot membership at seed time instead
  //      of evaluating live criteria. Flagged in the hand-back report.)
  //   - has 0-many CAMPAIGN (received)        -> join table campaign_recipients
  //   - has 0-many PATTERN (about her)        -> Pattern.clientId (reverse)
  //   - has 0-many CUE (about her)            -> Cue.clientId (reverse)
  //   - has 0-many SIGNAL (about her)         -> Signal.clientId (reverse)
  //   - has 0-many OPENING (offered to her)   -> join table opening_offers
  //   - has 0-many WAITLIST REQUEST (she's made) -> WaitlistRequest.clientId (reverse)
  //   - has 1 CHART (hers)                    -> Chart.clientId (reverse, unique)
}
