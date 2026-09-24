import type { BusinessId, DayId, PayoutId } from "../ids.js";

export type PayoutStatus = "initiated" | "in_transit" | "paid" | "failed";

/**
 * PAYOUT — money leaving Boulevard for her bank, a different thing from a
 * client paying her. This is what the "connect payouts" CAPABILITY now
 * actually unlocks. `expectedArrival` is the "lands Thursday" line.
 * Source: data/ADDENDUM_01.md, Part 2.
 */
export interface PayoutRow {
  /** INFRASTRUCTURE: primary key. */
  id: PayoutId;

  // core_content
  payoutReference: string;

  // metadata
  amount: number;
  initiatedAt: Date;
  expectedArrival: string;
  destination: string;
  status: PayoutStatus;
  paymentCount: number;

  // relationships
  businessId: BusinessId;
  dayId?: DayId;

  // has 0-many PAYMENT (settled in it) -> Payment.payoutId (reverse)
}
