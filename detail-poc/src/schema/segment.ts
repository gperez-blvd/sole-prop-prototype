import type { BusinessId, SegmentId, ServiceId } from "../ids.js";

export type SegmentFatigue = "fresh" | "warm" | "over_messaged";
export type SegmentCreatedBy = "operator" | "detail";

/**
 * SEGMENT — "Tox clients overdue."
 * Source: object-map.json → objects[].name === "SEGMENT"
 *
 * `size`, `reachableSms` and `reachableEmail` are NOT stored: they're
 * computed from segment_members + client consent by
 * RelationalStore.segmentReach() — see the class doc on campaign.ts for
 * why this matters for the consent hard rule.
 */
export interface SegmentRow {
  /** INFRASTRUCTURE: primary key. */
  id: SegmentId;

  // core_content
  segmentName: string;
  definition: string;

  // metadata (size/reachable deliberately excluded — see class doc)
  lastSent?: Date;
  sendFrequency?: string;
  /** △ UNRATIFIED-adjacent value set; not itself marked △ in the map, kept as-is. */
  fatigue?: SegmentFatigue;
  createdBy: SegmentCreatedBy;
  autoUpdating: boolean;

  // relationships
  businessId: BusinessId;
  serviceId?: ServiceId;

  // Reverse/join, not stored here:
  //   - has 0-many CLIENT (matching)   -> join table segment_members
  //     (INVENTED SIMPLIFICATION — see client.ts class doc: this is a
  //      static snapshot, not a live criteria evaluation.)
  //   - has 0-many CAMPAIGN (sent to it) -> Campaign.segmentId (reverse)
  //   - has 0-many PROPOSAL (about it)   -> Proposal.segmentId (reverse)
  //   - has 0-many PATTERN (about it)    -> Pattern.segmentId (reverse)
}
