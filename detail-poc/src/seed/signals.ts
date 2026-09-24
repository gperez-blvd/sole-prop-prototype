import type { SignalId } from "../ids.js";
import type { SignalRow } from "../schema/index.js";
import type { RelationalStore } from "../store/RelationalStore.js";
import type { SeedResult } from "./seed.js";
import { makeRng, pick, randomInt } from "./rng.js";

export interface EscalationCluster {
  /** Matches the `[[ESCALATE:tag]]` marker embedded in each signal's payload. */
  tag: string;
  signalIds: SignalId[];
}

export interface SignalGenResult {
  totalSignals: number;
  clusters: EscalationCluster[];
}

const TUE_9AM = new Date(2026, 8, 23, 9, 0).getTime();
const TUE_6PM = new Date(2026, 8, 23, 18, 0).getTime();

function randomTueTimestamp(rng: () => number): Date {
  return new Date(TUE_9AM + rng() * (TUE_6PM - TUE_9AM));
}

/**
 * Builds the ~400 SIGNAL rows for Tuesday: eight curated, narratively-tied
 * escalation clusters (tagged `[[ESCALATE:tag]]` so the ladder can find
 * them and route them to a cue — or, for one of them, deliberately NOT to
 * a cue — regardless of the generic classifier), plus filler signals
 * spread across the plausible sources, constructed so the generic
 * classifier resolves them silently (materially uneventful, or handled
 * autonomously via a threshold) — never accidentally landing on
 * "material, unhandled, uncurated", which would be an unscripted cue.
 *
 * Five clusters are from the original handoff (clinical-dani,
 * cascade-tasha, opening-priya, review-2star, weather-renee). Three are
 * from ADDENDUM_01.md: payment-declined and order-unclosed both produce a
 * CUE; low-stock-neurotoxin deliberately does not — "the cue waits for
 * Friday because a threshold says so."
 */
