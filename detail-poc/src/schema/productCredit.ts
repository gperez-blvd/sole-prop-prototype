import type { ClientId, OrderLineItemId, ProductCreditId, ProductId } from "../ids.js";

export type ProductCreditStatus = "active" | "depleted" | "refunded";

/**
 * PRODUCT CREDIT — prepaid units. The balance lives in the client's
 * wallet; treat it as a liability, not a convenience field. Refunding an
 * order deducts the balance automatically; refunding a redemption returns
 * units (neither of those flows is implemented here — this is a POC — but
 * the balance itself is real money already collected).
 * Source: data/ADDENDUM_01.md, Part 1.
 */
export interface ProductCreditRow {
  /** INFRASTRUCTURE: primary key. */
  id: ProductCreditId;

  // core_content
  creditLabel: string;

  // metadata
  unitsPurchased: number;
  unitsRemaining: number;
  purchasedAt: Date;
  discountApplied?: string;
  amountPaid: number;
  status: ProductCreditStatus;

  // relationships
  clientId: ClientId;
  productId: ProductId;
  /** Owning side of the symmetric 0-1:0-1 pair with ORDER LINE ITEM ("bought as"). */
  orderLineItemId?: OrderLineItemId;

  // has 0-many PRODUCT USAGE (redeemed against it) -> ProductUsage.productCreditId (reverse)
}
