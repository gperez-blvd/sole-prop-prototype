import type { PersonaId } from "../ids.js";

/**
 * PERSONA — Concierge / Fixer / Shadow / Hype.
 * Source: object-map.json → objects[].name === "PERSONA"
 *
 * Open item from the handoff: "PERSONA has only two operator CTAs and is a
 * candidate to become metadata on DETAIL." Kept as its own object per
 * instructions not to merge objects — flagged again in the hand-back report.
 */
export interface PersonaRow {
  /** INFRASTRUCTURE: primary key. */
  id: PersonaId;

  // core_content
  personaName: string;
  description: string;
  sampleCuePhrasing: string;

  // metadata
  defaultTonePositions: [number, number, number, number];
  adoptionRate: number;

  // has 0-many DETAIL (based on it) is resolved by reverse lookup on
  // Detail.personaId.
}
