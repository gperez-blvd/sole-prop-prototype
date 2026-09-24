import type {
  BusinessId,
  CampaignId,
  DayId,
  DetailId,
  OpeningId,
  ProductId,
  ProposalId,
  SegmentId,
  ServiceId,
} from "../ids.js";

export type CampaignType = "fill_a_gap" | "re_engagement" | "lapsed_winback" | "promotion" | "seasonal";
export type CampaignChannel = "sms" | "email";
export type CampaignStatus = "draft" | "proposed" | "scheduled" | "sending" | "sent" | "cancelled";
export type CampaignAuthoredBy = "operator" | "detail_in_her_voice";

/**
 * CAMPAIGN — "March filler promo."
 * Source: object-map.json → objects[].name === "CAMPAIGN"
 *
 * `audienceSize` and `reachableSize` are NOT stored: they're computed from
 * this campaign's segment membership and campaign_recipients rows by
 * RelationalStore.campaignReach(). This is load-bearing for the "never
 * messages without consent" hard rule — Reachable must always be the
 * consented subset, and a stored, driftable column could lie about that.
 */
export interface CampaignRow {
  /** INFRASTRUCTURE: primary key. */
  id: CampaignId;

  // core_content
  campaignName: string;
  subjectLine?: string;
  bodyCopy: string;
  offer?: string;

  // metadata (audienceSize/reachableSize deliberately excluded — see class doc)
  type: CampaignType;
  channel: CampaignChannel;
  status: CampaignStatus;
  scheduledFor?: Date;
  opens?: number;
  clicks?: number;
  bookingsAttributed?: number;
  revenueAttributed?: number;
  unsubscribes?: number;
  authoredBy: CampaignAuthoredBy;

  // relationships
  businessId: BusinessId;
  segmentId: SegmentId;
  /** Owning side of the symmetric 0-1:0-1 pair with PROPOSAL ("that raised it"). */
  raisedByProposalId?: ProposalId;
  /** Owning side of the symmetric 0-1:0-1 pair with OPENING ("it's filling"). */
  openingId?: OpeningId;
  serviceId?: ServiceId;
  dayId?: DayId;
  /** Added in ADDENDUM_01.md — "it promotes". */
  productId?: ProductId;
  /**
   * INFRASTRUCTURE ADDITION: realizes "DETAIL has 0-many CAMPAIGN
   * (drafted)" — the map only gives Campaign an "Authored By" string, no
   * FK back to a specific DETAIL row. Added and flagged rather than left
   * unrealizable.
   */
  draftedByDetailId?: DetailId;

  // has 0-many MESSAGE (sent from it)    -> Message.campaignId (reverse)
  // has 0-many APPOINTMENT (booked from it) -> Appointment.campaignId (reverse)
}
