import {
  makeId,
  type AppointmentId,
  type BriefingId,
  type BusinessId,
  type CampaignId,
  type CapabilityId,
  type ChartEntryId,
  type ChartId,
  type ClientId,
  type CueDecisionId,
  type CueId,
  type DayId,
  type DetailId,
  type FormId,
  type MessageId,
  type OpeningId,
  type OperatorId,
  type OrderId,
  type OrderLineItemId,
  type PatternId,
  type PaymentId,
  type PayoutId,
  type PersonaId,
  type ProductCreditId,
  type ProductId,
  type ProductUsageId,
  type ProductUsageRuleId,
  type ProposalId,
  type ReviewId,
  type SegmentId,
  type ServiceId,
  type SignalId,
  type ThresholdId,
  type WaitlistRequestId,
} from "../ids.js";
import type {
  ActionRow,
  AppointmentRow,
  AppointmentServiceRow,
  BriefingRow,
  BriefingCarriedProposalRow,
  BriefingCoveredOpeningRow,
  BriefingFlaggedClientRow,
  BriefingNewReviewRow,
  BriefingSummarizedActionRow,
  BusinessRow,
  CampaignRecipientRow,
  CampaignRow,
  CapabilityRow,
  ChartEntryProductRow,
  ChartEntryRow,
  ChartRow,
  ClientRow,
  CueDecisionRow,
  CueDecisionThresholdConsultationRow,
  CueRow,
  DayPatternEvidenceRow,
  DayRow,
  DetailRow,
  FormRow,
  MessageRow,
  OpeningOfferRow,
  OpeningRow,
  OpeningWaitlistMatchRow,
  OperatorQualifiedServiceRow,
  OperatorRow,
  OrderLineItemRow,
  OrderRow,
  PatternRow,
  PaymentRow,
  PayoutRow,
  PersonaRow,
  ProductCreditRow,
  ProductRow,
  ProductUsageRow,
  ProductUsageRuleRow,
  ProposalRow,
  ReviewRow,
  SegmentMemberRow,
  SegmentRow,
  ServiceGoverningThresholdRow,
  ServiceRow,
  SignalRow,
  SignalThresholdEvaluationRow,
  ThresholdRow,
  WaitlistRequestRow,
} from "../schema/index.js";
import { Table } from "./Table.js";
import {
  assertCanAdjustLineItemPrice,
  assertCanAnswerFormForClient,
  assertCanApplyOrderDiscount,
  assertCanCancelAppointment,
  assertCanChangeOwnVoice,
  assertCanChangePayoutDestination,
  assertCanChangePricePerItem,
  assertCanChangeRetailPrice,
  assertCanChargeAppointment,
  assertCanChargeClientFee,
  assertCanChargeForUnits,
  assertCanCloseOrder,
  assertCanDiscloseUnitCounts,
  assertCanDiscountCampaignToFillGap,
  assertCanDiscountLineItem,
  assertCanExpandOwnAutonomy,
  assertCanInitiatePayout,
  assertCanOfferDiscount,
  assertCanPlacePurchaseOrder,
  assertCanRedeemCreditWithoutAsking,
  assertCanRefundPayment,
  assertCanRetryPayment,
  assertCanSellPrepaidUnits,
  assertCanSetServicePrice,
  assertCanShareChartWithThirdParty,
  assertCanSignChartEntry,
  assertCanTakePayment,
  assertCanTakePaymentOnOrder,
  assertCanVoidOrRefundOrder,
  assertCanWaiveForm,
  assertConsentForCampaignSend,
  assertCueNotSuppressedIfClinicalOverride,
  assertCueSpokenTextIsNonDisclosing,
  type Actor,
} from "./hardRules.js";
import { TIGHTENED_CARDINALITIES } from "./relationships.js";

function requireFk<Id extends string>(exists: boolean, table: string, id: Id): void {
  if (!exists) throw new Error(`Referential integrity: ${table} has no row "${id}"`);
}

/**
 * `Omit<Union, K>` does NOT distribute over a discriminated union — it
 * collapses `keyof Union` to the keys common to every branch first, so
 * `Omit<OrderLineItemRow, "id" | "orderId">` silently loses every
 * `kind`-specific field (serviceId, productId, feeDescription...). This
 * distributes Omit over each branch first, preserving the discriminant.
 */
type DistributiveOmit<T, K extends keyof any> = T extends unknown ? Omit<T, K> : never;

