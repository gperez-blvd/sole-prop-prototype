import type { BusinessId, OperatorId } from "../ids.js";

export type OperatorRole = "owner" | "provider" | "front_desk";

/**
 * OPERATOR — Jazz. Solo provider, owner, front desk, entire staff.
 * Source: object-map.json → objects[].name === "OPERATOR"
 */
export interface OperatorRow {
  /** INFRASTRUCTURE: primary key, not a modeled attribute. */
  id: OperatorId;

  // core_content
  fullName: string;
  mobile: string;
  photoUrl?: string;

  // metadata
  roles: OperatorRole[];
  licensesAndCertifications: string[];
  tenureOnBoulevard: string;
  timezone: string;

  // relationships — owning side of "has 1 BUSINESS (works in)"
  businessId: BusinessId;

  // Not stored on this row (derived/reverse, resolved via RelationalStore):
  //   - has 1 DETAIL (personal operator)   -> Detail.operatorId (reverse, unique)
  //   - has 0-many APPOINTMENT (performing) -> Appointment.operatorId (reverse)
  //   - has 0-many SERVICE (qualified for)  -> join table operator_qualified_services
  //   - has 0-many CLIENT (serving)         -> DERIVED: distinct clients across this
  //                                            operator's appointments. Not a stored
  //                                            edge in the map; invented traversal.
  //   - has 0-many DAY (worked)             -> Day.operatorId (reverse)
  //   - has 0-many CHART ENTRY (authored)   -> ChartEntry.operatorId (reverse)
  //   - has 0-many ORDER (closed)           -> Order.closedByOperatorId (reverse, added in ADDENDUM_01.md)
}
