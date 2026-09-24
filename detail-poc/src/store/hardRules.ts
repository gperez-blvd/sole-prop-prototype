/**
 * The thirty-three `x`-marked CTAs on DETAIL's row in cta-matrix.json —
 * fifteen from the original handoff, eighteen more from ADDENDUM_01.md
 * (products and checkout). Per the handoff: "These aren't unbuilt
 * features; they're standing commitments. Enforce them so no code path
 * can reach them."
 *
 * Design: every RelationalStore mutator that could touch one of these
 * takes an `actor: Actor` parameter. The guard functions below live
 * *inside* those mutators (see RelationalStore.ts) — not bolted on beside
 * them — so there is no second, ungated way to reach the same effect.
 * Three rules (clinical-flag suppression, clinical detail aloud, and the
 * unit-count disclosure added in the addendum) are checked unconditionally
 * or structurally, regardless of actor, because the map itself says so
 * ("Every other cue type is threshold-governed; this one is not") or
 * because the schema simply gives client-facing tables no field to leak
 * unit counts into in the first place.
 */
import type { CueRow } from "../schema/index.js";

export type Actor = "operator" | "detail" | "client";

export class HardRuleViolationError extends Error {
  constructor(public readonly ruleId: string, detail: string) {
    super(`Hard rule "${ruleId}" violated: ${detail}`);
    this.name = "HardRuleViolationError";
  }
}

export interface HardRule {
  id: string;
  ctaObject: string;
  cta: string;
  description: string;
}