export class RelationalStore {
  readonly operators = new Table<OperatorId, OperatorRow>("operator");
  readonly businesses = new Table<BusinessId, BusinessRow>("business");
  readonly details = new Table<DetailId, DetailRow>("detail");
  readonly personas = new Table<PersonaId, PersonaRow>("persona");
  readonly patterns = new Table<PatternId, PatternRow>("pattern");
  readonly thresholds = new Table<ThresholdId, ThresholdRow>("threshold");
  readonly signals = new Table<SignalId, SignalRow>("signal");
  readonly cueDecisions = new Table<CueDecisionId, CueDecisionRow>("cue_decision");
  readonly cues = new Table<CueId, CueRow>("cue");
  readonly days = new Table<DayId, DayRow>("day");
  readonly briefings = new Table<BriefingId, BriefingRow>("briefing");
  readonly actions = new Table<import("../ids.js").ActionId, ActionRow>("action");
  readonly proposals = new Table<ProposalId, ProposalRow>("proposal");
  readonly capabilities = new Table<CapabilityId, CapabilityRow>("capability");
  readonly clients = new Table<ClientId, ClientRow>("client");
  readonly charts = new Table<ChartId, ChartRow>("chart");
  readonly chartEntries = new Table<ChartEntryId, ChartEntryRow>("chart_entry");
  readonly forms = new Table<FormId, FormRow>("form");
  readonly appointments = new Table<AppointmentId, AppointmentRow>("appointment");
  readonly services = new Table<ServiceId, ServiceRow>("service");
  readonly openings = new Table<OpeningId, OpeningRow>("opening");
  readonly waitlistRequests = new Table<WaitlistRequestId, WaitlistRequestRow>("waitlist_request");
  readonly messages = new Table<MessageId, MessageRow>("message");
  readonly campaigns = new Table<CampaignId, CampaignRow>("campaign");
  readonly segments = new Table<SegmentId, SegmentRow>("segment");
  readonly reviews = new Table<ReviewId, ReviewRow>("review");
  // Added in ADDENDUM_01.md (products and checkout):
  readonly products = new Table<ProductId, ProductRow>("product");
  readonly productUsageRules = new Table<ProductUsageRuleId, ProductUsageRuleRow>("product_usage_rule");
  readonly productUsages = new Table<ProductUsageId, ProductUsageRow>("product_usage");
  readonly productCredits = new Table<ProductCreditId, ProductCreditRow>("product_credit");
  readonly orders = new Table<OrderId, OrderRow>("order");
  readonly orderLineItems = new Table<OrderLineItemId, OrderLineItemRow>("order_line_item");
  readonly payments = new Table<PaymentId, PaymentRow>("payment");
  readonly payouts = new Table<PayoutId, PayoutRow>("payout");

  // Join tables — plain arrays; composite-keyed, so a Table<> (single id) doesn't fit.
  readonly operatorQualifiedServices: OperatorQualifiedServiceRow[] = [];
  readonly appointmentServices: AppointmentServiceRow[] = [];
  readonly dayPatternEvidence: DayPatternEvidenceRow[] = [];
  readonly briefingPatternAnnouncements: import("../schema/index.js").BriefingPatternAnnouncementRow[] = [];
  readonly signalThresholdEvaluations: SignalThresholdEvaluationRow[] = [];
  readonly cueDecisionThresholdConsultations: CueDecisionThresholdConsultationRow[] = [];
  readonly capabilityDependencies: import("../schema/index.js").CapabilityDependencyRow[] = [];
  readonly segmentMembers: SegmentMemberRow[] = [];
  readonly campaignRecipients: CampaignRecipientRow[] = [];
  readonly openingOffers: OpeningOfferRow[] = [];
  readonly openingWaitlistMatches: OpeningWaitlistMatchRow[] = [];
  readonly briefingFlaggedClients: BriefingFlaggedClientRow[] = [];
  readonly briefingCoveredOpenings: BriefingCoveredOpeningRow[] = [];
  readonly briefingCarriedProposals: BriefingCarriedProposalRow[] = [];
  readonly briefingSummarizedActions: BriefingSummarizedActionRow[] = [];
  readonly briefingNewReviews: BriefingNewReviewRow[] = [];
  readonly proposalAffectedClients: import("../schema/index.js").ProposalAffectedClientRow[] = [];
  readonly proposalFulfillsWaitlistRequests: import("../schema/index.js").ProposalFulfillsWaitlistRequestRow[] = [];
  readonly serviceGoverningThresholds: ServiceGoverningThresholdRow[] = [];
  readonly chartEntryProducts: ChartEntryProductRow[] = [];

