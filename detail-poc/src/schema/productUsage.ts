import type {
  AppointmentId,
  ChartEntryId,
  OrderLineItemId,
  ProductCreditId,
  ProductId,
  ProductUsageId,
  ServiceId,
} from "../ids.js";

/**
 * PRODUCT USAGE — the junction on APPOINTMENT × PRODUCT, as distinct from
 * PRODUCT USAGE RULE (the configured default). `quantityExpected` is set
 * at booking and editable; `quantityUsed` is the actual — the difference
 * between them is what makes usage-based pricing work, and is where a
 * "usage variance" PATTERN comes from.
 * Source: data/ADDENDUM_01.md, Part 1.
 *
 * Ownership note: this is the owning side of the symmetric 0-1:0-1 pairs
 * with CHART ENTRY ("documented in" / "it documents") and ORDER LINE ITEM
 * ("billed as" / "it bills") and PRODUCT CREDIT ("redeemed against" /
 * "redeemed against it") — each of those rows resolves the relationship
 * by reverse lookup rather than storing a second copy of the FK.
 */
export interface ProductUsageRow {
  /** INFRASTRUCTURE: primary key. */
  id: ProductUsageId;

  // core_content
  /** The map's own display id (e.g. BLVD-PU-8841) — distinct from the storage key. */
  usageRecordDisplayId: string;

  // metadata
  quantityExpected: number;
  quantityUsed: number;
  pricePerItemApplied: number;
  /** Amount folded into the service price — NOT client-facing on its own; see hardRules. */
  amountCharged: number;
  prepaidUnitsRedeemed: number;
  recordedAt: Date;

  // relationships
  appointmentId: AppointmentId;
  productId: ProductId;
  serviceId?: ServiceId;
  chartEntryId?: ChartEntryId;
  productCreditId?: ProductCreditId;
  orderLineItemId?: OrderLineItemId;
}