/** The canonical list, for the hand-back report and for the test file to iterate. */
export const HARD_RULES: HardRule[] = [
  { id: "no_charge_appointment", ctaObject: "APPOINTMENT", cta: "Charge", description: "DETAIL cannot charge an appointment." },
  { id: "no_charge_client_fee", ctaObject: "CLIENT", cta: "Charge a fee", description: "DETAIL cannot charge a client a fee." },
  { id: "no_offer_discount", ctaObject: "CLIENT", cta: "Offer a discount", description: "DETAIL cannot offer a client a discount." },
  { id: "no_change_service_price", ctaObject: "SERVICE", cta: "Change price", description: "DETAIL cannot write SERVICE.Price." },
  { id: "no_discount_campaign_to_fill_gap", ctaObject: "CAMPAIGN", cta: "Discount to fill a gap", description: "DETAIL cannot discount a campaign to fill a gap." },
  { id: "no_send_campaign_without_consent", ctaObject: "CAMPAIGN", cta: "Send without consent", description: "DETAIL cannot send a campaign to a client lacking marketing consent for that channel." },
  { id: "no_change_own_voice", ctaObject: "DETAIL", cta: "Change my own voice", description: "DETAIL cannot change its own voice." },
  { id: "no_expand_own_autonomy", ctaObject: "DETAIL", cta: "Expand my own autonomy", description: "DETAIL cannot expand its own autonomy." },
  { id: "no_cancel_appointment", ctaObject: "APPOINTMENT", cta: "Cancel", description: "DETAIL cannot cancel an appointment." },
  { id: "no_suppress_clinical_flag", ctaObject: "CUE", cta: "Suppress a clinical flag", description: "A clinical-override cue cannot be suppressed, deferred, or expired by anyone." },
  { id: "no_read_clinical_detail_aloud", ctaObject: "CHART", cta: "Read clinical detail aloud", description: "A clinical cue's spoken text can never carry its on-screen clinical detail." },
  { id: "no_disclose_chart_to_third_party", ctaObject: "CHART", cta: "Disclose to a third party", description: "DETAIL cannot disclose a chart to a third party." },
  { id: "no_sign_chart_entry_on_her_behalf", ctaObject: "CHART ENTRY", cta: "Sign on her behalf", description: "DETAIL cannot sign a chart entry on the operator's behalf." },
  { id: "no_waive_required_form", ctaObject: "FORM", cta: "Waive a required form", description: "DETAIL cannot waive a required form." },
  { id: "no_answer_form_for_client", ctaObject: "FORM", cta: "Answer for the client", description: "DETAIL cannot answer a form on the client's behalf." },

  // --- ADDENDUM_01.md: products and checkout (18 more) ---
  { id: "no_change_retail_price", ctaObject: "PRODUCT", cta: "Change retail price", description: "DETAIL cannot write PRODUCT.Retail Price." },
  { id: "no_place_purchase_order", ctaObject: "PRODUCT", cta: "Place a purchase order", description: "DETAIL cannot place a purchase order." },
  { id: "no_change_price_per_item", ctaObject: "PRODUCT USAGE RULE", cta: "Change price per item", description: "DETAIL cannot write PRODUCT USAGE RULE.Price Per Item — pricing is hers." },
  { id: "no_charge_for_units", ctaObject: "PRODUCT USAGE", cta: "Charge for units", description: "DETAIL cannot charge for product units used." },
  { id: "no_disclose_unit_counts", ctaObject: "PRODUCT USAGE", cta: "Disclose unit counts to the client", description: "DETAIL cannot disclose unit counts to the client — she sees the total charged, never the units used." },
  { id: "no_redeem_credit_without_asking", ctaObject: "PRODUCT CREDIT", cta: "Redeem without asking", description: "DETAIL cannot redeem prepaid units without asking first." },
  { id: "no_sell_prepaid_units", ctaObject: "PRODUCT CREDIT", cta: "Sell prepaid units", description: "DETAIL cannot sell prepaid units." },
  { id: "no_take_payment_order", ctaObject: "ORDER", cta: "Take a payment", description: "DETAIL cannot take a payment against an order." },
  { id: "no_apply_discount_order", ctaObject: "ORDER", cta: "Apply a discount", description: "DETAIL cannot apply a discount to an order." },
  { id: "no_close_order", ctaObject: "ORDER", cta: "Close it", description: "DETAIL cannot close an order." },
  { id: "no_void_or_refund_order", ctaObject: "ORDER", cta: "Void or refund", description: "DETAIL cannot void or refund an order." },
  { id: "no_adjust_price_line_item", ctaObject: "ORDER LINE ITEM", cta: "Adjust price", description: "DETAIL cannot adjust an order line item's price." },
  { id: "no_discount_line_item", ctaObject: "ORDER LINE ITEM", cta: "Discount", description: "DETAIL cannot discount an order line item." },
  { id: "no_take_payment", ctaObject: "PAYMENT", cta: "Take a payment", description: "DETAIL cannot take a payment." },
  { id: "no_retry_payment", ctaObject: "PAYMENT", cta: "Retry a payment", description: "DETAIL cannot retry a payment." },
  { id: "no_refund_payment", ctaObject: "PAYMENT", cta: "Refund", description: "DETAIL cannot refund a payment." },
  { id: "no_change_payout_destination", ctaObject: "PAYOUT", cta: "Change the destination", description: "DETAIL cannot change the payout destination." },
  { id: "no_initiate_payout", ctaObject: "PAYOUT", cta: "Initiate", description: "DETAIL cannot initiate a payout." },
];

function assertActorIsNotDetail(ruleId: string, description: string, actor: Actor): void {
  if (actor === "detail") {
    throw new HardRuleViolationError(ruleId, description);
  }
}

export function assertCanChargeAppointment(actor: Actor): void {
  assertActorIsNotDetail("no_charge_appointment", "attempted to charge an appointment as DETAIL", actor);
}

export function assertCanChargeClientFee(actor: Actor): void {
  assertActorIsNotDetail("no_charge_client_fee", "attempted to charge a client fee as DETAIL", actor);
}

export function assertCanOfferDiscount(actor: Actor): void {
  assertActorIsNotDetail("no_offer_discount", "attempted to offer a discount as DETAIL", actor);
}

export function assertCanSetServicePrice(actor: Actor): void {
  assertActorIsNotDetail("no_change_service_price", "attempted to write SERVICE.Price as DETAIL", actor);
}

export function assertCanDiscountCampaignToFillGap(actor: Actor): void {
  assertActorIsNotDetail(
    "no_discount_campaign_to_fill_gap",
    "attempted to discount a campaign to fill a gap as DETAIL",
    actor,
  );
}

