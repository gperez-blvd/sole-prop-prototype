import { test } from "node:test";
import assert from "node:assert/strict";
import { RelationalStore } from "../src/store/RelationalStore.js";
import { HardRuleViolationError } from "../src/store/hardRules.js";

/**
 * One test per `x`-marked DETAIL CTA in cta-matrix.json (15 total). Each
 * asserts the attempt *throws* — per the handoff, these must be
 * unimplementable, not merely unimplemented — via RelationalStore, the
 * only place these mutations can happen.
 */

function minimalStore() {
  const store = new RelationalStore();
  const business = store.createBusiness({
    businessName: "Jazz Aesthetics",
    brandPalette: [],
    brandVoice: "",
    bookingLink: "book.blvd.co/jazz",
    category: "Medical aesthetics",
    address: "Nashville, TN",
    hours: "Tue-Sat",
    starRating: 4.9,
    reviewCount: 1,
    activationStage: "steady",
  });
  const operator = store.createOperator({
    fullName: "Jazz Bennett",
    mobile: "555-0100",
    roles: ["owner", "provider"],
    licensesAndCertifications: [],
    tenureOnBoulevard: "Year 1",
    timezone: "America/Chicago",
    businessId: business.id,
  });
  const persona = store.createPersona({
    personaName: "Fixer",
    description: "",
    sampleCuePhrasing: "",
    defaultTonePositions: [0, 0, 0, 0],
    adoptionRate: 0,
  });
  const detail = store.createDetail({
    operatorId: operator.id,
    personaId: persona.id,
    name: "Fixer",
    voiceCalmToEnergetic: 50,
    voiceFactsToConversational: 50,
    voiceProfessionalToPlayful: 50,
    voiceHumor: 0,
    tenure: "Year 1",
    knowledgeLevel: 50,
    avgCuesPerDay: 5,
    status: "active",
  });
  const client = store.createClient({
    fullName: "Test Client",
    mobile: "555-0111",
    clientSince: new Date(),
    visitCount: 1,
    lifetimeValue: 0,
    noShowCount: 0,
    preferredChannel: "text",
    tags: [],
    marketingConsentSms: "denied",
    marketingConsentEmail: "denied",
    businessId: business.id,
  });
  const chart = store.createChart(client.id, {
    medicalHistory: "",
    allergies: "",
    medications: "",
    contraindicationNotes: "",
    baselinePhotoUrls: [],
    status: "current",
    retentionUntil: "per state rule",
    containsPhi: true,
  });
  const service = store.createService({
    serviceName: "Facial",
    description: "",
    durationMinutes: 60,
    price: 18000,
    priceModel: "flat",
    category: "facial",
    requiresConsentForm: false,
    discountable: true,
    businessId: business.id,
  });
  const day = store.createDay({
    date: new Date(),
    dayLabel: "Today",
    weekday: "Tuesday",
    status: "in_progress",
    weather: "clear",
    operatorId: operator.id,
    businessId: business.id,
  });
  const appointment = store.createAppointment(
    {
      confirmationNumber: "BLVD-0001",
      startTime: new Date(),
      durationMinutes: 60,
      status: "booked",
      price: 18000,
      depositTaken: false,
      roomOrDevice: "Suite 1",
      clientId: client.id,
      operatorId: operator.id,
      businessId: business.id,
      dayId: day.id,
      chartId: chart.id,
    },
    [service.id],
  );
  const chartEntry = store.createChartEntry({
    whatWasDone: "",
    observations: "",
    photoUrls: [],
    productsAndLots: "",
    type: "consult_note",
    authoredAt: new Date(),
    status: "draft",
    authoredBy: "operator",
    chartId: chart.id,
    operatorId: operator.id,
  });
  const form = store.createForm({
    formName: "Intake",
    responses: {},
    type: "intake",
    status: "sent",
    templateAndVersion: "v1",
    flagsRaised: [],
    requiredFor: "this_appointment",
    source: "client_completed",
    chartId: chart.id,
  });
  const segment = store.createSegment({
    segmentName: "All clients",
    definition: "everyone",
    createdBy: "operator",
    autoUpdating: false,
    businessId: business.id,
  });
  const campaign = store.createCampaign({
    campaignName: "Test campaign",
    bodyCopy: "hi",
    type: "promotion",
    channel: "sms",
    status: "draft",
    authoredBy: "operator",
    businessId: business.id,
    segmentId: segment.id,
  });

  // --- ADDENDUM_01.md fixtures ---
  const product = store.createProduct({
    productName: "Test vial",
    category: "back_bar",
    sellableAsRetail: false,
    usableInService: true,
    defaultUnitCost: 400,
    taxable: false,
    quantityOnHand: 5,
    reorderPoint: 2,
    activeAtLocation: true,
    businessId: business.id,
  });
  const productUsageRule = store.createProductUsageRule({
    ruleLabel: "Test service -> test vial",
    pricePerItem: 1300,
    defaultQuantity: 20,
    active: true,
    serviceId: service.id,
    productId: product.id,
  });
  const productUsage = store.createProductUsage({
    usageRecordDisplayId: "BLVD-PU-0001",
    quantityExpected: 20,
    quantityUsed: 20,
    pricePerItemApplied: 1300,
    amountCharged: 26000,
    prepaidUnitsRedeemed: 0,
    recordedAt: new Date(),
    appointmentId: appointment.id,
    productId: product.id,
  });
  const productCredit = store.createProductCredit({
    creditLabel: "Test prepaid units",
    unitsPurchased: 10,
    unitsRemaining: 10,
    purchasedAt: new Date(),
    amountPaid: 10000,
    status: "active",
    clientId: client.id,
    productId: product.id,
  });
  const order = store.createOrder(
    {
      orderNumber: "BLVD-O-0001",
      status: "open",
      subtotal: 18000,
      discounts: 0,
      tax: 0,
      gratuity: 0,
      total: 18000,
      openedAt: new Date(),
      businessId: business.id,
      clientId: client.id,
      appointmentId: appointment.id,
      dayId: day.id,
    },
    [
      {
        kind: "service",
        lineLabel: "Test service",
        quantity: 1,
        unitPriceAtSale: 18000,
        lineDiscount: 0,
        lineTotal: 18000,
        commissionBasis: "n/a",
        serviceId: service.id,
      },
    ],
  );
  const lineItem = store.orderLineItems.findOne((li) => li.orderId === order.id)!;
  const payment = store.createPayment({
    paymentReference: "ch_test",
    method: "card",
    amount: 18000,
    status: "pending",
    processedAt: new Date(),
    orderId: order.id,
    clientId: client.id,
  });
  const payout = store.createPayout({
    payoutReference: "po_test",
    amount: 100000,
    initiatedAt: new Date(),
    expectedArrival: "Thursday",
    destination: "bank •••• 0000",
    status: "initiated",
    paymentCount: 1,
    businessId: business.id,
  });

  return {
    store, business, operator, detail, client, chart, service, day, appointment, chartEntry, form, campaign,
    product, productUsageRule, productUsage, productCredit, order, lineItem, payment, payout,
  };
}

