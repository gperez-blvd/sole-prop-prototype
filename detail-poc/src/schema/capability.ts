import type { BusinessId, CapabilityId } from "../ids.js";

export type CapabilityStatus = "unavailable" | "available" | "proposed" | "declined" | "active";
export type CapabilityType = "integration" | "data_import" | "policy" | "first_time_action";

/**
 * CAPABILITY — "Payouts." The map marks this entire object △ UNRATIFIED —
 * every core_content field, every metadata field, every relationship. It
 * is implemented in full below, per the handoff ("Implement them, but list
 * them... as unratified so they can be pulled"), and every field/relation
 * repeats that flag so it's impossible to use one without seeing it.
 * Source: object-map.json → objects[].name === "CAPABILITY"
 */
export interface CapabilityRow {
  /** INFRASTRUCTURE: primary key. */
  id: CapabilityId;

  // core_content — △ UNRATIFIED (whole object)
  /** △ UNRATIFIED */
  name: string;
  /** △ UNRATIFIED */
  whatItUnlocks: string;
  /** △ UNRATIFIED */
  completionSurface?: string;

  // metadata — △ UNRATIFIED (whole object)
  /** △ UNRATIFIED */
  status: CapabilityStatus;
  /** △ UNRATIFIED */
  type: CapabilityType;
  /** △ UNRATIFIED */
  effort: string;
  /** △ UNRATIFIED */
  estimatedValue: string;
  /** △ UNRATIFIED */
  declinedAt?: Date;

  // relationships — △ UNRATIFIED (whole object)
  /** △ UNRATIFIED — "△ it belongs to" BUSINESS. */
  businessId: BusinessId;

  // △ UNRATIFIED relations resolved elsewhere, not stored here:
  //   - has 0-many PROPOSAL (△ surfaced by)  -> Proposal.capabilityId (reverse)
  //   - has 0-many THRESHOLD (△ it enables)  -> Threshold.enabledByCapabilityId (reverse)
  //   - has 0-many CAPABILITY (△ it depends on) -> join table capability_dependencies
}