/**
 * Consent is checked regardless of actor (a discount campaign sent by the
 * operator to an unconsented client would be just as wrong), but the rule
 * as written is scoped to DETAIL's own sends — see hardRules.test.ts.
 */
export function assertConsentForCampaignSend(actor: Actor, consentGranted: boolean): void {
  if (actor === "detail" && !consentGranted) {
    throw new HardRuleViolationError(
      "no_send_campaign_without_consent",
      "DETAIL attempted to send a campaign to a client without marketing consent for that channel",
    );
  }
}

export function assertCanChangeOwnVoice(actor: Actor): void {
  assertActorIsNotDetail("no_change_own_voice", "DETAIL attempted to change its own voice", actor);
}

export function assertCanExpandOwnAutonomy(actor: Actor): void {
  assertActorIsNotDetail("no_expand_own_autonomy", "DETAIL attempted to expand its own autonomy", actor);
}

export function assertCanCancelAppointment(actor: Actor): void {
  assertActorIsNotDetail("no_cancel_appointment", "DETAIL attempted to cancel an appointment", actor);
}

export function assertCanShareChartWithThirdParty(actor: Actor): void {
  assertActorIsNotDetail("no_disclose_chart_to_third_party", "DETAIL attempted to disclose a chart to a third party", actor);
}

export function assertCanSignChartEntry(actor: Actor): void {
  assertActorIsNotDetail("no_sign_chart_entry_on_her_behalf", "DETAIL attempted to sign a chart entry on the operator's behalf", actor);
}

export function assertCanWaiveForm(actor: Actor): void {
  assertActorIsNotDetail("no_waive_required_form", "DETAIL attempted to waive a required form", actor);
}

export function assertCanAnswerFormForClient(actor: Actor): void {
  assertActorIsNotDetail("no_answer_form_for_client", "DETAIL attempted to answer a form for the client", actor);
}

// --- ADDENDUM_01.md: products and checkout ---

export function assertCanChangeRetailPrice(actor: Actor): void {
  assertActorIsNotDetail("no_change_retail_price", "DETAIL attempted to write PRODUCT.Retail Price", actor);
}

/** No role in the CTA matrix has a legitimate "place a purchase order" CTA yet — always refused. */
export function assertCanPlacePurchaseOrder(actor: Actor): void {
  assertActorIsNotDetail("no_place_purchase_order", "DETAIL attempted to place a purchase order", actor);
}

export function assertCanChangePricePerItem(actor: Actor): void {
  assertActorIsNotDetail("no_change_price_per_item", "DETAIL attempted to write PRODUCT USAGE RULE.Price Per Item", actor);
}

export function assertCanChargeForUnits(actor: Actor): void {
  assertActorIsNotDetail("no_charge_for_units", "DETAIL attempted to charge for product units used", actor);
}

/**
 * Belt-and-suspenders: this is also enforced structurally by the schema
 * itself — ORDER, ORDER LINE ITEM and PAYMENT (the only client-facing
 * checkout surfaces) have no unit-count field at all to leak. Unit counts
 * live only on PRODUCT USAGE and CHART ENTRY, neither of which the client
 * ever sees. This guard exists so the rule is directly testable even
 * without constructing that whole surface.
 */
export function assertCanDiscloseUnitCounts(actor: Actor): void {
  assertActorIsNotDetail(
    "no_disclose_unit_counts",
    "DETAIL attempted to disclose unit counts to the client — she sees the total charged, never the units used",
    actor,
  );
}

export function assertCanRedeemCreditWithoutAsking(actor: Actor): void {
  assertActorIsNotDetail("no_redeem_credit_without_asking", "DETAIL attempted to redeem prepaid units without asking first", actor);
}

export function assertCanSellPrepaidUnits(actor: Actor): void {
  assertActorIsNotDetail("no_sell_prepaid_units", "DETAIL attempted to sell prepaid units", actor);
}

