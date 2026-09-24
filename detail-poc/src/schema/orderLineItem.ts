import type { AppointmentId, OrderId, OrderLineItemId, ProductId, ServiceId } from "../ids.js";

/**
 * ORDER LINE ITEM — the map's own junction example, and here it's a
 * discriminated union per the addendum's explicit instruction: "Kind is
 * one of service / retail product / prepaid units / fee, and exactly one
 * of the corresponding optional foreign keys is set. Don't model it as
 * five nullable columns and hope; enforce the discriminant." TypeScript's
 * discriminated union does exactly that — a `kind: "service"` line item
 * literally cannot carry a `productId` at the type level, and vice versa.
 *
 * `unitPriceAtSale` is a snapshot, not a live lookup — if a service's
 * price changes next month, past orders must not move.
 * Source: data/ADDENDUM_01.md, Part 2.
 *
 * Note: PRODUCT USAGE and PRODUCT CREDIT each declare "has 0-1 ORDER LINE
 * ITEM" (billed as / bought as) and own that FK themselves
 * (productUsage.orderLineItemId, productCredit.orderLineItemId) — this
 * row does NOT duplicate the pointer back; resolve it by reverse lookup.
 */
interface OrderLineItemBase {
  /** INFRASTRUCTURE: primary key. */
  id: OrderLineItemId;

  // core_content
  lineLabel: string;

  // metadata
  quantity: number;
  /** Snapshot at time of sale — never a live lookup. */
  unitPriceAtSale: number;
  lineDiscount: number;
  lineTotal: number;
  /** Commission is calculated on the total *after* product usage is folded in. */
  commissionBasis: string;

  // relationships
  orderId: OrderId;
  appointmentId?: AppointmentId;
}

export type OrderLineItemRow =
  | (OrderLineItemBase & { kind: "service"; serviceId: ServiceId })
  | (OrderLineItemBase & { kind: "retail_product"; productId: ProductId })
  | (OrderLineItemBase & { kind: "prepaid_units"; productId: ProductId })
  | (OrderLineItemBase & { kind: "fee"; feeDescription: string });
