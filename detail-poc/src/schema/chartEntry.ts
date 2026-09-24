import type {
  AppointmentId,
  ChartEntryId,
  ChartId,
  OperatorId,
  ServiceId,
} from "../ids.js";

export type ChartEntryType = "treatment_note" | "consult_note" | "photo" | "phone_note" | "amendment";
export type ChartEntryStatus = "draft" | "signed" | "amended";
export type ChartEntryAuthoredBy = "operator" | "detail_from_dictation";

/**
 * CHART ENTRY — "20 units, glabella and crow's feet."
 * Source: object-map.json → objects[].name === "CHART ENTRY"
 *
 * Note: the map's own core_content field is literally named "Products &
 * Lots" — kept as one free-text field (`productsAndLots`) rather than
 * split, since the map doesn't decompose it further.
 */
export interface ChartEntryRow {
  /** INFRASTRUCTURE: primary key. */
  id: ChartEntryId;

  // core_content
  whatWasDone: string;
  observations: string;
  photoUrls: string[];
  productsAndLots: string;

  // metadata
  type: ChartEntryType;
  unitsOrDosage?: string;
  sitesTreated?: string;
  authoredAt: Date;
  signedAt?: Date;
  status: ChartEntryStatus;
  authoredBy: ChartEntryAuthoredBy;

  // relationships
  chartId: ChartId;
  operatorId: OperatorId;
  appointmentId?: AppointmentId;
  serviceId?: ServiceId;
  /** Self-referential — "has 0-1 CHART ENTRY (it amends)". */
  amendsEntryId?: ChartEntryId;
}
