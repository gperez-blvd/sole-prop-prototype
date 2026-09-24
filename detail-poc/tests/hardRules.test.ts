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
  return { store, business, operator, detail, client, chart, service, day, appointment, chartEntry, form, campaign };
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