test("no_charge_appointment: DETAIL cannot charge an appointment", () => {
  const { store, appointment } = minimalStore();
  assert.throws(() => store.chargeAppointment(appointment.id, "detail"), HardRuleViolationError);
  // Sanity: the operator *can*.
  assert.doesNotThrow(() => store.chargeAppointment(appointment.id, "operator"));
});

test("no_charge_client_fee: DETAIL cannot charge a client a fee", () => {
  const { store, client } = minimalStore();
  assert.throws(() => store.chargeClientFee(client.id, 1000, "detail"), HardRuleViolationError);
});

test("no_offer_discount: DETAIL cannot offer a client a discount", () => {
  const { store, client } = minimalStore();
  assert.throws(() => store.offerDiscount(client.id, 500, "detail"), HardRuleViolationError);
});

test("no_change_service_price: DETAIL cannot write SERVICE.Price", () => {
  const { store, service } = minimalStore();
  assert.throws(() => store.setServicePrice(service.id, 1, "detail"), HardRuleViolationError);
  assert.doesNotThrow(() => store.setServicePrice(service.id, 20000, "operator"));
});

test("no_discount_campaign_to_fill_gap: DETAIL cannot discount a campaign to fill a gap", () => {
  const { store, campaign } = minimalStore();
  assert.throws(() => store.setCampaignOfferToDiscountGap(campaign.id, "$50 off", "detail"), HardRuleViolationError);
});

