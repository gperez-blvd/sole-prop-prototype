import type { ClientId, OrderId, PaymentId, PayoutId } from "../ids.js";

export type PaymentMethod = "card" | "cash" | "prepaid_credit" | "gift_card";
export type PaymentStatus = "pending" | "succeeded" | "declined" | "refunded";

/**
 * PAYMENT — separate from ORDER because one order can take several
 * tenders (card plus prepaid credit plus cash). `declined` is the one
 * payment state that produces a cue — see the ladder's "payment-declined"
 * escalation cluster.
 * Source: data/ADDENDUM_01.md, Part 2.
 */
export interface PaymentRow {
  /** INFRASTRUCTURE: primary key. */
  id: PaymentId;

  // core_content
  paymentReference: string;

  // metadata
  method: PaymentMethod;
  amount: number;
  cardLastFour?: string;
  status: PaymentStatus;
  processedAt: Date;
  declineReason?: string;

  // relationships
  orderId: OrderId;
  clientId?: ClientId;
  /** Owning side — settled into at most one payout. */
  payoutId?: PayoutId;

  // has 0-many SIGNAL (it generated) -> Signal.paymentId (reverse)
  // has 0-many CUE (it prompted)      -> Cue.paymentId (reverse)
}