  // ---------------------------------------------------------------------
  // Creation — each checks the FKs it declares before inserting.
  // ---------------------------------------------------------------------

  createBusiness(data: Omit<BusinessRow, "id">): BusinessRow {
    return this.businesses.insert({ id: makeId.business(), ...data });
  }

  createOperator(data: Omit<OperatorRow, "id">): OperatorRow {
    requireFk(this.businesses.has(data.businessId), "business", data.businessId);
    return this.operators.insert({ id: makeId.operator(), ...data });
  }

  createPersona(data: Omit<PersonaRow, "id">): PersonaRow {
    return this.personas.insert({ id: makeId.persona(), ...data });
  }

  createDetail(data: Omit<DetailRow, "id">): DetailRow {
    requireFk(this.operators.has(data.operatorId), "operator", data.operatorId);
    requireFk(this.personas.has(data.personaId), "persona", data.personaId);
    const existing = this.details.findOne((d) => d.operatorId === data.operatorId);
    if (existing) throw new Error(`DETAIL is 1:1 with OPERATOR — ${data.operatorId} already has one`);
    return this.details.insert({ id: makeId.detail(), ...data });
  }

  createClient(data: Omit<ClientRow, "id">): ClientRow {
    requireFk(this.businesses.has(data.businessId), "business", data.businessId);
    return this.clients.insert({ id: makeId.client(), ...data });
  }

  /** CLIENT "has 1 CHART" — call right after createClient. */
  createChart(clientId: ClientId, data: Omit<ChartRow, "id" | "clientId">): ChartRow {
    requireFk(this.clients.has(clientId), "client", clientId);
    const existing = this.charts.findOne((c) => c.clientId === clientId);
    if (existing) throw new Error(`CLIENT ${clientId} already has a CHART`);
    return this.charts.insert({ id: makeId.chart(), clientId, ...data });
  }

  createService(data: Omit<ServiceRow, "id">): ServiceRow {
    requireFk(this.businesses.has(data.businessId), "business", data.businessId);
    return this.services.insert({ id: makeId.service(), ...data });
  }

  qualifyOperatorForService(operatorId: OperatorId, serviceId: ServiceId): void {
    requireFk(this.operators.has(operatorId), "operator", operatorId);
    requireFk(this.services.has(serviceId), "service", serviceId);
    this.operatorQualifiedServices.push({ operatorId, serviceId });
  }

  createDay(data: Omit<DayRow, "id">): DayRow {
    requireFk(this.operators.has(data.operatorId), "operator", data.operatorId);
    requireFk(this.businesses.has(data.businessId), "business", data.businessId);
    return this.days.insert({ id: makeId.day(), ...data });
  }

  createThreshold(data: Omit<ThresholdRow, "id">): ThresholdRow {
    requireFk(this.details.has(data.detailId), "detail", data.detailId);
    return this.thresholds.insert({ id: makeId.threshold(), ...data });
  }

  /**
   * APPOINTMENT "has 1-many SERVICE" — genuinely many:many, enforced
   * non-empty here (the type alone can't guarantee a runtime array is
   * non-empty).
   */
  createAppointment(data: Omit<AppointmentRow, "id">, serviceIds: ServiceId[]): AppointmentRow {
    if (serviceIds.length === 0) {
      throw new Error("APPOINTMENT has 1-many SERVICE — at least one service is required");
    }
    requireFk(this.clients.has(data.clientId), "client", data.clientId);
    requireFk(this.operators.has(data.operatorId), "operator", data.operatorId);
    requireFk(this.businesses.has(data.businessId), "business", data.businessId);
    requireFk(this.days.has(data.dayId), "day", data.dayId);
    requireFk(this.charts.has(data.chartId), "chart", data.chartId);
    for (const serviceId of serviceIds) requireFk(this.services.has(serviceId), "service", serviceId);
    const row = this.appointments.insert({ id: makeId.appointment(), ...data });
    for (const serviceId of serviceIds) this.appointmentServices.push({ appointmentId: row.id, serviceId });
    return row;
  }

  createForm(data: Omit<FormRow, "id">): FormRow {
    requireFk(this.charts.has(data.chartId), "chart", data.chartId);
    return this.forms.insert({ id: makeId.form(), ...data });
  }