test("no_send_campaign_without_consent: DETAIL cannot send to a client lacking consent", () => {
  const { store, campaign, client } = minimalStore();
  // fixture client has marketingConsentSms: "denied"
  assert.throws(
    () => store.sendCampaignToClient(campaign.id, client.id, "sms", "detail"),
    HardRuleViolationError,
  );
});

test("no_change_own_voice: DETAIL cannot change its own voice", () => {
  const { store, detail } = minimalStore();
  assert.throws(
    () => store.updateDetailVoice(detail.id, { voiceHumor: 90 }, "detail"),
    HardRuleViolationError,
  );
  assert.doesNotThrow(() => store.updateDetailVoice(detail.id, { voiceHumor: 90 }, "operator"));
});

test("no_expand_own_autonomy: DETAIL cannot expand its own autonomy", () => {
  const { store, detail } = minimalStore();
  assert.throws(() => store.updateDetailAutonomy(detail.id, "detail"), HardRuleViolationError);
});

test("no_cancel_appointment: DETAIL cannot cancel an appointment", () => {
  const { store, appointment } = minimalStore();
  assert.throws(
    () => store.setAppointmentStatus(appointment.id, "cancelled", "detail"),
    HardRuleViolationError,
  );
  assert.doesNotThrow(() => store.setAppointmentStatus(appointment.id, "cancelled", "operator"));
});

test("no_suppress_clinical_flag: a clinical-override cue cannot be expired by anyone", () => {
  const { store, detail, day } = minimalStore();
  const decision = store.createCueDecision(
    {
      reasoning: "clinical",
      ladderStop: 5,
      outcome: "escalated",
      timingDecision: "speak_now",
      suppressedAlongside: [],
      decidedAt: new Date(),
      detailId: detail.id,
    },
    [
      store.createSignal({
        payload: "chart flag",
        sequence: 1,
        timestamp: new Date(),
        source: "chart",
        domain: "scheduling",
        businessId: store.businesses.list()[0]!.id,
        dayId: day.id,
      }).id,
    ],
    [],
  );
  const cue = store.createCue({
    spokenText: "Check the intake before you start.",
    onScreenDetail: "Client is on an anticoagulant.",
    timestamp: new Date(),
    type: "clinical_flag",
    channel: "in_ear",
    deliveryWindow: "between_clients",
    wordCount: 6,
    requiresDecision: false,
    status: "queued",
    personaVoiceUsed: "Fixer",
    clinicalOverride: true,
    detailId: detail.id,
    cueDecisionId: decision.id,
    dayId: day.id,
  });
  assert.throws(() => store.updateCueStatus(cue.id, "expired"), HardRuleViolationError);
});