export function generateSignals(store: RelationalStore, seed: SeedResult): SignalGenResult {
  const rng = makeRng(918);
  const { businessId, dayTueId, clientIds, appointmentIds, formIds } = seed;
  let sequence = 0;
  const next = (): number => (sequence += 1);

  const clusters: EscalationCluster[] = [];

  function curated(tag: string, rows: Omit<SignalRow, "id" | "sequence" | "businessId" | "dayId">[]) {
    const ids = rows.map(
      (r) =>
        store.createSignal({
          ...r,
          businessId,
          dayId: dayTueId,
          sequence: next(),
          payload: `${r.payload} [[ESCALATE:${tag}]]`,
        }).id,
    );
    clusters.push({ tag, signalIds: ids });
  }

  // 1. Clinical flag — Dani Reyes, anticoagulant. Always escalates,
  //    bypasses threshold governance entirely (handled specially in ladder.ts).
  curated("clinical-dani", [
    {
      payload: "chart flag: Dani Reyes is on an anticoagulant — confirm before injecting",
      timestamp: new Date(2026, 8, 23, 12, 15),
      source: "chart",
      domain: "scheduling",
      clientId: clientIds.dani,
      appointmentId: appointmentIds.dani,
      formId: formIds.daniIntake,
    },
  ]);

  // 2. The map's own worked example — Tasha's 1:30 runs 12 min late;
  //    cleanup window auto-shifted, Lena's 2:30 auto-texted. Two signals,
  //    one decision, one cue.
  curated("cascade-tasha", [
    {
      payload: "check-in: 1:30 client arrived 12 min late",
      timestamp: new Date(2026, 8, 23, 13, 42, 10),
      source: "check_in",
      domain: "scheduling",
      clientId: clientIds.tasha,
      appointmentId: appointmentIds.tasha,
    },
    {
      payload: "derived: cleanup window moved 2:27 -> 2:40; 2:30 client texted an updated time",
      timestamp: new Date(2026, 8, 23, 13, 42, 13),
      source: "derived",
      domain: "scheduling",
      clientId: clientIds.lena,
      appointmentId: appointmentIds.lena,
    },
  ]);

  // 3. Priya claims the Wednesday opening — a milestone, not a problem.
  curated("opening-priya", [
    {
      payload: "opening claimed: Priya booked Wed 2:30 lip filler from an open slot",
      timestamp: new Date(2026, 8, 23, 15, 5),
      source: "derived",
      domain: "scheduling",
      clientId: clientIds.priya,
      appointmentId: appointmentIds.priya,
    },
  ]);

  // 4. A 2-star review lands mid-afternoon.
  curated("review-2star", [
    {
      payload: 'review: 2 stars — "appointment ran long, wasn\'t told why"',
      timestamp: new Date(2026, 8, 23, 14, 50),
      source: "review",
      domain: "external",
    },
  ]);

  // 5. Rain moving in threatens the last two appointments' timing.
  curated("weather-renee", [
    {
      payload: "weather: rain from 3 PM risks pushing the 4:00 appointment late",
      timestamp: new Date(2026, 8, 23, 15, 0),
      source: "weather",
      domain: "external",
      clientId: clientIds.renee,
      appointmentId: appointmentIds.renee,
    },
  ]);

  // --- ADDENDUM_01.md: products and checkout ---

  // 6. Payment declined while the client is still in the room — "the only
  //    payment event that should ever interrupt."
  const declinedPayment = store.payments.findOne(
    (p) => p.orderId === seed.orderIds.tasha && p.status === "declined",
  );
  curated("payment-declined", [
    {
      payload: "payment: Tasha's card declined at checkout",
      timestamp: new Date(2026, 8, 23, 14, 15),
      source: "payment",
      domain: "payments",
      clientId: clientIds.tasha,
      appointmentId: appointmentIds.tasha,
      ...(declinedPayment ? { paymentId: declinedPayment.id } : {}),
    },
  ]);

  // 7. Lena's order is still open at end of day — same shape as an
  //    unsigned chart entry; belongs in the debrief.
  curated("order-unclosed", [
    {
      payload: "order: Lena's laser order still open at day's end",
      timestamp: new Date(2026, 8, 23, 17, 45),
      source: "derived",
      domain: "payments",
      clientId: clientIds.lena,
      appointmentId: appointmentIds.lena,
    },
  ]);

  // 8. Low stock on the neurotoxin vial — material, correctly NOT spoken
  //    today. "The cue waits for Friday because a threshold says so."
  //    Scripted in ladder.ts to resolve to `deferred` with no CUE.
  curated("low-stock-neurotoxin", [
    {
      payload: "stock: neurotoxin vials at 2, reorder point 3 — covers Thursday's tox appointments",
      timestamp: new Date(2026, 8, 23, 9, 30),
      source: "stock",
      domain: "inventory",
      productId: seed.products.vial,
    },
  ]);

  const curatedCount = clusters.reduce((sum, c) => sum + c.signalIds.length, 0);

  // --- filler: ~394 routine signals, all resolvable without a cue ---
  const allClientIds = [...seed.clientIds.others, clientIds.maya, clientIds.priya, clientIds.dani, clientIds.tasha, clientIds.lena, clientIds.morgan, clientIds.ava, clientIds.renee];

  const fillerCount = 400 - curatedCount;
  for (let i = 0; i < fillerCount; i++) {
    const roll = rng();
    let row: Omit<SignalRow, "id" | "sequence" | "businessId" | "dayId">;

    if (roll < 0.32) {
      // Routine payment collected — stays silent (threshold: stay_silent).
      row = {
        payload: `payment: $${randomInt(rng, 65, 650)} collected successfully`,
        timestamp: randomTueTimestamp(rng),
        source: "payment",
        domain: "payments",
        clientId: pick(rng, allClientIds),
      };
    } else if (roll < 0.5) {
      // FAQ-shaped DM — auto-replied (threshold: handle).
      row = {
        payload: pick(rng, [
          "dm: \"what are your hours?\"",
          "dm: \"do you have parking?\"",
          "dm: \"how much is a facial?\"",
          "dm: \"what's the address?\"",
        ]),
        timestamp: randomTueTimestamp(rng),
        source: "dm",
        domain: "messaging",
        clientId: pick(rng, allClientIds),
      };
    } else if (roll < 0.6) {
      // Minor, sub-15-min lateness elsewhere — auto-handled (threshold: handle).
      row = {
        payload: `check-in: client arrived ${randomInt(rng, 1, 14)} min late`,
        timestamp: randomTueTimestamp(rng),
        source: "check_in",
        domain: "scheduling",
        clientId: pick(rng, allClientIds),
      };
    } else if (roll < 0.63) {
      // Stock/inventory note — auto-handled (threshold: handle). (The
      // neurotoxin vial's OWN low-stock event is curated separately above
      // — deliberately worded differently so it isn't swept in here.)
      row = {
        payload: pick(rng, [
          "stock: numbing cream running low",
          "stock: gauze restocked",
          "stock: cotton rounds running low",
          "stock: retail serum restocked, 14 on hand",
        ]),
        timestamp: randomTueTimestamp(rng),
        source: "stock",
        domain: "inventory",
      };
    } else if (roll < 0.66) {
      // Routine product usage on a non-critical service — a minor
      // variance, genuinely uneventful (immaterial: no threshold matches,
      // no deviation keyword — the ladder never even evaluates it).
      row = {
        payload: "derived: product usage within normal range for this service",
        timestamp: randomTueTimestamp(rng),
        source: "derived",
        domain: "inventory",
        clientId: pick(rng, allClientIds),
      };
    } else if (roll < 0.68) {
      // Routine payout initiated — stays silent (threshold: stay_silent),
      // same family as the payment-succeeded threshold above.
      row = {
        payload: `payout: $${randomInt(rng, 800, 2600)} initiated, arriving in 1-2 business days`,
        timestamp: randomTueTimestamp(rng),
        source: "api",
        domain: "payments",
      };
    } else if (roll < 0.78) {
      // Routine, clear/mild weather — stays silent.
      row = {
        payload: pick(rng, ["weather: clear, 74°F", "weather: partly cloudy, mild", "weather: sunny, light breeze"]),
        timestamp: randomTueTimestamp(rng),
        source: "weather",
        domain: "external",
      };
    } else if (roll < 0.85) {
      // Positive review — auto-handled (threshold: handle, 4-5 stars).
      row = {
        payload: `review: ${pick(rng, [4, 5])} stars — "${pick(rng, ["great as always", "so gentle", "worth the drive", "in and out on time"])}"`,
        timestamp: randomTueTimestamp(rng),
        source: "review",
        domain: "external",
      };
    } else if (roll < 0.92) {
      // Form completed on schedule — no deviation, stays silent.
      row = {
        payload: "form: intake completed on time, no flags",
        timestamp: randomTueTimestamp(rng),
        source: "form",
        domain: "scheduling",
        clientId: pick(rng, allClientIds),
      };
    } else if (roll < 0.97) {
      // Routine API/system heartbeat — stays silent.
      row = {
        payload: pick(rng, [
          "api: calendar sync completed",
          "api: reminder sent successfully",
          "api: booking confirmation delivered",
        ]),
        timestamp: randomTueTimestamp(rng),
        source: "api",
        domain: "scheduling",
      };
    } else {
      // A handful of "material but not curated" signals: a same-day
      // cancellation elsewhere, absorbed without becoming a cue (suppressed
      // or deferred to the debrief — see ladder.ts) — demonstrates that
      // "matters" and "gets spoken" are different steps.
      row = {
        payload: pick(rng, [
          "reschedule: client moved Thursday's slot by an hour",
          "cancellation: same-day cancellation, spot reopened",
          "dm: \"can I bring a friend to watch?\"",
        ]),
        timestamp: randomTueTimestamp(rng),
        source: "derived",
        domain: "scheduling",
        clientId: pick(rng, allClientIds),
      };
    }

    store.createSignal({ ...row, businessId, dayId: dayTueId, sequence: next() });
  }

  return { totalSignals: sequence, clusters };
}
