import type { SignalDisposition, SignalRow } from "../schema/index.js";
import type { RelationalStore } from "../store/RelationalStore.js";
import type { SeedResult } from "../seed/seed.js";
import type { EscalationCluster } from "../seed/signals.js";
import { seedThresholds, type SeededThreshold } from "./thresholds.js";

export interface LadderRunResult {
  totalSignals: number;
  cueDecisionsCreated: number;
  cuesProduced: number;
  actionsCreated: number;
  dispositionCounts: Record<SignalDisposition, number>;
  ladderStopCounts: Record<1 | 2 | 3 | 4 | 5, number>;
}

const UNGOVERNED_MATERIAL_KEYWORDS = /reschedule|cancellation|bring a friend/i;

function bump<K extends string | number>(counts: Record<K, number>, key: K): void {
  counts[key] = (counts[key] ?? 0) + 1;
}

/**
 * Runs the five-step ladder over every SIGNAL for the day. The five
 * curated clusters (found by tag) are scripted directly — they're the
 * narrative the seed exists to prove — and always escalate. Every other
 * signal goes through the generic classifier: threshold-governed signals
 * resolve per their threshold's permittedAction (never asking); anything
 * else either doesn't matter at all, or matters but isn't curated, in
 * which case it is suppressed or deferred, never spoken. No signal outside
 * the five curated clusters — and the clinical case, which is structural,
 * not a cluster — can produce a Cue. That is what keeps ~400 in and ~5
 * cues out true by construction, not by luck.
 */
export function runLadder(
  store: RelationalStore,
  seed: SeedResult,
  clusters: EscalationCluster[],
): LadderRunResult {
  const seededThresholds = seedThresholds(store, seed.detailId);
  const result: LadderRunResult = {
    totalSignals: 0,
    cueDecisionsCreated: 0,
    cuesProduced: 0,
    actionsCreated: 0,
    dispositionCounts: {
      handled_silently: 0,
      suppressed: 0,
      deferred: 0,
      escalated_to_cue: 0,
      awaiting_approval: 0,
    },
    ladderStopCounts: { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 },
  };

  const clusteredSignalIds = new Set(clusters.flatMap((c) => c.signalIds));
  const allSignals = store.signals.find((s) => s.dayId === seed.dayTueId).sort((a, b) => a.sequence - b.sequence);
  result.totalSignals = allSignals.length;

  function resolve(signal: SignalRow, disposition: SignalDisposition, ladderStop: 1 | 2 | 3 | 4 | 5): void {
    store.signals.update(signal.id, { disposition });
    bump(result.dispositionCounts, disposition);
    bump(result.ladderStopCounts, ladderStop);
  }

  // --- 1. the five curated clusters, scripted ---
  for (const cluster of clusters) {
    const clusterSignals = cluster.signalIds.map((id) => store.signals.getOrThrow(id));
    const script = CLUSTER_SCRIPTS[cluster.tag];
    if (!script) throw new Error(`No script for escalation cluster "${cluster.tag}"`);
    script(store, seed, clusterSignals, seededThresholds, result);
  }

  // --- 2. everything else, through the generic classifier ---
  for (const signal of allSignals) {
    if (clusteredSignalIds.has(signal.id)) continue;

    const matched = seededThresholds.filter((t) => t.matches(signal));
    for (const t of matched) {
      store.recordThresholdEvaluation({
        signalId: signal.id,
        thresholdId: t.row.id,
        step: 3,
        result: `matched: ${t.row.permittedAction}`,
      });
    }

    const handleThreshold = matched.find((t) => t.row.permittedAction === "handle");
    const staySilentThreshold = matched.find((t) => t.row.permittedAction === "stay_silent");
    const ungovernedMaterial = matched.length === 0 && UNGOVERNED_MATERIAL_KEYWORDS.test(signal.payload);

    if (matched.length === 0 && !ungovernedMaterial) {
      // Step 2: doesn't matter. Ladder stops here — no evaluation to log,
      // no decision to weigh. This is the dominant case.
      store.signals.update(signal.id, { materiality: false, autoActionable: false });
      resolve(signal, "handled_silently", 2);
      continue;
    }

    store.signals.update(signal.id, { materiality: true });

    if (handleThreshold) {
      store.signals.update(signal.id, { autoActionable: true });
      store.createAction({
        description: `Auto-handled per threshold: ${handleThreshold.row.ruleStatement}`,
        outcome: "Executed without interrupting her.",
        timestamp: signal.timestamp,
        targetPrimitive: signal.domain === "inventory" ? "inventory" : signal.domain === "messaging" ? "messaging" : "calendar",
        reversible: true,
        authorizedBy: "threshold",
        status: "executed",
        visibleToOperator: "audit_only",
        detailId: seed.detailId,
        signalId: signal.id,
        thresholdId: handleThreshold.row.id,
        dayId: seed.dayTueId,
      });
      result.actionsCreated += 1;
      store.createCueDecision(
        {
          reasoning: `Handled under threshold: ${handleThreshold.row.ruleStatement}`,
          ladderStop: 3,
          outcome: "handled_silently",
          timingDecision: "hold_for_debrief",
          suppressedAlongside: [],
          decidedAt: signal.timestamp,
          detailId: seed.detailId,
        },
        [signal.id],
        [handleThreshold.row.id],
      );
      result.cueDecisionsCreated += 1;
      resolve(signal, "handled_silently", 3);
      continue;
    }

    if (staySilentThreshold) {
      store.signals.update(signal.id, { autoActionable: false });
      store.createCueDecision(
        {
          reasoning: `Evaluated and dismissed under threshold: ${staySilentThreshold.row.ruleStatement}`,
          ladderStop: 3,
          outcome: "handled_silently",
          timingDecision: "hold_for_debrief",
          suppressedAlongside: [],
          decidedAt: signal.timestamp,
          detailId: seed.detailId,
        },
        [signal.id],
        [staySilentThreshold.row.id],
      );
      result.cueDecisionsCreated += 1;
      resolve(signal, "handled_silently", 3);
      continue;
    }

    // Material, but ungoverned by any threshold and not one of the five
    // curated clusters — the case the handoff warns about. It still gets
    // a CueDecision (every signal does), but the answer at step 4 is no.
    store.signals.update(signal.id, { autoActionable: false });
    const disposition: SignalDisposition = signal.domain === "scheduling" ? "deferred" : "suppressed";
    store.createCueDecision(
      {
        reasoning: "Material, but not urgent and not part of a pattern she's asked to hear about yet.",
        ladderStop: 4,
        outcome: disposition,
        timingDecision: "hold_for_debrief",
        suppressedAlongside: [],
        decidedAt: signal.timestamp,
        detailId: seed.detailId,
      },
      [signal.id],
      [],
    );
    result.cueDecisionsCreated += 1;
    resolve(signal, disposition, 4);
  }

  return result;
}

