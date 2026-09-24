import type { BusinessId } from "../ids.js";

export type ActivationStage = "onboarded" | "activating" | "steady";

/**
 * BUSINESS — Jazz Aesthetics.
 * Source: object-map.json → objects[].name === "BUSINESS"
 */
export interface BusinessRow {
  /** INFRASTRUCTURE: primary key. */
  id: BusinessId;

  // core_content
  businessName: string;
  logoUrl?: string;
  brandPalette: string[];
  brandVoice: string;
  bookingLink: string;

  // metadata
  category: string;
  address: string;
  hours: string;
  starRating: number;
  reviewCount: number;
  /** △ UNRATIFIED — "△ Activation Stage" in the map: a proposal, not a decision. */
  activationStage: ActivationStage;

  // BUSINESS is the root of the graph — it has no outgoing FK of its own.
  // Everything else (has 1-many OPERATOR, has 0-many SERVICE/CLIENT/APPOINTMENT/
  // SIGNAL/DAY/CAMPAIGN/SEGMENT/PATTERN/REVIEW/OPENING/MESSAGE/WAITLIST REQUEST,
  // and — △ unratified — CAPABILITY, plus — added in ADDENDUM_01.md —
  // PRODUCT/ORDER/PAYOUT) is resolved by reverse lookup on those tables'
  // businessId, via RelationalStore.
}
