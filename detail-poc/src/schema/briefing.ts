import type { BriefingId, DayId, DetailId, OperatorId } from "../ids.js";

export type BriefingType = "brief" | "debrief";
export type BriefingStatus = "played" | "skipped" | "replayed";

/**
 * BRIEFING — "Morning, Jazz." / "That's the day."
 * Source: object-map.json → objects[].name === "BRIEFING"
 *
 * The map declares `DAY has 0-many BRIEFING`, but the handoff flags this as
 * narrower in reality: really 0-2 per day (one brief, one debrief,
 * distinguished by `type`). RelationalStore.createBriefing() enforces that
 * tighter bound at runtime and the violation is listed in the hand-back
 * report as a stubbed dependency rule, not silently assumed by the type.
 */
export interface BriefingRow {
  /** INFRASTRUCTURE: primary key. */
  id: BriefingId;

  // core_content
  headline: string;
  spokenScript: string;

  // metadata
  type: BriefingType;
  deliveredAt: Date;
  durationSeconds: number;
  itemCount: number;
  channel: string;
  status: BriefingStatus;

  // relationships
  dayId: DayId;
  detailId: DetailId;
  operatorId: OperatorId;

  // has 0-many CLIENT (flagged), OPENING (it covers), PROPOSAL (carried),
  // ACTION (summarized), REVIEW (new today), PATTERN (announced): none of
  // these have a reverse slot declared on the other object, so each is a
  // join table (see joinTables.ts: briefing_flagged_clients,
  // briefing_covered_openings, briefing_carried_proposals,
  // briefing_summarized_actions, briefing_new_reviews,
  // briefing_pattern_announcements).
}