type ClusterScript = (
  store: RelationalStore,
  seed: SeedResult,
  signals: SignalRow[],
  thresholds: SeededThreshold[],
  result: LadderRunResult,
) => void;

function finishEscalation(
  store: RelationalStore,
  seed: SeedResult,
  signals: SignalRow[],
  result: LadderRunResult,
  opts: {
    reasoning: string;
    timingDecision: "speak_now" | "wait_for_gap" | "hold_for_debrief";
    suppressedAlongside?: string[];
    consultedThresholdIds?: import("../ids.js").ThresholdId[];
    spokenText: string;
    onScreenDetail?: string;
    type: "interstitial" | "milestone" | "capability" | "clinical_flag";
    clinicalOverride?: boolean;
    intent?: "inform" | "decide" | "demonstrate" | "request";
    requiresDecision: boolean;
    clientId?: import("../ids.js").ClientId;
    appointmentId?: import("../ids.js").AppointmentId;
  },
): void {
  const decision = store.createCueDecision(
    {
      reasoning: opts.reasoning,
      ladderStop: 5,
      outcome: "escalated",
      timingDecision: opts.timingDecision,
      suppressedAlongside: opts.suppressedAlongside ?? [],
      decidedAt: signals[signals.length - 1]!.timestamp,
      detailId: seed.detailId,
    },
    signals.map((s) => s.id),
    opts.consultedThresholdIds ?? [],
  );
  result.cueDecisionsCreated += 1;

  const cue = store.createCue({
    spokenText: opts.spokenText,
    ...(opts.onScreenDetail !== undefined ? { onScreenDetail: opts.onScreenDetail } : {}),
    timestamp: signals[signals.length - 1]!.timestamp,
    type: opts.type,
    ...(opts.intent !== undefined ? { intent: opts.intent } : {}),
    channel: "in_ear",
    deliveryWindow: opts.timingDecision === "speak_now" ? "between_clients" : "commute",
    wordCount: opts.spokenText.split(/\s+/).length,
    requiresDecision: opts.requiresDecision,
    status: "delivered",
    personaVoiceUsed: "Fixer",
    clinicalOverride: opts.clinicalOverride ?? false,
    detailId: seed.detailId,
    cueDecisionId: decision.id,
    dayId: seed.dayTueId,
    ...(opts.clientId !== undefined ? { clientId: opts.clientId } : {}),
    ...(opts.appointmentId !== undefined ? { appointmentId: opts.appointmentId } : {}),
  });
  result.cuesProduced += 1;

  for (const signal of signals) {
    store.signals.update(signal.id, {
      materiality: true,
      autoActionable: opts.type !== "clinical_flag",
      disposition: "escalated_to_cue",
    });
    bump(result.dispositionCounts, "escalated_to_cue");
    bump(result.ladderStopCounts, 5);
  }
  void cue;
}