export function assertCanTakePaymentOnOrder(actor: Actor): void {
  assertActorIsNotDetail("no_take_payment_order", "DETAIL attempted to take a payment against an order", actor);
}

export function assertCanApplyOrderDiscount(actor: Actor): void {
  assertActorIsNotDetail("no_apply_discount_order", "DETAIL attempted to apply a discount to an order", actor);
}

export function assertCanCloseOrder(actor: Actor): void {
  assertActorIsNotDetail("no_close_order", "DETAIL attempted to close an order", actor);
}

export function assertCanVoidOrRefundOrder(actor: Actor): void {
  assertActorIsNotDetail("no_void_or_refund_order", "DETAIL attempted to void or refund an order", actor);
}

export function assertCanAdjustLineItemPrice(actor: Actor): void {
  assertActorIsNotDetail("no_adjust_price_line_item", "DETAIL attempted to adjust an order line item's price", actor);
}

export function assertCanDiscountLineItem(actor: Actor): void {
  assertActorIsNotDetail("no_discount_line_item", "DETAIL attempted to discount an order line item", actor);
}

export function assertCanTakePayment(actor: Actor): void {
  assertActorIsNotDetail("no_take_payment", "DETAIL attempted to take a payment", actor);
}

export function assertCanRetryPayment(actor: Actor): void {
  assertActorIsNotDetail("no_retry_payment", "DETAIL attempted to retry a payment", actor);
}

export function assertCanRefundPayment(actor: Actor): void {
  assertActorIsNotDetail("no_refund_payment", "DETAIL attempted to refund a payment", actor);
}

export function assertCanChangePayoutDestination(actor: Actor): void {
  assertActorIsNotDetail("no_change_payout_destination", "DETAIL attempted to change the payout destination", actor);
}

/** No role in the CTA matrix has a legitimate "initiate a payout" CTA yet — payouts are system-scheduled. */
export function assertCanInitiatePayout(actor: Actor): void {
  assertActorIsNotDetail("no_initiate_payout", "DETAIL attempted to initiate a payout", actor);
}

/**
 * Structural, unconditional (no `actor` parameter — it doesn't matter who
 * asked): a clinical-override cue can never be suppressed, deferred, or
 * expired. Called from RelationalStore.updateCueStatus() on every
 * transition attempt, not just at creation.
 */
export function assertCueNotSuppressedIfClinicalOverride(
  cue: CueRow,
  attempted: "suppress" | "defer" | "expire" | "tune_down",
): void {
  if (cue.clinicalOverride) {
    throw new HardRuleViolationError(
      "no_suppress_clinical_flag",
      `attempted to ${attempted} a clinical-override cue (${cue.id}) — clinical cues bypass every speaking-window/quiet-hours threshold and cannot be suppressed, deferred, expired, or tuned down`,
    );
  }
}

const CLINICAL_DETAIL_KEYWORDS = [
  "blood thinner",
  "anticoagulant",
  "pregnan",
  "allerg",
  "contraindicat",
  "lidocaine",
  "medication",
  "aspirin",
];

/**
 * Structural, unconditional: called from RelationalStore.createCue() on
 * every clinical-flag cue, before the row is ever stored. There is no
 * separate "unchecked" constructor path.
 */
export function assertCueSpokenTextIsNonDisclosing(spokenText: string, onScreenDetail: string | undefined): void {
  if (!onScreenDetail) return;
  const lowerSpoken = spokenText.toLowerCase();
  if (spokenText.trim() === onScreenDetail.trim()) {
    throw new HardRuleViolationError(
      "no_read_clinical_detail_aloud",
      "a clinical cue's spokenText must not equal its onScreenDetail",
    );
  }
  for (const keyword of CLINICAL_DETAIL_KEYWORDS) {
    if (lowerSpoken.includes(keyword) && onScreenDetail.toLowerCase().includes(keyword)) {
      throw new HardRuleViolationError(
        "no_read_clinical_detail_aloud",
        `a clinical cue's spokenText leaked a clinical-detail keyword ("${keyword}") that belongs only on-screen`,
      );
    }
  }
}
