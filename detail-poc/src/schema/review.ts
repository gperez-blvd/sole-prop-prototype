import type {
  AppointmentId,
  BusinessId,
  ClientId,
  DayId,
  MessageId,
  OperatorId,
  ReviewId,
} from "../ids.js";

export type ReviewSource = "google" | "instagram";
export type ReplyStatus = "drafted" | "sent" | "none";

/**
 * REVIEW — "She didn't rush me." 5 stars.
 * Source: object-map.json → objects[].name === "REVIEW"
 *
 * Open item from the handoff: "REVIEW reaches SERVICE only by proxy
 * through APPOINTMENT, so reviews with no appointment (unmatched Google
 * reviews) can't be attributed to a service." `appointmentId` is
 * therefore optional and there is deliberately no `serviceId` here.
 */
export interface ReviewRow {
  /** INFRASTRUCTURE: primary key. */
  id: ReviewId;

  // core_content
  reviewBody: string;
  /** May be unmatched to a CLIENT — kept as free text per the map's own example. */
  reviewerName: string;
  replyText?: string;

  // metadata
  starRating: number;
  date: Date;
  source: ReviewSource;
  replyStatus: ReplyStatus;
  taggedThemes: string[];

  // relationships
  clientId?: ClientId;
  businessId: BusinessId;
  operatorId?: OperatorId;
  appointmentId?: AppointmentId;
  replyMessageId?: MessageId;
  dayId: DayId;
}