  createChartEntry(data: Omit<ChartEntryRow, "id">): ChartEntryRow {
    requireFk(this.charts.has(data.chartId), "chart", data.chartId);
    requireFk(this.operators.has(data.operatorId), "operator", data.operatorId);
    return this.chartEntries.insert({ id: makeId.chartEntry(), ...data });
  }

  createOpening(data: Omit<OpeningRow, "id">): OpeningRow {
    requireFk(this.businesses.has(data.businessId), "business", data.businessId);
    requireFk(this.days.has(data.dayId), "day", data.dayId);
    return this.openings.insert({ id: makeId.opening(), ...data });
  }

  offerOpeningToClient(openingId: OpeningId, clientId: ClientId): void {
    requireFk(this.openings.has(openingId), "opening", openingId);
    requireFk(this.clients.has(clientId), "client", clientId);
    this.openingOffers.push({ openingId, clientId });
  }

  createWaitlistRequest(data: Omit<WaitlistRequestRow, "id">): WaitlistRequestRow {
    requireFk(this.clients.has(data.clientId), "client", data.clientId);
    requireFk(this.businesses.has(data.businessId), "business", data.businessId);
    return this.waitlistRequests.insert({ id: makeId.waitlistRequest(), ...data });
  }

  createMessage(data: Omit<MessageRow, "id">): MessageRow {
    requireFk(this.businesses.has(data.businessId), "business", data.businessId);
    return this.messages.insert({ id: makeId.message(), ...data });
  }

  createSegment(data: Omit<SegmentRow, "id">): SegmentRow {
    requireFk(this.businesses.has(data.businessId), "business", data.businessId);
    return this.segments.insert({ id: makeId.segment(), ...data });
  }

  addSegmentMember(segmentId: SegmentId, clientId: ClientId): void {
    requireFk(this.segments.has(segmentId), "segment", segmentId);
    requireFk(this.clients.has(clientId), "client", clientId);
    this.segmentMembers.push({ segmentId, clientId });
  }

  createCampaign(data: Omit<CampaignRow, "id">): CampaignRow {
    requireFk(this.businesses.has(data.businessId), "business", data.businessId);
    requireFk(this.segments.has(data.segmentId), "segment", data.segmentId);
    return this.campaigns.insert({ id: makeId.campaign(), ...data });
  }

  createReview(data: Omit<ReviewRow, "id">): ReviewRow {
    requireFk(this.businesses.has(data.businessId), "business", data.businessId);
    requireFk(this.days.has(data.dayId), "day", data.dayId);
    return this.reviews.insert({ id: makeId.review(), ...data });
  }

  createPattern(data: Omit<PatternRow, "id">): PatternRow {
    requireFk(this.businesses.has(data.businessId), "business", data.businessId);
    requireFk(this.details.has(data.detailId), "detail", data.detailId);
    return this.patterns.insert({ id: makeId.pattern(), ...data });
  }

  /** △ UNRATIFIED — implemented per the handoff ("implement, but flag"). */
  createCapability(data: Omit<CapabilityRow, "id">): CapabilityRow {
    requireFk(this.businesses.has(data.businessId), "business", data.businessId);
    return this.capabilities.insert({ id: makeId.capability(), ...data });
  }

  createProposal(data: Omit<ProposalRow, "id">): ProposalRow {
    requireFk(this.details.has(data.detailId), "detail", data.detailId);
    return this.proposals.insert({ id: makeId.proposal(), ...data });
  }

  /**
   * DAY "has 0-many BRIEFING" is declared but really 0-2 (brief + debrief).
   * See relationships.TIGHTENED_CARDINALITIES.
   */
  createBriefing(data: Omit<BriefingRow, "id">): BriefingRow {
    requireFk(this.days.has(data.dayId), "day", data.dayId);
    requireFk(this.details.has(data.detailId), "detail", data.detailId);
    requireFk(this.operators.has(data.operatorId), "operator", data.operatorId);
    const sameTypeToday = this.briefings.find((b) => b.dayId === data.dayId && b.type === data.type);
    if (sameTypeToday.length > 0) {
      const rule = TIGHTENED_CARDINALITIES.find((t) => t.fromObject === "DAY" && t.toObject === "BRIEFING");
      throw new Error(
        `DAY ${data.dayId} already has a "${data.type}" briefing — ${rule?.note ?? "tightened cardinality"}`,
      );
    }
    return this.briefings.insert({ id: makeId.briefing(), ...data });
  }