test("no_read_clinical_detail_aloud: spoken text cannot carry on-screen clinical detail", () => {
  const { store, detail, day } = minimalStore();
  const signal = store.createSignal({
    payload: "chart flag",
    sequence: 1,
    timestamp: new Date(),
    source: "chart",
    domain: "scheduling",
    businessId: store.businesses.list()[0]!.id,
    dayId: day.id,
  });
  const decision = store.createCueDecision(
    {
      reasoning: "clinical",
      ladderStop: 5,
      outcome: "escalated",
      timingDecision: "speak_now",
      suppressedAlongside: [],
      decidedAt: new Date(),
      detailId: detail.id,
    },
    [signal.id],
    [],
  );
  assert.throws(
    () =>
      store.createCue({
        spokenText: "Client is on a blood thinner, watch for bruising.",
        onScreenDetail: "Client is on a blood thinner (anticoagulant).",
        timestamp: new Date(),
        type: "clinical_flag",
        channel: "in_ear",
        deliveryWindow: "between_clients",
        wordCount: 8,
        requiresDecision: false,
        status: "queued",
        personaVoiceUsed: "Fixer",
        clinicalOverride: true,
        detailId: detail.id,
        cueDecisionId: decision.id,
        dayId: day.id,
      }),
    HardRuleViolationError,
  );
});

test("no_disclose_chart_to_third_party: DETAIL cannot disclose a chart to a third party", () => {
  const { store, chart } = minimalStore();
  assert.throws(() => store.shareChartWithThirdParty(chart.id, "detail"), HardRuleViolationError);
});

test("no_sign_chart_entry_on_her_behalf: DETAIL cannot sign a chart entry", () => {
  const { store, chartEntry } = minimalStore();
  assert.throws(() => store.signChartEntry(chartEntry.id, new Date(), "detail"), HardRuleViolationError);
  assert.doesNotThrow(() => store.signChartEntry(chartEntry.id, new Date(), "operator"));
});

test("no_waive_required_form: DETAIL cannot waive a required form", () => {
  const { store, form } = minimalStore();
  assert.throws(() => store.waiveForm(form.id, "detail"), HardRuleViolationError);
  assert.doesNotThrow(() => store.waiveForm(form.id, "operator"));
});

test("no_answer_form_for_client: DETAIL cannot answer a form on the client's behalf", () => {
  const { store, form } = minimalStore();
  assert.throws(
    () => store.recordFormResponses(form.id, { q1: "yes" }, "detail"),
    HardRuleViolationError,
  );
  assert.doesNotThrow(() => store.recordFormResponses(form.id, { q1: "yes" }, "client"));
});

// --- ADDENDUM_01.md: products and checkout (18 more) ---

test("no_change_retail_price: DETAIL cannot write PRODUCT.Retail Price", () => {
  const { store, product } = minimalStore();
  assert.throws(() => store.setProductRetailPrice(product.id, 1, "detail"), HardRuleViolationError);
  assert.doesNotThrow(() => store.setProductRetailPrice(product.id, 9600, "operator"));
});

test("no_place_purchase_order: DETAIL cannot place a purchase order", () => {
  const { store, product } = minimalStore();
  assert.throws(() => store.placePurchaseOrder(product.id, "detail"), HardRuleViolationError);
});

test("no_change_price_per_item: DETAIL cannot write PRODUCT USAGE RULE.Price Per Item", () => {
  const { store, productUsageRule } = minimalStore();
  assert.throws(
    () => store.setProductUsageRulePricePerItem(productUsageRule.id, 1, "detail"),
    HardRuleViolationError,
  );
  assert.doesNotThrow(() => store.setProductUsageRulePricePerItem(productUsageRule.id, 1400, "operator"));
});

test("no_charge_for_units: DETAIL cannot charge for product units used", () => {
  const { store, productUsage } = minimalStore();
  assert.throws(() => store.chargeForProductUsage(productUsage.id, "detail"), HardRuleViolationError);
});

test("no_disclose_unit_counts: DETAIL cannot disclose unit counts to the client", () => {
  const { store, productUsage } = minimalStore();
  assert.throws(() => store.discloseUnitCountsToClient(productUsage.id, "detail"), HardRuleViolationError);
});

test("no_redeem_credit_without_asking: DETAIL cannot redeem prepaid units without asking", () => {
  const { store, productCredit } = minimalStore();
  assert.throws(
    () => store.redeemProductCredit(productCredit.id, 1, "detail"),
    HardRuleViolationError,
  );
  assert.doesNotThrow(() => store.redeemProductCredit(productCredit.id, 1, "operator"));
});

