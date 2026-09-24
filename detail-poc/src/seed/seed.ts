import type {
  AppointmentId,
  BusinessId,
  ChartId,
  ClientId,
  DayId,
  DetailId,
  FormId,
  OperatorId,
  OrderId,
  PayoutId,
  ProductCreditId,
  ProductId,
  ServiceId,
} from "../ids.js";
import { RelationalStore } from "../store/RelationalStore.js";
import { makeRng, pick, randomInt } from "./rng.js";

const FIRST_NAMES = [
  "Dani", "Maya", "Priya", "Tasha", "Lena", "Morgan", "Ava", "Renee", "Kiara", "Jess",
  "Nina", "Sofia", "Bree", "Chloe", "Alyssa", "Tori", "Camille", "Jade", "Zoe", "Harper",
  "Lila", "Nora", "Eve", "Ines", "Rosa", "Mia", "Layla", "Isla", "Ruby", "Elena",
];
const LAST_NAMES = [
  "Reyes", "Okafor", "Sharma", "Ward", "Kim", "Blake", "James", "Cole", "Martinez", "Turner",
  "Nguyen", "Patel", "Diaz", "Foster", "Grant", "Hayes", "Ibarra", "Jansen", "Keller", "Lowe",
];

export interface SeedResult {
  store: RelationalStore;
  businessId: BusinessId;
  operatorId: OperatorId;
  detailId: DetailId;
  dayTueId: DayId;
  dayWedId: DayId;
  services: Record<"neurotoxin" | "lipFiller" | "facial" | "laser" | "peel", ServiceId>;
  clientIds: {
    maya: ClientId;
    priya: ClientId;
    dani: ClientId;
    tasha: ClientId;
    lena: ClientId;
    morgan: ClientId;
    ava: ClientId;
    renee: ClientId;
    others: ClientId[];
  };
  chartIds: Record<string, ChartId>;
  appointmentIds: Record<"morgan" | "ava" | "maya" | "dani" | "tasha" | "lena" | "renee" | "priya", AppointmentId>;
  formIds: { mayaConsent: FormId; daniIntake: FormId };
  products: { vial: ProductId; serum: ProductId };
  productCreditId: ProductCreditId;
  orderIds: {
    morgan: OrderId;
    ava: OrderId;
    maya: OrderId;
    dani: OrderId;
    tasha: OrderId;
    lena: OrderId;
    retail: OrderId;
    prepaid: OrderId;
    fee: OrderId;
  };
  payoutId: PayoutId;
}

function makeClientData(rng: () => number, fullName: string, index: number) {
  const consentPool = ["granted", "granted", "granted", "denied", "withdrawn"] as const;
  return {
    fullName,
    mobile: `(615) 555-${(1000 + index).toString().slice(-4)}`,
    clientSince: new Date(2024 + Math.floor(rng() * 3), Math.floor(rng() * 12), 1 + Math.floor(rng() * 27)),
    visitCount: randomInt(rng, 1, 20),
    lifetimeValue: randomInt(rng, 80, 6000),
    rebookingCadenceDays: randomInt(rng, 30, 120),
    noShowCount: randomInt(rng, 0, 2),
    preferredChannel: pick(rng, ["text", "email", "call"] as const),
    tags: rng() > 0.5 ? ["repeat"] : ["first-time"],
    marketingConsentSms: pick(rng, consentPool),
    marketingConsentEmail: pick(rng, consentPool),
  };
}

