import type { ProductId, ProductUsageRuleId, ServiceId } from "../ids.js";

/**
 * PRODUCT USAGE RULE — the junction on SERVICE × PRODUCT. `pricePerItem`
 * and `defaultQuantity` belong to the relationship, not either object —
 * price per unit varies by service and by product.
 *
 * `defaultQuantity` is load-bearing: it drives the price shown in the
 * self-booking overlay, which booking deposits and cancellation fees are
 * calculated from. Not cosmetic — see hardRules for why DETAIL can never
 * touch `pricePerItem`.
 * Source: data/ADDENDUM_01.md, Part 1.
 */
export interface ProductUsageRuleRow {
  /** INFRASTRUCTURE: primary key. */
  id: ProductUsageRuleId;

  // core_content
  ruleLabel: string;

  // metadata
  pricePerItem: number;
  defaultQuantity: number;
  active: boolean;

  // relationships — this row IS the SERVICE × PRODUCT junction.
  serviceId: ServiceId;
  productId: ProductId;
}