  // ---------------------------------------------------------------------
  // Products and checkout — added in ADDENDUM_01.md.
  // ---------------------------------------------------------------------

  createProduct(data: Omit<ProductRow, "id">): ProductRow {
    requireFk(this.businesses.has(data.businessId), "business", data.businessId);
    return this.products.insert({ id: makeId.product(), ...data });
  }

  /** CHART ENTRY "has 0-many PRODUCT (recorded by lot)" — one-directional join. */
  recordProductInChartEntry(chartEntryId: ChartEntryId, productId: ProductId): void {
    requireFk(this.chartEntries.has(chartEntryId), "chart_entry", chartEntryId);
    requireFk(this.products.has(productId), "product", productId);
    this.chartEntryProducts.push({ chartEntryId, productId });
  }

  /** PRODUCT USAGE RULE is itself the SERVICE × PRODUCT junction — no separate join table. */
  createProductUsageRule(data: Omit<ProductUsageRuleRow, "id">): ProductUsageRuleRow {
    requireFk(this.services.has(data.serviceId), "service", data.serviceId);
    requireFk(this.products.has(data.productId), "product", data.productId);
    return this.productUsageRules.insert({ id: makeId.productUsageRule(), ...data });
  }

  createProductUsage(data: Omit<ProductUsageRow, "id">): ProductUsageRow {
    requireFk(this.appointments.has(data.appointmentId), "appointment", data.appointmentId);
    requireFk(this.products.has(data.productId), "product", data.productId);
    return this.productUsages.insert({ id: makeId.productUsage(), ...data });
  }

  createProductCredit(data: Omit<ProductCreditRow, "id">): ProductCreditRow {
    requireFk(this.clients.has(data.clientId), "client", data.clientId);
    requireFk(this.products.has(data.productId), "product", data.productId);
    return this.productCredits.insert({ id: makeId.productCredit(), ...data });
  }

  /**
   * ORDER "has 1-many ORDER LINE ITEM (on it)" — enforced non-empty here,
   * same pattern as APPOINTMENT × SERVICE. Line items are supplied
   * pre-built (their discriminated `kind` decided by the caller) and get
   * their `orderId` stamped on here.
   */
  createOrder(data: Omit<OrderRow, "id">, lineItems: DistributiveOmit<OrderLineItemRow, "id" | "orderId">[]): OrderRow {
    if (lineItems.length === 0) {
      throw new Error("ORDER has 1-many ORDER LINE ITEM — at least one line item is required");
    }
    requireFk(this.businesses.has(data.businessId), "business", data.businessId);
    const order = this.orders.insert({ id: makeId.order(), ...data });
    for (const lineItem of lineItems) {
      this.orderLineItems.insert({ id: makeId.orderLineItem(), orderId: order.id, ...lineItem } as OrderLineItemRow);
    }
    return order;
  }

  createPayment(data: Omit<PaymentRow, "id">): PaymentRow {
    requireFk(this.orders.has(data.orderId), "order", data.orderId);
    return this.payments.insert({ id: makeId.payment(), ...data });
  }

  createPayout(data: Omit<PayoutRow, "id">): PayoutRow {
    requireFk(this.businesses.has(data.businessId), "business", data.businessId);
    return this.payouts.insert({ id: makeId.payout(), ...data });
  }

  // ---------------------------------------------------------------------
  // Signals, cue decisions, cues, actions — the ladder's working set.
  // ---------------------------------------------------------------------

  createSignal(data: Omit<SignalRow, "id">): SignalRow {
    requireFk(this.businesses.has(data.businessId), "business", data.businessId);
    requireFk(this.days.has(data.dayId), "day", data.dayId);
    return this.signals.insert({ id: makeId.signal(), ...data });
  }

  recordThresholdEvaluation(row: SignalThresholdEvaluationRow): void {
    requireFk(this.signals.has(row.signalId), "signal", row.signalId);
    requireFk(this.thresholds.has(row.thresholdId), "threshold", row.thresholdId);
    this.signalThresholdEvaluations.push(row);
  }

