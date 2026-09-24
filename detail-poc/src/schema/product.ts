import type { BusinessId, ProductId } from "../ids.js";

export type ProductCategory = "retail" | "back_bar";

/**
 * PRODUCT — one object, not two. A Botox vial is typically both sellable
 * as retail AND usable in a service; two independent booleans model that,
 * per the handoff: "You can track and charge for usage-based products
 * even if you don't sell those products as retail."
 * Source: data/ADDENDUM_01.md, Part 1.
 *
 * △ Expiry is deliberately NOT a field here — Boulevard doesn't track it.
 * Lot/expiry for what was actually injected lives on CHART ENTRY's
 * free-text "Products & Lots" field instead (a real gap between clinical
 * documentation and inventory management — see the addendum's "flag
 * back, not fix" note).
 */
export interface ProductRow {
  /** INFRASTRUCTURE: primary key. */
  id: ProductId;

  // core_content
  productName: string;
  description?: string;
  brand?: string;
  photoUrl?: string;

  // metadata
  skuOrUpc?: string;
  /** Only products whose category is "retail" appear at checkout. */
  category: ProductCategory;
  sellableAsRetail: boolean;
  usableInService: boolean;
  retailPrice?: number;
  /** Depletes first-in-first-out; see PRODUCT USAGE for what's actually consumed. */
  defaultUnitCost: number;
  taxable: boolean;
  supplier?: string;
  sizeOrColor?: string;
  quantityOnHand: number;
  reorderPoint: number;
  /** Per the docs: off by default when a product is created. */
  activeAtLocation: boolean;

  // relationships
  businessId: BusinessId;

  // Reverse/join, not stored here:
  //   - has 0-many PRODUCT USAGE RULE (configured for services) -> ProductUsageRule.productId
  //   - has 0-many PRODUCT USAGE (consumed in appointments)      -> ProductUsage.productId
  //   - has 0-many PRODUCT CREDIT (pre-sold as units)            -> ProductCredit.productId
  //   - has 0-many CHART ENTRY (recording lot & dose)            -> join table chart_entry_products
  //   - has 0-many SIGNAL (it generated)                          -> Signal.productId
  //   - has 0-many CAMPAIGN (promoting it)                        -> Campaign.productId
  //   - has 0-many ORDER LINE ITEM (sold as)                      -> OrderLineItem.productId
}