export function seed(): SeedResult {
  const rng = makeRng(20260923);
  const store = new RelationalStore();

  const business = store.createBusiness({
    businessName: "Jazz Aesthetics",
    brandPalette: ["#E4E4DE", "#C8AB7C", "#183E43"],
    brandVoice: "warm, direct, a little playful",
    bookingLink: "book.blvd.co/jazz",
    category: "Medical aesthetics",
    address: "Suite 204 · Nashville, TN",
    hours: "Tue–Sat · 9 to 6",
    starRating: 4.9,
    reviewCount: 38,
    activationStage: "steady",
  });

  const operator = store.createOperator({
    fullName: "Jazz Bennett",
    mobile: "(615) 555-0142",
    roles: ["owner", "provider", "front_desk"],
    licensesAndCertifications: ["injector", "esthetics"],
    tenureOnBoulevard: "Year 2",
    timezone: "America/Chicago",
    businessId: business.id,
  });

  const persona = store.createPersona({
    personaName: "Fixer",
    description: "the one who just handles it",
    sampleCuePhrasing: '"1:30 ran twelve late. Handled."',
    defaultTonePositions: [60, 35, 45, 15],
    adoptionRate: 0.41,
  });

  const detail = store.createDetail({
    operatorId: operator.id,
    personaId: persona.id,
    name: "Fixer",
    voiceCalmToEnergetic: 55,
    voiceFactsToConversational: 60,
    voiceProfessionalToPlayful: 40,
    voiceHumor: 20,
    tenure: "Year 1",
    knowledgeLevel: 62,
    avgCuesPerDay: 5,
    status: "active",
  });

  const services = {
    neurotoxin: store.createService({
      serviceName: "Neurotoxin",
      description: "Forehead, glabella, crow's feet.",
      durationMinutes: 45,
      price: 65000,
      priceModel: "per_unit",
      category: "injectable",
      processingTime: "10-14 days",
      requiresConsentForm: true,
      discountable: false,
      businessId: business.id,
    }).id,
    lipFiller: store.createService({
      serviceName: "Lip filler",
      description: "Syringe of hyaluronic acid filler.",
      durationMinutes: 45,
      price: 65000,
      priceModel: "flat",
      category: "injectable",
      requiresConsentForm: true,
      discountable: false,
      businessId: business.id,
    }).id,
    facial: store.createService({
      serviceName: "Signature facial",
      description: "Hydrating facial with LED.",
      durationMinutes: 60,
      price: 18000,
      priceModel: "flat",
      category: "facial",
      requiresConsentForm: false,
      discountable: true,
      businessId: business.id,
    }).id,
    laser: store.createService({
      serviceName: "Laser resurfacing",
      description: "Fractional laser, face.",
      durationMinutes: 50,
      price: 45000,
      priceModel: "flat",
      category: "laser",
      requiresConsentForm: true,
      discountable: false,
      businessId: business.id,
    }).id,
    peel: store.createService({
      serviceName: "Chemical peel",
      description: "Medium-depth peel.",
      durationMinutes: 40,
      price: 22000,
      priceModel: "flat",
      category: "peel",
      requiresConsentForm: false,
      discountable: true,
      businessId: business.id,
    }).id,
  } as const;
  for (const serviceId of Object.values(services)) {
    store.qualifyOperatorForService(operator.id, serviceId);
  }

  const dayTue = store.createDay({
    date: new Date(2026, 8, 23),
    dayLabel: "Tuesday the 23rd",
    weekday: "Tuesday",
    status: "complete",
    weather: "rain from 3 PM",
    operatorId: operator.id,
    businessId: business.id,
  });
  const dayWed = store.createDay({
    date: new Date(2026, 8, 24),
    dayLabel: "Wednesday the 24th",
    weekday: "Wednesday",
    status: "upcoming",
    weather: "clear",
    operatorId: operator.id,
    businessId: business.id,
  });

  // --- named clients for the day's narrative ---
  function makeChartFor(clientId: ClientId, overrides: Partial<Parameters<RelationalStore["createChart"]>[1]> = {}) {
    return store.createChart(clientId, {
      medicalHistory: "No significant history reported.",
      allergies: "NKDA",
      medications: "None reported.",
      contraindicationNotes: "None.",
      baselinePhotoUrls: [],
      status: "current",
      retentionUntil: "per state rule",
      containsPhi: true,
      ...overrides,
    });
  }

  const maya = store.createClient({
    fullName: "Maya Okafor",
    mobile: "(615) 555-0188",
    notes: "Nervous about bruising.",
    clientSince: new Date(2026, 8, 20),
    visitCount: 0,
    lifetimeValue: 0,
    noShowCount: 0,
    preferredChannel: "text",
    tags: ["first-time", "tox"],
    marketingConsentSms: "granted",
    marketingConsentEmail: "granted",
    businessId: business.id,
  });
  makeChartFor(maya.id);

  const priya = store.createClient({
    fullName: "Priya Sharma",
    mobile: "(615) 555-0199",
    clientSince: new Date(2025, 3, 4),
    visitCount: 4,
    lifetimeValue: 1400,
    noShowCount: 0,
    preferredChannel: "text",
    tags: ["repeat"],
    marketingConsentSms: "granted",
    marketingConsentEmail: "denied",
    businessId: business.id,
  });
  makeChartFor(priya.id);

  const dani = store.createClient({
    fullName: "Dani Reyes",
    mobile: "(615) 555-0142",
    clientSince: new Date(2025, 8, 12),
    visitCount: 6,
    lifetimeValue: 3100,
    noShowCount: 0,
    preferredChannel: "text",
    tags: ["repeat", "tox"],
    marketingConsentSms: "granted",
    marketingConsentEmail: "granted",
    businessId: business.id,
  });
  makeChartFor(dani.id, {
    allergies: "None known.",
    medications: "Low-dose aspirin (anticoagulant).",
    contraindicationNotes: "On a blood thinner — confirm with provider before injecting.",
  });

  const tasha = store.createClient({
    fullName: "Tasha Ward",
    mobile: "(615) 555-0151",
    clientSince: new Date(2025, 1, 2),
    visitCount: 9,
    lifetimeValue: 4200,
    noShowCount: 1,
    preferredChannel: "text",
    tags: ["repeat"],
    marketingConsentSms: "granted",
    marketingConsentEmail: "granted",
    businessId: business.id,
  });
  makeChartFor(tasha.id);

  const lena = store.createClient({
    fullName: "Lena Kim",
    mobile: "(615) 555-0163",
    clientSince: new Date(2024, 11, 1),
    visitCount: 14,
    lifetimeValue: 6100,
    noShowCount: 0,
    preferredChannel: "email",
    tags: ["repeat"],
    marketingConsentSms: "granted",
    marketingConsentEmail: "granted",
    businessId: business.id,
  });
  makeChartFor(lena.id);

  const morgan = store.createClient({
    fullName: "Morgan Blake",
    mobile: "(615) 555-0175",
    clientSince: new Date(2025, 5, 20),
    visitCount: 3,
    lifetimeValue: 540,
    noShowCount: 0,
    preferredChannel: "text",
    tags: ["repeat"],
    marketingConsentSms: "granted",
    marketingConsentEmail: "denied",
    businessId: business.id,
  });
  makeChartFor(morgan.id);

  const ava = store.createClient({
    fullName: "Ava James",
    mobile: "(615) 555-0187",
    clientSince: new Date(2025, 9, 9),
    visitCount: 2,
    lifetimeValue: 440,
    noShowCount: 0,
    preferredChannel: "text",
    tags: ["repeat"],
    marketingConsentSms: "denied",
    marketingConsentEmail: "granted",
    businessId: business.id,
  });
  makeChartFor(ava.id);

  const renee = store.createClient({
    fullName: "Renee Cole",
    mobile: "(615) 555-0193",
    clientSince: new Date(2024, 6, 6),
    visitCount: 20,
    lifetimeValue: 8400,
    noShowCount: 0,
    preferredChannel: "text",
    tags: ["vip", "repeat"],
    marketingConsentSms: "granted",
    marketingConsentEmail: "granted",
    businessId: business.id,
  });
  makeChartFor(renee.id);

  // --- 204 filler clients so "212 clients on file" holds ---
  const others: ClientId[] = [];
  for (let i = 0; i < 204; i++) {
    const fullName = `${pick(rng, FIRST_NAMES)} ${pick(rng, LAST_NAMES)}`;
    const client = store.createClient({ ...makeClientData(rng, fullName, i), businessId: business.id });
    makeChartFor(client.id);
    others.push(client.id);
  }

  // --- Tuesday's seven appointments ---
  const chartOf = (clientId: ClientId): ChartId => store.charts.findOne((c) => c.clientId === clientId)!.id;

  const apptMorgan = store.createAppointment(
    {
      confirmationNumber: "BLVD-1001",
      startTime: new Date(2026, 8, 23, 9, 0),
      durationMinutes: 60,
      status: "completed",
      checkInTime: new Date(2026, 8, 23, 8, 58),
      price: 18000,
      depositTaken: true,
      roomOrDevice: "Suite 204",
      clientId: morgan.id,
      operatorId: operator.id,
      businessId: business.id,
      dayId: dayTue.id,
      chartId: chartOf(morgan.id),
    },
    [services.facial],
  );

  const apptAva = store.createAppointment(
    {
      confirmationNumber: "BLVD-1002",
      startTime: new Date(2026, 8, 23, 10, 0),
      durationMinutes: 40,
      status: "completed",
      checkInTime: new Date(2026, 8, 23, 9, 55),
      price: 22000,
      depositTaken: true,
      roomOrDevice: "Suite 204",
      clientId: ava.id,
      operatorId: operator.id,
      businessId: business.id,
      dayId: dayTue.id,
      chartId: chartOf(ava.id),
    },
    [services.peel],
  );

  const apptMaya = store.createAppointment(
    {
      confirmationNumber: "BLVD-1003",
      notes: "First-time neurotoxin. Intake complete, no contraindications.",
      startTime: new Date(2026, 8, 23, 11, 0),
      durationMinutes: 45,
      status: "completed",
      checkInTime: new Date(2026, 8, 23, 10, 57),
      price: 65000,
      depositTaken: true,
      roomOrDevice: "Suite 204",
      clientId: maya.id,
      operatorId: operator.id,
      businessId: business.id,
      dayId: dayTue.id,
      chartId: chartOf(maya.id),
    },
    [services.neurotoxin],
  );
  const mayaConsentForm = store.createForm({
    formName: "Neurotoxin consent",
    responses: { pregnant: "no", allergies: "none" },
    signature: "Maya Okafor",
    type: "consent",
    status: "complete",
    templateAndVersion: "Boulevard tox consent v3",
    sentAt: new Date(2026, 8, 20),
    completedAt: new Date(2026, 8, 22, 23, 52),
    flagsRaised: [],
    requiredFor: "this_appointment",
    source: "client_completed",
    chartId: chartOf(maya.id),
    appointmentId: apptMaya.id,
    serviceId: services.neurotoxin,
  });

  const apptDani = store.createAppointment(
    {
      confirmationNumber: "BLVD-1004",
      startTime: new Date(2026, 8, 23, 12, 30),
      durationMinutes: 45,
      status: "completed",
      checkInTime: new Date(2026, 8, 23, 12, 28),
      price: 65000,
      depositTaken: true,
      roomOrDevice: "Suite 204",
      clientId: dani.id,
      operatorId: operator.id,
      businessId: business.id,
      dayId: dayTue.id,
      chartId: chartOf(dani.id),
    },
    [services.neurotoxin],
  );
  const daniIntakeForm = store.createForm({
    formName: "Neurotoxin consent · Intake — medical history",
    responses: { medications: "low-dose aspirin" },
    signature: "Dani Reyes",
    type: "medical_history",
    status: "complete",
    templateAndVersion: "Boulevard tox consent v3",
    sentAt: new Date(2026, 8, 21),
    completedAt: new Date(2026, 8, 22, 20, 10),
    flagsRaised: ["anticoagulant"],
    requiredFor: "this_appointment",
    source: "client_completed",
    chartId: chartOf(dani.id),
    appointmentId: apptDani.id,
    serviceId: services.neurotoxin,
  });

  const apptTasha = store.createAppointment(
    {
      confirmationNumber: "BLVD-4471",
      notes: "Second tox session, forehead only.",
      startTime: new Date(2026, 8, 23, 13, 30),
      durationMinutes: 45,
      status: "completed",
      checkInTime: new Date(2026, 8, 23, 13, 42),
      latenessMinutes: 12,
      price: 65000,
      depositTaken: true,
      roomOrDevice: "Suite 204",
      clientId: tasha.id,
      operatorId: operator.id,
      businessId: business.id,
      dayId: dayTue.id,
      chartId: chartOf(tasha.id),
    },
    [services.neurotoxin],
  );

  const apptLena = store.createAppointment(
    {
      confirmationNumber: "BLVD-1006",
      startTime: new Date(2026, 8, 23, 14, 30),
      durationMinutes: 50,
      status: "checked_in",
      checkInTime: new Date(2026, 8, 23, 14, 40),
      price: 45000,
      depositTaken: false,
      roomOrDevice: "Suite 204 · laser 1",
      clientId: lena.id,
      operatorId: operator.id,
      businessId: business.id,
      dayId: dayTue.id,
      chartId: chartOf(lena.id),
    },
    [services.laser],
  );

  const apptRenee = store.createAppointment(
    {
      confirmationNumber: "BLVD-1007",
      startTime: new Date(2026, 8, 23, 16, 0),
      durationMinutes: 60,
      status: "confirmed",
      price: 18000,
      depositTaken: false,
      roomOrDevice: "Suite 204",
      clientId: renee.id,
      operatorId: operator.id,
      businessId: business.id,
      dayId: dayTue.id,
      chartId: chartOf(renee.id),
    },
    [services.facial],
  );

  // --- Priya's opening, claimed for Wednesday 2:30 ---
  const opening = store.createOpening({
    slotLabel: "Wed 24, 2:30 PM, 90 minutes",
    startTime: new Date(2026, 8, 24, 14, 30),
    durationMinutes: 90,
    estimatedValue: 65000,
    origin: "schedule_gap",
    status: "filled",
    offerOrder: ["waitlist", "instagram"],
    businessId: business.id,
    serviceId: services.lipFiller,
    filledByClientId: priya.id,
    dayId: dayWed.id,
  });
  store.offerOpeningToClient(opening.id, priya.id);
  const apptPriya = store.createAppointment(
    {
      confirmationNumber: "BLVD-1101",
      startTime: opening.startTime,
      durationMinutes: 90,
      status: "booked",
      price: 65000,
      depositTaken: false,
      roomOrDevice: "Suite 204",
      clientId: priya.id,
      operatorId: operator.id,
      businessId: business.id,
      dayId: dayWed.id,
      chartId: chartOf(priya.id),
    },
    [services.lipFiller],
  );

  // --- schema-completeness fixtures: segment, campaign, review, message,
  //     pattern, proposal, capability, briefing, chart entries, waitlist ---
  const segment = store.createSegment({
    segmentName: "Tox clients overdue",
    definition: "Had tox, no visit in 100+ days.",
    createdBy: "detail",
    autoUpdating: true,
    businessId: business.id,
    serviceId: services.neurotoxin,
  });
  for (const clientId of [dani.id, tasha.id, ...others.slice(0, 30)]) {
    store.addSegmentMember(segment.id, clientId);
  }
  const campaign = store.createCampaign({
    campaignName: "Tox re-engagement",
    bodyCopy: "It's been a while — want back on the books?",
    type: "re_engagement",
    channel: "sms",
    status: "sent",
    authoredBy: "detail_in_her_voice",
    businessId: business.id,
    segmentId: segment.id,
    draftedByDetailId: detail.id,
  });
  for (const clientId of [dani.id, tasha.id]) {
    store.sendCampaignToClient(campaign.id, clientId, "sms", "operator");
  }

  store.createReview({
    reviewBody: "She didn't rush me.",
    reviewerName: "M. Okafor",
    starRating: 5,
    date: new Date(2026, 8, 23, 11, 30),
    source: "google",
    replyStatus: "none",
    taggedThemes: ["strength: didn't rush me"],
    clientId: maya.id,
    businessId: business.id,
    operatorId: operator.id,
    appointmentId: apptMaya.id,
    dayId: dayTue.id,
  });

  store.createMessage({
    body: "Running about 10 behind, see you at 2:40?",
    timestamp: new Date(2026, 8, 23, 13, 42, 15),
    direction: "outbound",
    channel: "sms",
    status: "sent",
    authoredBy: "detail_in_her_voice",
    clientId: lena.id,
    businessId: business.id,
    appointmentId: apptLena.id,
  });

  const pattern = store.createPattern({
    observation: "Your Thursdays book out three weeks ahead.",
    valueImplication: "One more half day ≈ $1,800 a month.",
    unit: "weekday",
    evidenceCount: 4,
    confidence: "high",
    firstObserved: new Date(2026, 6, 1),
    lastConfirmed: new Date(2026, 8, 18),
    direction: "strengthening",
    estimatedValue: 1800,
    status: "confirmed",
    businessId: business.id,
    detailId: detail.id,
  });
  store.createProposal({
    finding: "Tox clients are rebooking 18 days later than six months ago.",
    theMath: "120 clients × 0.77 fewer visits × $450 ≈ $41,000",
    recommendedAction: "Build a re-engagement plan.",
    spokenFraming: "Want me to build a re-engagement plan?",
    type: "growth_opportunity",
    estimatedValue: 41000,
    confidence: "medium",
    status: "pending",
    rollbackAvailable: false,
    surfacedAt: new Date(2026, 8, 23, 8, 5),
    detailId: detail.id,
    segmentId: segment.id,
    patternId: pattern.id,
  });

  store.createCapability({
    businessId: business.id,
    name: "Payouts",
    whatItUnlocks: '"I can move money for you."',
    status: "available",
    type: "integration",
    effort: "2 min",
    estimatedValue: "unlocks same-day payouts",
  });

  store.createBriefing({
    headline: '"Morning, Jazz."',
    spokenScript: "Seven today. Your 11:00 is Maya, first-time tox.",
    type: "brief",
    deliveredAt: new Date(2026, 8, 23, 7, 42),
    durationSeconds: 38,
    itemCount: 4,
    channel: "CarPlay",
    status: "played",
    dayId: dayTue.id,
    detailId: detail.id,
    operatorId: operator.id,
  });

  const mayaChartEntry = store.createChartEntry({
    whatWasDone: "20 units, glabella and crow's feet.",
    observations: "Mild erythema, no bruising at 10 min.",
    photoUrls: [],
    productsAndLots: "Botox, lot 4471C, exp 03/27.",
    type: "treatment_note",
    unitsOrDosage: "20 units",
    sitesTreated: "glabella, lateral canthus",
    authoredAt: new Date(2026, 8, 23, 11, 48),
    status: "signed",
    signedAt: new Date(2026, 8, 23, 11, 50),
    authoredBy: "operator",
    chartId: chartOf(maya.id),
    operatorId: operator.id,
    appointmentId: apptMaya.id,
    serviceId: services.neurotoxin,
  });
  const daniChartEntry = store.createChartEntry({
    whatWasDone: "20 units, glabella. Confirmed anticoagulant use before injecting.",
    observations: "No excess bruising observed.",
    photoUrls: [],
    productsAndLots: "Botox, lot 4471C, exp 03/27.",
    type: "treatment_note",
    unitsOrDosage: "20 units",
    sitesTreated: "glabella",
    authoredAt: new Date(2026, 8, 23, 12, 50),
    status: "signed",
    signedAt: new Date(2026, 8, 23, 12, 52),
    authoredBy: "operator",
    chartId: chartOf(dani.id),
    operatorId: operator.id,
    appointmentId: apptDani.id,
    serviceId: services.neurotoxin,
  });

  store.createWaitlistRequest({
    requestDisplayId: "BLVD-WL-0312",
    requestNote: "Wants anything Thursday afternoon.",
    desiredWindow: "Thursday afternoons",
    flexibility: "any_time",
    created: new Date(2026, 8, 22, 12, 40),
    status: "waiting",
    queueOrder: 1,
    timesOffered: 0,
    timesDeclined: 0,
    clientId: others[0]!,
    businessId: business.id,
    serviceId: services.facial,
  });

  // --- ADDENDUM_01.md: products and checkout ---

  const vial = store.createProduct({
    productName: "Botox 100u vial",
    brand: "Allergan",
    skuOrUpc: "300234598217",
    category: "back_bar",
    sellableAsRetail: false,
    usableInService: true,
    defaultUnitCost: 410, // $4.10, FIFO
    taxable: false,
    sizeOrColor: "100u",
    quantityOnHand: 2,
    reorderPoint: 3,
    activeAtLocation: true,
    businessId: business.id,
  });
  const serum = store.createProduct({
    productName: "Vitamin C serum",
    brand: "SkinCeuticals",
    skuOrUpc: "800012345671",
    category: "retail",
    sellableAsRetail: true,
    usableInService: false,
    retailPrice: 9600,
    defaultUnitCost: 4200,
    taxable: true,
    sizeOrColor: "30ml",
    quantityOnHand: 14,
    reorderPoint: 4,
    activeAtLocation: true,
    businessId: business.id,
  });
  store.recordProductInChartEntry(mayaChartEntry.id, vial.id);
  store.recordProductInChartEntry(daniChartEntry.id, vial.id);

  // Usage-based pricing is Premier/Enterprise only — a CAPABILITY, not a
  // given. Seeded active so the usage path runs; the gate is real.
  const usageBasedPricing = store.createCapability({
    businessId: business.id,
    name: "Usage-based pricing",
    whatItUnlocks: '"I can bill by what you actually used, not just the flat price."',
    status: "active",
    type: "policy",
    effort: "n/a — plan gate",
    estimatedValue: "accurate product cost recovery",
  });

  store.createProductUsageRule({
    ruleLabel: "Neurotoxin → Botox 100u vial",
    pricePerItem: 1300, // $13/unit
    defaultQuantity: 20,
    active: true,
    serviceId: services.neurotoxin,
    productId: vial.id,
  });

  // Maya's units: expected vs. used differ — the variance path runs.
  store.createProductUsage({
    usageRecordDisplayId: "BLVD-PU-8841",
    quantityExpected: 20,
    quantityUsed: 24,
    pricePerItemApplied: 1300,
    // NOTE (INVENTED SIMPLIFICATION): per the addendum, this amount is
    // "folded into the service price" rather than itemized separately —
    // Maya's order line item below stays a flat $650 rather than
    // reconciling to 24 × $13. Flagged in the hand-back report.
    amountCharged: 31200,
    prepaidUnitsRedeemed: 0,
    recordedAt: new Date(2026, 8, 23, 11, 30),
    appointmentId: apptMaya.id,
    productId: vial.id,
    serviceId: services.neurotoxin,
    chartEntryId: mayaChartEntry.id,
  });

  // Renee pre-buys prepaid tox units at a bulk rate — a liability on her
  // wallet, redeemed against future appointments (some redeemed already,
  // represented here as a lower `unitsRemaining` than `unitsPurchased`
  // rather than by backfilling individual historical PRODUCT USAGE rows).
  const productCredit = store.createProductCredit({
    creditLabel: "20 prepaid tox units",
    unitsPurchased: 20,
    unitsRemaining: 8,
    purchasedAt: new Date(2026, 8, 23, 11, 20),
    discountApplied: "10% bulk rate",
    amountPaid: 23400,
    status: "active",
    clientId: renee.id,
    productId: vial.id,
  });

  // --- closed orders for all seven appointments' checkouts, plus a
  //     retail walk-in, a prepaid-units purchase, and a fee — summing to
  //     exactly $3,180.00 collected. Lena's stays OPEN (unclosed at
  //     day's end); Renee's appointment hasn't happened yet, so it has
  //     no order at all.
  function closedServiceOrder(
    orderNumber: string,
    clientId: ClientId,
    appointmentId: AppointmentId,
    serviceId: ServiceId,
    price: number,
    openedAt: Date,
    closedAt: Date,
  ): OrderId {
    const order = store.createOrder(
      {
        orderNumber,
        status: "closed",
        subtotal: price,
        discounts: 0,
        tax: 0,
        gratuity: 0,
        total: price,
        openedAt,
        closedAt,
        businessId: business.id,
        clientId,
        appointmentId,
        closedByOperatorId: operator.id,
        dayId: dayTue.id,
      },
      [
        {
          kind: "service",
          lineLabel: `${orderNumber} · service`,
          quantity: 1,
          unitPriceAtSale: price,
          lineDiscount: 0,
          lineTotal: price,
          commissionBasis: "total after product usage folded in",
          appointmentId,
          serviceId,
        },
      ],
    );
    store.createPayment({
      paymentReference: `ch_${orderNumber}`,
      method: "card",
      amount: price,
      cardLastFour: "6411",
      status: "succeeded",
      processedAt: closedAt,
      orderId: order.id,
      clientId,
    });
    return order.id;
  }

  const orderMorgan = closedServiceOrder(
    "BLVD-O-9001", morgan.id, apptMorgan.id, services.facial, 18000,
    new Date(2026, 8, 23, 9, 0), new Date(2026, 8, 23, 9, 58),
  );
  const orderAva = closedServiceOrder(
    "BLVD-O-9002", ava.id, apptAva.id, services.peel, 22000,
    new Date(2026, 8, 23, 10, 0), new Date(2026, 8, 23, 10, 40),
  );
  const orderMaya = closedServiceOrder(
    "BLVD-O-9003", maya.id, apptMaya.id, services.neurotoxin, 65000,
    new Date(2026, 8, 23, 11, 0), new Date(2026, 8, 23, 11, 55),
  );
  const orderDani = closedServiceOrder(
    "BLVD-O-9004", dani.id, apptDani.id, services.neurotoxin, 65000,
    new Date(2026, 8, 23, 12, 30), new Date(2026, 8, 23, 13, 15),
  );

  // Tasha's checkout: declined once, then a successful retry.
  const orderTasha = store.createOrder(
    {
      orderNumber: "BLVD-O-9005",
      status: "closed",
      subtotal: 65000,
      discounts: 0,
      tax: 0,
      gratuity: 0,
      total: 65000,
      openedAt: new Date(2026, 8, 23, 13, 42),
      closedAt: new Date(2026, 8, 23, 14, 20),
      businessId: business.id,
      clientId: tasha.id,
      appointmentId: apptTasha.id,
      closedByOperatorId: operator.id,
      dayId: dayTue.id,
    },
    [
      {
        kind: "service",
        lineLabel: "BLVD-O-9005 · service",
        quantity: 1,
        unitPriceAtSale: 65000,
        lineDiscount: 0,
        lineTotal: 65000,
        commissionBasis: "total after product usage folded in",
        appointmentId: apptTasha.id,
        serviceId: services.neurotoxin,
      },
    ],
  );
  const tashaDeclinedPayment = store.createPayment({
    paymentReference: "ch_BLVD-O-9005_1",
    method: "card",
    amount: 65000,
    cardLastFour: "4242",
    status: "declined",
    processedAt: new Date(2026, 8, 23, 14, 15),
    declineReason: "insufficient_funds",
    orderId: orderTasha.id,
    clientId: tasha.id,
  });
  // The legitimate retry path: OPERATOR-attributed, not DETAIL's — see
  // hardRules.assertCanRetryPayment.
  store.retryPayment(tashaDeclinedPayment.id, "operator");
  store.createPayment({
    paymentReference: "ch_BLVD-O-9005_2",
    method: "card",
    amount: 65000,
    cardLastFour: "6411",
    status: "succeeded",
    processedAt: new Date(2026, 8, 23, 14, 20),
    orderId: orderTasha.id,
    clientId: tasha.id,
  });

  // Lena's checkout: stays OPEN through end of day — the "unclosed order" cue.
  const orderLena = store.createOrder(
    {
      orderNumber: "BLVD-O-9006",
      status: "open",
      subtotal: 45000,
      discounts: 0,
      tax: 0,
      gratuity: 0,
      total: 45000,
      openedAt: new Date(2026, 8, 23, 14, 40),
      businessId: business.id,
      clientId: lena.id,
      appointmentId: apptLena.id,
      dayId: dayTue.id,
    },
    [
      {
        kind: "service",
        lineLabel: "BLVD-O-9006 · service",
        quantity: 1,
        unitPriceAtSale: 45000,
        lineDiscount: 0,
        lineTotal: 45000,
        commissionBasis: "total after product usage folded in",
        appointmentId: apptLena.id,
        serviceId: services.laser,
      },
    ],
  );

  // A retail-only walk-in — no client record, per the map's own "0 for a
  // retail walk-in" example.
  const orderRetail = store.createOrder(
    {
      orderNumber: "BLVD-O-9007",
      status: "closed",
      subtotal: 9600,
      discounts: 0,
      tax: 0,
      gratuity: 0,
      total: 9600,
      openedAt: new Date(2026, 8, 23, 11, 10),
      closedAt: new Date(2026, 8, 23, 11, 15),
      businessId: business.id,
      closedByOperatorId: operator.id,
      dayId: dayTue.id,
    },
    [
      {
        kind: "retail_product",
        lineLabel: "Vitamin C serum",
        quantity: 1,
        unitPriceAtSale: 9600,
        lineDiscount: 0,
        lineTotal: 9600,
        commissionBasis: "retail — no commission",
        productId: serum.id,
      },
    ],
  );
  store.createPayment({
    paymentReference: "ch_BLVD-O-9007",
    method: "cash",
    amount: 9600,
    status: "succeeded",
    processedAt: new Date(2026, 8, 23, 11, 15),
    orderId: orderRetail.id,
  });

  // Renee's prepaid-units purchase — this order IS the ProductCredit's
  // purchase event.
  const orderPrepaid = store.createOrder(
    {
      orderNumber: "BLVD-O-9008",
      status: "closed",
      subtotal: 26000,
      discounts: 2600,
      tax: 0,
      gratuity: 0,
      total: 23400,
      openedAt: new Date(2026, 8, 23, 11, 18),
      closedAt: new Date(2026, 8, 23, 11, 22),
      businessId: business.id,
      clientId: renee.id,
      closedByOperatorId: operator.id,
      dayId: dayTue.id,
    },
    [
      {
        kind: "prepaid_units",
        lineLabel: "20 prepaid tox units",
        quantity: 20,
        unitPriceAtSale: 1300,
        lineDiscount: 2600,
        lineTotal: 23400,
        commissionBasis: "prepaid — commission on redemption, not purchase",
        productId: vial.id,
      },
    ],
  );
  const prepaidLineItem = store.orderLineItems.findOne((li) => li.orderId === orderPrepaid.id)!;
  store.productCredits.update(productCredit.id, { orderLineItemId: prepaidLineItem.id });
  store.createPayment({
    paymentReference: "ch_BLVD-O-9008",
    method: "card",
    amount: 23400,
    cardLastFour: "6411",
    status: "succeeded",
    processedAt: new Date(2026, 8, 23, 11, 22),
    orderId: orderPrepaid.id,
    clientId: renee.id,
  });

  // A missed-appointment fee, charged by the OPERATOR (never DETAIL — see
  // hardRules.assertCanChargeClientFee) to a different client.
  const feeClientId = others[1]!;
  const orderFee = store.createOrder(
    {
      orderNumber: "BLVD-O-9009",
      status: "closed",
      subtotal: 50000,
      discounts: 0,
      tax: 0,
      gratuity: 0,
      total: 50000,
      openedAt: new Date(2026, 8, 23, 15, 30),
      closedAt: new Date(2026, 8, 23, 15, 32),
      businessId: business.id,
      clientId: feeClientId,
      closedByOperatorId: operator.id,
      dayId: dayTue.id,
    },
    [
      {
        kind: "fee",
        lineLabel: "Missed-appointment fee",
        quantity: 1,
        unitPriceAtSale: 50000,
        lineDiscount: 0,
        lineTotal: 50000,
        commissionBasis: "fee — no commission",
        feeDescription: "Missed-appointment fee",
      },
    ],
  );
  store.createPayment({
    paymentReference: "ch_BLVD-O-9009",
    method: "card",
    amount: 50000,
    cardLastFour: "0192",
    status: "succeeded",
    processedAt: new Date(2026, 8, 23, 15, 32),
    orderId: orderFee.id,
    clientId: feeClientId,
  });

  const payout = store.createPayout({
    payoutReference: "po_1M4kTue",
    amount: 242000,
    initiatedAt: new Date(2026, 8, 23, 14, 10),
    expectedArrival: "Thursday",
    destination: "bank •••• 2208",
    status: "initiated",
    paymentCount: 7,
    businessId: business.id,
    dayId: dayTue.id,
  });

  // Usage-variance and cost-drift material — background depth, not
  // wired into today's ladder (the addendum lists these as new PATTERN/
  // PROPOSAL material, distinct from the day's signal-driven escalations).
  const usageVariancePattern = store.createPattern({
    observation: "You average 24 units on glabella; this one was 40.",
    valueImplication: "Consistent over-delivery on tox — worth a pricing look.",
    unit: "service",
    evidenceCount: 6,
    confidence: "medium",
    firstObserved: new Date(2026, 7, 1),
    lastConfirmed: new Date(2026, 8, 23),
    direction: "strengthening",
    estimatedValue: 0,
    status: "watching",
    businessId: business.id,
    detailId: detail.id,
    serviceId: services.neurotoxin,
  });
  store.createProposal({
    finding: "Botox unit cost is up 12% since spring; retail-adjacent pricing hasn't moved.",
    theMath: "2,400 units/month × $0.49 extra ≈ $1,176/month in margin drift",
    recommendedAction: "Review neurotoxin pricing against current unit cost.",
    spokenFraming: "Your product cost crept up — want me to model a price test?",
    type: "growth_opportunity",
    estimatedValue: 14000,
    confidence: "medium",
    status: "pending",
    rollbackAvailable: true,
    surfacedAt: new Date(2026, 8, 23, 8, 6),
    detailId: detail.id,
    serviceId: services.neurotoxin,
    patternId: usageVariancePattern.id,
  });
  void usageBasedPricing;

  return {
    store,
    businessId: business.id,
    operatorId: operator.id,
    detailId: detail.id,
    dayTueId: dayTue.id,
    dayWedId: dayWed.id,
    services,
    clientIds: { maya: maya.id, priya: priya.id, dani: dani.id, tasha: tasha.id, lena: lena.id, morgan: morgan.id, ava: ava.id, renee: renee.id, others },
    chartIds: {},
    appointmentIds: {
      morgan: apptMorgan.id,
      ava: apptAva.id,
      maya: apptMaya.id,
      dani: apptDani.id,
      tasha: apptTasha.id,
      lena: apptLena.id,
      renee: apptRenee.id,
      priya: apptPriya.id,
    },
    formIds: { mayaConsent: mayaConsentForm.id, daniIntake: daniIntakeForm.id },
    products: { vial: vial.id, serum: serum.id },
    productCreditId: productCredit.id,
    orderIds: {
      morgan: orderMorgan,
      ava: orderAva,
      maya: orderMaya,
      dani: orderDani,
      tasha: orderTasha.id,
      lena: orderLena.id,
      retail: orderRetail.id,
      prepaid: orderPrepaid.id,
      fee: orderFee.id,
    },
    payoutId: payout.id,
  };
}