  /**
   * CUE DECISION "has 1-many SIGNAL (it resolved)" — enforced non-empty
   * here, then written back onto each SIGNAL (the owning FK lives there).
   */
  createCueDecision(
    data: Omit<CueDecisionRow, "id">,
    signalIds: SignalId[],
    consultedThresholdIds: ThresholdId[],
  ): CueDecisionRow {
    if (signalIds.length === 0) {
      throw new Error("CUE DECISION has 1-many SIGNAL — at least one signal is required");
    }
    requireFk(this.details.has(data.detailId), "detail", data.detailId);
    for (const signalId of signalIds) requireFk(this.signals.has(signalId), "signal", signalId);
    const decision = this.cueDecisions.insert({ id: makeId.cueDecision(), ...data });
    for (const signalId of signalIds) {
      this.signals.update(signalId, { cueDecisionId: decision.id });
    }
    for (const thresholdId of consultedThresholdIds) {
      requireFk(this.thresholds.has(thresholdId), "threshold", thresholdId);
      this.cueDecisionThresholdConsultations.push({ cueDecisionId: decision.id, thresholdId });
    }
    return decision;
  }

  /**
   * Structural enforcement of "cannot read clinical detail aloud" — see
   * hardRules.assertCueSpokenTextIsNonDisclosing. Runs on every cue,
   * before it's ever stored.
   */
  createCue(data: Omit<CueRow, "id">): CueRow {
    requireFk(this.details.has(data.detailId), "detail", data.detailId);
    requireFk(this.cueDecisions.has(data.cueDecisionId), "cue_decision", data.cueDecisionId);
    requireFk(this.days.has(data.dayId), "day", data.dayId);
    if (data.type === "clinical_flag" || data.clinicalOverride) {
      assertCueSpokenTextIsNonDisclosing(data.spokenText, data.onScreenDetail);
    }
    return this.cues.insert({ id: makeId.cue(), ...data });
  }

  /**
   * Structural enforcement of "cannot suppress a clinical flag" — checked
   * on every status transition, regardless of caller.
   */
  updateCueStatus(cueId: CueId, status: CueRow["status"]): CueRow {
    const cue = this.cues.getOrThrow(cueId);
    if (status === "expired") {
      assertCueNotSuppressedIfClinicalOverride(cue, "expire");
    }
    return this.cues.update(cueId, { status });
  }

  createAction(data: Omit<ActionRow, "id">): ActionRow {
    requireFk(this.details.has(data.detailId), "detail", data.detailId);
    requireFk(this.days.has(data.dayId), "day", data.dayId);
    return this.actions.insert({ id: makeId.action(), ...data });
  }

  // ---------------------------------------------------------------------
  // Guarded mutators — one per hard rule that touches real state. Each
  // takes `actor` and refuses DETAIL, per hardRules.ts.
  // ---------------------------------------------------------------------

  setAppointmentStatus(id: AppointmentId, status: AppointmentRow["status"], actor: Actor): AppointmentRow {
    if (status === "cancelled") assertCanCancelAppointment(actor);
    return this.appointments.update(id, { status });
  }

  chargeAppointment(id: AppointmentId, actor: Actor): AppointmentRow {
    assertCanChargeAppointment(actor);
    requireFk(this.appointments.has(id), "appointment", id);
    return this.appointments.update(id, { depositTaken: true });
  }

  chargeClientFee(_clientId: ClientId, _amountCents: number, actor: Actor): void {
    assertCanChargeClientFee(actor);
  }

  offerDiscount(_clientId: ClientId, _amountCents: number, actor: Actor): void {
    assertCanOfferDiscount(actor);
  }

  setServicePrice(id: ServiceId, price: number, actor: Actor): ServiceRow {
    assertCanSetServicePrice(actor);
    return this.services.update(id, { price });
  }

  setCampaignOfferToDiscountGap(id: CampaignId, offer: string, actor: Actor): CampaignRow {
    assertCanDiscountCampaignToFillGap(actor);
    return this.campaigns.update(id, { offer });
  }

  /** Writes a campaign_recipients row; refuses DETAIL sends without consent. */
  sendCampaignToClient(campaignId: CampaignId, clientId: ClientId, channel: "sms" | "email", actor: Actor): void {
    requireFk(this.campaigns.has(campaignId), "campaign", campaignId);
    const client = this.clients.getOrThrow(clientId);
    const consentGranted =
      channel === "sms" ? client.marketingConsentSms === "granted" : client.marketingConsentEmail === "granted";
    assertConsentForCampaignSend(actor, consentGranted);
    this.campaignRecipients.push({ campaignId, clientId, channel, consentVerified: consentGranted });
  }

