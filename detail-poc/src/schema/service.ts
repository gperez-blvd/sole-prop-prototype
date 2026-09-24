import type { BusinessId, ServiceId } from "../ids.js";

export type PriceModel = "flat" | "per_unit";
export type ServiceCategory = "injectable" | "laser" | "facial" | "peel";

/**
 * SERVICE — Lip filler, $650.
 * Source: object-map.json → objects[].name === "SERVICE"
 *
 * `price` is deliberately unwritable by DETAIL — see the "never changes
 * price" hard rule in hardRules.ts, which guards every mutator of this
 * field.
 */
export interface ServiceRow {
  /** INFRASTRUCTURE: primary key. */
  id: ServiceId;

  // core_content
  serviceName: string;
  description: string;
  photoUrl?: string;

  // metadata
  durationMinutes: number;
  price: number;
  priceModel: PriceModel;
  category: ServiceCategory;
  processingTime?: string;
  requiresConsentForm: boolean;
  discountable: boolean;

  // relationships
  businessId: BusinessId;

  // Reverse/join/derived, not stored here:
  //   - has 0-many APPOINTMENT (performed in)     -> join table appointment_services
  //   - has 0-many OPERATOR (qualified to perform)-> join table operator_qualified_services
  //   - has 0-many THRESHOLD (governed by)        -> join table service_governing_thresholds
  //   - has 0-many CAMPAIGN (promoting it)        -> Campaign.serviceId (reverse)
  //   - has 0-many SEGMENT (defined by it)        -> Segment.serviceId (reverse)
  //   - has 0-many PATTERN (about it)              -> Pattern.serviceId (reverse)
  //   - has 0-many CLIENT (who've had it)          -> DERIVED via appointment_services
  //   - has 0-many WAITLIST REQUEST (requesting it)-> WaitlistRequest.serviceId (reverse)
  //   - has 0-many CHART ENTRY (documenting it)    -> ChartEntry.serviceId (reverse)
  //   - has 0-many FORM (consents for it)          -> Form.serviceId (reverse)
  //
  // Added in ADDENDUM_01.md:
  //   - has 0-many PRODUCT USAGE RULE (its usage config)      -> ProductUsageRule.serviceId (required, reverse)
  //   - has 0-many PRODUCT USAGE (consumed performing it)     -> ProductUsage.serviceId (reverse)
  //   - has 0-many ORDER LINE ITEM (sold as)                   -> OrderLineItem.serviceId (reverse)
}
