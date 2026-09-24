import type { ChartId, ClientId } from "../ids.js";

export type ChartStatus = "open" | "current" | "locked";

/**
 * CHART — clinical record. 1:1 with CLIENT, modeled as its own table
 * because it's a different access and retention boundary than CLIENT.
 * Source: object-map.json → objects[].name === "CHART"
 *
 * `openFlags` and `entryCount` are rollups of nested CHART ENTRY / FORM
 * rows per the handoff's "Derived vs. stored" note — computed by
 * RelationalStore.chartStats(), not stored as independent columns.
 */
export interface ChartRow {
  /** INFRASTRUCTURE: primary key. */
  id: ChartId;

  // core_content
  medicalHistory: string;
  allergies: string;
  medications: string;
  contraindicationNotes: string;
  baselinePhotoUrls: string[];

  // metadata (non-derived only — see class doc)
  status: ChartStatus;
  lastReviewed?: Date;
  lastUpdated?: Date;
  /** Placeholder per the handoff: "per state rule" is not legal advice. */
  retentionUntil: string;
  /** △ UNRATIFIED — "△ Contains PHI" in the map. */
  containsPhi: boolean;

  // relationships — owning side of the 1:1 with CLIENT.
  clientId: ClientId;

  // Reverse, not stored here:
  //   - has 0-many CHART ENTRY (filed in it) -> ChartEntry.chartId (reverse)
  //   - has 0-many FORM (filed in it)         -> Form.chartId (reverse)
  //   - has 0-many APPOINTMENT (it covers)    -> Appointment.chartId (reverse)
}