  updateDetailVoice(id: DetailId, sliders: Partial<Pick<DetailRow, "voiceCalmToEnergetic" | "voiceFactsToConversational" | "voiceProfessionalToPlayful" | "voiceHumor">>, actor: Actor): DetailRow {
    assertCanChangeOwnVoice(actor);
    return this.details.update(id, sliders);
  }

  updateDetailAutonomy(id: DetailId, actor: Actor): DetailRow {
    assertCanExpandOwnAutonomy(actor);
    // No autonomy field exists to expand — the guard is the whole point.
    return this.details.getOrThrow(id);
  }

  shareChartWithThirdParty(id: ChartId, actor: Actor): void {
    assertCanShareChartWithThirdParty(actor);
    requireFk(this.charts.has(id), "chart", id);
  }

  signChartEntry(id: ChartEntryId, signedAt: Date, actor: Actor): ChartEntryRow {
    assertCanSignChartEntry(actor);
    return this.chartEntries.update(id, { status: "signed", signedAt });
  }

  waiveForm(id: FormId, actor: Actor): FormRow {
    assertCanWaiveForm(actor);
    return this.forms.update(id, { status: "waived" });
  }

  recordFormResponses(id: FormId, responses: Record<string, string>, actor: Actor): FormRow {
    assertCanAnswerFormForClient(actor);
    return this.forms.update(id, { responses, status: "complete", completedAt: new Date() });
  }

  // --- ADDENDUM_01.md: products and checkout ---

  setProductRetailPrice(id: ProductId, retailPrice: number, actor: Actor): ProductRow {
    assertCanChangeRetailPrice(actor);
    return this.products.update(id, { retailPrice });
  }

  /** No CTA for this exists on any role yet — always refused. */
  placePurchaseOrder(_productId: ProductId, actor: Actor): void {
    assertCanPlacePurchaseOrder(actor);
  }

  setProductUsageRulePricePerItem(id: ProductUsageRuleId, pricePerItem: number, actor: Actor): ProductUsageRuleRow {
    assertCanChangePricePerItem(actor);
    return this.productUsageRules.update(id, { pricePerItem });
  }

  chargeForProductUsage(_productUsageId: ProductUsageId, actor: Actor): void {
    assertCanChargeForUnits(actor);
  }

  /**
   * See hardRules.assertCanDiscloseUnitCounts: also enforced structurally
   * by the schema (no client-facing table carries a unit-count field).
   * This guard makes the rule directly testable.
   */
  discloseUnitCountsToClient(_productUsageId: ProductUsageId, actor: Actor): void {
    assertCanDiscloseUnitCounts(actor);
  }

  redeemProductCredit(id: ProductCreditId, units: number, actor: Actor): ProductCreditRow {
    assertCanRedeemCreditWithoutAsking(actor);
    const credit = this.productCredits.getOrThrow(id);
    return this.productCredits.update(id, { unitsRemaining: credit.unitsRemaining - units });
  }

  sellPrepaidUnits(_clientId: ClientId, _productId: ProductId, actor: Actor): void {
    assertCanSellPrepaidUnits(actor);
  }

  takePaymentOnOrder(id: OrderId, actor: Actor): OrderRow {
    assertCanTakePaymentOnOrder(actor);
    return this.orders.getOrThrow(id);
  }

  applyOrderDiscount(id: OrderId, discount: number, actor: Actor): OrderRow {
    assertCanApplyOrderDiscount(actor);
    return this.orders.update(id, { discounts: discount });
  }

  closeOrder(id: OrderId, closedByOperatorId: OperatorId, actor: Actor): OrderRow {
    assertCanCloseOrder(actor);
    requireFk(this.operators.has(closedByOperatorId), "operator", closedByOperatorId);
    return this.orders.update(id, { status: "closed", closedAt: new Date(), closedByOperatorId });
  }

  voidOrRefundOrder(id: OrderId, status: "voided" | "refunded" | "partially_refunded", actor: Actor): OrderRow {
    assertCanVoidOrRefundOrder(actor);
    return this.orders.update(id, { status });
  }

  adjustOrderLineItemPrice(id: OrderLineItemId, unitPriceAtSale: number, actor: Actor): OrderLineItemRow {
    assertCanAdjustLineItemPrice(actor);
    return this.orderLineItems.update(id, { unitPriceAtSale });
  }

  discountOrderLineItem(id: OrderLineItemId, lineDiscount: number, actor: Actor): OrderLineItemRow {
    assertCanDiscountLineItem(actor);
    return this.orderLineItems.update(id, { lineDiscount });
  }

