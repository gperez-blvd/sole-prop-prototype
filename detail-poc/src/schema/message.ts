import type {
  ActionId,
  AppointmentId,
  BusinessId,
  CampaignId,
  ClientId,
  MessageId,
  SignalId,
} from "../ids.js";

export type MessageDirection = "inbound" | "outbound";
export type MessageChannel = "sms" | "instagram_dm" | "email";
export type MessageStatus = "draft" | "sent" | "delivered" | "replied";
export type MessageAuthoredBy = "operator" | "detail_in_her_voice" | "template";

/**
 * MESSAGE — "Running about 10 behind, see you at 2:40?"
 * Source: object-map.json → objects[].name === "MESSAGE"
 */
export interface MessageRow {
  /** INFRASTRUCTURE: primary key. */
  id: MessageId;

  // core_content
  body: string;

  // metadata
  timestamp: Date;
  direction: MessageDirection;
  channel: MessageChannel;
  status: MessageStatus;
  authoredBy: MessageAuthoredBy;
  toneRead?: string;

  // relationships
  clientId?: ClientId;
  businessId: BusinessId;
  appointmentId?: AppointmentId;
  /** Owning side of the symmetric 0-1:0-1 pair with ACTION ("that sent it"). */
  sentByActionId?: ActionId;
  /**
   * INFRASTRUCTURE ADDITION: the map declares "MESSAGE has 0-1 SIGNAL (it
   * generated)" with no reverse slot on SIGNAL. Added so an inbound
   * message that becomes a signal has somewhere to record that link.
   */
  generatedSignalId?: SignalId;
  campaignId?: CampaignId;
}
