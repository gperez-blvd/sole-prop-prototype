import type {
  AppointmentId,
  BusinessId,
  ClientId,
  ServiceId,
  WaitlistRequestId,
} from "../ids.js";

export type WaitlistFlexibility = "specific_date" | "any_weekday" | "any_time";
export type WaitlistStatus = "waiting" | "offered" | "booked" | "expired" | "withdrawn";

/**
 * WAITLIST REQUEST — BLVD-WL-0312, "wants anything Thursday afternoon."
 * Source: object-map.json → objects[].name === "WAITLIST REQUEST"
 */
export interface WaitlistRequestRow {
  /** INFRASTRUCTURE: primary key. */
  id: WaitlistRequestId;

  // core_content
  /** The map's own "Request ID" display field — distinct from the row's `id`. */
  requestDisplayId: string;
  requestNote?: string;

  // metadata
  desiredWindow: string;
  flexibility: WaitlistFlexibility;
  created: Date;
  expires?: Date;
  status: WaitlistStatus;
  queueOrder: number;
  timesOffered: number;
  timesDeclined: number;

  // relationships
  clientId: ClientId;
  businessId: BusinessId;
  serviceId?: ServiceId;
  becameAppointmentId?: AppointmentId;

  // has 0-many OPENING (offered to her) -> join table opening_waitlist_matches
}
