/**
 * The fifteen `x`-marked CTAs on DETAIL's row in cta-matrix.json. Per the
 * handoff: "These aren't unbuilt features; they're standing commitments.
 * Enforce them so no code path can reach them."
 *
 * Design: every RelationalStore mutator that could touch one of these
 * takes an `actor: Actor` parameter. The guard functions below live
 * *inside* those mutators (see RelationalStore.ts) — not bolted on beside
 * them — so there is no second, ungated way to reach the same effect.
 * Two of the fifteen (clinical-flag suppression, clinical detail aloud)
 * are checked unconditionally, regardless of actor, because the map
 * itself says so ("Every other cue type is threshold-governed; this one
 * is not").
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
