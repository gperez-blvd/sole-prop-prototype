import type { AppointmentId, BusinessId, ClientId, DayId, OperatorId, OrderId } from "../ids.js";

export type OrderStatus = "open" | "closed" | "voided" | "refunded" | "partially_refunded";

/**
 * ORDER — the transaction. Opens at check-in, closes on payment.
 * `clientId` is optional because a retail-only walk-in has no client
 * record. `has 1-many ORDER LINE ITEM` is enforced non-empty on write,
 * same pattern as APPOINTMENT × SERVICE.
 * Source: data/ADDENDUM_01.md, Part 2.
 */
export interface OrderRow {
  /** INFRASTRUCTURE: primary key. */
  id: OrderId;

  // core_content
  orderNumber: string;

  // metadata
  status: OrderStatus;
  subtotal: number;
  discounts: number;
  tax: number;
  gratuity: number;
  total: number;
  openedAt: Date;
  closedAt?: Date;

  // relationships
  businessId: BusinessId;
  clientId?: ClientId;
  appointmentId?: AppointmentId;
  /** Owning side of "has 0-1 OPERATOR (who closed it)". */
  closedByOperatorId?: OperatorId;
  dayId?: DayId;

  // "has 1-many ORDER LINE ITEM (on it)" -> OrderLineItem.orderId, enforced
  // non-empty by RelationalStore.createOrder().
  // has 0-many PAYMENT (tendered against it) -> Payment.orderId (reverse)
}