test("no_sell_prepaid_units: DETAIL cannot sell prepaid units", () => {
  const { store, client, product } = minimalStore();
  assert.throws(() => store.sellPrepaidUnits(client.id, product.id, "detail"), HardRuleViolationError);
  assert.doesNotThrow(() => store.sellPrepaidUnits(client.id, product.id, "operator"));
});

test("no_take_payment_order: DETAIL cannot take a payment against an order", () => {
  const { store, order } = minimalStore();
  assert.throws(() => store.takePaymentOnOrder(order.id, "detail"), HardRuleViolationError);
  assert.doesNotThrow(() => store.takePaymentOnOrder(order.id, "operator"));
});

test("no_apply_discount_order: DETAIL cannot apply a discount to an order", () => {
  const { store, order } = minimalStore();
  assert.throws(() => store.applyOrderDiscount(order.id, 500, "detail"), HardRuleViolationError);
  assert.doesNotThrow(() => store.applyOrderDiscount(order.id, 500, "operator"));
});

test("no_close_order: DETAIL cannot close an order", () => {
  const { store, order, operator } = minimalStore();
  assert.throws(() => store.closeOrder(order.id, operator.id, "detail"), HardRuleViolationError);
  assert.doesNotThrow(() => store.closeOrder(order.id, operator.id, "operator"));
});

test("no_void_or_refund_order: DETAIL cannot void or refund an order", () => {
  const { store, order } = minimalStore();
  assert.throws(() => store.voidOrRefundOrder(order.id, "voided", "detail"), HardRuleViolationError);
  assert.doesNotThrow(() => store.voidOrRefundOrder(order.id, "voided", "operator"));
});

test("no_adjust_price_line_item: DETAIL cannot adjust an order line item's price", () => {
  const { store, lineItem } = minimalStore();
  assert.throws(
    () => store.adjustOrderLineItemPrice(lineItem.id, 100, "detail"),
    HardRuleViolationError,
  );
  assert.doesNotThrow(() => store.adjustOrderLineItemPrice(lineItem.id, 100, "operator"));
});

test("no_discount_line_item: DETAIL cannot discount an order line item", () => {
  const { store, lineItem } = minimalStore();
  assert.throws(() => store.discountOrderLineItem(lineItem.id, 100, "detail"), HardRuleViolationError);
  assert.doesNotThrow(() => store.discountOrderLineItem(lineItem.id, 100, "operator"));
});

test("no_take_payment: DETAIL cannot take a payment", () => {
  const { store, order } = minimalStore();
  assert.throws(() => store.takePayment(order.id, "detail"), HardRuleViolationError);
});

test("no_retry_payment: DETAIL cannot retry a payment", () => {
  const { store, payment } = minimalStore();
  assert.throws(() => store.retryPayment(payment.id, "detail"), HardRuleViolationError);
  assert.doesNotThrow(() => store.retryPayment(payment.id, "operator"));
});

test("no_refund_payment: DETAIL cannot refund a payment", () => {
  const { store, payment } = minimalStore();
  assert.throws(() => store.refundPayment(payment.id, "detail"), HardRuleViolationError);
  assert.doesNotThrow(() => store.refundPayment(payment.id, "operator"));
});

test("no_change_payout_destination: DETAIL cannot change the payout destination", () => {
  const { store, payout } = minimalStore();
  assert.throws(
    () => store.changePayoutDestination(payout.id, "bank •••• 1111", "detail"),
    HardRuleViolationError,
  );
  assert.doesNotThrow(() => store.changePayoutDestination(payout.id, "bank •••• 1111", "operator"));
});

test("no_initiate_payout: DETAIL cannot initiate a payout", () => {
  const { store, business } = minimalStore();
  assert.throws(() => store.initiatePayout(business.id, "detail"), HardRuleViolationError);
});
