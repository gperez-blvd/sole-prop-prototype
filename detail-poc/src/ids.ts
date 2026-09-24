/**
 * Branded ID types, one per table, so a ClientId can never be silently passed
 * where an AppointmentId is expected — this is the "cardinality enforced at
 * the type level where possible" requirement biting at the ID layer.
 *
 * INFRASTRUCTURE: `id` fields are not present in object-map.json (which
 * describes attributes, not storage keys). Every table needs one to exist
 * as a row at all, so we add it here and call it out as infrastructure
 * rather than a modeled attribute.
 */

let counter = 0;

/** Deterministic, sortable id generator (not a real UUID — fine for a POC). */
function nextId(prefix: string): string {
  counter += 1;
  return `${prefix}_${counter.toString(36).padStart(6, "0")}`;
}

export type Brand<T, B extends string> = T & { readonly __brand: B };

export type OperatorId = Brand<string, "OperatorId">;
export type BusinessId = Brand<string, "BusinessId">;
export type DetailId = Brand<string, "DetailId">;
export type PersonaId = Brand<string, "PersonaId">;
export type PatternId = Brand<string, "PatternId">;
export type ThresholdId = Brand<string, "ThresholdId">;
export type SignalId = Brand<string, "SignalId">;
export type CueDecisionId = Brand<string, "CueDecisionId">;
export type CueId = Brand<string, "CueId">;
export type DayId = Brand<string, "DayId">;
export type BriefingId = Brand<string, "BriefingId">;
export type ActionId = Brand<string, "ActionId">;
export type ProposalId = Brand<string, "ProposalId">;
export type CapabilityId = Brand<string, "CapabilityId">;
export type ClientId = Brand<string, "ClientId">;
export type ChartId = Brand<string, "ChartId">;
export type ChartEntryId = Brand<string, "ChartEntryId">;
export type FormId = Brand<string, "FormId">;
export type AppointmentId = Brand<string, "AppointmentId">;
export type ServiceId = Brand<string, "ServiceId">;
export type OpeningId = Brand<string, "OpeningId">;
export type WaitlistRequestId = Brand<string, "WaitlistRequestId">;
export type MessageId = Brand<string, "MessageId">;
export type CampaignId = Brand<string, "CampaignId">;
export type SegmentId = Brand<string, "SegmentId">;
export type ReviewId = Brand<string, "ReviewId">;
export type ProductId = Brand<string, "ProductId">;
export type ProductUsageRuleId = Brand<string, "ProductUsageRuleId">;
export type ProductUsageId = Brand<string, "ProductUsageId">;
export type ProductCreditId = Brand<string, "ProductCreditId">;
export type OrderId = Brand<string, "OrderId">;
export type OrderLineItemId = Brand<string, "OrderLineItemId">;
export type PaymentId = Brand<string, "PaymentId">;
export type PayoutId = Brand<string, "PayoutId">;

export const makeId = {
  operator: () => nextId("operator") as OperatorId,
  business: () => nextId("business") as BusinessId,
  detail: () => nextId("detail") as DetailId,
  persona: () => nextId("persona") as PersonaId,
  pattern: () => nextId("pattern") as PatternId,
  threshold: () => nextId("threshold") as ThresholdId,
  signal: () => nextId("signal") as SignalId,
  cueDecision: () => nextId("cue_decision") as CueDecisionId,
  cue: () => nextId("cue") as CueId,
  day: () => nextId("day") as DayId,
  briefing: () => nextId("briefing") as BriefingId,
  action: () => nextId("action") as ActionId,
  proposal: () => nextId("proposal") as ProposalId,
  capability: () => nextId("capability") as CapabilityId,
  client: () => nextId("client") as ClientId,
  chart: () => nextId("chart") as ChartId,
  chartEntry: () => nextId("chart_entry") as ChartEntryId,
  form: () => nextId("form") as FormId,
  appointment: () => nextId("appointment") as AppointmentId,
  service: () => nextId("service") as ServiceId,
  opening: () => nextId("opening") as OpeningId,
  waitlistRequest: () => nextId("waitlist_request") as WaitlistRequestId,
  message: () => nextId("message") as MessageId,
  campaign: () => nextId("campaign") as CampaignId,
  segment: () => nextId("segment") as SegmentId,
  review: () => nextId("review") as ReviewId,
  product: () => nextId("product") as ProductId,
  productUsageRule: () => nextId("product_usage_rule") as ProductUsageRuleId,
  productUsage: () => nextId("product_usage") as ProductUsageId,
  productCredit: () => nextId("product_credit") as ProductCreditId,
  order: () => nextId("order") as OrderId,
  orderLineItem: () => nextId("order_line_item") as OrderLineItemId,
  payment: () => nextId("payment") as PaymentId,
  payout: () => nextId("payout") as PayoutId,
};

/** Reset the id counter. Used only so test files get stable, readable ids. */
export function resetIdCounterForTests(): void {
  counter = 0;
}
