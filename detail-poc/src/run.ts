import { seed } from "./seed/seed.js";
import { generateSignals } from "./seed/signals.js";
import { runLadder } from "./ladder/ladder.js";
import { printHandBackReport } from "./report.js";

const seeded = seed();
const { clusters } = generateSignals(seeded.store, seeded);
const ladderResult = runLadder(seeded.store, seeded, clusters);

// Compose the evening debrief now that the day has actually happened —
// DAY "has 0-many BRIEFING", tightened at runtime to 0-2 (brief + debrief).
seeded.store.createBriefing({
  headline: '"That\'s the day."',
  spokenScript: `Seven appointments, ${ladderResult.cuesProduced} things worth mentioning. Everything else, handled.`,
  type: "debrief",
  deliveredAt: new Date(2026, 8, 23, 18, 20),
  durationSeconds: 40,
  itemCount: ladderResult.cuesProduced,
  channel: "CarPlay",
  status: "played",
  dayId: seeded.dayTueId,
  detailId: seeded.detailId,
  operatorId: seeded.operatorId,
});

printHandBackReport(seeded.store, seeded.dayTueId, ladderResult);

if (ladderResult.totalSignals < 350 || ladderResult.totalSignals > 450) {
  console.error(`\n⚠ signal count ${ladderResult.totalSignals} is outside the ~400 target band.`);
  process.exitCode = 1;
}
if (ladderResult.cuesProduced < 3 || ladderResult.cuesProduced > 8) {
  console.error(`\n⚠ cue count ${ladderResult.cuesProduced} is outside the "about 5" target band.`);
  process.exitCode = 1;
}