  takePayment(_orderId: OrderId, actor: Actor): void {
    assertCanTakePayment(actor);
  }

  retryPayment(id: PaymentId, actor: Actor): PaymentRow {
    assertCanRetryPayment(actor);
    return this.payments.update(id, { status: "succeeded" });
  }

  refundPayment(id: PaymentId, actor: Actor): PaymentRow {
    assertCanRefundPayment(actor);
    return this.payments.update(id, { status: "refunded" });
  }

  changePayoutDestination(id: PayoutId, destination: string, actor: Actor): PayoutRow {
    assertCanChangePayoutDestination(actor);
    return this.payouts.update(id, { destination });
  }

  /** No CTA for this exists on any role yet — payouts are system-scheduled. Always refused. */
  initiatePayout(_businessId: BusinessId, actor: Actor): void {
    assertCanInitiatePayout(actor);
  }

  // ---------------------------------------------------------------------
  // Derived rollups — computed, never stored, per the handoff's
  // "Derived vs. stored" note.
  // ---------------------------------------------------------------------

  dayStats(dayId: DayId) {
    const appointments = this.appointments.find((a) => a.dayId === dayId);
    const signals = this.signals.find((s) => s.dayId === dayId);
    const cues = this.cues.find((c) => c.dayId === dayId);
    const actions = this.actions.find((a) => a.dayId === dayId);
    // ADDENDUM_01.md: "Collected — derived from closed ORDERS." Not from
    // appointment price/deposit anymore — an order can discount, tax, tip,
    // or partially refund, none of which the appointment row knows about.
    const collectedCents = this.orders
      .find((o) => o.dayId === dayId && o.status === "closed")
      .reduce((sum, o) => sum + o.total, 0);
    const unclosedOrders = this.orders.find((o) => o.dayId === dayId && o.status === "open").length;
    return {
      appointmentCount: appointments.length,
      clientsSeen: new Set(appointments.filter((a) => a.status === "completed").map((a) => a.clientId)).size,
      collected: collectedCents,
      unclosedOrders,
      rebookedInRoom: 0,
      utilization:
        appointments.length === 0
          ? 0
          : appointments.reduce((sum, a) => sum + a.durationMinutes, 0) / (9 * 60),
      cuesSpoken: cues.filter((c) => c.status === "delivered" || c.status === "acknowledged").length,
      signalsProcessed: signals.filter((s) => s.disposition !== undefined).length,
      actionsTakenWithoutHer: actions.filter((a) => a.visibleToOperator === "audit_only").length,
    };
  }

  chartStats(chartId: ChartId) {
    const entries = this.chartEntries.find((e) => e.chartId === chartId);
    const forms = this.forms.find((f) => f.chartId === chartId);
    return {
      entryCount: entries.length,
      openFlags: forms.reduce((sum, f) => sum + f.flagsRaised.length, 0),
    };
  }

  appointmentReadiness(appointmentId: AppointmentId): "ready" | "forms_outstanding" | "consent_expired" | "blocked" {
    const forms = this.forms.find((f) => f.appointmentId === appointmentId);
    const now = new Date();
    if (forms.some((f) => f.status === "expired" || (f.expires && f.expires < now))) return "consent_expired";
    if (forms.some((f) => f.status === "not_sent" || f.status === "sent" || f.status === "overdue")) {
      return "forms_outstanding";
    }
    return "ready";
  }

  segmentReach(segmentId: SegmentId): { size: number; reachableSms: number; reachableEmail: number } {
    const memberIds = this.segmentMembers.filter((m) => m.segmentId === segmentId).map((m) => m.clientId);
    const members = memberIds.map((id) => this.clients.getOrThrow(id));
    return {
      size: members.length,
      reachableSms: members.filter((c) => c.marketingConsentSms === "granted").length,
      reachableEmail: members.filter((c) => c.marketingConsentEmail === "granted").length,
    };
  }

  campaignReach(campaignId: CampaignId): { audienceSize: number; reachableSize: number } {
    const campaign = this.campaigns.getOrThrow(campaignId);
    const { size } = this.segmentReach(campaign.segmentId);
    const sentConsented = this.campaignRecipients.filter(
      (r) => r.campaignId === campaignId && r.consentVerified,
    ).length;
    return { audienceSize: size, reachableSize: sentConsented };
  }
}
