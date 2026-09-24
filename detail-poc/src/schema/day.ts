import type { BusinessId, DayId, OperatorId } from "../ids.js";

export type DayStatus = "upcoming" | "in_progress" | "complete";

/**
 * DAY — Tuesday the 23rd.
 * Source: object-map.json → objects[].name === "DAY"
 *
 * DAY is a Container Object: per the handoff's "Derived vs. stored" note,
 * its rollup metadata (Appointment Count, Clients Seen, Collected, vs.
 * Weekday Average, Rebooked in Room, Utilization, Cues Spoken, Signals
 * Processed, Actions Taken Without Her) is NOT stored here — it's computed
 * from nested rows by RelationalStore.dayStats(). Only genuinely
 * independent inputs (weekday, status, weather, the △ day note) live on
 * the row itself.
 *
 * ADDENDUM_01.md gives `Collected` a real source: "derived from closed
 * ORDERS." dayStats() now sums OrderRow.total across this day's closed
 * orders instead of guessing from appointment price/deposit.
 */
export interface DayRow {
  /** INFRASTRUCTURE: primary key. */
  id: DayId;

  // core_content
  date: Date;
  dayLabel: string;
  /** △ UNRATIFIED — "△ Day Note" in the map. */
  dayNote?: string;

  // metadata (non-derived only — see class doc)
  weekday: string;
  status: DayStatus;
  weather: string;

  // relationships
  operatorId: OperatorId;
  businessId: BusinessId;

  // Reverse, not stored here (all computed via RelationalStore):
  //   BRIEFING, APPOINTMENT, OPENING, CUE, ACTION, SIGNAL, REVIEW, CAMPAIGN
  //   each carry a dayId back to this row; PATTERN evidence is a join
  //   table (day_pattern_evidence). Added in ADDENDUM_01.md: ORDER and
  //   PAYOUT also carry an (optional) dayId back to this row.
}