const CLUSTER_SCRIPTS: Record<string, ClusterScript> = {
  "clinical-dani": (store, seed, signals, _thresholds, result) => {
    finishEscalation(store, seed, signals, result, {
      reasoning:
        "Dani's intake flags an anticoagulant. Clinical flags bypass every speaking-window and quiet-hours threshold — this is spoken regardless.",
      timingDecision: "speak_now",
      spokenText: "Check Dani's intake before you start.",
      onScreenDetail: "Dani is on an anticoagulant (low-dose aspirin) — confirm with her provider before injecting.",
      type: "clinical_flag",
      clinicalOverride: true,
      intent: "inform",
      requiresDecision: false,
      clientId: seed.clientIds.dani,
      appointmentId: seed.appointmentIds.dani,
    });
  },

  "cascade-tasha": (store, seed, signals, seededThresholds, result) => {
    const lateness = seededThresholds.find((t) => t.row.ruleStatement.startsWith("Lateness under 15"));
    store.createAction({
      description: "Moved cleanup window 2:27 → 2:40; texted the 2:30 client an updated time.",
      outcome: "Sent. Delivered.",
      timestamp: signals[0]!.timestamp,
      targetPrimitive: "calendar",
      reversible: true,
      authorizedBy: "threshold",
      status: "executed",
      visibleToOperator: "reported_in_cue",
      detailId: seed.detailId,
      signalId: signals[0]!.id,
      ...(lateness ? { thresholdId: lateness.row.id } : {}),
      dayId: seed.dayTueId,
    });
    result.actionsCreated += 1;
    finishEscalation(store, seed, signals, result, {
      reasoning: "Her 1:30 ran late enough (12 min) to affect the next client — worth a brief heads up, not a decision.",
      timingDecision: "wait_for_gap",
      suppressedAlongside: ["3 marketing notices", "1 stock alert", "2 payout confirmations"],
      ...(lateness ? { consultedThresholdIds: [lateness.row.id] } : {}),
      spokenText: "Your 1:30 ran twelve late. I moved your cleanup window and texted your 2:30. Nothing you need to do.",
      type: "interstitial",
      intent: "inform",
      requiresDecision: false,
      clientId: seed.clientIds.tasha,
      appointmentId: seed.appointmentIds.tasha,
    });
  },

  "opening-priya": (store, seed, signals, _thresholds, result) => {
    finishEscalation(store, seed, signals, result, {
      reasoning: "A revenue-relevant opening just filled — worth a quick, good-news mention.",
      timingDecision: "wait_for_gap",
      spokenText: "Priya took your 2:30 tomorrow. Filled.",
      type: "milestone",
      intent: "inform",
      requiresDecision: false,
      clientId: seed.clientIds.priya,
      appointmentId: seed.appointmentIds.priya,
    });
  },

  "review-2star": (store, seed, signals, _thresholds, result) => {
    finishEscalation(store, seed, signals, result, {
      reasoning: "A low review needs her voice, not DETAIL's — drafted a reply, asking before sending.",
      timingDecision: "wait_for_gap",
      spokenText: "New 2-star review came in. Want me to send the reply I drafted?",
      type: "interstitial",
      intent: "request",
      requiresDecision: true,
    });
  },

  "weather-renee": (store, seed, signals, _thresholds, result) => {
    finishEscalation(store, seed, signals, result, {
      reasoning: "Rain risks pushing the last two appointments late — nudged reminders ahead of it, flagging it once.",
      timingDecision: "wait_for_gap",
      spokenText: "Rain's rolling in at 3. I nudged your last two reminders early — you might run behind.",
      type: "interstitial",
      intent: "inform",
      requiresDecision: false,
      clientId: seed.clientIds.renee,
      appointmentId: seed.appointmentIds.renee,
    });
  },
};
